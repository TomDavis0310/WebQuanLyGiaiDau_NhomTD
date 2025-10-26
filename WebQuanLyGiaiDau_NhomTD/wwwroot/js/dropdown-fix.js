// Dropdown Fix for Admin Menu
document.addEventListener('DOMContentLoaded', function() {
    // Xử lý trung chuyển Bootstrap Dropdowns
    initializeDropdowns();
    
    // Bootstrap 5 Dropdown Popper Initialization (thêm animation tùy chỉnh)
    initBootstrapDropdownsWithAnimation();
});

function initializeDropdowns() {
    // Fix for dropdowns not working correctly
    const dropdowns = document.querySelectorAll('.nav-item-enhanced.dropdown');
    
    if (dropdowns.length === 0) {
        return; // No dropdowns found, exit gracefully
    }
    
    dropdowns.forEach(dropdown => {
        const toggleBtn = dropdown.querySelector('.dropdown-toggle');
        const menu = dropdown.querySelector('.dropdown-menu');
        
        if (toggleBtn && menu) {
            // Handle hover event
            dropdown.addEventListener('mouseenter', function() {
                menu.classList.add('show');
            });
            
            dropdown.addEventListener('mouseleave', function() {
                menu.classList.remove('show');
            });
            
            // Handle click event for mobile
            toggleBtn.addEventListener('click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                
                // Toggle the 'show' class
                menu.classList.toggle('show');
            });
            
            // Close when clicking outside
            document.addEventListener('click', function(e) {
                if (!dropdown.contains(e.target)) {
                    menu.classList.remove('show');
                }
            });
        }
    });
}

function initBootstrapDropdownsWithAnimation() {
    // Thêm hiệu ứng mượt mà cho bootstrap dropdowns
    const dropdownToggle = document.querySelectorAll('.dropdown-toggle');
    
    if (typeof bootstrap !== 'undefined' && dropdownToggle.length > 0) {
        try {
            dropdownToggle.forEach(toggle => {
                // Kiểm tra xem dropdown đã được khởi tạo chưa
                if (!toggle.classList.contains('dropdown-initialized')) {
                    const dropdown = new bootstrap.Dropdown(toggle, {
                        // Auto close khi click bên ngoài
                        autoClose: true
                    });
                    // Đánh dấu đã khởi tạo
                    toggle.classList.add('dropdown-initialized');
                }
            });
        } catch (error) {
            console.log("Dropdown initialization error:", error);
        }
    }
}
