/* ========================================
   SERVICE WORKER FOR PERFORMANCE OPTIMIZATION
   ======================================== */

const CACHE_NAME = 'hossainlab-v1.2';
const RUNTIME = 'runtime';

// Resources to cache immediately
const PRECACHE_URLS = [
  '/',
  '/about/',
  '/research/',
  '/publications/',
  '/teaching/',
  '/talks/',
  '/press/',
  '/styles.css',
  '/performance.css',
  '/performance.js'
];

// Install event - cache essential resources
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        console.log('📦 Precaching resources');
        return cache.addAll(PRECACHE_URLS);
      })
      .then(self.skipWaiting())
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', event => {
  const currentCaches = [CACHE_NAME, RUNTIME];
  event.waitUntil(
    caches.keys().then(cacheNames => {
      return cacheNames.filter(cacheName => !currentCaches.includes(cacheName));
    }).then(cachesToDelete => {
      return Promise.all(cachesToDelete.map(cacheToDelete => {
        console.log('🗑️ Deleting old cache:', cacheToDelete);
        return caches.delete(cacheToDelete);
      }));
    }).then(() => self.clients.claim())
  );
});

// Fetch event - serve from cache with network fallback
self.addEventListener('fetch', event => {
  // Skip cross-origin requests
  if (event.request.url.startsWith(self.location.origin)) {
    event.respondWith(
      caches.match(event.request).then(cachedResponse => {
        if (cachedResponse) {
          // Serve from cache
          return cachedResponse;
        }

        return caches.open(RUNTIME).then(cache => {
          return fetch(event.request).then(response => {
            // Cache successful responses
            if (response.status === 200) {
              // Clone the response before caching
              cache.put(event.request, response.clone());
            }
            return response;
          });
        });
      })
    );
  }
});

// Handle cache updates
self.addEventListener('message', event => {
  if (event.data.action === 'skipWaiting') {
    self.skipWaiting();
  }
});

// Background sync for offline functionality
self.addEventListener('sync', event => {
  if (event.tag === 'background-sync') {
    console.log('🔄 Background sync triggered');
  }
});

// Push notifications (if needed in future)
self.addEventListener('push', event => {
  if (event.data) {
    const options = {
      body: event.data.text(),
      icon: '/files/profiles/icon.png',
      badge: '/files/profiles/icon.png'
    };

    event.waitUntil(
      self.registration.showNotification('Hossain Lab', options)
    );
  }
});