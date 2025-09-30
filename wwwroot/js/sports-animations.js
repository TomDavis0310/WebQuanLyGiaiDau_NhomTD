// Sports 24/7 Dynamic Animations JavaScript

document.addEventListener('DOMContentLoaded', function() {
    // Initialize all animations
    initSportsAnimations();
    initCounterAnimations();
    initScrollAnimations();
    initNavbarEffects();
    initTypingEffect();
    // Removed particle effects for static background
    // initParticleEffects();
});

// Main sports animations initialization
function initSportsAnimations() {
    // Add entrance animations to elements
    const animatedElements = document.querySelectorAll('.dynamic-entrance');
    animatedElements.forEach((element, index) => {
        element.style.animationDelay = `${index * 0.2}s`;
    });

    // Energy button hover effects - simplified
    const energyButtons = document.querySelectorAll('.energy-button');
    energyButtons.forEach(button => {
        // Remove any existing animations
        button.style.animation = 'none';
    });

    // Champion card effects
    const championCards = document.querySelectorAll('.champion-card');
    championCards.forEach(card => {
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-10px) scale(1.02)';
            this.style.boxShadow = '0 20px 40px rgba(255, 107, 53, 0.3)';
        });

        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0) scale(1)';
            this.style.boxShadow = '';
        });
    });
}

// Animated counter for statistics
function initCounterAnimations() {
    // Only target elements with data-count attribute
    const counters = document.querySelectorAll('.stat-number[data-count]');

    const observerOptions = {
        threshold: 0.5,
        rootMargin: '0px 0px -100px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                animateCounter(entry.target);
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    counters.forEach(counter => {
        observer.observe(counter);
    });
}

function animateCounter(element) {
    const dataCount = element.getAttribute('data-count');
    if (!dataCount) {
        // If no data-count attribute, don't animate
        return;
    }

    const target = parseInt(dataCount);
    if (isNaN(target)) {
        // If data-count is not a valid number, don't animate
        return;
    }

    const duration = 2000; // 2 seconds
    const step = target / (duration / 16); // 60fps
    let current = 0;

    const timer = setInterval(() => {
        current += step;
        if (current >= target) {
            current = target;
            clearInterval(timer);
        }
        element.textContent = Math.floor(current).toLocaleString();
    }, 16);
}

// Scroll-triggered animations
function initScrollAnimations() {
    const animatedElements = document.querySelectorAll('.animate-fade-in-up, .animate-slide-up, .animate-bounce-in');

    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const delay = entry.target.getAttribute('data-delay') || 0;
                setTimeout(() => {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                }, delay * 1000);
                observer.unobserve(entry.target);
            }
        });
    }, observerOptions);

    animatedElements.forEach(element => {
        element.style.opacity = '0';
        element.style.transform = 'translateY(30px)';
        element.style.transition = 'all 0.8s cubic-bezier(0.25, 0.46, 0.45, 0.94)';
        observer.observe(element);
    });
}

// Enhanced Navbar scroll effects
function initNavbarEffects() {
    const navbar = document.getElementById('mainNavbar');
    if (!navbar) return;

    // Smooth scroll effect
    let lastScrollTop = 0;
    window.addEventListener('scroll', throttle(() => {
        const scrollTop = window.pageYOffset || document.documentElement.scrollTop;

        if (scrollTop > 100) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }

        // Hide/show navbar on scroll
        if (scrollTop > lastScrollTop && scrollTop > 200) {
            navbar.style.transform = 'translateY(-100%)';
        } else {
            navbar.style.transform = 'translateY(0)';
        }
        lastScrollTop = scrollTop;
    }, 10));

    // Active nav item highlighting with smooth transitions
    const navItems = document.querySelectorAll('.nav-item-enhanced');
    const currentPath = window.location.pathname;

    navItems.forEach(item => {
        const link = item.querySelector('.nav-link');
        if (link) {
            const linkPath = new URL(link.href).pathname;
            if (linkPath === currentPath) {
                item.classList.add('active');
            }

            // Add click animation
            link.addEventListener('click', function(e) {
                // Create ripple effect
                const ripple = document.createElement('span');
                ripple.className = 'nav-ripple';
                this.appendChild(ripple);

                const rect = this.getBoundingClientRect();
                const size = Math.max(rect.width, rect.height);
                ripple.style.width = ripple.style.height = size + 'px';
                ripple.style.left = (e.clientX - rect.left - size / 2) + 'px';
                ripple.style.top = (e.clientY - rect.top - size / 2) + 'px';

                setTimeout(() => {
                    ripple.remove();
                }, 600);
            });
        }
    });

    // Navbar brand animation
    const navbarBrand = document.querySelector('.navbar-brand');
    if (navbarBrand) {
        navbarBrand.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-3px) scale(1.05)';
        });

        navbarBrand.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0) scale(1)';
        });
    }

    // Mobile menu animation
    const navbarToggler = document.querySelector('.navbar-toggler');
    const navbarCollapse = document.querySelector('.navbar-collapse');

    if (navbarToggler && navbarCollapse) {
        navbarToggler.addEventListener('click', function() {
            this.classList.toggle('active');
        });
    }
}

// Typing effect for hero title - Disabled to prevent conflicts
function initTypingEffect() {
    // Disabled - handled in individual pages
    return;
}

// Particle effects for hero section
// Particle effects have been disabled for static background
function initParticleEffects() {
    // Function disabled to remove animated background
    return;
}

// Particle creation has been disabled
function createParticle(container) {
    // Function disabled to remove animated background
    return;
}

// Smooth scrolling for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Add CSS for navbar effects only (removed floating particles)
const style = document.createElement('style');
style.textContent = `
    .typing-cursor {
        animation: blink 1s infinite;
        color: var(--primary-color);
    }

    @keyframes blink {
        0%, 50% { opacity: 1; }
        51%, 100% { opacity: 0; }
    }

    .sports-wave {
        position: relative;
        overflow: hidden;
    }

    .sports-wave::before {
        content: '';
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.2), transparent);
    }

    /* Enhanced Navbar Animations */
    .sports-nav-enhanced {
        transition: all 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
    }

    .nav-ripple {
        position: absolute;
        border-radius: 50%;
        background: rgba(255, 255, 255, 0.3);
        transform: scale(0);
        animation: ripple 0.6s linear;
        pointer-events: none;
    }

    @keyframes ripple {
        to {
            transform: scale(2);
            opacity: 0;
        }
    }

    .navbar-toggler.active {
        transform: rotate(90deg);
    }

    .navbar-toggler.active .navbar-toggler-icon {
        background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 30 30'%3e%3cpath stroke='rgba%28255, 255, 255, 0.8%29' stroke-linecap='round' stroke-miterlimit='10' stroke-width='2' d='M6 18L18 6M6 6l12 12'/%3e%3c/svg%3e");
    }

    /* Smooth navbar hide/show */
    .sports-nav-enhanced {
        transition: transform 0.3s ease-in-out;
    }

    /* Simplified dropdown - no complex animations */
    .dropdown-menu {
        opacity: 1 !important;
        transform: none !important;
        pointer-events: auto !important;
    }

    .dropdown-item {
        opacity: 1 !important;
        transform: none !important;
    }
`;
document.head.appendChild(style);

// Performance optimization: Throttle scroll events
function throttle(func, limit) {
    let inThrottle;
    return function() {
        const args = arguments;
        const context = this;
        if (!inThrottle) {
            func.apply(context, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    }
}

// Apply throttling to scroll events
window.addEventListener('scroll', throttle(() => {
    // Scroll-based animations can be added here
}, 16)); // ~60fps
