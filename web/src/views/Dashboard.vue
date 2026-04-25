<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
    <!-- Header -->
    <header class="bg-white shadow-lg sticky top-0 z-10 border-b-2 border-brand-accent/20">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-20">
          <!-- Logo -->
          <div class="flex items-center flex-1">
            <Logo size="small" />
          </div>
          
          <!-- Right side buttons -->
          <div class="flex items-center gap-3">
            <button
              @click="showSearch = !showSearch"
              class="p-2 text-secondary-600 hover:text-brand-accent transition-colors rounded-lg hover:bg-brand-accent/10"
              :class="{ 'text-brand-accent bg-brand-accent/10': showSearch }"
            >
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
              </svg>
            </button>
            <button
              @click="toggleMenu"
              class="p-2 text-secondary-600 hover:text-brand-accent transition-colors rounded-lg hover:bg-brand-accent/10"
            >
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
              </svg>
            </button>
          </div>
        </div>
        
        <!-- Search Bar -->
        <div v-if="showSearch" class="pb-4 animate-slide-down">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Search your good thoughts..."
            class="input-field"
          />
        </div>
      </div>
    </header>

    <!-- Mobile Drawer -->
    <MobileDrawer :is-open="showMenu" @close="showMenu = false" />

    <!-- Pull to Refresh Indicator -->
    <div
      v-if="isPulling"
      class="fixed top-0 left-0 right-0 z-30 flex items-center justify-center bg-brand-accent/10 py-4 transition-transform pointer-events-none"
      :style="{ transform: `translateY(${Math.min(pullDistance, 80)}px)` }"
    >
      <div class="flex items-center gap-2 text-brand-accent">
        <svg
          class="w-6 h-6 animate-spin"
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
        </svg>
        <span class="font-medium">Pull to refresh</span>
      </div>
    </div>

    <!-- Main Content -->
    <main
      ref="mainContent"
      class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 pb-24 sm:pb-8"
    >
      <!-- Add Good Thing Button -->
      <div class="mb-6">
        <button
          @click.stop.prevent="goToAddPost"
          class="w-full sm:w-auto bg-brand-accent hover:bg-brand-accent-hover text-white font-semibold py-4 px-8 rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 transform hover:scale-[1.02] flex items-center justify-center gap-3 text-lg min-h-[44px] relative z-10"
          type="button"
        >
          <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
          </svg>
          <span>Add Good Thought</span>
        </button>
      </div>

      <!-- Posts Section -->
      <div v-if="loading" class="text-center py-20">
        <div class="animate-spin text-brand-accent text-5xl mb-4">⏳</div>
        <p class="text-secondary-600 text-lg">Loading your good thoughts...</p>
      </div>
      
      <div v-else-if="filteredPosts.length === 0" class="text-center py-20">
        <div class="max-w-md mx-auto">
          <div class="w-32 h-32 mx-auto mb-6 bg-brand-accent/10 rounded-full flex items-center justify-center">
            <svg class="w-16 h-16 text-brand-accent" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
          </div>
          <h3 class="text-2xl font-bold text-brand-dark mb-2">No good thoughts yet</h3>
          <p class="text-secondary-600 mb-6">Start recording the good things you've done!</p>
          <button
            @click="$router.push('/add')"
            class="bg-brand-accent hover:bg-brand-accent-hover text-white font-semibold py-3 px-6 rounded-lg shadow-md hover:shadow-lg transition-all"
          >
            Add Your First Good Thought
          </button>
        </div>
      </div>
      
      <!-- Posts Grid - Improved Design -->
      <div v-else>
        <div class="mb-6 flex items-center justify-between flex-wrap gap-4">
          <h2 class="text-2xl font-bold text-brand-dark">
            Your Good Thoughts
            <span class="text-lg font-normal text-secondary-600 ml-2">({{ filteredPosts.length }})</span>
          </h2>
          
          <!-- Posts per page selector (optional) -->
          <div class="flex items-center gap-2">
            <label class="text-sm text-secondary-600">Show:</label>
            <select
              v-model="postsPerPage"
              @change="currentPage = 1"
              class="px-3 py-1.5 border border-gray-300 rounded-lg text-sm focus:ring-2 focus:ring-brand-accent focus:border-brand-accent outline-none"
            >
              <option :value="6">6</option>
              <option :value="12">12</option>
              <option :value="24">24</option>
              <option :value="48">48</option>
            </select>
          </div>
        </div>
        
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          <div
            v-for="post in paginatedPosts"
            :key="post.postId"
            @click.stop.prevent="viewPost(post)"
            class="bg-white rounded-xl shadow-md hover:shadow-xl transition-all duration-300 cursor-pointer transform hover:-translate-y-1 overflow-hidden border border-gray-100 relative"
            role="button"
            tabindex="0"
            @keyup.enter.stop.prevent="viewPost(post)"
          >
            <!-- Image Section -->
            <div class="w-full h-64 overflow-hidden bg-gradient-to-br from-brand-accent/10 to-brand-accent/5 flex items-center justify-center">
              <img 
                v-if="post.photoUrl"
                :src="post.photoUrl" 
                :alt="post.note" 
                class="w-full h-full object-cover hover:scale-105 transition-transform duration-300 select-none"
                draggable="false"
              />
              <div v-else class="flex flex-col items-center justify-center p-8 text-center pointer-events-none">
                <svg class="w-20 h-20 text-brand-accent/40 mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                </svg>
                <p class="text-brand-accent/60 text-sm font-medium">Good Thought</p>
              </div>
            </div>
            
            <!-- Content Section -->
            <div class="p-5">
              <!-- Date Badge -->
              <div class="mb-3">
                <span class="inline-flex items-center gap-1 text-xs font-medium text-brand-accent bg-brand-accent/10 px-3 py-1 rounded-full">
                  <svg class="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                  </svg>
                  {{ getPostDate(post) }}
                </span>
              </div>
              
              <!-- Note Text -->
              <div class="min-h-[60px]">
                <p v-if="post.note" class="text-gray-800 text-base leading-relaxed line-clamp-3" style="-webkit-line-clamp: 3; line-clamp: 3;">
                  {{ post.note }}
                </p>
                <p v-else class="text-gray-400 italic text-sm">
                  No note added
                </p>
              </div>
              
              <!-- Footer with icon indicator -->
              <div class="mt-4 pt-4 border-t border-gray-100 flex items-center justify-between">
                <div class="flex items-center gap-2 text-xs text-secondary-600">
                  <svg v-if="post.photoUrl" class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                  </svg>
                  <span v-if="post.photoUrl">With Photo</span>
                  <span v-else>Text Only</span>
                </div>
                <svg class="w-5 h-5 text-brand-accent" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
                </svg>
              </div>
            </div>
          </div>
        </div>
        
        <!-- Pagination -->
        <div v-if="totalPages > 1" class="mt-8 flex flex-col sm:flex-row items-center justify-between gap-4">
          <!-- Posts Info -->
          <div class="text-sm text-secondary-600">
            Showing {{ ((currentPage - 1) * postsPerPage) + 1 }} - {{ Math.min(currentPage * postsPerPage, filteredPosts.length) }} of {{ filteredPosts.length }} posts
          </div>
          
          <!-- Pagination Controls -->
          <div class="flex items-center gap-2">
            <!-- Previous Button -->
            <button
              @click="goToPage(currentPage - 1)"
              :disabled="!hasPreviousPage"
              class="px-4 py-2 rounded-lg border border-gray-300 text-secondary-700 hover:bg-brand-accent hover:text-white hover:border-brand-accent transition-all disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-transparent disabled:hover:text-secondary-700"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            
            <!-- Page Numbers -->
            <div class="flex items-center gap-1">
              <template v-for="page in getPageNumbers()">
                <button
                  v-if="page !== '...'"
                  :key="page"
                  @click="goToPage(page)"
                  :class="[
                    'px-4 py-2 rounded-lg border transition-all min-w-[40px]',
                    page === currentPage
                      ? 'bg-brand-accent text-white border-brand-accent font-semibold'
                      : 'border-gray-300 text-secondary-700 hover:bg-brand-accent/10 hover:border-brand-accent/50'
                  ]"
                >
                  {{ page }}
                </button>
                <span v-else :key="`ellipsis-${page}`" class="px-2 text-secondary-500">...</span>
              </template>
            </div>
            
            <!-- Next Button -->
            <button
              @click="goToPage(currentPage + 1)"
              :disabled="!hasNextPage"
              class="px-4 py-2 rounded-lg border border-gray-300 text-secondary-700 hover:bg-brand-accent hover:text-white hover:border-brand-accent transition-all disabled:opacity-50 disabled:cursor-not-allowed disabled:hover:bg-transparent disabled:hover:text-secondary-700"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </button>
          </div>
        </div>
      </div>
    </main>

    <!-- Bottom Navigation (Mobile Only) -->
    <BottomNavigation :show-menu="showMenu" @toggle-menu="toggleMenu" />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { getAllPosts } from '../utils/postUtils'
import { formatDate } from '../utils/dateUtils'
import Logo from '../components/Logo.vue'
import BottomNavigation from '../components/BottomNavigation.vue'
import MobileDrawer from '../components/MobileDrawer.vue'
import { trackSearch } from '../utils/analytics'
import { usePullToRefresh } from '../composables/useTouchGestures'
import { postsCache } from '../utils/storage'

const router = useRouter()
const authStore = useAuthStore()

const posts = ref([])
const loading = ref(true)
const showMenu = ref(false)
const showSearch = ref(false)
const searchQuery = ref('')
const currentPage = ref(1)
const postsPerPage = ref(12) // Show 12 posts per page
const mainContent = ref(null)

let unsubscribePosts = null

// Pull to refresh
const handleRefresh = async () => {
  loading.value = true
  // Clear cache and reload
  if (authStore.user) {
    await postsCache.clear(authStore.user.email)
    loadPosts()
  }
}

const { isPulling, pullDistance } = usePullToRefresh(handleRefresh)

const filteredPosts = computed(() => {
  if (!searchQuery.value) {
    return posts.value
  }
  const query = searchQuery.value.toLowerCase()
  return posts.value.filter(post => 
    post.note && post.note.toLowerCase().includes(query)
  )
})

const paginatedPosts = computed(() => {
  const start = (currentPage.value - 1) * postsPerPage.value
  const end = start + postsPerPage.value
  return filteredPosts.value.slice(start, end)
})

const totalPages = computed(() => {
  return Math.ceil(filteredPosts.value.length / postsPerPage.value)
})

const hasNextPage = computed(() => {
  return currentPage.value < totalPages.value
})

const hasPreviousPage = computed(() => {
  return currentPage.value > 1
})

const getPostDate = (post) => {
  if (!post.timeStamp) {
    return 'Unknown date'
  }
  
  try {
    let timestamp = post.timeStamp.server_time
    
    // Handle Firebase ServerValue.TIMESTAMP object format
    if (timestamp && typeof timestamp === 'object' && timestamp['.sv']) {
      // This is a Firebase server timestamp placeholder, use current time as fallback
      timestamp = Date.now()
    }
    
    // Handle string timestamps
    if (typeof timestamp === 'string') {
      timestamp = parseInt(timestamp)
    }
    
    // Check if timestamp is valid number
    if (!timestamp || isNaN(timestamp) || timestamp <= 0) {
      return 'Unknown date'
    }
    
    const date = new Date(timestamp)
    
    // Check if date is valid
    if (isNaN(date.getTime())) {
      return 'Unknown date'
    }
    
    return formatDate(date, 'dd MMM yyyy')
  } catch (error) {
    console.error('Error formatting date:', error, post)
    return 'Unknown date'
  }
}

const toggleMenu = () => {
  showMenu.value = !showMenu.value
}

const goToAddPost = (event) => {
  if (event) {
    event.preventDefault()
    event.stopPropagation()
  }
  console.log('Navigating to add post')
  router.push('/add').catch((error) => {
    console.error('Navigation error:', error)
  })
}

const viewPost = (post, event) => {
  if (event) {
    event.preventDefault()
    event.stopPropagation()
  }
  
  if (!post || !post.postId) {
    console.error('Invalid post:', post)
    return
  }
  
  console.log('Viewing post:', post.postId)
  router.push(`/post/${post.postId}`).catch((error) => {
    console.error('Navigation error:', error)
  })
}

const handleSignOut = async () => {
  await authStore.signOut()
  showMenu.value = false
}

const goToPage = (page) => {
  if (page >= 1 && page <= totalPages.value) {
    currentPage.value = page
    // Scroll to top of posts section
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }
}

const getPageNumbers = () => {
  const pages = []
  const total = totalPages.value
  const current = currentPage.value
  
  if (total <= 7) {
    // Show all pages if 7 or fewer
    for (let i = 1; i <= total; i++) {
      pages.push(i)
    }
  } else {
    // Show first page, current page, and pages around it
    if (current <= 3) {
      // Near the start
      for (let i = 1; i <= 5; i++) {
        pages.push(i)
      }
      pages.push('...')
      pages.push(total)
    } else if (current >= total - 2) {
      // Near the end
      pages.push(1)
      pages.push('...')
      for (let i = total - 4; i <= total; i++) {
        pages.push(i)
      }
    } else {
      // In the middle
      pages.push(1)
      pages.push('...')
      for (let i = current - 1; i <= current + 1; i++) {
        pages.push(i)
      }
      pages.push('...')
      pages.push(total)
    }
  }
  
  return pages
}

// Reset to page 1 when search query changes and track search
watch(searchQuery, (newQuery) => {
  currentPage.value = 1
  if (newQuery && newQuery.trim().length > 0) {
    trackSearch(newQuery.trim())
  }
})

// Reset to page 1 when posts per page changes
watch(postsPerPage, () => {
  currentPage.value = 1
})

const loadPosts = async () => {
  if (!authStore.user) return

  // Try to load from cache first
  const cachedPosts = await postsCache.get(authStore.user.email)
  if (cachedPosts) {
    posts.value = cachedPosts
    loading.value = false
  }

  // Load from Firebase
  unsubscribePosts = getAllPosts(authStore.user.email, async (data) => {
    const sortedPosts = data.sort((a, b) => {
      const timeA = a.timeStamp?.server_time || 0
      const timeB = b.timeStamp?.server_time || 0
      return timeB - timeA
    })
    posts.value = sortedPosts
    loading.value = false
    
    // Cache the posts
    await postsCache.set(authStore.user.email, sortedPosts)
  })
}

onMounted(() => {
  loadPosts()
})

onUnmounted(() => {
  if (unsubscribePosts) unsubscribePosts()
})
</script>

<style scoped>
@keyframes slide-down {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-slide-down {
  animation: slide-down 0.3s ease-out;
}

.line-clamp-3 {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
