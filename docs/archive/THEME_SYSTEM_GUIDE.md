# 🎨 Hệ Thống Dark Mode & Light Mode - Hướng Dẫn Đầy Đủ

## 📋 Tổng Quan

Website đã được nâng cấp với hệ thống theme hiện đại, hỗ trợ **Dark Mode** và **Light Mode** với bộ màu pastel tươi sáng và tương phản tốt.

---

## 🎨 Bảng Màu Pastel

### Light Mode
- **Background:**
  - Primary: `#fef9f3` (Trắng kem)
  - Secondary: `#fff5f0` (Hồng nhạt)
  - Card: `#ffffff` (Trắng tinh)

- **Text:**
  - Primary: `#2d3142` (Xanh đen)
  - Secondary: `#5a6273` (Xám xanh)
  - Tertiary: `#8b93a7` (Xám nhạt)

- **Accent Colors:**
  - Primary: `#ff9a8b` → `#ff8577` (Hồng cam)
  - Secondary: `#a8e6cf` → `#8dd9b8` (Xanh lá)
  - Accent: `#ffd3b6` → `#ffbf9f` (Cam nhạt)
  - Info: `#a8dadc` → `#8fcfd1` (Xanh dương)
  - Success: `#b4f8c8` → `#9cf0b3` (Xanh lục)
  - Warning: `#ffe5b4` → `#ffd99f` (Vàng)
  - Danger: `#ffaaa5` → `#ff9591` (Đỏ)

### Dark Mode
- **Background:**
  - Primary: `#1a1d2e` (Xanh đen đậm)
  - Secondary: `#22263a` (Xanh đen)
  - Card: `#2a2f45` (Xanh xám)

- **Text:**
  - Primary: `#f0f4f8` (Trắng xám)
  - Secondary: `#c5cdd9` (Xám sáng)
  - Tertiary: `#9ea7b8` (Xám)

- **Accent Colors:**
  - Primary: `#ff8577` → `#ff9a8b` (Hồng cam sáng)
  - Secondary: `#7ac9a3` → `#8dd9b8` (Xanh lá sáng)
  - Accent: `#ffbf9f` → `#ffd3b6` (Cam sáng)
  - Info: `#6db8c4` → `#8fcfd1` (Xanh dương sáng)
  - Success: `#85e3a4` → `#9cf0b3` (Xanh lục sáng)

---

## ✨ Tính Năng

### 1. Theme Switcher
- **Nút toggle:** Góc dưới bên phải màn hình
- **Icon:** Mặt trời (Light) / Mặt trăng (Dark)
- **Keyboard shortcut:** `Ctrl + Shift + D`
- **Lưu preference:** localStorage
- **Auto-detect:** System preference

### 2. Tương Phản Tốt
- ✅ Text đọc rõ trong mọi điều kiện
- ✅ Border và shadow phù hợp với từng mode
- ✅ Hover effects rõ ràng
- ✅ Focus states dễ nhận biết

### 3. Smooth Transitions
- Chuyển đổi mượt mà giữa các theme
- Animation tinh tế
- Không gây giật lag

---

## 🛠️ Cấu Trúc File

```
wwwroot/
├── css/
│   ├── theme.css             ← Hệ thống theme chính (CSS Variables)
│   ├── site.css              ← Style chung, cập nhật với theme
│   ├── sports-theme.css      ← Sports styling, tương thích theme
│   ├── sidebar.css           ← Sidebar styling với theme
│   └── youtube-integration.css ← YouTube styling với theme
└── js/
    └── theme-switcher.js     ← Logic chuyển đổi theme
```

---

## 📝 Cách Sử Dụng CSS Variables

### Trong file CSS mới:

```css
/* Sử dụng theme variables */
.your-element {
    background: var(--card-bg);
    color: var(--text-primary);
    border: 1px solid var(--border-color);
    box-shadow: var(--shadow-md);
}

.your-element:hover {
    background: var(--bg-hover);
    color: var(--color-primary);
}
```

### Variables Chính:

#### Background
- `--bg-primary` - Background chính
- `--bg-secondary` - Background phụ
- `--bg-tertiary` - Background thứ ba
- `--card-bg` - Background card
- `--bg-hover` - Hover background

#### Text
- `--text-primary` - Text chính
- `--text-secondary` - Text phụ
- `--text-tertiary` - Text muted
- `--text-inverse` - Text trên background tối

#### Colors
- `--color-primary` - Màu chính (hồng cam)
- `--color-secondary` - Màu phụ (xanh lá)
- `--color-accent` - Màu accent (cam)
- `--color-info` - Thông tin (xanh dương)
- `--color-success` - Thành công (xanh lục)
- `--color-warning` - Cảnh báo (vàng)
- `--color-danger` - Nguy hiểm (đỏ)

#### Borders & Shadows
- `--border-color` - Border chính
- `--border-light` - Border nhạt
- `--shadow-sm` - Shadow nhỏ
- `--shadow-md` - Shadow trung bình
- `--shadow-lg` - Shadow lớn
- `--shadow-hover` - Shadow khi hover

#### Gradients
- `--gradient-primary` - Gradient chính
- `--gradient-secondary` - Gradient phụ
- `--gradient-accent` - Gradient accent
- `--gradient-cool` - Gradient mát
- `--gradient-warm` - Gradient ấm

---

## 🎯 Best Practices

### 1. Luôn sử dụng CSS Variables
```css
/* ✅ ĐÚNG */
.element {
    background: var(--card-bg);
    color: var(--text-primary);
}

/* ❌ SAI */
.element {
    background: white;
    color: black;
}
```

### 2. Thêm Transitions
```css
.element {
    background: var(--card-bg);
    color: var(--text-primary);
    transition: background-color 0.3s ease, color 0.3s ease;
}
```

### 3. Test cả 2 modes
- Luôn test trên Dark Mode
- Kiểm tra tương phản text
- Xác nhận hover effects
- Đảm bảo readability

### 4. Sử dụng Semantic Variables
```css
/* ✅ Semantic */
.card {
    background: var(--card-bg);
    border: 1px solid var(--card-border);
}

/* ❌ Hard-coded */
.card {
    background: #ffffff;
    border: 1px solid #eeeeee;
}
```

---

## 🔧 Customization

### Thêm màu mới:

Thêm vào `theme.css` trong cả 2 blocks `:root` và `[data-theme="dark"]`:

```css
:root {
    --your-custom-color: #yourcolor;
}

[data-theme="dark"] {
    --your-custom-color: #darkversion;
}
```

### Override cho component cụ thể:

```css
.special-component {
    --card-bg: var(--color-secondary);
    --text-primary: var(--text-inverse);
}
```

---

## 📱 Responsive Design

Theme system tự động responsive:

```css
@media (max-width: 768px) {
    .theme-toggle {
        width: 50px;
        height: 50px;
        bottom: 20px;
        right: 20px;
    }
}
```

---

## 🐛 Troubleshooting

### Theme không chuyển?
1. Kiểm tra console log
2. Xóa localStorage: `localStorage.clear()`
3. Hard refresh: `Ctrl + F5`

### Màu không đúng?
1. Kiểm tra CSS load order
2. `theme.css` phải load TRƯỚC các file khác
3. Xác nhận variable name đúng

### Transition lag?
1. Giảm số elements transition
2. Sử dụng `will-change` property
3. Optimize transitions

---

## 📊 Performance

- **CSS Variables:** Instant theme switching
- **LocalStorage:** Persist user preference
- **No Flash:** Theme applied before render
- **Optimized:** Minimal JavaScript

---

## 🎉 Features Ready

✅ Dark Mode / Light Mode toggle  
✅ Bộ màu pastel tươi sáng  
✅ Tương phản tốt  
✅ Smooth transitions  
✅ Keyboard shortcuts  
✅ Auto-detect system theme  
✅ LocalStorage persistence  
✅ Fully responsive  
✅ Backward compatible  
✅ Accessible (WCAG)  

---

## 📞 Support

Nếu gặp vấn đề:
1. Kiểm tra console errors
2. Verify CSS load order
3. Test với clean localStorage
4. Check browser compatibility

---

## 🚀 Next Steps

1. Test toàn bộ website
2. Kiểm tra tất cả pages
3. Verify responsive
4. Thu thập feedback
5. Fine-tune colors nếu cần

---

**Tận hưởng hệ thống theme mới! 🎨✨**
