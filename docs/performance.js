/* ========================================
   PERFORMANCE OPTIMIZATION JAVASCRIPT
   ======================================== */

(function() {
  'use strict';

  // ===== CRITICAL PERFORMANCE INITIALIZATION ===== //

  // Performance monitoring
  const perfMonitor = {
    start: performance.now(),
    marks: {},

    mark(name) {
      this.marks[name] = performance.now();
    },

    measure(name, startMark) {
      const duration = performance.now() - (this.marks[startMark] || this.start);
      console.log(`⏱️ ${name}: ${duration.toFixed(2)}ms`);
      return duration;
    }
  };

  // ===== LOADING OPTIMIZATION ===== //

  // Page loading state management
  const loadingManager = {
    init() {
      // Show loading screen
      this.showLoading();

      // Hide loading when page is ready
      if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => this.hideLoading());
      } else {
        this.hideLoading();
      }
    },

    showLoading() {
      const loader = document.createElement('div');
      loader.className = 'page-loading';
      loader.innerHTML = '<div class="loading-spinner"></div>';
      document.body.appendChild(loader);
    },

    hideLoading() {
      setTimeout(() => {
        const loader = document.querySelector('.page-loading');
        if (loader) {
          loader.classList.add('fade-out');
          setTimeout(() => loader.remove(), 300);
        }
      }, 100);
    }
  };

  // ===== LAZY LOADING IMPLEMENTATION ===== //

  const lazyLoader = {
    observer: null,

    init() {
      if ('IntersectionObserver' in window) {
        this.observer = new IntersectionObserver(this.handleIntersection.bind(this), {
          rootMargin: '50px 0px',
          threshold: 0.1
        });

        this.observeElements();
      } else {
        // Fallback for older browsers
        this.loadAllElements();
      }
    },

    observeElements() {
      // Observe lazy images
      document.querySelectorAll('img[loading="lazy"]').forEach(img => {
        this.observer.observe(img);
      });

      // Observe lazy elements
      document.querySelectorAll('.lazy-element').forEach(el => {
        this.observer.observe(el);
      });
    },

    handleIntersection(entries) {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const element = entry.target;

          if (element.tagName === 'IMG') {
            this.loadImage(element);
          } else {
            element.classList.add('in-view');
          }

          this.observer.unobserve(element);
        }
      });
    },

    loadImage(img) {
      img.addEventListener('load', () => {
        img.classList.add('loaded');
      });

      if (img.dataset.src) {
        img.src = img.dataset.src;
      }
    },

    loadAllElements() {
      document.querySelectorAll('.lazy-element').forEach(el => {
        el.classList.add('in-view');
      });

      document.querySelectorAll('img[loading="lazy"]').forEach(img => {
        this.loadImage(img);
      });
    }
  };

  // ===== SMOOTH SCROLL ENHANCEMENT ===== //

  const smoothScroll = {
    init() {
      // Enhanced smooth scrolling for anchor links
      document.addEventListener('click', (e) => {
        const link = e.target.closest('a[href^="#"]');
        if (link) {
          e.preventDefault();
          const targetId = link.getAttribute('href').substring(1);
          const target = document.getElementById(targetId);

          if (target) {
            target.scrollIntoView({
              behavior: 'smooth',
              block: 'start'
            });

            // Update URL without jumping
            history.pushState(null, null, `#${targetId}`);
          }
        }
      });
    }
  };

  // ===== ANIMATION PERFORMANCE ===== //

  const animationManager = {
    init() {
      // Apply stagger animations to grids
      this.applyStaggerAnimation();

      // Apply optimized hover effects
      this.applyOptimizedHovers();
    },

    applyStaggerAnimation() {
      const grids = document.querySelectorAll('.talks-container, .media-container, .courses-container, .projects-grid');
      grids.forEach(grid => {
        grid.classList.add('stagger-animation');
      });
    },

    applyOptimizedHovers() {
      const cards = document.querySelectorAll('.talk-card, .media-card, .course-card, .project-card');
      cards.forEach(card => {
        card.classList.add('optimized-hover');
      });
    }
  };

  // ===== RESOURCE OPTIMIZATION ===== //

  const resourceOptimizer = {
    init() {
      // Preload critical resources
      this.preloadCriticalResources();

      // Optimize images
      this.optimizeImages();

      // Defer non-critical scripts
      this.deferNonCriticalScripts();
    },

    preloadCriticalResources() {
      // Preload critical fonts
      const fontPreload = document.createElement('link');
      fontPreload.rel = 'preload';
      fontPreload.as = 'font';
      fontPreload.type = 'font/woff2';
      fontPreload.href = 'https://fonts.gstatic.com/s/inter/v12/UcCO3FwrK3iLTeHuS_fvQtMwCp50KnMw2boKoduKmMEVuLyfAZ9hiA.woff2';
      fontPreload.crossOrigin = 'anonymous';
      document.head.appendChild(fontPreload);
    },

    optimizeImages() {
      // Add loading="lazy" to images that don't have it
      document.querySelectorAll('img:not([loading])').forEach(img => {
        if (!this.isInViewport(img)) {
          img.loading = 'lazy';
        }
      });
    },

    isInViewport(element) {
      const rect = element.getBoundingClientRect();
      return rect.top < window.innerHeight && rect.bottom > 0;
    },

    deferNonCriticalScripts() {
      // Defer analytics and other non-critical scripts
      const scripts = document.querySelectorAll('script[data-defer]');
      scripts.forEach(script => {
        const newScript = document.createElement('script');
        newScript.src = script.src;
        newScript.async = true;
        document.body.appendChild(newScript);
        script.remove();
      });
    }
  };

  // ===== PERFORMANCE MONITORING ===== //

  const performanceMonitor = {
    init() {
      // Monitor Core Web Vitals
      this.monitorWebVitals();

      // Monitor custom metrics
      this.monitorCustomMetrics();
    },

    monitorWebVitals() {
      // Largest Contentful Paint
      new PerformanceObserver((entryList) => {
        const entries = entryList.getEntries();
        const lastEntry = entries[entries.length - 1];
        console.log('🎯 LCP:', lastEntry.startTime);
      }).observe({entryTypes: ['largest-contentful-paint']});

      // First Input Delay
      new PerformanceObserver((entryList) => {
        const entries = entryList.getEntries();
        entries.forEach((entry) => {
          console.log('⚡ FID:', entry.processingStart - entry.startTime);
        });
      }).observe({entryTypes: ['first-input']});

      // Cumulative Layout Shift
      new PerformanceObserver((entryList) => {
        const entries = entryList.getEntries();
        entries.forEach((entry) => {
          if (!entry.hadRecentInput) {
            console.log('📐 CLS:', entry.value);
          }
        });
      }).observe({entryTypes: ['layout-shift']});
    },

    monitorCustomMetrics() {
      // Time to Interactive approximation
      window.addEventListener('load', () => {
        setTimeout(() => {
          perfMonitor.measure('Time to Interactive (approx)', 'start');
        }, 0);
      });

      // Page load completion
      window.addEventListener('load', () => {
        perfMonitor.measure('Page Load Complete', 'start');
      });
    }
  };

  // ===== INITIALIZATION ===== //

  function initializePerformanceOptimizations() {
    perfMonitor.mark('start');

    // Initialize all performance modules
    loadingManager.init();
    lazyLoader.init();
    smoothScroll.init();
    animationManager.init();
    resourceOptimizer.init();
    performanceMonitor.init();

    perfMonitor.measure('Performance initialization complete', 'start');
  }

  // Start optimization when DOM is ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializePerformanceOptimizations);
  } else {
    initializePerformanceOptimizations();
  }

  // ===== UTILITY FUNCTIONS ===== //

  // Debounce function for performance
  window.debounce = function(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  };

  // Throttle function for scroll events
  window.throttle = function(func, limit) {
    let inThrottle;
    return function() {
      const args = arguments;
      const context = this;
      if (!inThrottle) {
        func.apply(context, args);
        inThrottle = true;
        setTimeout(() => inThrottle = false, limit);
      }
    };
  };

})();