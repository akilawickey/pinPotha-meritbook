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
          <h1 class="text-xl font-semibold text-brand-dark">{{ formattedDate }}</h1>
          <div class="w-10"></div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
      <div v-if="loading" class="text-center py-12">
        <div class="animate-spin text-brand-accent text-4xl">⏳</div>
        <p class="mt-4 text-secondary-600">Loading posts...</p>
      </div>

      <div v-else-if="posts.length === 0" class="text-center py-12">
        <p class="text-secondary-500 text-lg">No posts for this date</p>
        <button
          @click="goToAdd"
          class="mt-4 bg-brand-accent hover:bg-brand-accent-hover text-white font-semibold py-2 px-6 rounded-xl shadow-lg hover:shadow-xl transition-all duration-300"
        >
          Add Good Thought
        </button>
      </div>

      <div v-else class="space-y-4">
        <div
          v-for="post in posts"
          :key="post.postId"
          @click="viewPost(post)"
          class="card cursor-pointer hover:shadow-lg transition-shadow"
        >
          <div v-if="post.photoUrl" class="w-full h-64 overflow-hidden rounded-t-lg mb-4">
            <img :src="post.photoUrl" :alt="post.note" class="w-full h-full object-cover" />
          </div>
          <p v-if="post.note" class="text-gray-700">{{ post.note }}</p>
          <p v-else class="text-gray-400 italic">No note</p>
        </div>
      </div>
    </main>

    <!-- Floating Action Button -->
    <button
      @click="goToAdd"
      class="fixed bottom-6 right-6 bg-brand-accent hover:bg-brand-accent-hover text-white rounded-full w-14 h-14 shadow-xl flex items-center justify-center transition-all duration-300 hover:scale-110 hover:shadow-2xl"
    >
      <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
      </svg>
    </button>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { getPostsByDate } from '../utils/postUtils'
import { formatDate } from '../utils/dateUtils'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()

const posts = ref([])
const loading = ref(true)

const dateMillis = computed(() => parseInt(route.params.date))
const postDate = computed(() => new Date(dateMillis.value))
const formattedDate = computed(() => formatDate(postDate.value, 'dd-MM-yyyy'))

let unsubscribe = null

const viewPost = (post) => {
  router.push(`/post/${post.postId}`)
}

const goToAdd = () => {
  router.push({
    path: '/add',
    query: { date: dateMillis.value }
  })
}

onMounted(() => {
  if (authStore.user) {
    unsubscribe = getPostsByDate(authStore.user.email, postDate.value, (data) => {
      posts.value = data.sort((a, b) => {
        const timeA = a.timeStamp?.server_time || 0
        const timeB = b.timeStamp?.server_time || 0
        return timeB - timeA
      })
      loading.value = false
    })
  }
})

onUnmounted(() => {
  if (unsubscribe) unsubscribe()
})
</script>

