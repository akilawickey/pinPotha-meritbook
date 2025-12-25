<template>
  <Teleport to="body">
    <!-- Backdrop -->
    <Transition name="fade">
      <div
        v-if="isOpen"
        class="fixed inset-0 z-40 bg-black/50 transition-opacity"
        @click="close"
      ></div>
    </Transition>

    <!-- Drawer -->
    <Transition name="slide-right">
      <aside
        v-if="isOpen"
        class="fixed top-0 left-0 bottom-0 z-50 w-80 max-w-[85vw] bg-white shadow-2xl overflow-y-auto safe-area-inset-left safe-area-inset-top safe-area-inset-bottom"
        @click.stop
      >
        <!-- Header -->
        <div class="sticky top-0 z-10 bg-white border-b-2 border-brand-accent/20 px-4 py-4 flex items-center justify-between">
          <div class="flex items-center gap-3">
            <div v-if="user" class="w-10 h-10 rounded-full bg-brand-accent/10 flex items-center justify-center">
              <img
                v-if="user.photoURL"
                :src="user.photoURL"
                :alt="user.displayName || 'User'"
                class="w-10 h-10 rounded-full"
              />
              <svg v-else class="w-6 h-6 text-brand-accent" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z" />
              </svg>
            </div>
            <div>
              <p class="font-semibold text-brand-dark">{{ user?.displayName || 'User' }}</p>
              <p class="text-xs text-secondary-600">{{ user?.email }}</p>
            </div>
          </div>
          <button
            @click="close"
            class="p-2 text-secondary-600 hover:text-brand-accent transition-colors"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>
        </div>

        <!-- Menu Items -->
        <nav class="py-4">
          <button
            @click="navigateTo('/dashboard')"
            class="w-full px-4 py-3 flex items-center gap-3 text-left hover:bg-brand-accent/5 transition-colors"
            :class="{ 'bg-brand-accent/10 text-brand-accent': $route.path === '/dashboard' }"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
            </svg>
            <span class="font-medium">Dashboard</span>
          </button>

          <button
            @click="navigateTo('/add')"
            class="w-full px-4 py-3 flex items-center gap-3 text-left hover:bg-brand-accent/5 transition-colors"
            :class="{ 'bg-brand-accent/10 text-brand-accent': $route.path === '/add' }"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
            </svg>
            <span class="font-medium">Add Good Thought</span>
          </button>

          <div class="border-t border-gray-200 my-2"></div>

          <button
            @click="handleSignOut"
            class="w-full px-4 py-3 flex items-center gap-3 text-left text-red-600 hover:bg-red-50 transition-colors"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1" />
            </svg>
            <span class="font-medium">Sign Out</span>
          </button>
        </nav>
      </aside>
    </Transition>
  </Teleport>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const props = defineProps({
  isOpen: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['close'])

const router = useRouter()
const authStore = useAuthStore()

const user = computed(() => authStore.user)

const close = () => {
  emit('close')
}

const navigateTo = (path) => {
  router.push(path)
  close()
}

const handleSignOut = async () => {
  await authStore.signOut()
  close()
}
</script>


<style scoped>
/* Safe area for devices with notches */
.safe-area-inset-left {
  padding-left: env(safe-area-inset-left);
}

.safe-area-inset-top {
  padding-top: env(safe-area-inset-top);
}

.safe-area-inset-bottom {
  padding-bottom: env(safe-area-inset-bottom);
}

/* Transitions */
.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.3s ease;
}

.fade-enter-from,
.fade-leave-to {
  opacity: 0;
}

.slide-right-enter-active,
.slide-right-leave-active {
  transition: transform 0.3s ease;
}

.slide-right-enter-from {
  transform: translateX(-100%);
}

.slide-right-leave-to {
  transform: translateX(-100%);
}
</style>

