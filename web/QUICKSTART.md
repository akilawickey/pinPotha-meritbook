# Quick Start Guide

## Installation & Setup

1. **Navigate to the web directory:**
   ```bash
   cd web
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Start the development server:**
   ```bash
   npm run dev
   ```

4. **Open your browser:**
   The app will automatically open at `http://localhost:3000`

## First Time Setup

1. **Sign In:**
   - Click "Sign in with Google"
   - Select your Google account
   - Grant permissions if prompted

2. **Create Your First Post:**
   - Click the "+" button (floating action button)
   - Add a note describing your good thought
   - Optionally add a photo
   - Click "Post Good Thought"

3. **Explore Features:**
   - View posts in the dashboard grid
   - Click on calendar dates to see posts for that day
   - Use the search bar to find specific posts
   - Click on any post to view details
   - Share or delete posts from the details page

## Building for Production

```bash
npm run build
```

The production build will be in the `dist` directory.

## Troubleshooting

### Firebase Authentication Issues
- Make sure Firebase is properly configured in `src/firebase/config.js`
- Check that Google Sign-In is enabled in Firebase Console

### Image Upload Issues
- Ensure Firebase Storage is enabled
- Check storage rules in Firebase Console

### Database Connection Issues
- Verify Firebase Realtime Database is enabled
- Check database rules allow authenticated users to read/write

## Development Tips

- The app uses Vue 3 Composition API
- State management is handled by Pinia
- Firebase services are initialized in `src/firebase/config.js`
- All Firebase operations are in `src/utils/postUtils.js`
- Routes are defined in `src/router/index.js`

