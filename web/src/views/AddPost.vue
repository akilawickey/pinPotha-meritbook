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
          <h1 class="text-xl font-semibold text-brand-dark">{{ isEditMode ? 'Edit Good Thought' : 'Add Good Thought' }}</h1>
          <div class="w-10"></div>
        </div>
      </div>
    </header>

    <!-- Main Content -->
    <main class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
      <div class="card">
        <!-- Calendar -->
        <div class="mb-6">
          <label class="block text-sm font-medium text-gray-700 mb-2">Select Date</label>
          <input
            v-model="selectedDate"
            type="date"
            class="input-field"
          />
        </div>

        <!-- Note Input -->
        <div class="mb-6">
          <label class="block text-sm font-medium text-gray-700 mb-2">Your Good Thought</label>
          <textarea
            v-model="note"
            rows="4"
            placeholder="Type your good thing here..."
            class="input-field resize-none"
          ></textarea>
        </div>

        <!-- Image Preview -->
        <div v-if="imagePreview" class="mb-6">
          <label class="block text-sm font-medium text-gray-700 mb-2">Image Preview</label>
          <div class="relative">
            <img :src="imagePreview" alt="Preview" class="w-full max-h-64 object-cover rounded-lg" />
            <button
              @click="removeImage"
              class="absolute top-2 right-2 bg-red-600 text-white rounded-full p-2 hover:bg-red-700"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>
        </div>

        <!-- Image Upload -->
        <div class="mb-6">
          <label class="block text-sm font-medium text-gray-700 mb-2">Add Photo (Optional)</label>
          <div class="flex gap-4">
            <label class="flex-1">
              <input
                type="file"
                accept="image/*"
                @change="handleImageSelect"
                class="hidden"
                ref="fileInput"
              />
              <div class="border-2 border-dashed border-gray-300 rounded-lg p-6 text-center cursor-pointer hover:border-brand-accent transition-colors">
                <svg class="w-12 h-12 mx-auto text-gray-400 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
                </svg>
                <p class="text-sm text-gray-600">Choose from Gallery</p>
              </div>
            </label>
            <button
              @click="openCamera"
              class="flex-1 border-2 border-dashed border-gray-300 rounded-lg p-6 text-center cursor-pointer hover:border-brand-accent transition-colors"
            >
              <svg class="w-12 h-12 mx-auto text-gray-400 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 9a2 2 0 012-2h.93a2 2 0 001.664-.89l.812-1.22A2 2 0 0110.07 4h3.86a2 2 0 011.664.89l.812 1.22A2 2 0 0018.07 7H19a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V9z" />
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 13a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
              <p class="text-sm text-gray-600">Take Photo</p>
            </button>
          </div>
        </div>

        <!-- Submit Button -->
        <button
          @click="handleSubmit"
          :disabled="loading || (!note.trim() && !selectedFile)"
          class="w-full bg-brand-accent hover:bg-brand-accent-hover text-white font-semibold py-3 px-6 rounded-xl shadow-lg hover:shadow-xl transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed text-lg"
        >
          <span v-if="loading">{{ isEditMode ? 'Updating...' : 'Posting...' }}</span>
          <span v-else>{{ isEditMode ? 'Update Good Thought' : 'Post Good Thought' }}</span>
        </button>

        <p v-if="error" class="mt-4 text-red-600 text-sm text-center">{{ error }}</p>
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { createPost, uploadImage, updatePost, getAllPosts } from '../utils/postUtils'
import { trackPostCreated, trackPostUpdated, trackImageUploaded } from '../utils/analytics'

const router = useRouter()
const route = useRoute()
const authStore = useAuthStore()

const note = ref('')
const selectedFile = ref(null)
const imagePreview = ref(null)
const selectedDate = ref(new Date().toISOString().split('T')[0])
const loading = ref(false)
const error = ref('')
const fileInput = ref(null)
const isEditMode = ref(false)
const editingPostId = ref(null)
const existingPhotoUrl = ref(null)
const originalPostDate = ref(null)

onMounted(async () => {
  // Check if we're in edit mode
  if (route.query.edit === 'true' && route.query.postId && route.query.date) {
    isEditMode.value = true
    editingPostId.value = route.query.postId
    
    // Set the date
    const dateMillis = parseInt(route.query.date)
    const date = new Date(dateMillis)
    selectedDate.value = date.toISOString().split('T')[0]
    originalPostDate.value = date
    
    // Load existing post data
    await loadPostData()
  } else if (route.query.date) {
    // Just setting date for new post
    const dateMillis = parseInt(route.query.date)
    const date = new Date(dateMillis)
    selectedDate.value = date.toISOString().split('T')[0]
  }
})

const loadPostData = async () => {
  if (!authStore.user || !editingPostId.value) return
  
  try {
    loading.value = true
    
    // Get all posts and find the one we're editing
    return new Promise((resolve) => {
      const unsubscribe = getAllPosts(authStore.user.email, (posts) => {
        const postToEdit = posts.find(p => p.postId === editingPostId.value)
        
        if (postToEdit) {
          note.value = postToEdit.note || ''
          if (postToEdit.photoUrl) {
            existingPhotoUrl.value = postToEdit.photoUrl
            imagePreview.value = postToEdit.photoUrl
          }
        }
        
        if (unsubscribe) unsubscribe()
        resolve()
      })
    })
  } catch (err) {
    console.error('Error loading post data:', err)
    error.value = 'Failed to load post data'
  } finally {
    loading.value = false
  }
}

const handleImageSelect = (event) => {
  const file = event.target.files[0]
  if (file) {
    selectedFile.value = file
    const reader = new FileReader()
    reader.onload = (e) => {
      imagePreview.value = e.target.result
    }
    reader.readAsDataURL(file)
  }
}

const removeImage = () => {
  selectedFile.value = null
  imagePreview.value = null
  existingPhotoUrl.value = null
  if (fileInput.value) {
    fileInput.value.value = ''
  }
}

const openCamera = () => {
  // For web, we'll use the file input with capture attribute
  if (fileInput.value) {
    fileInput.value.setAttribute('capture', 'environment')
    fileInput.value.click()
  }
}

const handleSubmit = async () => {
  if (!note.value.trim() && !selectedFile.value && !existingPhotoUrl.value) {
    error.value = 'Please add a note or photo'
    return
  }

  try {
    loading.value = true
    error.value = ''

    const postData = {
      note: note.value.trim() || null
    }

    // Handle image: upload new one if selected, or keep existing if no new file
    if (selectedFile.value) {
      // New image selected - upload it
      const imageUrl = await uploadImage(selectedFile.value)
      postData.photoUrl = imageUrl
      trackImageUploaded()
    } else if (existingPhotoUrl.value && imagePreview.value === existingPhotoUrl.value) {
      // Keep existing image (user didn't remove it)
      postData.photoUrl = existingPhotoUrl.value
    } else if (!imagePreview.value) {
      // User removed the image
      postData.photoUrl = null
    }

    // Get the date
    let date = originalPostDate.value || new Date()
    if (selectedDate.value && !originalPostDate.value) {
      // Parse the date string and set time to current time
      const selected = new Date(selectedDate.value)
      const now = new Date()
      selected.setHours(now.getHours(), now.getMinutes(), now.getSeconds(), now.getMilliseconds())
      date = selected
    } else if (selectedDate.value && originalPostDate.value) {
      // In edit mode, use the original date
      date = originalPostDate.value
    }

    if (isEditMode.value && editingPostId.value) {
      // Update existing post
      await updatePost(
        authStore.user.email,
        editingPostId.value,
        date,
        postData,
        existingPhotoUrl.value
      )
      trackPostUpdated()
    } else {
      // Create new post
      await createPost(authStore.user.email, postData, date)
      trackPostCreated()
    }

    // Reset form
    note.value = ''
    selectedFile.value = null
    imagePreview.value = null
    selectedDate.value = new Date().toISOString().split('T')[0]
    isEditMode.value = false
    editingPostId.value = null
    existingPhotoUrl.value = null
    originalPostDate.value = null

    // Navigate back to dashboard
    router.push('/dashboard')
  } catch (err) {
    error.value = isEditMode.value ? 'Failed to update post. Please try again.' : 'Failed to post. Please try again.'
    console.error('Post error:', err)
  } finally {
    loading.value = false
  }
}
</script>

