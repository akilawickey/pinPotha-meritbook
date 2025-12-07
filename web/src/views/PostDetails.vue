<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-md sticky top-0 z-10 border-b-2 border-brand-accent/20">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <button @click="$router.back()" class="p-2 hover:bg-brand-accent/10 rounded-lg transition-colors text-secondary-600 hover:text-brand-accent">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
          </button>
          <h1 class="text-lg font-semibold text-brand-dark">Post Details</h1>
          <div class="flex gap-2">
            <button
              @click="handleEdit"
              class="p-2 hover:bg-brand-accent/10 rounded-lg transition-colors text-secondary-600 hover:text-brand-accent"
              title="Edit"
            >
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
              </svg>
            </button>
            <button
              @click="handleShare"
              class="p-2 hover:bg-brand-accent/10 rounded-lg transition-colors text-secondary-600 hover:text-brand-accent"
              title="Share"
            >
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" />
              </svg>
            </button>
            <button
              @click="showDeleteDialog = true"
              class="p-2 hover:bg-red-50 rounded-lg text-red-600 transition-colors"
              title="Delete"
            >
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
              </svg>
            </button>
          </div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main
      ref="contentRef"
      class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-6"
    >
      <div v-if="loading" class="text-center py-12">
        <div class="animate-spin text-brand-accent text-4xl">⏳</div>
        <p class="mt-4 text-secondary-600">Loading post...</p>
      </div>

      <div v-else-if="post" class="space-y-6">
        <!-- Date Section - Prominent Display -->
        <div class="bg-gradient-to-r from-brand-accent/10 to-brand-accent/5 rounded-xl p-6 border-l-4 border-brand-accent">
          <div class="flex items-center justify-between flex-wrap gap-4">
            <div class="flex items-center gap-4">
              <div class="bg-brand-accent/20 p-3 rounded-lg">
                <svg class="w-8 h-8 text-brand-accent" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
              </div>
              <div>
                <p class="text-sm text-secondary-600 font-medium mb-1">Date</p>
                <p class="text-2xl font-bold text-brand-dark">{{ formattedDate }}</p>
                <p v-if="formattedTime" class="text-sm text-secondary-500 mt-1">{{ formattedTime }}</p>
              </div>
            </div>
            <div v-if="post.photoUrl" class="flex items-center gap-2 text-sm text-secondary-600 bg-white/60 px-3 py-2 rounded-lg">
              <svg class="w-5 h-5 text-brand-accent" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
              <span>With Photo</span>
            </div>
          </div>
        </div>

        <!-- Image Section -->
        <div class="bg-white rounded-xl shadow-lg overflow-hidden">
          <div v-if="post.photoUrl" class="w-full">
            <img 
              :src="post.photoUrl" 
              :alt="post.note || 'Post image'" 
              class="w-full h-auto object-cover"
            />
          </div>
          <div v-else class="w-full h-96 bg-gradient-to-br from-brand-accent/10 to-brand-accent/5 flex items-center justify-center">
            <div class="flex flex-col items-center justify-center p-8 text-center">
              <svg class="w-32 h-32 text-brand-accent/40 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
              <p class="text-brand-accent/60 text-lg font-medium">Good Thought</p>
            </div>
          </div>
        </div>

        <!-- Note Content Section -->
        <div class="bg-white rounded-xl shadow-lg p-8">
          <div class="flex items-center gap-3 mb-6 pb-4 border-b border-gray-200">
            <div class="bg-brand-accent/10 p-2 rounded-lg">
              <svg class="w-6 h-6 text-brand-accent" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
              </svg>
            </div>
            <h2 class="text-xl font-bold text-brand-dark">Your Good Thought</h2>
          </div>
          
          <div v-if="post.note" class="prose prose-lg max-w-none">
            <p class="text-gray-800 text-lg leading-relaxed whitespace-pre-wrap font-normal">
              {{ post.note }}
            </p>
          </div>
          <div v-else class="text-center py-12">
            <p class="text-gray-400 italic text-lg">No note added to this good thought</p>
          </div>
        </div>
      </div>

      <div v-else class="text-center py-12">
        <div class="bg-white rounded-xl shadow-lg p-12 max-w-md mx-auto">
          <svg class="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
          <p class="text-gray-500 text-lg font-semibold mb-2">Post not found</p>
          <p class="text-gray-400 text-sm mb-6">The post you're looking for doesn't exist or has been deleted.</p>
          <button
            @click="$router.push('/dashboard')"
            class="btn-primary"
          >
            Back to Dashboard
          </button>
        </div>
      </div>
    </main>

    <!-- Delete Confirmation Dialog -->
    <div
      v-if="showDeleteDialog"
      class="fixed inset-0 z-20 bg-black bg-opacity-50 flex items-center justify-center p-4"
      @click="showDeleteDialog = false"
    >
      <div class="bg-white rounded-lg p-6 max-w-md w-full" @click.stop>
        <h3 class="text-lg font-semibold mb-4">Delete Post</h3>
        <p class="text-gray-600 mb-6">Are you sure you want to delete this post? This action cannot be undone.</p>
        <div class="flex gap-4">
          <button
            @click="showDeleteDialog = false"
            class="flex-1 btn-secondary"
          >
            Cancel
          </button>
          <button
            @click="handleDelete"
            :disabled="deleting"
            class="flex-1 bg-red-600 hover:bg-red-700 text-white font-medium py-2 px-4 rounded-lg transition-colors disabled:opacity-50"
          >
            {{ deleting ? 'Deleting...' : 'Delete' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { getAllPosts, deletePost } from '../utils/postUtils'
import { formatDate } from '../utils/dateUtils'
import { trackPostDeleted, trackPostViewed } from '../utils/analytics'
import { setSEO, addStructuredData, generateArticleSchema } from '../utils/seo'
import { useSwipe } from '../composables/useTouchGestures'
import { useDisplay } from '../composables/useDisplay'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const post = ref(null)
const loading = ref(true)
const showDeleteDialog = ref(false)
const deleting = ref(false)
const contentRef = ref(null)
const { isMobile } = useDisplay()

const postId = computed(() => route.params.postId)

const getPostDate = () => {
  if (!post.value?.timeStamp) {
    return null
  }
  
  try {
    let timestamp = post.value.timeStamp.server_time
    
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
      return null
    }
    
    const date = new Date(timestamp)
    
    // Check if date is valid
    if (isNaN(date.getTime())) {
      return null
    }
    
    return date
  } catch (error) {
    console.error('Error parsing timestamp:', post.value.timeStamp, error)
    return null
  }
}

const formattedDate = computed(() => {
  const date = getPostDate()
  if (!date) {
    return 'Unknown date'
  }
  return formatDate(date, 'dd MMMM yyyy')
})

const formattedTime = computed(() => {
  const date = getPostDate()
  if (!date) {
    return null
  }
  const hours = String(date.getHours()).padStart(2, '0')
  const minutes = String(date.getMinutes()).padStart(2, '0')
  return `${hours}:${minutes}`
})

let unsubscribePosts = null

const findPost = () => {
  if (!authStore.user) {
    loading.value = false
    return
  }
  
  unsubscribePosts = getAllPosts(authStore.user.email, (posts) => {
    const foundPost = posts.find(p => p.postId === postId.value)
    if (foundPost) {
      post.value = foundPost
      trackPostViewed()
      
      // Update SEO for this post
      const postNote = foundPost.note || 'Good Thought'
      const postDescription = postNote.length > 160 ? postNote.substring(0, 157) + '...' : postNote
      
      setSEO({
        title: `${postNote.substring(0, 50)}${postNote.length > 50 ? '...' : ''} - PinPotha`,
        description: postDescription,
        image: foundPost.photoUrl || 'https://pinpotha.lk/og-image.png',
        url: `https://pinpotha.lk/post/${foundPost.postId}`,
        type: 'article'
      })
      
      // Add Article structured data
      const articleSchema = generateArticleSchema(foundPost)
      if (articleSchema) {
        addStructuredData(articleSchema)
      }
    }
    loading.value = false
    if (unsubscribePosts) {
      unsubscribePosts()
      unsubscribePosts = null
    }
  })
}

onUnmounted(() => {
  if (unsubscribePosts) {
    unsubscribePosts()
  }
})

const handleDelete = async () => {
  if (!post.value || !authStore.user) return

  try {
    deleting.value = true
    
    // Get the post date correctly
    let timestamp = post.value.timeStamp?.server_time
    
    // Handle Firebase ServerValue.TIMESTAMP object format
    if (timestamp && typeof timestamp === 'object' && timestamp['.sv']) {
      timestamp = Date.now()
    }
    
    // Handle string timestamps
    if (typeof timestamp === 'string') {
      timestamp = parseInt(timestamp)
    }
    
    // Validate timestamp
    if (!timestamp || isNaN(timestamp) || timestamp <= 0) {
      throw new Error('Invalid post timestamp')
    }
    
    const postDate = new Date(timestamp)
    
    // Validate date
    if (isNaN(postDate.getTime())) {
      throw new Error('Invalid post date')
    }
    
    console.log('Deleting post:', {
      userId: authStore.user.email,
      postId: post.value.postId,
      date: postDate,
      photoUrl: post.value.photoUrl
    })
    
    await deletePost(
      authStore.user.email,
      post.value.postId,
      postDate,
      post.value.photoUrl
    )
    
    trackPostDeleted()
    console.log('Post deleted successfully')
    router.push('/dashboard')
  } catch (error) {
    console.error('Delete error:', error)
    alert(`Failed to delete post: ${error.message || 'Please try again.'}`)
  } finally {
    deleting.value = false
    showDeleteDialog.value = false
  }
}

const handleEdit = () => {
  if (!post.value) return
  
  // Get the post date correctly
  let timestamp = post.value.timeStamp?.server_time
  
  // Handle Firebase ServerValue.TIMESTAMP object format
  if (timestamp && typeof timestamp === 'object' && timestamp['.sv']) {
    timestamp = Date.now()
  }
  
  // Handle string timestamps
  if (typeof timestamp === 'string') {
    timestamp = parseInt(timestamp)
  }
  
  // Validate timestamp
  if (!timestamp || isNaN(timestamp) || timestamp <= 0) {
    alert('Invalid post date. Cannot edit this post.')
    return
  }
  
  // Navigate to edit page with post data
  router.push({
    path: '/add',
    query: {
      edit: 'true',
      postId: post.value.postId,
      date: timestamp
    }
  })
}

const handleShare = async () => {
  if (!post.value) return

  const shareData = {
    title: 'PinPotha - Good Thought',
    text: post.value.note || 'Check out my good thought!',
    url: post.value.photoUrl || window.location.href
  }

  try {
    if (navigator.share) {
      await navigator.share(shareData)
    } else {
      // Fallback: copy to clipboard
      const textToCopy = post.value.note || post.value.photoUrl || ''
      await navigator.clipboard.writeText(textToCopy)
      alert('Copied to clipboard!')
    }
  } catch (error) {
    if (error.name !== 'AbortError') {
      console.error('Share error:', error)
    }
  }
}

onMounted(() => {
  findPost()
  
  // Setup swipe gestures for mobile navigation
  if (isMobile.value && contentRef.value) {
    useSwipe(contentRef, {
      onSwipeLeft: () => {
        // Swipe left to go back
        router.back()
      },
      threshold: 50
    })
  }
})
</script>

