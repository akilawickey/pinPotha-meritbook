import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { VitePWA } from 'vite-plugin-pwa'
import { fileURLToPath, URL } from 'node:url'

export default defineConfig({
  plugins: [
    vue(),
    VitePWA({
      registerType: 'autoUpdate',
      // Only include assets that actually exist - remove missing favicon references
      includeAssets: [],
      manifest: {
        name: 'PinPotha - Digital පින් පොත',
        short_name: 'PinPotha',
        description: 'Record and remember the good things you\'ve done in your life',
        theme_color: '#4A90E2',
        background_color: '#ffffff',
        display: 'standalone',
        orientation: 'portrait',
        scope: '/',
        start_url: '/',
        icons: [
          // Only include icons that exist - remove missing icon references
          // You can add these later when you create the actual icon files
        ]
      },
      workbox: {
        // Only precache files in production build, not dev source files
        globPatterns: ['**/*.{js,css,html,ico,png,svg,woff2}'],
        // Ignore source files, dev files, and missing assets
        globIgnores: [
          '**/src/**',
          '**/*.vue',
          '**/*.map',
          '**/node_modules/**',
          '**/favicon.png',
          '**/apple-touch-icon.png',
          '**/favicon-32x32.png',
          '**/favicon-16x16.png'
        ],
        // Don't warn about missing precache files
        dontCacheBustURLsMatching: /\.\w{8}\./,
        // Handle missing files gracefully - don't fail on missing files
        mode: 'production',
        // Handle missing files gracefully
        cleanupOutdatedCaches: true,
        skipWaiting: true,
        clientsClaim: true,
        // Suppress warnings for missing precache files
        navigateFallback: '/index.html',
        navigateFallbackDenylist: [/^\/_/, /\/[^/?]+\.[^/]+$/],
        runtimeCaching: [
          // Handle dev source files - let them pass through without warnings
          {
            urlPattern: /^\/src\/.*/i,
            handler: 'NetworkOnly',
            options: {
              cacheName: 'dev-source-files',
              networkTimeoutSeconds: 0
            }
          },
          // Handle missing favicon files - let them pass through
          {
            urlPattern: /\/(favicon|apple-touch-icon).*\.(png|ico)$/i,
            handler: 'NetworkOnly',
            options: {
              cacheName: 'favicon-ignore',
              networkTimeoutSeconds: 0
            }
          },
          {
            urlPattern: /^https:\/\/fonts\.googleapis\.com\/.*/i,
            handler: 'CacheFirst',
            options: {
              cacheName: 'google-fonts-cache',
              expiration: {
                maxEntries: 10,
                maxAgeSeconds: 60 * 60 * 24 * 365 // 1 year
              },
              cacheableResponse: {
                statuses: [0, 200]
              }
            }
          },
          {
            urlPattern: /^https:\/\/fonts\.gstatic\.com\/.*/i,
            handler: 'CacheFirst',
            options: {
              cacheName: 'gstatic-fonts-cache',
              expiration: {
                maxEntries: 10,
                maxAgeSeconds: 60 * 60 * 24 * 365 // 1 year
              },
              cacheableResponse: {
                statuses: [0, 200]
              }
            }
          },
          {
            urlPattern: /^https:\/\/firebasestorage\.googleapis\.com\/.*/i,
            handler: 'CacheFirst',
            options: {
              cacheName: 'firebase-storage-cache',
              expiration: {
                maxEntries: 50,
                maxAgeSeconds: 60 * 60 * 24 * 30 // 30 days
              }
            }
          },
          {
            urlPattern: /^https:\/\/.*\.firebaseio\.com\/.*/i,
            handler: 'NetworkFirst',
            options: {
              cacheName: 'firebase-database-cache',
              networkTimeoutSeconds: 3,
              expiration: {
                maxEntries: 50,
                maxAgeSeconds: 60 * 5 // 5 minutes
              }
            }
          },
          {
            // Ignore external analytics and tracking requests
            urlPattern: /^https:\/\/(www\.)?google-analytics\.com\/.*/i,
            handler: 'NetworkOnly',
            options: {
              cacheName: 'analytics-ignore',
              networkTimeoutSeconds: 0
            }
          },
          {
            // Ignore other analytics services
            urlPattern: /^https:\/\/.*\.googletagmanager\.com\/.*/i,
            handler: 'NetworkOnly',
            options: {
              cacheName: 'analytics-ignore',
              networkTimeoutSeconds: 0
            }
          }
        ]
      },
      devOptions: {
        enabled: true,
        type: 'module',
        // Suppress warnings in dev mode
        suppressWarnings: true,
        navigateFallback: '/index.html'
      }
    })
  ],
  resolve: {
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url))
    }
  },
  server: {
    port: 3000,
    open: true
  },
  build: {
    outDir: 'dist',
    assetsDir: 'assets',
    sourcemap: false,
    minify: 'esbuild',
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor': ['vue', 'vue-router', 'pinia'],
          'firebase': ['firebase/app', 'firebase/auth', 'firebase/database', 'firebase/storage']
        }
      }
    }
  },
  // Ensure public directory files are copied to dist
  publicDir: 'public'
})

