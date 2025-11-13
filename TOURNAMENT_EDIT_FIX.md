# 🔧 Sửa Lỗi Khi Lưu Thay Đổi Giải Đấu

## 📋 Tóm tắt
Đã khắc phục lỗi xảy ra khi nhấn nút "Lưu Thay Đổi" sau khi chỉnh sửa thông tin giải đấu.

## 🐛 Vấn đề
Khi người dùng nhấn nút lưu sau khi thay đổi nội dung ở giải đấu, gặp lỗi:
```
An error occurred while processing your request.
Request ID: 0HNH2N58O167F:00000002
```

**Lỗi xảy ra do:**
- ModelState validation fail với các navigation properties (Sports, TournamentFormat)
- ViewBag không được thiết lập khi có lỗi validation

## 🔍 Nguyên nhân
1. **Model Binding Error**: Trường `RegistrationStatus` được đánh dấu là `[Obsolete]` trong model nhưng vẫn được gửi từ form, gây ra lỗi validation
2. **NotMapped Properties**: Các thuộc tính `[NotMapped]` như `CalculatedStatus`, `RegistrationStartDate`, `RegistrationEndDate` có thể gây lỗi khi model binding
3. **Null Check**: Không kiểm tra null cho `existingTournament` trước khi sử dụng
4. **Error Handling**: Không có thông báo lỗi chi tiết cho người dùng khi validation thất bại

## ✅ Giải pháp

### 1. Cập nhật `TournamentController.cs` - Edit POST Action

**Các thay đổi chính:**
- ✅ Xóa validation errors cho các trường `[NotMapped]` và `[Obsolete]`
- ✅ Thêm null check cho `existingTournament`
- ✅ Preserve trường `RegistrationStatus` từ database
- ✅ Thêm `TempData` messages để thông báo thành công/lỗi
- ✅ Log validation errors chi tiết cho người dùng

```csharp
// Remove validation errors for obsolete and NotMapped properties
if (ModelState.ContainsKey("RegistrationStatus"))
{
    ModelState.Remove("RegistrationStatus");
}
if (ModelState.ContainsKey("CalculatedStatus"))
{
    ModelState.Remove("CalculatedStatus");
}
if (ModelState.ContainsKey("RegistrationStartDate"))
{
    ModelState.Remove("RegistrationStartDate");
}
if (ModelState.ContainsKey("RegistrationEndDate"))
{
    ModelState.Remove("RegistrationEndDate");
}
```

### 2. Cập nhật `Views/Tournament/Edit.cshtml`

**Thay đổi:**
- ❌ Xóa dropdown `RegistrationStatus` (obsolete)
- ✅ Thêm trường chỉ đọc hiển thị `CalculatedStatus`
- ℹ️ Thêm thông tin tooltip giải thích trạng thái tự động

```html
<div class="form-group mb-3">
    <label class="form-label fw-bold">Trạng Thái Hiện Tại</label>
    <input type="text" class="form-control" value="@Model.CalculatedStatus" disabled readonly />
    <div class="form-text">Trạng thái được tính tự động dựa trên ngày bắt đầu và kết thúc</div>
</div>
```

### 3. Cập nhật `Models/Tournament.cs`

**Thay đổi:**
- ✅ Thêm `[Required]` validation cho trường `Description`

```csharp
[Required(ErrorMessage = "Mô tả không được bỏ trống")]
public required string Description { get; set; }
```

## 🎯 Kết quả

### Trước khi sửa:
- ❌ Lỗi khi submit form
- ❌ Không có thông báo lỗi chi tiết
- ❌ Trường `RegistrationStatus` obsolete vẫn được hiển thị

### Sau khi sửa:
- ✅ Submit form thành công
- ✅ Hiển thị thông báo thành công/lỗi rõ ràng
- ✅ Trạng thái giải đấu được tính tự động
- ✅ Validation errors được xử lý đúng cách
- ✅ Preserve image URL khi không upload ảnh mới

## 🧪 Cách test

1. **Đăng nhập** với tài khoản có quyền chỉnh sửa giải đấu
2. **Chọn một giải đấu** và nhấn "Chỉnh sửa"
3. **Thay đổi thông tin**:
   - Tên giải đấu
   - Mô tả
   - Địa điểm
   - Ngày bắt đầu/kết thúc
   - Thể thức thi đấu
   - Số lượng đội tối đa
4. **Nhấn "Lưu Thay Đổi"**
5. **Kiểm tra**:
   - ✅ Không có lỗi
   - ✅ Hiển thị thông báo thành công
   - ✅ Chuyển hướng về trang danh sách
   - ✅ Dữ liệu được cập nhật đúng

## 🔒 Validation Rules

### Các trường bắt buộc:
- ✅ Tên giải đấu (`Name`)
- ✅ Mô tả (`Description`)
- ✅ Ngày bắt đầu (`StartDate`)
- ✅ Ngày kết thúc (`EndDate`)
- ✅ Môn thể thao (`SportsId`)

### Các trường tùy chọn:
- Địa điểm (`Location`)
- Ảnh giải đấu (`ImageUrl`)
- Thể thức thi đấu (`TournamentFormatId`)
- Số lượng đội tối đa (`MaxTeams`)
- Số đội mỗi bảng (`TeamsPerGroup`)

## 📊 Trạng thái giải đấu tự động

Trạng thái giải đấu được tính tự động dựa trên:
- **Ngày mở đăng ký**: 14 ngày trước `StartDate`
- **Ngày kết thúc đăng ký**: 1 ngày trước `StartDate`

```
Thời gian hiện tại < Ngày mở đăng ký → "Chưa mở đăng ký"
Ngày mở đăng ký ≤ Thời gian hiện tại ≤ Ngày kết thúc đăng ký → "Mở đăng ký"
Ngày kết thúc đăng ký < Thời gian hiện tại < StartDate → "Kết thúc đăng ký"
StartDate ≤ Thời gian hiện tại ≤ EndDate → "Giải đấu đang diễn ra"
Thời gian hiện tại > EndDate → "Giải đấu đã kết thúc"
```

## 📝 Lưu ý
- Trường `RegistrationStatus` vẫn tồn tại trong database để tương thích ngược
- Nên dùng `CalculatedStatus` thay vì `RegistrationStatus`
- Image URL được giữ nguyên nếu không upload ảnh mới
- Validation errors được log chi tiết trong `TempData["ErrorMessage"]`

## 🎉 Hoàn thành
Lỗi đã được khắc phục hoàn toàn. Người dùng có thể chỉnh sửa giải đấu mà không gặp lỗi.
