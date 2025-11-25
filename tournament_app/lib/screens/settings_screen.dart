import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../config/app_config.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _matchNotifications = true;
  bool _newsNotifications = true;
  bool _tournamentNotifications = true;
  String _selectedLanguage = 'vi';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài Đặt'),
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Account Section
          _buildSectionHeader('Tài Khoản'),
          _buildListTile(
            icon: Icons.person_outline,
            title: 'Chỉnh sửa thông tin',
            subtitle: 'Cập nhật thông tin cá nhân',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            },
          ),
          _buildListTile(
            icon: Icons.lock_outline,
            title: 'Đổi mật khẩu',
            subtitle: 'Thay đổi mật khẩu của bạn',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            },
          ),
          const Divider(height: 1),

          // Points & Shop Section
          _buildSectionHeader('Điểm & Cửa Hàng'),
          _buildListTile(
            icon: Icons.shopping_bag_outlined,
            title: 'Cửa hàng điểm',
            subtitle: 'Đổi điểm lấy quà tặng',
            onTap: () {
              Navigator.pushNamed(context, '/shop');
            },
          ),
          _buildListTile(
            icon: Icons.card_giftcard_outlined,
            title: 'Túi quà của tôi',
            subtitle: 'Xem các quà tặng đã đổi',
            onTap: () {
              Navigator.pushNamed(context, '/my-rewards');
            },
          ),
          _buildListTile(
            icon: Icons.history,
            title: 'Lịch sử điểm',
            subtitle: 'Xem lịch sử tích lũy và sử dụng điểm',
            onTap: () {
              Navigator.pushNamed(context, '/points-history');
            },
          ),
          const Divider(height: 1),

          // Notifications Section
          _buildSectionHeader('Thông Báo'),
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('Bật thông báo'),
            subtitle: const Text('Nhận thông báo từ ứng dụng'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
                if (!value) {
                  _matchNotifications = false;
                  _newsNotifications = false;
                  _tournamentNotifications = false;
                }
              });
            },
          ),
          if (_notificationsEnabled) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.sports_soccer, size: 20),
                    title: const Text('Trận đấu', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Thông báo về trận đấu', style: TextStyle(fontSize: 12)),
                    value: _matchNotifications,
                    onChanged: _notificationsEnabled
                        ? (value) {
                            setState(() {
                              _matchNotifications = value;
                            });
                          }
                        : null,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.article_outlined, size: 20),
                    title: const Text('Tin tức', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Thông báo tin tức mới', style: TextStyle(fontSize: 12)),
                    value: _newsNotifications,
                    onChanged: _notificationsEnabled
                        ? (value) {
                            setState(() {
                              _newsNotifications = value;
                            });
                          }
                        : null,
                  ),
                  SwitchListTile(
                    secondary: const Icon(Icons.emoji_events_outlined, size: 20),
                    title: const Text('Giải đấu', style: TextStyle(fontSize: 14)),
                    subtitle: const Text('Thông báo về giải đấu', style: TextStyle(fontSize: 12)),
                    value: _tournamentNotifications,
                    onChanged: _notificationsEnabled
                        ? (value) {
                            setState(() {
                              _tournamentNotifications = value;
                            });
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ],
          const Divider(height: 1),

          // Appearance Section
          _buildSectionHeader('Giao Diện'),
          
          // Theme Toggle
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppTheme.getPrimaryGradient(context),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              boxShadow: isDark ? AppTheme.darkCardShadow : AppTheme.lightCardShadow,
            ),
            child: ListTile(
              leading: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: Colors.white,
              ),
              title: Text(
                isDark ? 'Chế độ Tối' : 'Chế độ Sáng',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                isDark 
                    ? 'Nhấn để chuyển sang chế độ sáng' 
                    : 'Nhấn để chuyển sang chế độ tối',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              trailing: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Switch(
                  value: isDark,
                  onChanged: (_) => themeProvider.toggleTheme(),
                  activeColor: AppTheme.lightAccentYellow,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          
          _buildListTile(
            icon: Icons.language_outlined,
            title: 'Ngôn ngữ',
            subtitle: _getLanguageName(_selectedLanguage),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(),
          ),
          const Divider(height: 1),

          // Storage Section
          _buildSectionHeader('Bộ Nhớ'),
          _buildListTile(
            icon: Icons.cleaning_services_outlined,
            title: 'Xóa bộ nhớ cache',
            subtitle: 'Giải phóng không gian lưu trữ',
            onTap: () => _showClearCacheDialog(),
          ),
          const Divider(height: 1),

          // About Section
          _buildSectionHeader('Về Ứng Dụng'),
          _buildListTile(
            icon: Icons.info_outline,
            title: 'Giới thiệu',
            subtitle: 'Phiên bản 1.0.0',
            onTap: () => _showAboutDialog(),
          ),
          _buildListTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Chính sách bảo mật',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển')),
              );
            },
          ),
          _buildListTile(
            icon: Icons.description_outlined,
            title: 'Điều khoản sử dụng',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển')),
              );
            },
          ),
          _buildListTile(
            icon: Icons.help_outline,
            title: 'Trợ giúp & Hỗ trợ',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển')),
              );
            },
          ),
          const Divider(height: 1),

          // System Configuration Section
          _buildSectionHeader('Hệ Thống'),
          _buildListTile(
            icon: Icons.dns_outlined,
            title: 'Cấu hình máy chủ',
            subtitle: 'IP: ${AppConfig.currentIp}',
            onTap: () => _showServerConfigDialog(),
          ),
          const Divider(height: 1),

          // Logout Section
          _buildSectionHeader(''),
          _buildListTile(
            icon: Icons.logout,
            iconColor: Colors.red,
            title: 'Đăng xuất',
            titleColor: Colors.red,
            onTap: () => _showLogoutDialog(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    if (title.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? iconColor,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'vi':
        return 'Tiếng Việt';
      case 'en':
        return 'English';
      default:
        return 'Tiếng Việt';
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Tiếng Việt'),
              value: 'vi',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã chuyển sang Tiếng Việt'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tính năng đang phát triển'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bộ nhớ cache'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tất cả bộ nhớ cache? '
          'Điều này sẽ giải phóng không gian lưu trữ nhưng có thể làm chậm ứng dụng lần đầu mở.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cache clearing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa bộ nhớ cache'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'TDSports',
      applicationVersion: '1.0.0',
      applicationIcon: const FlutterLogo(size: 48),
      applicationLegalese: '© 2025 TDSports. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Ứng dụng quản lý giải đấu thể thao toàn diện. '
          'Theo dõi trận đấu, cập nhật kết quả, xem bảng xếp hạng và nhiều tính năng khác.',
        ),
      ],
    );
  }

  void _showServerConfigDialog() {
    final ipController = TextEditingController(text: AppConfig.currentIp);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cấu hình máy chủ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Nhập địa chỉ IP của máy chủ API:'),
            const SizedBox(height: 8),
            TextField(
              controller: ipController,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: 192.168.1.10',
                border: OutlineInputBorder(),
                labelText: 'IP Address',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            const Text(
              'Lưu ý: Cần khởi động lại ứng dụng để áp dụng thay đổi hoàn toàn.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final newIp = ipController.text.trim();
              if (newIp.isNotEmpty) {
                await AppConfig.updateIp(newIp);
                if (mounted) {
                  setState(() {}); // Refresh UI to show new IP
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã cập nhật IP thành: $newIp'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              await authProvider.logout();
              
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
