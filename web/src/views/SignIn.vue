<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-primary-50 to-primary-100 px-4">
    <div class="max-w-md w-full">
      <div class="card text-center">
        <div class="mb-8">
          <h1 class="text-4xl font-bold text-primary-700 mb-2">PinPotha</h1>
          <p class="text-gray-600">Record and remember the good things you've done</p>
        </div>
        
        <div class="mb-6">
          <p class="text-gray-700 mb-4">
            The ancient people had a small book called 'PIN POTHA' which they used to record and memorize good things they had done. 
            This app brings back that good habit to our modern era.
          </p>
        </div>

        <button
          @click="handleSignIn"
          :disabled="loading"
          class="w-full btn-primary flex items-center justify-center gap-3 py-3 text-lg"
        >
          <svg v-if="!loading" class="w-6 h-6" viewBox="0 0 24 24">
            <path fill="currentColor" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
            <path fill="currentColor" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
            <path fill="currentColor" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
            <path fill="currentColor" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
          </svg>
          <span v-if="loading" class="animate-spin">⏳</span>
          <span>{{ loading ? 'Signing in...' : 'Sign in with Google' }}</span>
        </button>

        <p v-if="error" class="mt-4 text-red-600 text-sm">{{ error }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
const loading = ref(false)
const error = ref('')

const handleSignIn = async () => {
  try {
    loading.value = true
    error.value = ''
    await authStore.signInWithGoogle()
  } catch (err) {
    error.value = 'Failed to sign in. Please try again.'
    console.error('Sign in error:', err)
  } finally {
    loading.value = false
  }
}
</script>

