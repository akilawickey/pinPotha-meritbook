<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Header -->
    <header class="bg-white shadow-md sticky top-0 z-10 border-b-2 border-brand-accent/20">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center gap-2">
            <div class="w-8 h-8 bg-brand-accent rounded-lg flex items-center justify-center">
              <svg width="20" height="20" viewBox="0 0 100 100" fill="none" xmlns="http://www.w3.org/2000/svg">
                <rect x="15" y="10" width="35" height="60" rx="4" fill="#ffffff"/>
                <rect x="48" y="20" width="30" height="40" rx="2" fill="#ffffff"/>
              </svg>
            </div>
            <h1 class="text-2xl font-bold text-brand-dark">PinPotha</h1>
          </div>
          <div class="flex items-center gap-4">
            <button
              @click="showSearch = !showSearch"
              class="p-2 text-secondary-600 hover:text-brand-accent transition-colors rounded-lg hover:bg-brand-accent/10"
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
        <div v-if="showSearch" class="pb-4">
          <input
            v-model="searchQuery"
            type="text"
            placeholder="Search by note..."
            class="input-field"
          />
        </div>
      </div>
    </header>

    <!-- Side Menu -->
    <div
      v-if="showMenu"
      class="fixed inset-0 z-20 bg-black bg-opacity-50"
      @click="showMenu = false"
    >
      <div
        class="fixed right-0 top-0 h-full w-64 bg-white shadow-xl transform transition-transform"
        @click.stop
      >
        <div class="p-4 border-b">
          <div class="flex items-center gap-3 mb-4">
            <img
              :src="authStore.user?.photoURL || '/default-avatar.png'"
              :alt="authStore.user?.displayName"
              class="w-12 h-12 rounded-full"
            />
            <div>
              <p class="font-semibold">{{ authStore.user?.displayName }}</p>
              <p class="text-sm text-gray-600">{{ authStore.user?.email }}</p>
            </div>
          </div>
        </div>
        <nav class="p-4">
          <button
            @click="handleSignOut"
            class="w-full text-left px-4 py-2 text-red-600 hover:bg-red-50 rounded-lg transition-colors"
          >
            Sign Out
          </button>
        </nav>
      </div>
    </div>

    <!-- Main Content -->
    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
      <!-- Calendar Section -->
      <div class="card mb-6">
        <div class="flex items-center justify-between mb-4">
          <h2 class="text-xl font-semibold">{{ currentMonth }}</h2>
          <div class="flex gap-2">
            <button @click="previousMonth" class="p-2 hover:bg-gray-100 rounded">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
              </svg>
            </button>
            <button @click="nextMonth" class="p-2 hover:bg-gray-100 rounded">
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
              </svg>
            </button>
          </div>
        </div>
        
        <div class="grid grid-cols-7 gap-2 mb-2">
          <div v-for="day in ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']" :key="day" class="text-center text-sm font-medium text-gray-600">
            {{ day }}
          </div>
        </div>
        
        <div class="grid grid-cols-7 gap-2">
          <div
            v-for="day in calendarDays"
            :key="day.date"
            @click="selectDate(day.date)"
            :class="[
              'aspect-square flex items-center justify-center rounded-lg cursor-pointer transition-colors',
              day.isCurrentMonth ? 'hover:bg-secondary-100' : 'text-gray-300',
              day.hasPosts ? 'bg-brand-accent/20 font-semibold text-brand-dark' : '',
              isSelectedDate(day.date) ? 'bg-brand-accent text-white shadow-md' : ''
            ]"
          >
            {{ day.day }}
          </div>
        </div>
      </div>

      <!-- Posts Grid -->
      <div v-if="loading" class="text-center py-12">
        <div class="animate-spin text-brand-accent text-4xl">⏳</div>
        <p class="mt-4 text-secondary-600">Loading posts...</p>
      </div>
      
      <div v-else-if="filteredPosts.length === 0" class="text-center py-12">
        <p class="text-gray-500 text-lg">No posts yet</p>
        <p class="text-gray-400 mt-2">Start recording your good thoughts!</p>
      </div>
      
      <div v-else class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 gap-4">
        <div
          v-for="post in filteredPosts"
          :key="post.postId"
          @click="viewPost(post)"
          class="card cursor-pointer hover:shadow-lg transition-shadow aspect-square overflow-hidden"
        >
          <div v-if="post.photoUrl" class="w-full h-3/4 overflow-hidden rounded-t-lg">
            <img :src="post.photoUrl" :alt="post.note" class="w-full h-full object-cover" />
          </div>
          <div class="p-2 h-1/4 flex items-center">
            <p class="text-sm text-gray-700 line-clamp-2">{{ post.note || 'No note' }}</p>
          </div>
        </div>
      </div>
    </main>

    <!-- Floating Action Button -->
    <button
      @click="$router.push('/add')"
      class="fixed bottom-6 right-6 bg-brand-accent hover:bg-brand-accent-hover text-white rounded-full w-14 h-14 shadow-xl flex items-center justify-center transition-all duration-300 hover:scale-110 hover:shadow-2xl"
    >
      <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4" />
      </svg>
    </button>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { getAllPosts, getPostDates } from '../utils/postUtils'
import { formatDate } from '../utils/dateUtils'

const router = useRouter()
const authStore = useAuthStore()

const posts = ref([])
const postDates = ref([])
const loading = ref(true)
const showMenu = ref(false)
const showSearch = ref(false)
const searchQuery = ref('')
const currentDate = ref(new Date())
const selectedDate = ref(null)

let unsubscribePosts = null
let unsubscribeDates = null

const currentMonth = computed(() => {
  return formatDate(currentDate.value, 'MMM yyyy')
})

const calendarDays = computed(() => {
  const year = currentDate.value.getFullYear()
  const month = currentDate.value.getMonth()
  const firstDay = new Date(year, month, 1)
  const lastDay = new Date(year, month + 1, 0)
  const startDate = new Date(firstDay)
  startDate.setDate(startDate.getDate() - firstDay.getDay())
  
  const days = []
  for (let i = 0; i < 42; i++) {
    const date = new Date(startDate)
    date.setDate(startDate.getDate() + i)
    const dayDate = new Date(date.getFullYear(), date.getMonth(), date.getDate())
    
    days.push({
      date: dayDate,
      day: date.getDate(),
      isCurrentMonth: date.getMonth() === month,
      hasPosts: postDates.value.some(d => {
        const dDate = new Date(d)
        return dDate.getFullYear() === dayDate.getFullYear() &&
               dDate.getMonth() === dayDate.getMonth() &&
               dDate.getDate() === dayDate.getDate()
      })
    })
  }
  return days
})

const filteredPosts = computed(() => {
  if (!searchQuery.value) {
    return posts.value
  }
  const query = searchQuery.value.toLowerCase()
  return posts.value.filter(post => 
    post.note && post.note.toLowerCase().includes(query)
  )
})

const isSelectedDate = (date) => {
  if (!selectedDate.value) return false
  return date.getTime() === selectedDate.value.getTime()
}

const selectDate = (date) => {
  selectedDate.value = date
  router.push(`/posts/${date.getTime()}`)
}

const previousMonth = () => {
  currentDate.value = new Date(currentDate.value.getFullYear(), currentDate.value.getMonth() - 1, 1)
}

const nextMonth = () => {
  currentDate.value = new Date(currentDate.value.getFullYear(), currentDate.value.getMonth() + 1, 1)
}

const toggleMenu = () => {
  showMenu.value = !showMenu.value
}

const viewPost = (post) => {
  router.push(`/post/${post.postId}`)
}

const handleSignOut = async () => {
  await authStore.signOut()
  showMenu.value = false
}

onMounted(() => {
  if (authStore.user) {
    unsubscribePosts = getAllPosts(authStore.user.email, (data) => {
      posts.value = data.sort((a, b) => {
        const timeA = a.timeStamp?.server_time || 0
        const timeB = b.timeStamp?.server_time || 0
        return timeB - timeA
      })
      loading.value = false
    })
    
    unsubscribeDates = getPostDates(authStore.user.email, (dates) => {
      postDates.value = dates
    })
  }
})

onUnmounted(() => {
  if (unsubscribePosts) unsubscribePosts()
  if (unsubscribeDates) unsubscribeDates()
})
</script>

