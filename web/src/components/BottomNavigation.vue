<template>
  <nav
    v-if="showBottomNav"
    class="fixed bottom-0 left-0 right-0 z-50 bg-white border-t-2 border-brand-accent/20 shadow-lg safe-area-inset-bottom"
  >
    <div class="flex items-center justify-around h-16 px-2">
      <!-- Dashboard -->
      <button
        @click="navigateTo('/dashboard')"
        :class="[
          'flex flex-col items-center justify-center flex-1 h-full transition-colors',
          isActive('/dashboard') ? 'text-brand-accent' : 'text-secondary-500'
        ]"
      >
        <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
        </svg>
        <span class="text-xs font-medium">Home</span>
      </button>

      <!-- Add Post -->
      <button
        @click="navigateTo('/add')"
        :class="[
          'flex flex-col items-center justify-center flex-1 h-full transition-colors',
          isActive('/add') ? 'text-brand-accent' : 'text-secondary-500'
        ]"
      >
        <div class="relative">
          <div class="absolute inset-0 bg-brand-accent/20 rounded-full blur-md"></div>
          <div class="relative w-12 h-12 bg-brand-accent rounded-full flex items-center justify-center shadow-lg transform transition-transform hover:scale-110">
            <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
          </div>
        </div>
      </button>

      <!-- Profile/Menu -->
      <button
        @click="toggleMenu"
        :class="[
          'flex flex-col items-center justify-center flex-1 h-full transition-colors',
          showMenu ? 'text-brand-accent' : 'text-secondary-500'
        ]"
      >
        <svg class="w-6 h-6 mb-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
        </svg>
        <span class="text-xs font-medium">Menu</span>
      </button>
    </div>
  </nav>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useDisplay } from '@/composables/useDisplay'

const route = useRoute()
const router = useRouter()
const { isMobile } = useDisplay()

const props = defineProps({
  showMenu: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['toggle-menu'])

const showBottomNav = computed(() => {
  return isMobile.value && route.meta.requiresAuth
})

const isActive = (path) => {
  return route.path === path
}

const navigateTo = (path) => {
  router.push(path)
}

const toggleMenu = () => {
  emit('toggle-menu')
}
</script>

<style scoped>
/* Safe area for devices with notches */
.safe-area-inset-bottom {
  padding-bottom: env(safe-area-inset-bottom);
}
</style>

