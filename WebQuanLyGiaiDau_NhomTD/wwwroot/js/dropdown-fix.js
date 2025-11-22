// Dropdown Fix for Admin Menu and Profile
document.addEventListener('DOMContentLoaded', function() {
    // Đợi một chút để Bootstrap khởi tạo xong
    setTimeout(function() {
        // Bootstrap 5 Dropdown Initialization
        initBootstrapDropdowns();
    }, 100);
});

function initBootstrapDropdowns() {
    // Khởi tạo tất cả các dropdown bằng Bootstrap 5
    const dropdownElementList = document.querySelectorAll('[data-bs-toggle="dropdown"]');
    
    if (typeof bootstrap === 'undefined') {
        console.error('Bootstrap is not loaded!');
        return;
    }
    
    if (dropdownElementList.length === 0) {
        console.log('No dropdowns found');
        return;
    }
    
    try {
        dropdownElementList.forEach(function(dropdownToggleEl) {
            // Kiểm tra xem đã được khởi tạo chưa
            if (!dropdownToggleEl.classList.contains('dropdown-initialized')) {
                // Khởi tạo dropdown
                const dropdown = new bootstrap.Dropdown(dropdownToggleEl, {
                    autoClose: true,
                    boundary: 'viewport',
                    popperConfig: null
                });
                
                // Đánh dấu đã khởi tạo
                dropdownToggleEl.classList.add('dropdown-initialized');
                
                // Log để debug
                console.log('Initialized dropdown:', dropdownToggleEl.id || dropdownToggleEl.className);
                
                // Thêm event listener để debug
                dropdownToggleEl.addEventListener('click', function(e) {
                    console.log('Dropdown clicked:', this.id || this.className);
                    // Không preventDefault ở đây, để Bootstrap xử lý
                });
                
                // Listen to show event
                dropdownToggleEl.addEventListener('show.bs.dropdown', function () {
                    console.log('Dropdown showing');
                });
                
                // Listen to shown event
                dropdownToggleEl.addEventListener('shown.bs.dropdown', function () {
                    console.log('Dropdown shown');
                });
            }
        });
        
        console.log('All dropdowns initialized successfully');
    } catch (error) {
        console.error('Error initializing dropdowns:', error);
    }
}
