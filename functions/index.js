const crypto = require("node:crypto");
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { logger } = require("firebase-functions/v2");
const admin = require("firebase-admin");
const { Resend } = require("resend");

admin.initializeApp();

const CODE_TTL_MS = 10 * 60 * 1000;
const MAX_ATTEMPTS = 5;
const CODE_LENGTH = 6;

function hashCode(code) {
  return crypto.createHash("sha256").update(code).digest("hex");
}

function generateCode() {
  return String(Math.floor(Math.random() * 10 ** CODE_LENGTH)).padStart(
    CODE_LENGTH,
    "0",
  );
}

function normalizeEmail(email) {
  return String(email || "").trim().toLowerCase();
}

function getEmailPath(email) {
  return email.replace(/\./g, ",");
}

function getCodeRef(emailPath) {
  return admin.database().ref(`accountDeletionCodes/${emailPath}`);
}

async function deleteUserPhotoByUrl(photoUrl) {
  if (!photoUrl || typeof photoUrl !== "string") {
    return;
  }

  try {
    const url = new URL(photoUrl);
    const pathMatch = url.pathname.match(/\/o\/(.+)/);
    if (!pathMatch?.[1]) {
      return;
    }

    const objectPath = decodeURIComponent(pathMatch[1]);
    await admin.storage().bucket().file(objectPath).delete({ ignoreNotFound: true });
  } catch (error) {
    logger.warn("Failed to delete photo", { photoUrl, error: error.message });
  }
}

async function deleteUserPostsAndPhotos(emailPath) {
  const postsRef = admin.database().ref(`posts/${emailPath}`);
  const snapshot = await postsRef.get();

  if (snapshot.exists()) {
    const deletions = [];
    snapshot.forEach((dateSnap) => {
      dateSnap.forEach((postSnap) => {
        const post = postSnap.val();
        if (post?.photoUrl) {
          deletions.push(deleteUserPhotoByUrl(post.photoUrl));
        }
      });
    });
    await Promise.allSettled(deletions);
  }

  await postsRef.remove();
}

exports.sendAccountDeletionCode = onCall({ region: "us-central1" }, async (request) => {
  if (!process.env.RESEND_API_KEY || !process.env.RESEND_FROM_EMAIL) {
    throw new HttpsError(
      "failed-precondition",
      "Resend is not configured. Set RESEND_API_KEY and RESEND_FROM_EMAIL.",
    );
  }

  const email = normalizeEmail(request.data?.email);
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new HttpsError("invalid-argument", "Enter a valid email address.");
  }

  const code = generateCode();
  const expiresAt = Date.now() + CODE_TTL_MS;
  const emailPath = getEmailPath(email);
  const codeRef = getCodeRef(emailPath);

  let uid = null;
  try {
    const userRecord = await admin.auth().getUserByEmail(email);
    uid = userRecord.uid;
  } catch (error) {
    if (error?.code !== "auth/user-not-found") {
      throw error;
    }
  }

  await codeRef.set({
    codeHash: hashCode(code),
    expiresAt,
    attempts: 0,
    email,
    uid,
    createdAt: Date.now(),
  });

  const resend = new Resend(process.env.RESEND_API_KEY);
  const emailResult = await resend.emails.send({
    from: process.env.RESEND_FROM_EMAIL,
    to: email,
    subject: "PinPotha account deletion confirmation code",
    text: `Your PinPotha account deletion code is ${code}. It expires in 10 minutes.`,
    html: `<p>Your PinPotha account deletion code is <strong>${code}</strong>.</p><p>This code expires in 10 minutes.</p>`,
  });

  if (emailResult?.error) {
    logger.error("Resend email failed", { error: emailResult.error });
    throw new HttpsError("internal", "Failed to send confirmation email.");
  }

  return { success: true, expiresInSeconds: CODE_TTL_MS / 1000 };
});

exports.confirmAccountDeletion = onCall({ region: "us-central1" }, async (request) => {
  const email = normalizeEmail(request.data?.email);
  const code = String(request.data?.code || "").trim();
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new HttpsError("invalid-argument", "Enter a valid email address.");
  }
  if (!/^\d{6}$/.test(code)) {
    throw new HttpsError("invalid-argument", "Enter a valid 6-digit code.");
  }

  const emailPath = getEmailPath(email);
  const codeRef = getCodeRef(emailPath);
  const snapshot = await codeRef.get();

  if (!snapshot.exists()) {
    throw new HttpsError("not-found", "No active deletion code. Request a new code.");
  }

  const stored = snapshot.val();
  if (stored.email !== email) {
    throw new HttpsError("permission-denied", "Code does not belong to this account.");
  }

  if (Date.now() > Number(stored.expiresAt || 0)) {
    await codeRef.remove();
    throw new HttpsError("deadline-exceeded", "Code expired. Request a new one.");
  }

  const attempts = Number(stored.attempts || 0);
  if (attempts >= MAX_ATTEMPTS) {
    await codeRef.remove();
    throw new HttpsError("resource-exhausted", "Too many attempts. Request a new code.");
  }

  const valid = hashCode(code) === stored.codeHash;
  if (!valid) {
    await codeRef.update({ attempts: attempts + 1 });
    throw new HttpsError("permission-denied", "Invalid code.");
  }

  await deleteUserPostsAndPhotos(emailPath);
  await codeRef.remove();
  if (stored.uid) {
    await admin.auth().deleteUser(stored.uid);
  }

  return { success: true };
});
