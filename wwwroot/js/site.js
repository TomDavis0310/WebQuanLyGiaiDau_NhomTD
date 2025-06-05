// Modern Sports Tournament Management System - Enhanced JavaScript
// Professional UI interactions, animations, and user experience enhancements

$(document).ready(function() {
    // Initialize all components
    initializeApp();
    
    // Initialize scrollable navbar
    initializeScrollableNavbar();
    
    // Fix for user profile dropdown
    fixUserProfileDropdown();
});

// Fix user profile dropdown issues
function fixUserProfileDropdown() {
    // Ensure Bootstrap dropdown is properly initialized
    var userDropdown = document.getElementById('userDropdown');
    if (userDropdown) {
        var dropdownInstance = new bootstrap.Dropdown(userDropdown);
        
        // Add click handler to ensure dropdown works properly
        $(userDropdown).on('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            dropdownInstance.toggle();
        });
    }
    
    // Also fix any .user-profile-dropdown elements that might not have proper ID
    $('.user-profile-dropdown').each(function() {
        var $this = $(this);
        var dropdownInstance = new bootstrap.Dropdown($this[0]);
        
        // Add click handler to ensure dropdown works properly
        $this.on('click', function(e) {
            e.preventDefault();
            e.stopPropagation();
            dropdownInstance.toggle();
        });
    });
}

// Initialize horizontal scrolling for navbar with many items
function initializeScrollableNavbar() {
    const navbarNav = document.querySelector('.navbar-nav.me-auto');
    
    if (navbarNav) {
        // Add scroll hint indicators
        const scrollContainer = document.createElement('div');
        scrollContainer.className = 'navbar-scroll-container';
        navbarNav.parentNode.insertBefore(scrollContainer, navbarNav);
        scrollContainer.appendChild(navbarNav);
        
        // Check if scrolling is needed
        const checkScroll = () => {
            if (navbarNav.scrollWidth > navbarNav.clientWidth) {
                scrollContainer.classList.add('has-overflow');
            } else {
                scrollContainer.classList.remove('has-overflow');
            }
        };
        
        // Initialize and listen for window resize
        checkScroll();
        window.addEventListener('resize', checkScroll);
        
        // Add scroll buttons for mobile
        if (window.innerWidth < 1200) {
            // Add scroll buttons implementation if needed
        }
    }
}

function initializeApp() {
    // Core functionality
    initializeDescriptions();
    initializeAnimations();
    initializeNavbar();
    initializeButtons();
    initializeForms();
    initializeTables();
    initializeCards();
    initializeModals();
    initializeTooltips();
    initializeLoadingStates();

    // Re-initialize when content is loaded via AJAX
    $(document).on('ajaxComplete', function() {
        initializeDescriptions();
        initializeAnimations();
        initializeButtons();
    });
}

// ===== DESCRIPTION TOGGLE FUNCTIONALITY =====
function initializeDescriptions() {
    $('.tournament-description').each(function() {
        const description = $(this);
        const fullText = description.text();

        if (fullText.length > 150) {
            const truncatedText = fullText.substring(0, 150) + '...';
            const truncatedElement = $('<span class="truncated-text">' + truncatedText + '</span>');
            const fullElement = $('<span class="full-text" style="display: none;">' + fullText + '</span>');
            const toggleButton = $('<button class="btn btn-sm btn-link text-primary p-0 ms-1 toggle-description">Xem thêm</button>');

            description.empty().append(truncatedElement).append(fullElement).append(toggleButton);

            toggleButton.on('click', function(e) {
                e.preventDefault();
                const button = $(this);
                const truncated = description.find('.truncated-text');
                const full = description.find('.full-text');

                if (truncated.is(':visible')) {
                    truncated.fadeOut(200, function() {
                        full.fadeIn(200);
                        button.text('Thu gọn');
                    });
                } else {
                    full.fadeOut(200, function() {
                        truncated.fadeIn(200);
                        button.text('Xem thêm');
                    });
                }
            });
        }
    });
}

// ===== SCROLL ANIMATIONS =====
function initializeAnimations() {
    // Intersection Observer for scroll animations
    const observerOptions = {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
    };

    const observer = new IntersectionObserver(function(entries) {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const element = entry.target;

                // Add animation classes based on data attributes
                if (element.dataset.animation) {
                    element.classList.add(element.dataset.animation);
                } else {
                    element.classList.add('animate-fade-in-up');
                }

                // Add stagger delay if specified
                if (element.dataset.delay) {
                    element.style.animationDelay = element.dataset.delay + 's';
                }

                observer.unobserve(element);
            }
        });
    }, observerOptions);

    // Observe elements with animation classes
    document.querySelectorAll('.sports-card, .stats-card, .team-card, .feature-card, .news-card').forEach(el => {
        observer.observe(el);
    });
}

// ===== NAVBAR ENHANCEMENTS =====
function initializeNavbar() {
    const navbar = $('.sports-navbar');
    let lastScrollTop = 0;

    $(window).scroll(function() {
        const scrollTop = $(this).scrollTop();

        // Add scrolled class for styling
        if (scrollTop > 50) {
            navbar.addClass('scrolled');
        } else {
            navbar.removeClass('scrolled');
        }

        // Hide/show navbar on scroll (optional)
        if (scrollTop > lastScrollTop && scrollTop > 100) {
            navbar.addClass('navbar-hidden');
        } else {
            navbar.removeClass('navbar-hidden');
        }

        lastScrollTop = scrollTop;
    });

    // Smooth scroll for anchor links
    $('a[href^="#"]').on('click', function(e) {
        e.preventDefault();
        const target = $(this.getAttribute('href'));
        if (target.length) {
            $('html, body').animate({
                scrollTop: target.offset().top - 80
            }, 800, 'easeInOutCubic');
        }
    });
}

// ===== BUTTON ENHANCEMENTS =====
function initializeButtons() {
    // Add ripple effect to buttons
    $('.btn-sports-primary, .btn-sports-secondary, .btn-sports-outline, .btn-sports-accent').on('click', function(e) {
        const button = $(this);
        const ripple = $('<span class="ripple"></span>');

        const rect = this.getBoundingClientRect();
        const size = Math.max(rect.width, rect.height);
        const x = e.clientX - rect.left - size / 2;
        const y = e.clientY - rect.top - size / 2;

        ripple.css({
            width: size,
            height: size,
            left: x,
            top: y,
            position: 'absolute',
            borderRadius: '50%',
            background: 'rgba(255, 255, 255, 0.3)',
            transform: 'scale(0)',
            animation: 'ripple 0.6s linear',
            pointerEvents: 'none'
        });

        button.css('position', 'relative').css('overflow', 'hidden').append(ripple);

        setTimeout(() => ripple.remove(), 600);
    });

    // Loading state for form submissions
    $('form').on('submit', function() {
        const submitBtn = $(this).find('button[type="submit"]');
        if (submitBtn.length) {
            submitBtn.addClass('btn-loading').prop('disabled', true);

            // Re-enable after 5 seconds as fallback
            setTimeout(() => {
                submitBtn.removeClass('btn-loading').prop('disabled', false);
            }, 5000);
        }
    });
}

// ===== FORM ENHANCEMENTS =====
function initializeForms() {
    // Real-time validation feedback
    $('.form-control').on('input blur', function() {
        const input = $(this);
        const value = input.val().trim();

        // Remove existing validation classes
        input.removeClass('is-valid is-invalid');

        // Basic validation
        if (input.attr('required') && value === '') {
            input.addClass('is-invalid');
        } else if (value !== '') {
            // Email validation
            if (input.attr('type') === 'email') {
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (emailRegex.test(value)) {
                    input.addClass('is-valid');
                } else {
                    input.addClass('is-invalid');
                }
            } else {
                input.addClass('is-valid');
            }
        }
    });

    // Floating labels effect
    $('.form-floating .form-control').on('focus blur', function() {
        const input = $(this);
        const label = input.siblings('label');

        if (input.is(':focus') || input.val() !== '') {
            label.addClass('active');
        } else {
            label.removeClass('active');
        }
    });
}

// ===== TABLE ENHANCEMENTS =====
function initializeTables() {
    // Enhanced table row hover effects
    $('.table tbody tr').hover(
        function() {
            $(this).addClass('table-row-hover');
        },
        function() {
            $(this).removeClass('table-row-hover');
        }
    );

    // Sortable table headers (if needed)
    $('.table th[data-sortable]').on('click', function() {
        const header = $(this);
        const table = header.closest('table');
        const index = header.index();
        const isAsc = header.hasClass('sort-asc');

        // Remove sort classes from all headers
        table.find('th').removeClass('sort-asc sort-desc');

        // Add appropriate sort class
        if (isAsc) {
            header.addClass('sort-desc');
        } else {
            header.addClass('sort-asc');
        }

        // Trigger custom sort event
        table.trigger('sort', [index, !isAsc]);
    });
}

// ===== CARD ENHANCEMENTS =====
function initializeCards() {
    // Parallax effect for card images
    $('.sports-card').on('mousemove', function(e) {
        const card = $(this);
        const rect = this.getBoundingClientRect();
        const x = e.clientX - rect.left;
        const y = e.clientY - rect.top;

        const centerX = rect.width / 2;
        const centerY = rect.height / 2;

        const rotateX = (y - centerY) / 10;
        const rotateY = (centerX - x) / 10;

        card.css('transform', `perspective(1000px) rotateX(${rotateX}deg) rotateY(${rotateY}deg) scale3d(1.02, 1.02, 1.02)`);
    });

    $('.sports-card').on('mouseleave', function() {
        $(this).css('transform', '');
    });
}

// ===== MODAL ENHANCEMENTS =====
function initializeModals() {
    // Enhanced modal animations
    $('.modal').on('show.bs.modal', function() {
        $(this).find('.modal-dialog').addClass('animate-scale-in');
    });

    $('.modal').on('hide.bs.modal', function() {
        $(this).find('.modal-dialog').removeClass('animate-scale-in');
    });
}

// ===== TOOLTIP INITIALIZATION =====
function initializeTooltips() {
    // Initialize Bootstrap tooltips
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function(tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
}

// ===== LOADING STATES =====
function initializeLoadingStates() {
    // Show loading spinner for AJAX requests
    $(document).ajaxStart(function() {
        $('.loading-overlay').fadeIn(200);
    });

    $(document).ajaxStop(function() {
        $('.loading-overlay').fadeOut(200);
    });

    // Add loaded class to body on window load
    $(window).on('load', function() {
        $('body').addClass('loaded');
    });
}

// ===== UTILITY FUNCTIONS =====

// Smooth scroll to element
function scrollToElement(element, offset = 80) {
    const target = $(element);
    if (target.length) {
        $('html, body').animate({
            scrollTop: target.offset().top - offset
        }, 800);
    }
}

// Show notification
function showNotification(message, type = 'info', duration = 3000) {
    const notification = $(`
        <div class="notification notification-${type} animate-slide-in-down">
            <div class="notification-content">
                <i class="bi bi-info-circle me-2"></i>
                <span>${message}</span>
                <button class="btn-close" aria-label="Close"></button>
            </div>
        </div>
    `);

    $('body').append(notification);

    // Auto remove
    setTimeout(() => {
        notification.addClass('animate-fade-out');
        setTimeout(() => notification.remove(), 300);
    }, duration);

    // Manual close
    notification.find('.btn-close').on('click', function() {
        notification.addClass('animate-fade-out');
        setTimeout(() => notification.remove(), 300);
    });
}

// Add CSS for ripple effect and notifications
const additionalCSS = `
    <style>
        @keyframes ripple {
            to {
                transform: scale(4);
                opacity: 0;
            }
        }

        .navbar-hidden {
            transform: translateY(-100%);
        }

        .table-row-hover {
            background-color: var(--bg-tertiary) !important;
            transform: scale(1.01);
        }

        .notification {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 9999;
            background: white;
            border-radius: 8px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            padding: 16px;
            max-width: 400px;
        }

        .notification-success { border-left: 4px solid var(--success-color); }
        .notification-error { border-left: 4px solid var(--danger-color); }
        .notification-warning { border-left: 4px solid var(--warning-color); }
        .notification-info { border-left: 4px solid var(--info-color); }

        .notification-content {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .animate-fade-out {
            animation: fadeOut 0.3s ease forwards;
        }

        @keyframes fadeOut {
            to { opacity: 0; transform: translateX(100%); }
        }

        .loading-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 9998;
            display: none;
            align-items: center;
            justify-content: center;
        }
    </style>
`;

$('head').append(additionalCSS);
