import { defineStore } from 'pinia'
import { ref } from 'vue'
import { 
  signInWithPopup, 
  signOut as firebaseSignOut,
  onAuthStateChanged 
} from 'firebase/auth'
import { auth, googleProvider } from '../firebase/config'
import router from '../router'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const loading = ref(true)

  const initAuth = () => {
    onAuthStateChanged(auth, (firebaseUser) => {
      user.value = firebaseUser
      loading.value = false
      
      if (firebaseUser && router.currentRoute.value.path === '/') {
        router.push('/dashboard')
      } else if (!firebaseUser && router.currentRoute.value.meta.requiresAuth) {
        router.push('/')
      }
    })
  }

  const signInWithGoogle = async () => {
    try {
      loading.value = true
      await signInWithPopup(auth, googleProvider)
      router.push('/dashboard')
    } catch (error) {
      console.error('Sign in error:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  const signOut = async () => {
    try {
      await firebaseSignOut(auth)
      router.push('/')
    } catch (error) {
      console.error('Sign out error:', error)
      throw error
    }
  }

  return {
    user,
    loading,
    initAuth,
    signInWithGoogle,
    signOut
  }
})

