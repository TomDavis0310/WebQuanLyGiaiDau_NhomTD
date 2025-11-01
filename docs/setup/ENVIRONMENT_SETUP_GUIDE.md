# 🚀 Environment Configuration Guide

## 📱 Flutter App Environment Setup

### Development Mode (Default)

**Run normally:**
```bash
flutter run
```

**Override API URL:**
```bash
# For Android Emulator
flutter run --dart-define=API_URL=http://10.0.2.2:8080/api

# For iOS Simulator
flutter run --dart-define=API_URL=http://localhost:8080/api

# For Physical Device (replace with your PC's IP)
flutter run --dart-define=API_URL=http://192.168.1.100:8080/api
```

### Production Mode

**Build for production:**
```bash
# Android
flutter build apk --dart-define=ENV=production

# iOS
flutter build ios --dart-define=ENV=production
```

**Run in production mode:**
```bash
flutter run --dart-define=ENV=production
```

**With custom production API:**
```bash
flutter run --dart-define=ENV=production --dart-define=API_URL=https://your-api.azurewebsites.net/api
```

---

## 🌐 Backend Environment Setup

### Local Development

**Default:** `http://localhost:8080`

The backend is configured to listen on localhost by default. This is set in `Program.cs`:

```csharp
builder.WebHost.UseUrls($"http://localhost:{port}");
```

### Allow Network Access (for mobile devices)

If you need to access the backend from mobile devices on the same network:

```csharp
// Program.cs - Change to:
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");
```

Then access via your PC's IP address:
- Windows: `ipconfig` → Look for IPv4 Address
- Mac/Linux: `ifconfig` → Look for inet address

**Example:** `http://192.168.1.100:8080`

### Production Deployment

For production (e.g., Azure, AWS, Heroku):

```csharp
// Program.cs is already configured to use PORT environment variable
var port = Environment.GetEnvironmentVariable("PORT") ?? "8080";
```

The platform will set the PORT automatically.

---

## 🔧 Quick Setup Guide

### Step 1: Find Your PC's IP Address

**Windows:**
```powershell
ipconfig | Select-String "IPv4"
```

**Output example:**
```
IPv4 Address. . . . . . . . . . . : 192.168.1.100
```

### Step 2: Update Flutter Environment Config

Edit `lib/config/environment.dart`:

```dart
static String _getDevApiUrl() {
  // For Physical Device (update with your PC's IP):
  return 'http://192.168.1.100:8080/api';  // ← Update this
}
```

### Step 3: Allow Firewall (Windows)

```powershell
# Run as Administrator
New-NetFirewallRule -DisplayName "ASP.NET Core Dev" -Direction Inbound -LocalPort 8080 -Protocol TCP -Action Allow
```

### Step 4: Update Backend for Network Access (Optional)

Only if testing on physical device:

```csharp
// Program.cs - Line 13
builder.WebHost.UseUrls($"http://0.0.0.0:{port}");
```

### Step 5: Run Both

**Terminal 1 - Backend:**
```powershell
cd D:\WebQuanLyGiaiDau_NhomTD\WebQuanLyGiaiDau_NhomTD
dotnet run
```

**Terminal 2 - Flutter:**
```bash
cd D:\WebQuanLyGiaiDau_NhomTD\tournament_app
flutter run
```

---

## 📊 Environment Variables Reference

### Flutter (dart-define)

| Variable | Values | Description |
|----------|--------|-------------|
| `ENV` | `development`, `production` | Current environment |
| `API_URL` | URL string | Override API base URL |

### Backend (.NET)

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8080` | Server port |
| `GOOGLE_CLIENT_ID` | - | Google OAuth Client ID |
| `GOOGLE_CLIENT_SECRET` | - | Google OAuth Client Secret |

---

## 🧪 Testing Different Configurations

### Test 1: Emulator (Default)
```bash
# No changes needed
flutter run
# Uses: http://10.0.2.2:8080/api
```

### Test 2: Physical Device
```bash
# Update environment.dart with your IP first
flutter run --dart-define=API_URL=http://192.168.1.100:8080/api
```

### Test 3: Production Mode
```bash
# Update environment.dart with production URL first
flutter run --dart-define=ENV=production
# Uses: https://your-api.azurewebsites.net/api
```

---

## ⚠️ Troubleshooting

### Problem: "Connection Refused" on Mobile

**Solution:**
1. Check backend is running: `http://localhost:8080/swagger`
2. Check firewall allows port 8080
3. Check PC and device on same WiFi
4. Verify IP address is correct
5. Try `http://0.0.0.0:8080` in Program.cs

### Problem: "Certificate Error" in Production

**Solution:**
1. Ensure production API uses HTTPS
2. Update `apiBaseUrl` to use `https://`
3. For development with self-signed certs, add:

```dart
// For DEVELOPMENT ONLY - bypass SSL
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

// In main.dart (development only):
void main() {
  if (Environment.isDevelopment) {
    HttpOverrides.global = MyHttpOverrides();
  }
  runApp(MyApp());
}
```

### Problem: "CORS Error" from Mobile

**Solution:**
Backend already configured with CORS. Verify:

```csharp
// Program.cs - Should have:
app.UseCors("AllowAll");
```

---

## 📝 Best Practices

### Development
- ✅ Use `localhost` or `10.0.2.2` for emulators
- ✅ Use actual IP for physical devices
- ✅ Enable CORS with `AllowAll` policy
- ✅ Use HTTP (not HTTPS) to avoid cert issues

### Production
- ✅ Always use HTTPS
- ✅ Use restrictive CORS policy (`AllowMobileApp`)
- ✅ Set `ENV=production`
- ✅ Never commit production API URLs to git
- ✅ Use environment variables or secure config

---

**Last Updated:** November 1, 2025
