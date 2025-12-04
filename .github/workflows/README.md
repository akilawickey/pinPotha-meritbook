# GitHub Actions Workflows

## Deploy to Firebase Hosting

The `deploy-firebase.yml` workflow automatically deploys the web application to Firebase Hosting when code is pushed to:
- `develop-web` branch
- `main` branch
- `master` branch

Or when manually triggered from the GitHub Actions tab.

## ⚠️ Setup Required

**IMPORTANT**: Before the workflow can run, you **must** set up the Firebase Service Account secret.

### Step-by-Step Setup

1. **Get Firebase Service Account Key**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project: `pinpotha-1295`
   - Click the gear icon ⚙️ → **Project Settings**
   - Go to **Service Accounts** tab
   - Click **Generate New Private Key**
   - Click **Generate Key** in the confirmation dialog
   - A JSON file will download - **keep this file secure!**

2. **Add Secret to GitHub**:
   - Go to your GitHub repository
   - Click **Settings** → **Secrets and variables** → **Actions**
   - Click **New repository secret**
   - **Name**: `FIREBASE_SERVICE_ACCOUNT`
   - **Value**: Open the downloaded JSON file and copy **ALL** its contents
   - Paste the entire JSON into the value field
   - Click **Add secret**

3. **Verify Setup**:
   - The secret should now appear in your secrets list
   - You can test by pushing to `develop-web` branch or manually triggering the workflow

### What the Workflow Does

1. ✅ Checks out the code
2. ✅ Sets up Node.js 18
3. ✅ Installs dependencies from `web/package-lock.json`
4. ✅ Builds the Vue.js application
5. ✅ Validates Firebase Service Account secret exists
6. ✅ Deploys to Firebase Hosting
7. ✅ Deploys Firebase Database Rules (if configured)

### Troubleshooting

#### Error: "Input required and not supplied: firebaseServiceAccount"
**Solution**: The `FIREBASE_SERVICE_ACCOUNT` secret is not set. Follow the setup steps above.

#### Error: "Permission denied"
**Solution**: 
- Verify the service account JSON is correct
- Check that the service account has proper permissions in Firebase
- Ensure the project ID matches (`pinpotha-1295`)

#### Error: "Project not found"
**Solution**: 
- Verify project ID in `.firebaserc` matches your Firebase project
- Check that the service account has access to the project

### Monitoring

Check the workflow status in:
- **GitHub**: Repository → **Actions** tab
- **Firebase Console**: Hosting → Deployments

### Security Notes

- ⚠️ **Never commit** the service account JSON file to the repository
- ⚠️ The service account key has full access to your Firebase project
- ⚠️ If the key is compromised, regenerate it immediately in Firebase Console
- ✅ Using GitHub Secrets is the secure way to store this sensitive data

