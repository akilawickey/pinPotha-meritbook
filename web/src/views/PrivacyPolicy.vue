<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
    <header class="bg-white shadow-lg border-b-2 border-brand-accent/20">
      <div class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-5">
        <button
          @click="goBack"
          class="text-secondary-600 hover:text-brand-accent transition-colors mb-3"
        >
          ← Back
        </button>
        <h1 class="text-2xl font-bold text-brand-dark">Privacy Policy</h1>
        <p class="text-secondary-600 text-sm mt-1">
          This policy explains how PinPotha handles personal information across Android and Web.
        </p>
      </div>
    </header>

    <main class="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <section class="bg-white rounded-xl shadow-sm border border-gray-200 p-6 space-y-6 text-sm text-secondary-700 leading-relaxed">
        <p>
          PinPotha ("we", "our", or "us") is a journaling app that helps users record positive actions and thoughts.
          This Privacy Policy describes what information we collect, how we use it, and the choices available to users.
        </p>

        <div>
          <h2 class="text-base font-semibold text-brand-dark mb-2">Information We Collect</h2>
          <ul class="list-disc pl-5 space-y-1">
            <li>Google account information used for sign in (email address, display name, and profile photo).</li>
            <li>User content you create in the app, including notes/posts, timestamps, and uploaded photos.</li>
            <li>Basic technical and analytics events (for example, app usage and screen interactions) to improve reliability.</li>
          </ul>
        </div>

        <div>
          <h2 class="text-base font-semibold text-brand-dark mb-2">How We Use Information</h2>
          <ul class="list-disc pl-5 space-y-1">
            <li>To authenticate users and keep accounts secure.</li>
            <li>To store, sync, and display user-created posts and images.</li>
            <li>To operate, maintain, and improve app performance and user experience.</li>
            <li>To respond to support or legal requests where applicable.</li>
          </ul>
        </div>

        <div>
          <h2 class="text-base font-semibold text-brand-dark mb-2">Data Storage and Third-Party Services</h2>
          <p>
            PinPotha uses Firebase services (Authentication, Realtime Database, Cloud Storage, and Analytics) provided by
            Google to operate core app functionality. Your data is processed and stored through these services.
          </p>
        </div>

        <div>
          <h2 class="text-base font-semibold text-brand-dark mb-2">Data Sharing</h2>
          <p>
            We do not sell personal information. We only share data with service providers required to run the app
            (such as Firebase), and only as needed for service delivery, security, analytics, or legal compliance.
          </p>
        </div>

        <div>
          <h2 class="text-base font-semibold text-brand-dark mb-2">Data Retention</h2>
          <p>
            We retain user data while the account is active or as required to provide the service.
            If you delete your account, related app data is removed through our account deletion flow,
            except where limited retention is required by law or for security/audit reasons.
          </p>
        </div>

        <div>
          <h2 class="text-base font-semibold text-brand-dark mb-2">Account Deletion and User Rights</h2>
          <p>
            Users can request deletion from the <span class="font-medium">Delete Account</span> page available in the app.
            After email verification, account data and associated content are deleted. Users may also request access or
            correction of their data through support contact channels.
          </p>
          <p class="mt-2">
            Open the deletion form here:
            <router-link to="/account" class="text-brand-accent font-medium hover:underline">
              Delete Account
            </router-link>
          </p>
        </div>

        <div>
          <h2 class="text-base font-semibold text-brand-dark mb-2">Children's Privacy</h2>
          <p>
            PinPotha is not intended for children under 13 (or the minimum digital consent age in your country).
            We do not knowingly collect personal data from children without required parental/legal consent.
          </p>
        </div>

        <div>
          <h2 class="text-base font-semibold text-brand-dark mb-2">Security</h2>
          <p>
            We use reasonable administrative and technical safeguards to protect personal information.
            However, no internet-based service can be guaranteed to be 100% secure.
          </p>
        </div>

        <div>
          <h2 class="text-base font-semibold text-brand-dark mb-2">Changes to This Policy</h2>
          <p>
            We may update this Privacy Policy from time to time. Updates will be posted on this page with a revised effective date.
          </p>
        </div>

        <div>
          <h2 class="text-base font-semibold text-brand-dark mb-2">Contact Us</h2>
          <p>
            For privacy-related questions, use the contact details listed in the app store listing or project support channels.
          </p>
        </div>

        <div class="mt-8 pt-4 border-t border-gray-200">
          <p class="text-xs text-secondary-500">Effective date: April 24, 2026</p>
        </div>
      </section>
    </main>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = useRouter()
const authStore = useAuthStore()

const goBack = () => {
  if (authStore.user) {
    router.push('/dashboard')
    return
  }
  router.push('/')
}
</script>
