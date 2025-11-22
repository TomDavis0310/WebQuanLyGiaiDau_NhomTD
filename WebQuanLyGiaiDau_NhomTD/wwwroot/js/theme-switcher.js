// ========================================
// Theme Switcher JavaScript
// Dark Mode & Light Mode Toggle
// ========================================

(function() {
    'use strict';

    // Theme Management
    const ThemeManager = {
        STORAGE_KEY: 'user-theme-preference',
        THEME_ATTR: 'data-theme',
        THEMES: {
            LIGHT: 'light',
            DARK: 'dark'
        },

        // Initialize theme on page load
        init: function() {
            this.applyTheme(this.getSavedTheme());
            this.attachEventListeners();
            this.initializeToggleButton();
        },

        // Get saved theme from localStorage or system preference
        getSavedTheme: function() {
            const savedTheme = localStorage.getItem(this.STORAGE_KEY);
            
            if (savedTheme) {
                return savedTheme;
            }

            // Check system preference
            if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
                return this.THEMES.DARK;
            }

            return this.THEMES.LIGHT;
        },

        // Apply theme to document
        applyTheme: function(theme) {
            document.documentElement.setAttribute(this.THEME_ATTR, theme);
            localStorage.setItem(this.STORAGE_KEY, theme);
            this.updateToggleButton(theme);
            
            // Dispatch custom event for other scripts
            document.dispatchEvent(new CustomEvent('themeChanged', { detail: { theme } }));
        },

        // Toggle between themes
        toggleTheme: function() {
            const currentTheme = document.documentElement.getAttribute(this.THEME_ATTR);
            const newTheme = currentTheme === this.THEMES.LIGHT ? this.THEMES.DARK : this.THEMES.LIGHT;
            
            this.applyTheme(newTheme);
            this.animateToggle();
        },

        // Initialize toggle button
        initializeToggleButton: function() {
            const currentTheme = this.getSavedTheme();
            this.updateToggleButton(currentTheme);
        },

        // Update toggle button appearance
        updateToggleButton: function(theme) {
            const toggleBtn = document.querySelector('.theme-toggle');
            if (!toggleBtn) return;

            const sunIcon = toggleBtn.querySelector('.bi-sun-fill');
            const moonIcon = toggleBtn.querySelector('.bi-moon-stars-fill');

            if (theme === this.THEMES.DARK) {
                if (sunIcon) sunIcon.style.display = 'block';
                if (moonIcon) moonIcon.style.display = 'none';
            } else {
                if (sunIcon) sunIcon.style.display = 'none';
                if (moonIcon) moonIcon.style.display = 'block';
            }
        },

        // Animate toggle button
        animateToggle: function() {
            const toggleBtn = document.querySelector('.theme-toggle');
            if (!toggleBtn) return;

            toggleBtn.style.transform = 'scale(0.9) rotate(180deg)';
            
            setTimeout(() => {
                toggleBtn.style.transform = 'scale(1) rotate(0deg)';
            }, 300);
        },

        // Attach event listeners
        attachEventListeners: function() {
            // Toggle button click
            document.addEventListener('click', (e) => {
                if (e.target.closest('.theme-toggle')) {
                    this.toggleTheme();
                }
            });

            // Listen for system theme changes
            if (window.matchMedia) {
                window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
                    // Only apply if user hasn't manually set a preference
                    if (!localStorage.getItem(this.STORAGE_KEY)) {
                        this.applyTheme(e.matches ? this.THEMES.DARK : this.THEMES.LIGHT);
                    }
                });
            }

            // Keyboard shortcut (Ctrl/Cmd + Shift + D)
            document.addEventListener('keydown', (e) => {
                if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'D') {
                    e.preventDefault();
                    this.toggleTheme();
                }
            });
        }
    };

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => ThemeManager.init());
    } else {
        ThemeManager.init();
    }

    // Expose ThemeManager globally
    window.ThemeManager = ThemeManager;

})();

// ========================================
// Theme-aware components
// ========================================

// Update charts/graphs colors when theme changes
document.addEventListener('themeChanged', function(e) {
    const theme = e.detail.theme;
    console.log('Theme changed to:', theme);
    
    // You can add custom logic here for updating charts, graphs, etc.
    // Example:
    // if (window.updateChartColors) {
    //     window.updateChartColors(theme);
    // }
});

// Smooth transition for theme change
document.addEventListener('DOMContentLoaded', function() {
    // Add transition class after initial load
    setTimeout(() => {
        document.body.classList.add('theme-transition-enabled');
    }, 100);
});
