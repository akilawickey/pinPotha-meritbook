/**
 * SEO Utility Functions
 * Manages dynamic meta tags, structured data, and SEO-related functionality
 */

const defaultSEO = {
  title: 'PinPotha - Digital පින් පොත | Record Your Good Thoughts',
  description: 'Record and remember the good things you\'ve done in your life. A digital journal for tracking your positive actions and good thoughts.',
  keywords: 'pinpotha, digital pinpotha, good thoughts, diary, journal, sri lanka, positive actions, merit book, පින් පොත',
  image: 'https://pinpotha.lk/og-image.png',
  url: 'https://pinpotha.lk',
  type: 'website'
}

/**
 * Update document title
 */
export const setTitle = (title) => {
  if (title) {
    document.title = title
    // Update meta title tag if it exists
    updateMetaTag('property', 'og:title', title)
    updateMetaTag('name', 'twitter:title', title)
  }
}

/**
 * Update meta description
 */
export const setDescription = (description) => {
  if (description) {
    updateMetaTag('name', 'description', description)
    updateMetaTag('property', 'og:description', description)
    updateMetaTag('name', 'twitter:description', description)
  }
}

/**
 * Update meta keywords
 */
export const setKeywords = (keywords) => {
  if (keywords) {
    updateMetaTag('name', 'keywords', keywords)
  }
}

/**
 * Update Open Graph image
 */
export const setImage = (image) => {
  if (image) {
    updateMetaTag('property', 'og:image', image)
    updateMetaTag('name', 'twitter:image', image)
  }
}

/**
 * Update canonical URL
 */
export const setCanonical = (url) => {
  let canonical = document.querySelector('link[rel="canonical"]')
  if (!canonical) {
    canonical = document.createElement('link')
    canonical.setAttribute('rel', 'canonical')
    document.head.appendChild(canonical)
  }
  canonical.setAttribute('href', url)
  
  // Also update og:url
  updateMetaTag('property', 'og:url', url)
  updateMetaTag('name', 'twitter:url', url)
}

/**
 * Update Open Graph type
 */
export const setType = (type) => {
  updateMetaTag('property', 'og:type', type)
}

/**
 * Helper function to update or create meta tags
 */
const updateMetaTag = (attribute, value, content) => {
  let meta = document.querySelector(`meta[${attribute}="${value}"]`)
  if (!meta) {
    meta = document.createElement('meta')
    meta.setAttribute(attribute, value)
    document.head.appendChild(meta)
  }
  meta.setAttribute('content', content)
}

/**
 * Set comprehensive SEO meta tags for a page
 */
export const setSEO = (options = {}) => {
  const seo = {
    title: options.title || defaultSEO.title,
    description: options.description || defaultSEO.description,
    keywords: options.keywords || defaultSEO.keywords,
    image: options.image || defaultSEO.image,
    url: options.url || defaultSEO.url,
    type: options.type || defaultSEO.type
  }

  setTitle(seo.title)
  setDescription(seo.description)
  setKeywords(seo.keywords)
  setImage(seo.image)
  setCanonical(seo.url)
  setType(seo.type)
}

/**
 * Add structured data (JSON-LD) to the page
 */
export const addStructuredData = (data) => {
  // Remove existing structured data with the same @type if it exists
  const existingScript = document.querySelector(`script[type="application/ld+json"][data-seo-type="${data['@type']}"]`)
  if (existingScript) {
    existingScript.remove()
  }

  const script = document.createElement('script')
  script.type = 'application/ld+json'
  script.setAttribute('data-seo-type', data['@type'] || 'default')
  script.textContent = JSON.stringify(data)
  document.head.appendChild(script)
}

/**
 * Remove structured data by type
 */
export const removeStructuredData = (type) => {
  const script = document.querySelector(`script[type="application/ld+json"][data-seo-type="${type}"]`)
  if (script) {
    script.remove()
  }
}

/**
 * Generate BreadcrumbList structured data
 */
export const generateBreadcrumbs = (items) => {
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: items.map((item, index) => ({
      '@type': 'ListItem',
      position: index + 1,
      name: item.name,
      item: item.url
    }))
  }
}

/**
 * Generate Article structured data for posts
 */
export const generateArticleSchema = (post) => {
  if (!post) return null

  const date = post.timeStamp?.server_time 
    ? new Date(parseInt(post.timeStamp.server_time))
    : new Date()

  return {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: post.note || 'Good Thought',
    description: post.note || 'A good thought recorded in PinPotha',
    image: post.photoUrl || 'https://pinpotha.lk/og-image.png',
    datePublished: date.toISOString(),
    dateModified: date.toISOString(),
    author: {
      '@type': 'Person',
      name: 'PinPotha User'
    },
    publisher: {
      '@type': 'Organization',
      name: 'PinPotha',
      logo: {
        '@type': 'ImageObject',
        url: 'https://pinpotha.lk/logo.png'
      }
    }
  }
}

/**
 * Reset SEO to default values
 */
export const resetSEO = () => {
  setSEO(defaultSEO)
}

