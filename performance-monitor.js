/* ========================================
   ADVANCED PERFORMANCE MONITORING & OPTIMIZATION
   ======================================== */

class PerformanceOptimizer {
  constructor() {
    this.metrics = {};
    this.observers = [];
    this.isProduction = location.hostname !== 'localhost';
    this.init();
  }

  init() {
    this.setupCriticalOptimizations();
    this.setupLazyLoading();
    this.setupPerformanceMonitoring();
    this.setupResourceOptimization();
    this.setupUserExperienceEnhancements();
  }

  // ===== CRITICAL OPTIMIZATIONS ===== //

  setupCriticalOptimizations() {
    // Prevent layout shifts
    this.preventLayoutShifts();

    // Optimize fonts
    this.optimizeFonts();

    // Preload critical resources
    this.preloadCriticalResources();
  }

  preventLayoutShifts() {
    // Add aspect ratio containers for images
    document.querySelectorAll('img:not([width]):not([height])').forEach(img => {
      img.addEventListener('load', () => {
        const container = img.parentElement;
        if (container && !container.style.aspectRatio) {
          const aspectRatio = img.naturalWidth / img.naturalHeight;
          container.style.aspectRatio = aspectRatio.toString();
        }
      });
    });
  }

  optimizeFonts() {
    // Ensure font-display: swap for web fonts
    if ('FontFace' in window) {
      document.fonts.ready.then(() => {
        console.log('✅ Fonts loaded');
      });
    }
  }

  preloadCriticalResources() {
    const criticalImages = [
      '/files/profiles/icon.png',
      '/files/img/banner.jpg'
    ];

    criticalImages.forEach(src => {
      const link = document.createElement('link');
      link.rel = 'preload';
      link.as = 'image';
      link.href = src;
      document.head.appendChild(link);
    });
  }

  // ===== LAZY LOADING ===== //

  setupLazyLoading() {
    if ('IntersectionObserver' in window) {
      this.setupIntersectionObserver();
    } else {
      this.fallbackLazyLoading();
    }
  }

  setupIntersectionObserver() {
    const options = {
      root: null,
      rootMargin: '50px 0px',
      threshold: 0.1
    };

    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.loadElement(entry.target);
          observer.unobserve(entry.target);
        }
      });
    }, options);

    // Observe lazy elements
    document.querySelectorAll('[data-lazy], .lazy-element, img[loading="lazy"]').forEach(el => {
      observer.observe(el);
    });

    this.observers.push(observer);
  }

  loadElement(element) {
    if (element.tagName === 'IMG') {
      this.loadImage(element);
    } else {
      element.classList.add('in-view');
      if (element.dataset.lazy) {
        this.loadContent(element);
      }
    }
  }

  loadImage(img) {
    if (img.dataset.src) {
      img.src = img.dataset.src;
    }
    if (img.dataset.srcset) {
      img.srcset = img.dataset.srcset;
    }

    img.addEventListener('load', () => {
      img.classList.add('loaded');
      img.style.opacity = '1';
    });

    img.addEventListener('error', () => {
      img.classList.add('error');
    });
  }

  loadContent(element) {
    const content = element.dataset.lazy;
    if (content) {
      element.innerHTML = content;
    }
  }

  fallbackLazyLoading() {
    // Fallback for browsers without IntersectionObserver
    const lazyElements = document.querySelectorAll('[data-lazy], .lazy-element');
    lazyElements.forEach(el => {
      this.loadElement(el);
    });
  }

  // ===== PERFORMANCE MONITORING ===== //

  setupPerformanceMonitoring() {
    this.monitorCoreWebVitals();
    this.monitorCustomMetrics();
    this.monitorResourceTiming();
  }

  monitorCoreWebVitals() {
    // Largest Contentful Paint (LCP)
    if ('PerformanceObserver' in window) {
      try {
        const lcpObserver = new PerformanceObserver((entryList) => {
          const entries = entryList.getEntries();
          const lastEntry = entries[entries.length - 1];
          this.metrics.lcp = lastEntry.startTime;
          this.logMetric('LCP', lastEntry.startTime, 'ms');
        });
        lcpObserver.observe({ entryTypes: ['largest-contentful-paint'] });
        this.observers.push(lcpObserver);
      } catch (e) {
        console.warn('LCP monitoring not supported');
      }

      // First Input Delay (FID)
      try {
        const fidObserver = new PerformanceObserver((entryList) => {
          entryList.getEntries().forEach((entry) => {
            const fid = entry.processingStart - entry.startTime;
            this.metrics.fid = fid;
            this.logMetric('FID', fid, 'ms');
          });
        });
        fidObserver.observe({ entryTypes: ['first-input'] });
        this.observers.push(fidObserver);
      } catch (e) {
        console.warn('FID monitoring not supported');
      }

      // Cumulative Layout Shift (CLS)
      try {
        let clsValue = 0;
        const clsObserver = new PerformanceObserver((entryList) => {
          entryList.getEntries().forEach((entry) => {
            if (!entry.hadRecentInput) {
              clsValue += entry.value;
              this.metrics.cls = clsValue;
              this.logMetric('CLS', clsValue);
            }
          });
        });
        clsObserver.observe({ entryTypes: ['layout-shift'] });
        this.observers.push(clsObserver);
      } catch (e) {
        console.warn('CLS monitoring not supported');
      }
    }
  }

  monitorCustomMetrics() {
    // Time to Interactive (TTI) approximation
    window.addEventListener('load', () => {
      setTimeout(() => {
        this.metrics.tti = performance.now();
        this.logMetric('TTI (approx)', this.metrics.tti, 'ms');
      }, 0);
    });

    // Page Load Time
    window.addEventListener('load', () => {
      const loadTime = performance.timing.loadEventEnd - performance.timing.navigationStart;
      this.metrics.pageLoad = loadTime;
      this.logMetric('Page Load', loadTime, 'ms');
    });

    // DOM Content Loaded
    document.addEventListener('DOMContentLoaded', () => {
      const domTime = performance.timing.domContentLoadedEventEnd - performance.timing.navigationStart;
      this.metrics.domContentLoaded = domTime;
      this.logMetric('DOM Content Loaded', domTime, 'ms');
    });
  }

  monitorResourceTiming() {
    window.addEventListener('load', () => {
      const resources = performance.getEntriesByType('resource');

      // Analyze slow resources
      const slowResources = resources.filter(resource => resource.duration > 1000);
      if (slowResources.length > 0) {
        console.warn('🐌 Slow resources detected:', slowResources);
      }

      // Calculate total resource load time
      const totalResourceTime = resources.reduce((total, resource) => total + resource.duration, 0);
      this.metrics.totalResourceTime = totalResourceTime;
      this.logMetric('Total Resource Time', totalResourceTime, 'ms');
    });
  }

  logMetric(name, value, unit = '') {
    if (!this.isProduction) {
      const color = this.getMetricColor(name, value);
      console.log(`%c📊 ${name}: ${value.toFixed(2)}${unit}`, `color: ${color}; font-weight: bold;`);
    }
  }

  getMetricColor(metric, value) {
    const thresholds = {
      'LCP': { good: 2500, poor: 4000 },
      'FID': { good: 100, poor: 300 },
      'CLS': { good: 0.1, poor: 0.25 }
    };

    const threshold = thresholds[metric];
    if (!threshold) return '#2196F3';

    if (value <= threshold.good) return '#4CAF50';
    if (value <= threshold.poor) return '#FF9800';
    return '#F44336';
  }

  // ===== RESOURCE OPTIMIZATION ===== //

  setupResourceOptimization() {
    this.optimizeImages();
    this.prefetchNextPage();
    this.setupServiceWorker();
  }

  optimizeImages() {
    // Add WebP support detection
    const supportsWebP = this.checkWebPSupport();

    document.querySelectorAll('img[data-webp]').forEach(img => {
      if (supportsWebP && img.dataset.webp) {
        img.src = img.dataset.webp;
      }
    });

    // Progressive image enhancement
    document.querySelectorAll('img[data-placeholder]').forEach(img => {
      const placeholder = img.dataset.placeholder;
      if (placeholder) {
        img.style.backgroundImage = `url(${placeholder})`;
        img.style.backgroundSize = 'cover';
        img.style.filter = 'blur(5px)';

        img.addEventListener('load', () => {
          img.style.filter = 'none';
          img.style.backgroundImage = 'none';
        });
      }
    });
  }

  checkWebPSupport() {
    return new Promise(resolve => {
      const webP = new Image();
      webP.onload = webP.onerror = () => resolve(webP.height === 2);
      webP.src = 'data:image/webp;base64,UklGRjoAAABXRUJQVlA4IC4AAACyAgCdASoCAAIALmk0mk0iIiIiIgBoSygABc6WWgAA/veff/0PP8bA//LwYAAA';
    });
  }

  prefetchNextPage() {
    // Prefetch likely next pages on hover
    document.querySelectorAll('a[href^="/"]').forEach(link => {
      link.addEventListener('mouseenter', () => {
        const prefetchLink = document.createElement('link');
        prefetchLink.rel = 'prefetch';
        prefetchLink.href = link.href;
        document.head.appendChild(prefetchLink);
      }, { once: true });
    });
  }

  setupServiceWorker() {
    if ('serviceWorker' in navigator && this.isProduction) {
      navigator.serviceWorker.register('/sw.js')
        .then(registration => {
          console.log('✅ Service Worker registered');
        })
        .catch(error => {
          console.warn('Service Worker registration failed:', error);
        });
    }
  }

  // ===== USER EXPERIENCE ENHANCEMENTS ===== //

  setupUserExperienceEnhancements() {
    this.setupSmoothScrolling();
    this.setupProgressIndicator();
    this.setupKeyboardNavigation();
    this.setupTouchOptimizations();
  }

  setupSmoothScrolling() {
    // Enhanced smooth scrolling for internal links
    document.addEventListener('click', (e) => {
      const link = e.target.closest('a[href^="#"]');
      if (link && link.hash) {
        e.preventDefault();
        const target = document.querySelector(link.hash);
        if (target) {
          target.scrollIntoView({
            behavior: 'smooth',
            block: 'start'
          });
          history.pushState(null, null, link.hash);
        }
      }
    });
  }

  setupProgressIndicator() {
    // Reading progress indicator
    const progressBar = document.createElement('div');
    progressBar.style.cssText = `
      position: fixed;
      top: 0;
      left: 0;
      width: 0%;
      height: 3px;
      background: linear-gradient(90deg, #3b82f6, #10b981);
      z-index: 10000;
      transition: width 0.1s ease-out;
    `;
    document.body.appendChild(progressBar);

    const updateProgress = () => {
      const scrolled = (window.scrollY / (document.documentElement.scrollHeight - window.innerHeight)) * 100;
      progressBar.style.width = `${Math.min(scrolled, 100)}%`;
    };

    window.addEventListener('scroll', updateProgress, { passive: true });
  }

  setupKeyboardNavigation() {
    // Enhanced keyboard navigation
    document.addEventListener('keydown', (e) => {
      // Skip links with Alt + 1
      if (e.altKey && e.key === '1') {
        const mainContent = document.querySelector('main, #main, .main-content');
        if (mainContent) {
          mainContent.focus();
          mainContent.scrollIntoView();
        }
      }
    });
  }

  setupTouchOptimizations() {
    // Optimize touch interactions
    if ('ontouchstart' in window) {
      document.body.classList.add('touch-device');

      // Remove hover effects on touch devices
      document.querySelectorAll('.optimized-hover').forEach(el => {
        el.addEventListener('touchstart', () => {}, { passive: true });
      });
    }
  }

  // ===== CLEANUP ===== //

  destroy() {
    this.observers.forEach(observer => observer.disconnect());
    this.observers = [];
  }
}

// Initialize performance optimizer
let perfOptimizer;

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => {
    perfOptimizer = new PerformanceOptimizer();
  });
} else {
  perfOptimizer = new PerformanceOptimizer();
}

// Export for debugging
window.perfOptimizer = perfOptimizer;