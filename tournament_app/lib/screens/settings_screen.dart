import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
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
  String _selectedTheme = 'system';

  @override
  Widget build(BuildContext context) {
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
          _buildListTile(
            icon: Icons.language_outlined,
            title: 'Ngôn ngữ',
            subtitle: _getLanguageName(_selectedLanguage),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(),
          ),
          _buildListTile(
            icon: Icons.palette_outlined,
            title: 'Giao diện',
            subtitle: _getThemeName(_selectedTheme),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(),
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

  String _getThemeName(String theme) {
    switch (theme) {
      case 'light':
        return 'Sáng';
      case 'dark':
        return 'Tối';
      case 'system':
        return 'Theo hệ thống';
      default:
        return 'Theo hệ thống';
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

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn giao diện'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Sáng'),
              value: 'light',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
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
            RadioListTile<String>(
              title: const Text('Tối'),
              value: 'dark',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
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
            RadioListTile<String>(
              title: const Text('Theo hệ thống'),
              value: 'system',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                Navigator.pop(context);
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
