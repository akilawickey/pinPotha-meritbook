import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { trackPageView } from '../utils/analytics'
import { setSEO } from '../utils/seo'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'SignIn',
      component: () => import('../views/SignIn.vue'),
      meta: { 
        requiresAuth: false,
        seo: {
          title: 'PinPotha - Digital පින් පොත | Sign In',
          description: 'Sign in to PinPotha and start recording your good thoughts. A digital journal for tracking your positive actions and good deeds.',
          keywords: 'pinpotha sign in, digital pinpotha login, good thoughts app, sri lanka journal app'
        }
      }
    },
    {
      path: '/dashboard',
      name: 'Dashboard',
      component: () => import('../views/Dashboard.vue'),
      meta: { 
        requiresAuth: true,
        seo: {
          title: 'Dashboard - PinPotha | Your Good Thoughts',
          description: 'View all your recorded good thoughts and positive actions in your PinPotha dashboard.',
          keywords: 'pinpotha dashboard, my good thoughts, view posts, digital journal'
        }
      }
    },
    {
      path: '/add',
      name: 'Add',
      component: () => import('../views/AddPost.vue'),
      meta: { 
        requiresAuth: true,
        seo: {
          title: 'Add Good Thought - PinPotha',
          description: 'Record a new good thought or positive action in your PinPotha journal.',
          keywords: 'add good thought, record positive action, pinpotha new post'
        }
      }
    },
    {
      path: '/posts/:date',
      name: 'PostList',
      component: () => import('../views/PostList.vue'),
      meta: { 
        requiresAuth: true,
        seo: {
          title: 'Posts - PinPotha',
          description: 'View your good thoughts for a specific date.',
          keywords: 'pinpotha posts, date posts, good thoughts by date'
        }
      }
    },
    {
      path: '/post/:postId',
      name: 'PostDetails',
      component: () => import('../views/PostDetails.vue'),
      meta: { 
        requiresAuth: true,
        seo: {
          title: 'Post Details - PinPotha',
          description: 'View details of your good thought.',
          keywords: 'pinpotha post details, view good thought'
        }
      }
    }
  ]
})

router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()
  
  // Wait for auth to initialize if still loading
  // This is important after redirect-based authentication
  if (authStore.loading) {
    // Poll until auth is initialized (max 3 seconds)
    const maxWait = 3000
    const startTime = Date.now()
    while (authStore.loading && (Date.now() - startTime) < maxWait) {
      await new Promise(resolve => setTimeout(resolve, 50))
    }
  }
  
  if (to.meta.requiresAuth && !authStore.user) {
    next('/')
  } else if (to.path === '/' && authStore.user) {
    next('/dashboard')
  } else {
    next()
  }
})

// Update SEO and track page views
router.afterEach((to) => {
  // Update SEO meta tags
  if (to.meta.seo) {
    const baseUrl = 'https://pinpotha.lk'
    setSEO({
      ...to.meta.seo,
      url: `${baseUrl}${to.path}`
    })
  }
  
  // Track page views for analytics
  trackPageView(to.path, to.name)
})

export default router

