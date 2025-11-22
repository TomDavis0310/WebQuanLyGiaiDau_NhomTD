// Sidebar Toggle Functionality
document.addEventListener('DOMContentLoaded', function () {
    const sidebarWrapper = document.querySelector('.sidebar-wrapper');
    const sidebarToggle = document.getElementById('sidebarToggle');
    const mainWrapper = document.querySelector('.main-wrapper');

    // Check if elements exist
    if (!sidebarToggle || !sidebarWrapper) {
        console.warn('Sidebar elements not found');
        return;
    }

    // Load sidebar state from localStorage
    const sidebarState = localStorage.getItem('sidebarCollapsed');
    if (sidebarState === 'true') {
        sidebarWrapper.classList.add('collapsed');
    }

    // Toggle sidebar on button click
    sidebarToggle.addEventListener('click', function () {
        sidebarWrapper.classList.toggle('collapsed');
        
        // Save state to localStorage
        const isCollapsed = sidebarWrapper.classList.contains('collapsed');
        localStorage.setItem('sidebarCollapsed', isCollapsed);
    });

    // For mobile: toggle with active class
    if (window.innerWidth <= 768) {
        sidebarToggle.addEventListener('click', function (e) {
            e.stopPropagation();
            sidebarWrapper.classList.toggle('active');
        });

        // Close sidebar when clicking outside on mobile
        document.addEventListener('click', function (e) {
            if (window.innerWidth <= 768) {
                // Không đóng sidebar nếu click vào dropdown
                const isDropdownClick = e.target.closest('.dropdown, .dropdown-menu, .dropdown-toggle');
                if (!isDropdownClick && !sidebarWrapper.contains(e.target) && !sidebarToggle.contains(e.target)) {
                    sidebarWrapper.classList.remove('active');
                }
            }
        });

        // Close sidebar when clicking a link on mobile
        const navLinks = document.querySelectorAll('.sidebar-nav .nav-link');
        navLinks.forEach(link => {
            link.addEventListener('click', function () {
                if (window.innerWidth <= 768) {
                    sidebarWrapper.classList.remove('active');
                }
            });
        });
    }

    // Active menu item highlighting
    const currentPath = window.location.pathname;
    const navLinks = document.querySelectorAll('.sidebar-nav .nav-link');
    
    navLinks.forEach(link => {
        const linkPath = link.getAttribute('href');
        if (linkPath && currentPath.includes(linkPath) && linkPath !== '/') {
            link.classList.add('active');
        } else if (linkPath === '/' && currentPath === '/') {
            link.classList.add('active');
        }
    });

    // Handle window resize
    let resizeTimer;
    window.addEventListener('resize', function () {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function () {
            if (window.innerWidth > 768) {
                // Remove mobile-specific class on desktop
                sidebarWrapper.classList.remove('active');
            }
        }, 250);
    });
});
