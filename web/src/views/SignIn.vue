<template>
  <div class="min-h-screen flex items-center justify-center bg-gradient-to-br from-secondary-50 via-white to-brand-accent-light/20 px-4 py-8">
    <div class="max-w-md w-full">
      <div class="card text-center shadow-xl border-2 border-brand-accent/20">
        <!-- Logo Section -->
        <div class="mb-8 flex justify-center">
          <Logo />
        </div>
        
        <!-- Tagline -->
        <div class="mb-8">
          <p class="text-secondary-700 text-lg font-medium mb-2">
            Record and remember the good things you've done
          </p>
          <div class="w-24 h-1 bg-gradient-to-r from-brand-accent to-brand-accent-light mx-auto rounded-full"></div>
        </div>
        
        <!-- Description -->
        <div class="mb-8 px-4">
          <p class="text-secondary-600 text-sm leading-relaxed">
            The ancient people had a small book called <span class="font-semibold text-brand-accent">'PIN POTHA'</span> which they used to record and memorize good things they had done. 
            This app brings back that good habit to our modern era.
          </p>
        </div>

        <!-- Sign In Button -->
        <button
          @click="handleSignIn"
          :disabled="loading"
          class="w-full bg-brand-accent hover:bg-brand-accent-hover text-white font-semibold py-4 px-6 rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 transform hover:scale-[1.02] disabled:opacity-50 disabled:cursor-not-allowed disabled:transform-none flex items-center justify-center gap-3 text-lg"
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

        <!-- Error Message -->
        <p v-if="error" class="mt-4 text-red-600 text-sm bg-red-50 py-2 px-4 rounded-lg">{{ error }}</p>
      </div>
      
      <!-- Footer -->
      <div class="mt-6 text-center">
        <p class="text-secondary-600 text-xs">
          Powered by <span class="font-semibold text-brand-dark">leafylanka</span>
        </p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useAuthStore } from '../stores/auth'
import Logo from '../components/Logo.vue'

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

<style scoped>
.card {
  @apply bg-white rounded-2xl p-8;
  box-shadow: 0 10px 40px rgba(30, 58, 95, 0.1);
}
</style>
