import { defineStore } from 'pinia'
import { ref } from 'vue'
import { 
  signInWithPopup,
  signInWithRedirect,
  getRedirectResult,
  signOut as firebaseSignOut,
  onAuthStateChanged 
} from 'firebase/auth'
import { auth, googleProvider } from '../firebase/config'
import router from '../router'
import { trackSignIn, trackSignOut, setAnalyticsUserId } from '../utils/analytics'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const loading = ref(true)
  const redirectError = ref(null) // Store redirect errors to show to user

  const initAuth = async () => {
    // Standard Firebase pattern: Set up auth state listener first
    // This will fire immediately with current auth state
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      user.value = firebaseUser
      loading.value = false
      
      if (firebaseUser) {
        setAnalyticsUserId(firebaseUser.email || firebaseUser.uid)
        
        // Redirect to dashboard if on sign-in page
        const currentPath = router.currentRoute.value.path
        if (currentPath === '/' || currentPath === '/signin') {
          await new Promise(resolve => setTimeout(resolve, 100))
          router.replace('/dashboard').catch(() => {
            window.location.replace('/dashboard')
          })
        }
      } else {
        // Redirect to sign-in if trying to access protected route
        if (router.currentRoute.value.meta.requiresAuth) {
          router.push('/')
        }
      }
    })
    
    // Check for redirect result (standard Firebase pattern)
    // This handles redirect-based authentication when popup fails
    try {
      const result = await getRedirectResult(auth)
      
      if (result && result.user) {
        trackSignIn('google')
        // User state is already updated by onAuthStateChanged above
      }
    } catch (error) {
      console.error('Error processing redirect result:', error)
      
      // Store error to show user
      let errorMessage = 'Sign in failed. Please try again.'
      if (error.code === 'auth/unauthorized-domain') {
        errorMessage = 'This domain is not authorized. Please check Firebase Console settings.'
      } else if (error.code === 'auth/operation-not-allowed') {
        errorMessage = 'Google sign-in is not enabled. Please contact support.'
      } else if (error.code === 'auth/network-request-failed') {
        errorMessage = 'Network error. Please check your connection and try again.'
      } else if (error.message) {
        errorMessage = `Sign in error: ${error.message}`
      }
      
      redirectError.value = errorMessage
      setTimeout(() => {
        redirectError.value = null
      }, 5000)
    }
    
    return unsubscribe
  }

  const signInWithGoogle = async () => {
    try {
      loading.value = true
      
      // Standard Firebase pattern: Try popup first (better UX), fallback to redirect
      // Popup works in most browsers and provides better user experience
      // Redirect is used as fallback for WebViews or when popups are blocked
      try {
        const result = await signInWithPopup(auth, googleProvider)
        // Popup sign-in successful
        console.log('✅ Popup sign-in successful:', result.user.email)
        trackSignIn('google')
        
        // User state will be updated by onAuthStateChanged
        // Redirect to dashboard if on sign-in page
        const currentPath = router.currentRoute.value.path
        if (currentPath === '/' || currentPath === '/signin') {
          await new Promise(resolve => setTimeout(resolve, 100))
          router.replace('/dashboard').catch(() => {
            window.location.replace('/dashboard')
          })
        }
      } catch (popupError) {
        // If popup fails (blocked or not supported), fallback to redirect
        if (popupError?.code === 'auth/popup-blocked' || 
            popupError?.code === 'auth/popup-closed-by-user' ||
            popupError?.code === 'auth/cancelled-popup-request') {
          console.log('Popup blocked or cancelled, falling back to redirect...')
          
          // Use redirect as fallback
          await signInWithRedirect(auth, googleProvider)
          // Page will redirect, so we won't reach code below
        } else {
          // Other popup errors, throw to be handled below
          throw popupError
        }
      }
    } catch (err) {
      console.error('Sign in error:', err)
      loading.value = false
      
      let errorMessage = 'Failed to sign in. Please try again.'
      if (err?.code === 'auth/unauthorized-domain') {
        errorMessage = 'This domain is not authorized. Please check Firebase Console settings.'
      } else if (err?.code === 'auth/operation-not-allowed') {
        errorMessage = 'Google sign-in is not enabled. Please contact support.'
      } else if (err?.code === 'auth/network-request-failed') {
        errorMessage = 'Network error. Please check your connection and try again.'
      } else if (err?.code === 'auth/popup-closed-by-user') {
        errorMessage = 'Sign in was cancelled. Please try again.'
      } else if (err?.message) {
        errorMessage = err.message
      }
      
      const enhancedError = new Error(errorMessage)
      enhancedError.code = err?.code
      throw enhancedError
    }
  }

  const signOut = async () => {
    try {
      await firebaseSignOut(auth)
      trackSignOut()
      router.push('/')
    } catch (error) {
      console.error('Sign out error:', error)
      throw error
    }
  }

  return {
    user,
    loading,
    redirectError,
    initAuth,
    signInWithGoogle,
    signOut
  }
})

