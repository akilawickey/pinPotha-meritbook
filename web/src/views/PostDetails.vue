<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-sm sticky top-0 z-10">
      <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <button @click="$router.back()" class="p-2 hover:bg-gray-100 rounded">
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
          </button>
          <h1 class="text-xl font-semibold">{{ formattedDate }}</h1>
          <div class="flex gap-2">
            <button
              @click="handleShare"
              class="p-2 hover:bg-gray-100 rounded"
            >
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8.684 13.342C8.886 12.938 9 12.482 9 12c0-.482-.114-.938-.316-1.342m0 2.684a3 3 0 110-2.684m0 2.684l6.632 3.316m-6.632-6l6.632-3.316m0 0a3 3 0 105.367-2.684 3 3 0 00-5.367 2.684zm0 9.316a3 3 0 105.368 2.684 3 3 0 00-5.368-2.684z" />
              </svg>
            </button>
            <button
              @click="showDeleteDialog = true"
              class="p-2 hover:bg-red-50 rounded text-red-600"
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
    <main class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
      <div v-if="loading" class="text-center py-12">
        <div class="animate-spin text-primary-600 text-4xl">⏳</div>
        <p class="mt-4 text-gray-600">Loading post...</p>
      </div>

      <div v-else-if="post" class="card">
        <div v-if="post.photoUrl" class="mb-6">
          <img :src="post.photoUrl" :alt="post.note" class="w-full rounded-lg" />
        </div>
        <div v-if="post.note" class="text-lg text-gray-700 whitespace-pre-wrap">
          {{ post.note }}
        </div>
        <p v-else class="text-gray-400 italic">No note</p>
      </div>

      <div v-else class="text-center py-12">
        <p class="text-gray-500 text-lg">Post not found</p>
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
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { getAllPosts, deletePost } from '../utils/postUtils'
import { formatDate } from '../utils/dateUtils'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const post = ref(null)
const loading = ref(true)
const showDeleteDialog = ref(false)
const deleting = ref(false)

const postId = computed(() => route.params.postId)
const formattedDate = computed(() => {
  if (post.value?.timeStamp?.server_time) {
    return formatDate(new Date(post.value.timeStamp.server_time), 'dd-MM-yyyy')
  }
  return ''
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
  if (!post.value) return

  try {
    deleting.value = true
    const postDate = new Date(post.value.timeStamp.server_time)
    await deletePost(
      authStore.user.email,
      post.value.postId,
      postDate,
      post.value.photoUrl
    )
    router.push('/dashboard')
  } catch (error) {
    console.error('Delete error:', error)
    alert('Failed to delete post. Please try again.')
  } finally {
    deleting.value = false
    showDeleteDialog.value = false
  }
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
})
</script>

