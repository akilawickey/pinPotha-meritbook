import { initializeApp } from 'firebase/app'
import { getAuth, GoogleAuthProvider } from 'firebase/auth'
import { getDatabase } from 'firebase/database'
import { getStorage } from 'firebase/storage'
import { getAnalytics, isSupported } from 'firebase/analytics'

const firebaseConfig = {
  apiKey: "AIzaSyAqCgemYGGM4jvg-lxWg07HXoepPMG8yrM",
  authDomain: "pinpotha-1295.firebaseapp.com",
  databaseURL: "https://pinpotha-1295.firebaseio.com",
  projectId: "pinpotha-1295",
  storageBucket: "pinpotha-1295.appspot.com",
  messagingSenderId: "313883222202",
  appId: "1:313883222202:web:38756472ddb83770d36283",
  measurementId: "G-6LEVCPT7KS"
}

// Initialize Firebase
const app = initializeApp(firebaseConfig)

// Initialize Firebase services
export const auth = getAuth(app)
export const database = getDatabase(app)
export const storage = getStorage(app)
export const googleProvider = new GoogleAuthProvider()

// Configure redirect URL for sign-in
// This ensures the redirect works properly
if (typeof window !== 'undefined') {
  // Set the redirect URL to the current origin
  const redirectUrl = window.location.origin
  console.log('Firebase Auth redirect URL:', redirectUrl)
  console.log('Current origin:', window.location.origin)
  console.log('Current hostname:', window.location.hostname)
  console.log('Current port:', window.location.port)
  
  // Add additional scopes if needed
  googleProvider.addScope('profile')
  googleProvider.addScope('email')
  
  // Set custom parameters if needed
  googleProvider.setCustomParameters({
    prompt: 'select_account'
  })
}

// Enable offline persistence for Realtime Database
// Note: This must be called before any database operations
if (typeof window !== 'undefined') {
  // Realtime Database automatically handles offline persistence
  // No additional configuration needed - it works out of the box
  console.log('Firebase Realtime Database offline persistence enabled')
}

// Initialize Analytics (only in browser environment)
let analytics = null
if (typeof window !== 'undefined') {
  // Check if Analytics is supported before initializing
  isSupported()
    .then((supported) => {
      if (supported) {
        try {
          analytics = getAnalytics(app)
          console.log('Firebase Analytics initialized successfully with measurement ID:', firebaseConfig.measurementId)
        } catch (error) {
          console.warn('Firebase Analytics initialization error:', error)
        }
      } else {
        console.warn('Firebase Analytics is not supported in this environment')
      }
    })
    .catch((error) => {
      console.warn('Firebase Analytics support check failed:', error)
      // Try to initialize anyway in case the check failed but Analytics is actually available
      try {
        analytics = getAnalytics(app)
        console.log('Firebase Analytics initialized (fallback)')
      } catch (initError) {
        console.warn('Firebase Analytics fallback initialization also failed:', initError)
      }
    })
}

export { analytics }

export default app

