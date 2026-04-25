<template>
  <div class="min-h-screen bg-gradient-to-br from-gray-50 to-gray-100">
    <header class="bg-white shadow-lg border-b-2 border-brand-accent/20">
      <div class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-5">
        <button
          @click="goBack"
          class="text-secondary-600 hover:text-brand-accent transition-colors mb-3"
        >
          ← Back
        </button>
        <h1 class="text-2xl font-bold text-brand-dark">Account Settings</h1>
        <p class="text-secondary-600 text-sm mt-1">Manage your account and personal data.</p>
      </div>
    </header>

    <main class="max-w-2xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <section class="bg-white rounded-xl border border-red-200 shadow-sm p-6">
        <h2 class="text-xl font-semibold text-red-700">Delete account</h2>
        <p class="text-sm text-secondary-700 mt-2">
          This permanently deletes your account, all posts, and associated uploaded photos.
        </p>
        <div class="mt-4">
          <label class="block text-sm font-medium text-secondary-700 mb-2">Email address</label>
          <input
            v-model.trim="email"
            type="email"
            placeholder="Enter your account email"
            class="input-field"
          />
        </div>

        <p class="text-sm text-secondary-700 mt-2">We will send a 6-digit confirmation code to this email.</p>

        <div class="mt-5 flex flex-col sm:flex-row gap-3">
          <button
            @click="handleSendCode"
            :disabled="sendingCode || deleting || !email"
            class="bg-brand-accent hover:bg-brand-accent-hover text-white px-4 py-2 rounded-lg font-medium transition-colors disabled:opacity-60"
          >
            {{ sendingCode ? 'Sending code...' : 'Send confirmation code' }}
          </button>
        </div>

        <div class="mt-5">
          <label class="block text-sm font-medium text-secondary-700 mb-2">
            Confirmation code
          </label>
          <input
            v-model="code"
            type="text"
            maxlength="6"
            inputmode="numeric"
            placeholder="Enter 6-digit code"
            class="input-field max-w-xs"
          />
        </div>

        <div class="mt-5">
          <button
            @click="handleDeleteAccount"
            :disabled="deleting || code.length !== 6 || !email"
            class="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-lg font-medium transition-colors disabled:opacity-60"
          >
            {{ deleting ? 'Deleting account...' : 'Confirm and delete account' }}
          </button>
        </div>

        <p v-if="message" class="mt-4 text-sm text-green-700 bg-green-50 px-3 py-2 rounded-lg">
          {{ message }}
        </p>
        <p v-if="error" class="mt-4 text-sm text-red-700 bg-red-50 px-3 py-2 rounded-lg">
          {{ error }}
        </p>
      </section>
    </main>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { signOut } from 'firebase/auth'
import { auth } from '../firebase/config'
import { useAuthStore } from '../stores/auth'
import { sendAccountDeletionCode, confirmAccountDeletion } from '../utils/accountDeletion'
import { storage } from '../utils/storage'

const router = useRouter()
const authStore = useAuthStore()

const sendingCode = ref(false)
const deleting = ref(false)
const email = ref(authStore.user?.email || '')
const code = ref('')
const message = ref('')
const error = ref('')

const extractErrorMessage = (err, fallback) => {
  return err?.message?.replace('FirebaseError: ', '') || fallback
}

const goBack = () => {
  if (authStore.user) {
    router.push('/dashboard')
    return
  }
  router.push('/')
}

const handleSendCode = async () => {
  message.value = ''
  error.value = ''
  sendingCode.value = true

  try {
    await sendAccountDeletionCode(email.value)
    message.value = 'Confirmation code sent. Please check your email inbox.'
  } catch (err) {
    error.value = extractErrorMessage(err, 'Failed to send confirmation code.')
  } finally {
    sendingCode.value = false
  }
}

const handleDeleteAccount = async () => {
  message.value = ''
  error.value = ''
  deleting.value = true

  try {
    await confirmAccountDeletion(email.value, code.value)
    await storage.clear()
    await signOut(auth).catch(() => {})
    await router.replace('/')
  } catch (err) {
    error.value = extractErrorMessage(err, 'Failed to delete account.')
  } finally {
    deleting.value = false
  }
}
</script>
