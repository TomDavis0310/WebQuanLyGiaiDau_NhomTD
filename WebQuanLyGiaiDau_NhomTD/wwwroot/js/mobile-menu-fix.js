// Mobile Menu Enhancement
document.addEventListener('DOMContentLoaded', function() {
    initMobileMenu();
    
    // Re-initialize on window resize
    window.addEventListener('resize', debounce(function() {
        initMobileMenu();
    }, 250));
});

function initMobileMenu() {
    const isMobile = window.innerWidth < 992;
    const navbarToggler = document.querySelector('.navbar-toggler');
    const mobileDropdowns = document.querySelectorAll('.dropdown-toggle');
    
    if (isMobile && navbarToggler) {
        // Handle mobile navbar toggle animation
        navbarToggler.addEventListener('click', function() {
            this.classList.toggle('active');
        });
        
        // Handle mobile dropdown arrow icons
        mobileDropdowns.forEach(dropdown => {
            if (!dropdown.querySelector('.mobile-arrow')) {
                const arrowIcon = document.createElement('i');
                arrowIcon.className = 'bi bi-chevron-down ms-2 mobile-arrow';
                dropdown.appendChild(arrowIcon);
            }
            
            // Toggle arrow direction on click in mobile
            dropdown.addEventListener('click', function() {
                const arrow = this.querySelector('.mobile-arrow');
                if (arrow) {
                    if (this.getAttribute('aria-expanded') === 'true') {
                        arrow.classList.replace('bi-chevron-down', 'bi-chevron-up');
                    } else {
                        arrow.classList.replace('bi-chevron-up', 'bi-chevron-down');
                    }
                }
            });
        });
        
        // Close navbar collapse when clicking a nav-link (except dropdowns)
        const navLinks = document.querySelectorAll('.navbar-nav .nav-link:not(.dropdown-toggle)');
        navLinks.forEach(link => {
            link.addEventListener('click', function() {
                const navbarCollapse = document.querySelector('.navbar-collapse');
                if (navbarCollapse && navbarCollapse.classList.contains('show')) {
                    navbarToggler.click(); // Close the navbar
                }
            });
        });
    }
}

// Helper function - debounce for performance
function debounce(func, wait) {
    let timeout;
    return function() {
        const context = this, args = arguments;
        clearTimeout(timeout);
        timeout = setTimeout(function() {
            func.apply(context, args);
        }, wait);
    };
}
