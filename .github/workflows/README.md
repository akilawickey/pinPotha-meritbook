# GitHub Actions Workflows

## Deploy to Firebase Hosting

The `deploy-firebase.yml` workflow automatically deploys the web application to Firebase Hosting when code is pushed to:
- `develop-web` branch
- `main` branch
- `master` branch

Or when manually triggered from the GitHub Actions tab.

### Setup Required

Before the workflow can run, you need to:

1. **Add Firebase Service Account Secret to GitHub**:
   - Go to Firebase Console → Project Settings → Service Accounts
   - Generate a new private key
   - Copy the JSON content
   - Go to GitHub Repository → Settings → Secrets → Actions
   - Add a new secret named `FIREBASE_SERVICE_ACCOUNT` with the JSON content

2. **Verify Firebase Project ID**:
   - The project ID is set to `pinpotha-1295` in `.firebaserc`
   - Make sure this matches your Firebase project

### What the Workflow Does

1. Checks out the code
2. Sets up Node.js 18
3. Installs dependencies from `web/package-lock.json`
4. Builds the Vue.js application
5. Deploys to Firebase Hosting

### Monitoring

Check the workflow status in:
- GitHub → Actions tab
- Firebase Console → Hosting → Deployments

