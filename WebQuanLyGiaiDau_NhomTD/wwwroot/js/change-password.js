// Change Password Page JavaScript
$(document).ready(function() {
    // Force layout recalculation on page load and viewport changes
    function forceLayoutRecalculation() {
        // Force repaint and reflow
        const container = document.querySelector('.change-password-container');
        if (container) {
            container.style.visibility = 'hidden';
            container.offsetHeight; // Force reflow
            container.style.visibility = '';
        }
        
        // Force Bootstrap grid recalculation
        const rows = document.querySelectorAll('.row');
        rows.forEach(row => {
            row.style.display = 'none';
            row.offsetHeight; // Force reflow
            row.style.display = '';
        });
    }

    // Initial layout fix
    setTimeout(forceLayoutRecalculation, 100);

    // Handle viewport changes (like F12 DevTools toggle)
    let resizeTimer;
    $(window).on('resize', function() {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(function() {
            forceLayoutRecalculation();
        }, 150);
    });

    // Additional viewport change detection
    window.addEventListener('orientationchange', forceLayoutRecalculation);
    
    // MediaQuery listener for responsive breakpoints
    const mediaQuery = window.matchMedia('(max-width: 991.98px)');
    mediaQuery.addListener(forceLayoutRecalculation);

    // Password visibility toggle
    $('.password-toggle').on('click', function() {
        const targetId = $(this).data('target');
        const targetInput = $(`#${targetId}`);
        const icon = $(this).find('i');
        
        if (targetInput.attr('type') === 'password') {
            targetInput.attr('type', 'text');
            icon.removeClass('bi-eye-fill').addClass('bi-eye-slash-fill');
        } else {
            targetInput.attr('type', 'password');
            icon.removeClass('bi-eye-slash-fill').addClass('bi-eye-fill');
        }
    });

    // Password strength checker
    $('#Input_NewPassword').on('input', function() {
        const password = $(this).val();
        const strengthIndicator = $('#passwordStrength');
        const strengthFill = $('#strengthFill');
        const strengthText = $('#strengthText');

        if (password.length === 0) {
            strengthIndicator.removeClass('active');
            return;
        }

        strengthIndicator.addClass('active');
        const strength = calculatePasswordStrength(password);
        
        // Remove all previous classes
        strengthFill.removeClass('weak fair good strong');
        
        switch (strength.level) {
            case 'weak':
                strengthFill.addClass('weak');
                strengthText.text('Yếu - ' + strength.feedback);
                break;
            case 'fair':
                strengthFill.addClass('fair');
                strengthText.text('Trung bình - ' + strength.feedback);
                break;
            case 'good':
                strengthFill.addClass('good');
                strengthText.text('Tốt - ' + strength.feedback);
                break;
            case 'strong':
                strengthFill.addClass('strong');
                strengthText.text('Mạnh - Mật khẩu rất an toàn!');
                break;
        }
    });

    // Password match checker
    function checkPasswordMatch() {
        const newPassword = $('#Input_NewPassword').val();
        const confirmPassword = $('#Input_ConfirmPassword').val();
        const matchIndicator = $('#passwordMatch');

        if (confirmPassword.length === 0) {
            matchIndicator.removeClass('show error');
            return;
        }

        matchIndicator.addClass('show');

        if (newPassword === confirmPassword) {
            matchIndicator.removeClass('error');
            matchIndicator.find('i').removeClass('bi-x-circle-fill').addClass('bi-check-circle-fill');
            matchIndicator.find('span').text('Mật khẩu khớp');
        } else {
            matchIndicator.addClass('error');
            matchIndicator.find('i').removeClass('bi-check-circle-fill').addClass('bi-x-circle-fill');
            matchIndicator.find('span').text('Mật khẩu không khớp');
        }
    }

    $('#Input_ConfirmPassword').on('input', checkPasswordMatch);
    $('#Input_NewPassword').on('input', checkPasswordMatch);

    // Form submission with loading state
    $('#change-password-form').on('submit', function() {
        const submitBtn = $('#updatePasswordBtn');
        submitBtn.addClass('loading');
        submitBtn.prop('disabled', true);
        
        // Re-enable button after 3 seconds (in case of validation errors)
        setTimeout(function() {
            submitBtn.removeClass('loading');
            submitBtn.prop('disabled', false);
        }, 3000);
    });

    // Floating labels enhancement
    $('.form-control-modern').on('focus blur', function() {
        const $this = $(this);
        const $label = $this.siblings('.floating-label');
        
        if ($this.val() !== '' || $this.is(':focus')) {
            $label.addClass('active');
        } else {
            $label.removeClass('active');
        }
    });

    // Initialize floating labels on page load
    $('.form-control-modern').each(function() {
        const $this = $(this);
        const $label = $this.siblings('.floating-label');
        
        if ($this.val() !== '') {
            $label.addClass('active');
        }
    });

    // Handle form validation display
    if ($('.field-error:visible').length > 0) {
        $('#updatePasswordBtn').removeClass('loading').prop('disabled', false);
    }
});

// Password strength calculation function
function calculatePasswordStrength(password) {
    let score = 0;
    let feedback = [];

    // Length check
    if (password.length >= 8) {
        score += 25;
    } else {
        feedback.push('cần ít nhất 8 ký tự');
    }

    // Uppercase check
    if (/[A-Z]/.test(password)) {
        score += 25;
    } else {
        feedback.push('thêm chữ hoa');
    }

    // Lowercase check
    if (/[a-z]/.test(password)) {
        score += 25;
    } else {
        feedback.push('thêm chữ thường');
    }

    // Number check
    if (/\d/.test(password)) {
        score += 12.5;
    } else {
        feedback.push('thêm số');
    }

    // Special character check
    if (/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password)) {
        score += 12.5;
    } else {
        feedback.push('thêm ký tự đặc biệt');
    }

    // Determine strength level
    let level;
    if (score < 25) {
        level = 'weak';
    } else if (score < 50) {
        level = 'fair';
    } else if (score < 75) {
        level = 'good';
    } else {
        level = 'strong';
    }

    return {
        level: level,
        score: score,
        feedback: feedback.length > 0 ? feedback.join(', ') : 'Mật khẩu đạt yêu cầu'
    };
}

// Additional animations and effects
$(window).on('load', function() {
    // Add entrance animation
    $('.change-password-container').addClass('animated fadeInUp');
    
    // Stagger animation for form groups
    $('.form-group-enhanced').each(function(index) {
        $(this).css('animation-delay', (index * 0.1) + 's');
        $(this).addClass('animated fadeInLeft');
    });
});

// Add some CSS animation classes if not already defined
if (!$('style#change-password-animations').length) {
    $('<style id="change-password-animations">').html(`
        .animated {
            animation-duration: 0.6s;
            animation-fill-mode: both;
        }
        
        .fadeInUp {
            animation-name: fadeInUp;
        }
        
        .fadeInLeft {
            animation-name: fadeInLeft;
        }
        
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translate3d(0, 30px, 0);
            }
            to {
                opacity: 1;
                transform: translate3d(0, 0, 0);
            }
        }
        
        @keyframes fadeInLeft {
            from {
                opacity: 0;
                transform: translate3d(-30px, 0, 0);
            }
            to {
                opacity: 1;
                transform: translate3d(0, 0, 0);
            }
        }
    `).appendTo('head');
}

// Enhanced form validation and user experience
function initializeFormEnhancements() {
    // Add focus/blur effects for better UX
    $('.form-control-modern').on('focus', function() {
        $(this).closest('.input-container').addClass('focused');
    }).on('blur', function() {
        $(this).closest('.input-container').removeClass('focused');
    });

    // Add enhanced error handling
    function showEnhancedError(field, message) {
        const $field = $(field);
        const $errorElement = $field.closest('.form-group-enhanced').find('.field-error');
        
        if ($errorElement.length) {
            $errorElement.text(message).fadeIn(300);
            $field.addClass('is-invalid');
        }
    }

    function clearEnhancedError(field) {
        const $field = $(field);
        const $errorElement = $field.closest('.form-group-enhanced').find('.field-error');
        
        if ($errorElement.length) {
            $errorElement.fadeOut(300);
            $field.removeClass('is-invalid').addClass('is-valid');
        }
    }

    // Enhanced form submission
    $('#change-password-form').on('submit', function(e) {
        const $submitBtn = $('#updatePasswordBtn');
        
        // Add loading state
        $submitBtn.addClass('loading').prop('disabled', true);
        
        // Auto-remove loading state after timeout
        setTimeout(function() {
            $submitBtn.removeClass('loading').prop('disabled', false);
        }, 5000);
    });
}

// Initialize enhancements
initializeFormEnhancements();

console.log('Change Password page fully loaded with all enhancements');