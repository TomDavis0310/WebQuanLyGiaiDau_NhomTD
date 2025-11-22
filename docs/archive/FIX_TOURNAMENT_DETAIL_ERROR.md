# 🔧 Fix Lỗi Tournament Detail Screen

## ❌ Lỗi Gặp Phải
```
Error: type 'Null' is not a subtype of type 'num' in type cast
```

## 🔍 Nguyên Nhân

API có thể trả về `null` cho các field `maxTeams` và `teamsPerGroup`, nhưng model `TournamentDetail` định nghĩa chúng là **required int** (không thể null).

### Dữ Liệu API:
```json
{
  "maxTeams": 6,           // Có thể là null
  "teamsPerGroup": 6       // Có thể là null
}
```

### Model Cũ (Lỗi):
```dart
class TournamentDetail {
  final int maxTeams;        // ❌ Required, không thể null
  final int teamsPerGroup;   // ❌ Required, không thể null
}
```

## ✅ Cách Fix

### 1. Cập Nhật Model
**File:** `tournament_app/lib/models/tournament_detail.dart`

```dart
class TournamentDetail {
  final int? maxTeams;        // ✅ Nullable
  final int? teamsPerGroup;   // ✅ Nullable
}
```

### 2. Regenerate Code
```bash
cd tournament_app
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Cập Nhật UI
**File:** `tournament_app/lib/screens/tournament_detail_screen.dart`

**Quick Stats Card:**
```dart
// Cũ
'${tournament!.registeredTeamsCount}/${tournament!.maxTeams}'

// Mới
'${tournament!.registeredTeamsCount}/${tournament!.maxTeams ?? 0}'
```

**Info Rows:**
```dart
// Cũ
_buildInfoRow(Icons.groups, 'Số đội tối đa', '${tournament!.maxTeams}')

// Mới
_buildInfoRow(Icons.groups, 'Số đội tối đa', '${tournament!.maxTeams ?? 'Chưa xác định'}')
```

### 4. Thêm Logging
**File:** `tournament_app/lib/services/api_service.dart`

Thêm try-catch để log chi tiết khi parse error:
```dart
try {
  print('Tournament API Response: ${jsonData['data']}');
  final tournamentDetail = TournamentDetail.fromJson(jsonData['data']);
  // ...
} catch (parseError, stackTrace) {
  print('Parse Error: $parseError');
  print('Stack Trace: $stackTrace');
  print('Raw JSON: ${jsonData['data']}');
  // ...
}
```

## 📝 Files Đã Thay Đổi

1. ✅ `tournament_app/lib/models/tournament_detail.dart`
   - Chuyển `maxTeams` và `teamsPerGroup` thành nullable (`int?`)

2. ✅ `tournament_app/lib/models/tournament_detail.g.dart`
   - Tự động regenerate bởi build_runner

3. ✅ `tournament_app/lib/screens/tournament_detail_screen.dart`
   - Xử lý null values với `??` operator
   - Hiển thị "Chưa xác định" hoặc `0` khi null

4. ✅ `tournament_app/lib/services/api_service.dart`
   - Thêm logging chi tiết cho debug

## 🧪 Test Lại

1. **Chạy app:**
   ```bash
   cd tournament_app
   flutter run
   ```

2. **Navigate:**
   ```
   Sports List → Bóng Rổ → Giải đầu tiên
   ```

3. **Kiểm tra:**
   - ✅ Không còn crash
   - ✅ Hiển thị thông tin giải đấu
   - ✅ Quick stats hiển thị đúng
   - ✅ Tab "Tổng quan" hoạt động
   - ✅ 3 tabs hoạt động bình thường

## 🎯 Kết Quả Mong Đợi

### Trước Fix (Lỗi):
- App crash ngay khi vào Tournament Detail
- Error dialog hiện ra
- Không thể xem chi tiết giải đấu

### Sau Fix (Hoạt động):
- ✅ Màn hình load thành công
- ✅ Hiển thị đầy đủ thông tin
- ✅ Số đội: "0/6" hoặc "X/6"
- ✅ Nếu API trả null: "Chưa xác định"
- ✅ 3 tabs hoạt động mượt

## 📊 API Response Handling

### Case 1: API trả về đầy đủ
```json
{
  "maxTeams": 6,
  "teamsPerGroup": 6
}
```
→ Hiển thị: "6", "6"

### Case 2: API trả về null
```json
{
  "maxTeams": null,
  "teamsPerGroup": null
}
```
→ Hiển thị: "Chưa xác định", "Chưa xác định"

### Case 3: API không có field
```json
{
  // Không có maxTeams, teamsPerGroup
}
```
→ Hiển thị: "Chưa xác định", "Chưa xác định"

## 🔄 Hot Reload vs Full Restart

Sau khi fix:
- **Model changes** → Cần **FULL RESTART** (Stop và Run lại)
- **UI changes** → Có thể dùng **HOT RELOAD** (r trong terminal)

## 💡 Best Practices

### 1. Nullable Fields
Luôn đánh dấu nullable cho fields có thể null từ API:
```dart
final int? maxTeams;     // Nullable
final int minTeams;      // Not nullable - phải có giá trị
```

### 2. Null-Safety Operators
```dart
value ?? defaultValue    // If value is null, use defaultValue
value?.property          // Safe navigation
value!                   // Force unwrap (chắc chắn không null)
```

### 3. Model Generation
Sau khi sửa model:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Debug Logging
Luôn log raw JSON khi gặp parse error để dễ debug.

## 🚀 Next Steps

1. ✅ Fix đã apply
2. ✅ Code regenerated
3. ⏳ Run app và test
4. ⏳ Verify tất cả 3 tabs
5. ⏳ Test navigation
6. ⏳ Test với nhiều tournaments khác

## 📞 Nếu Vẫn Còn Lỗi

1. **Check console logs** - Xem parse error chi tiết
2. **Verify API response** - Dùng curl hoặc Postman
3. **Check model mapping** - So sánh JSON keys với model fields
4. **Full restart app** - Stop và run lại hoàn toàn

---

**Status:** ✅ FIXED - Sẵn sàng test lại!
