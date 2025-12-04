import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { trackPageView } from '../utils/analytics'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'SignIn',
      component: () => import('../views/SignIn.vue'),
      meta: { requiresAuth: false }
    },
    {
      path: '/dashboard',
      name: 'Dashboard',
      component: () => import('../views/Dashboard.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/add',
      name: 'Add',
      component: () => import('../views/AddPost.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/posts/:date',
      name: 'PostList',
      component: () => import('../views/PostList.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/post/:postId',
      name: 'PostDetails',
      component: () => import('../views/PostDetails.vue'),
      meta: { requiresAuth: true }
    }
  ]
})

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  
  if (to.meta.requiresAuth && !authStore.user) {
    next('/')
  } else if (to.path === '/' && authStore.user) {
    next('/dashboard')
  } else {
    next()
  }
})

// Track page views
router.afterEach((to, from) => {
  trackPageView(to.name || 'Unknown', to.path)
})

export default router

