import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'
import router from './router'
import { useAuthStore } from './stores/auth'
import './style.css'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)

// Initialize auth before mounting to ensure auth state is ready
// This is especially important for redirect-based authentication
const authStore = useAuthStore()

// Mount app first, then initialize auth
// This ensures the router is available when auth state changes
app.mount('#app')

// Initialize auth after mounting
authStore.initAuth().catch((error) => {
  console.error('Error initializing auth:', error)
  // Auth state will be handled by onAuthStateChanged
})
