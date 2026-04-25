import { analytics } from '../firebase/config'
import { logEvent, setUserId, setUserProperties } from 'firebase/analytics'

/**
 * Log a custom event to Firebase Analytics
 * @param {string} eventName - Name of the event
 * @param {object} eventParams - Additional parameters for the event
 */
export const logAnalyticsEvent = (eventName, eventParams = {}) => {
  if (analytics) {
    try {
      logEvent(analytics, eventName, eventParams)
      console.log('Analytics event logged:', eventName, eventParams)
    } catch (error) {
      console.error('Error logging analytics event:', error)
    }
  }
}

/**
 * Set the user ID for analytics
 * @param {string} userId - User ID (email or UID)
 */
export const setAnalyticsUserId = (userId) => {
  if (analytics && userId) {
    try {
      setUserId(analytics, userId)
      console.log('Analytics user ID set:', userId)
    } catch (error) {
      console.error('Error setting analytics user ID:', error)
    }
  }
}

/**
 * Set user properties for analytics
 * @param {object} properties - User properties object
 */
export const setAnalyticsUserProperties = (properties) => {
  if (analytics && properties) {
    try {
      setUserProperties(analytics, properties)
      console.log('Analytics user properties set:', properties)
    } catch (error) {
      console.error('Error setting analytics user properties:', error)
    }
  }
}

/**
 * Track page view
 * @param {string} pageName - Name of the page
 * @param {string} pagePath - Path of the page
 */
export const trackPageView = (pageName, pagePath) => {
  logAnalyticsEvent('page_view', {
    page_title: pageName,
    page_location: pagePath
  })
}

/**
 * Track user sign in
 * @param {string} method - Sign in method (e.g., 'google')
 */
export const trackSignIn = (method = 'google') => {
  logAnalyticsEvent('login', {
    method: method
  })
}

/**
 * Track user sign out
 */
export const trackSignOut = () => {
  logAnalyticsEvent('logout')
}

/**
 * Track post creation
 */
export const trackPostCreated = () => {
  logAnalyticsEvent('post_created')
}

/**
 * Track post update
 */
export const trackPostUpdated = () => {
  logAnalyticsEvent('post_updated')
}

/**
 * Track post deletion
 */
export const trackPostDeleted = () => {
  logAnalyticsEvent('post_deleted')
}

/**
 * Track post view
 */
export const trackPostViewed = () => {
  logAnalyticsEvent('post_viewed')
}

/**
 * Track image upload
 */
export const trackImageUploaded = () => {
  logAnalyticsEvent('image_uploaded')
}

/**
 * Track search
 * @param {string} searchTerm - Search term used
 */
export const trackSearch = (searchTerm) => {
  logAnalyticsEvent('search', {
    search_term: searchTerm
  })
}

