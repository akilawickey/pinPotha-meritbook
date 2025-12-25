/**
 * Vue 3 Composable for SEO Management
 * Provides easy-to-use SEO functions in Vue components
 */
import { onMounted, onUnmounted } from 'vue'
import { 
  setSEO, 
  addStructuredData, 
  removeStructuredData,
  generateArticleSchema,
  generateBreadcrumbs,
  resetSEO
} from '../utils/seo'

/**
 * Composable for managing SEO in Vue components
 * @param {Object} options - SEO options
 * @returns {Object} SEO management functions
 */
export function useSEO(options = {}) {
  // Set initial SEO on mount
  onMounted(() => {
    if (options.title || options.description) {
      setSEO({
        title: options.title,
        description: options.description,
        keywords: options.keywords,
        image: options.image,
        url: options.url,
        type: options.type || 'website'
      })
    }

    // Add structured data if provided
    if (options.structuredData) {
      addStructuredData(options.structuredData)
    }

    // Add breadcrumbs if provided
    if (options.breadcrumbs && options.breadcrumbs.length > 0) {
      const breadcrumbData = generateBreadcrumbs(options.breadcrumbs)
      addStructuredData(breadcrumbData)
    }
  })

  // Cleanup on unmount
  onUnmounted(() => {
    if (options.structuredData) {
      removeStructuredData(options.structuredData['@type'] || 'default')
    }
    if (options.breadcrumbs) {
      removeStructuredData('BreadcrumbList')
    }
  })

  return {
    setSEO,
    addStructuredData,
    removeStructuredData,
    generateArticleSchema,
    generateBreadcrumbs,
    resetSEO
  }
}

