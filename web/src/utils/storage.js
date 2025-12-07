import localforage from 'localforage'

// Configure localforage
localforage.config({
  name: 'PinPotha',
  storeName: 'pinpotha_store',
  description: 'PinPotha persistent storage'
})

/**
 * Persistent storage utility using IndexedDB
 */
export const storage = {
  /**
   * Set a value in storage
   */
  async set(key, value) {
    try {
      await localforage.setItem(key, value)
      return true
    } catch (error) {
      console.error('Storage set error:', error)
      return false
    }
  },

  /**
   * Get a value from storage
   */
  async get(key, defaultValue = null) {
    try {
      const value = await localforage.getItem(key)
      return value !== null ? value : defaultValue
    } catch (error) {
      console.error('Storage get error:', error)
      return defaultValue
    }
  },

  /**
   * Remove a value from storage
   */
  async remove(key) {
    try {
      await localforage.removeItem(key)
      return true
    } catch (error) {
      console.error('Storage remove error:', error)
      return false
    }
  },

  /**
   * Clear all storage
   */
  async clear() {
    try {
      await localforage.clear()
      return true
    } catch (error) {
      console.error('Storage clear error:', error)
      return false
    }
  },

  /**
   * Get all keys
   */
  async keys() {
    try {
      return await localforage.keys()
    } catch (error) {
      console.error('Storage keys error:', error)
      return []
    }
  }
}

/**
 * Store user posts cache
 */
export const postsCache = {
  async set(userId, posts) {
    return await storage.set(`posts_${userId}`, {
      data: posts,
      timestamp: Date.now()
    })
  },

  async get(userId, maxAge = 5 * 60 * 1000) { // 5 minutes default
    const cached = await storage.get(`posts_${userId}`)
    if (!cached) return null

    const age = Date.now() - cached.timestamp
    if (age > maxAge) {
      await storage.remove(`posts_${userId}`)
      return null
    }

    return cached.data
  },

  async clear(userId) {
    return await storage.remove(`posts_${userId}`)
  }
}

/**
 * Store user preferences
 */
export const preferences = {
  async set(key, value) {
    return await storage.set(`pref_${key}`, value)
  },

  async get(key, defaultValue = null) {
    return await storage.get(`pref_${key}`, defaultValue)
  }
}

