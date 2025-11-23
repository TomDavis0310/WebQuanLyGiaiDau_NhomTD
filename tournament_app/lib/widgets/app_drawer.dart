import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../screens/login_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/dashboard_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final isAuthenticated = authProvider.isAuthenticated;
          final user = authProvider.user;

          return Column(
            children: [
              // Drawer Header
              _buildHeader(context, isAuthenticated, user),
              
              // Drawer Items
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _buildDrawerItem(
                      context,
                      icon: Icons.home_outlined,
                      title: 'Trang Chủ',
                      onTap: () {
                        Navigator.pop(context); // Close drawer
                        // Navigate to home if not already there
                        // Since this drawer is mostly used on Home, just closing is fine
                        // Or we can use a global navigation key to switch tabs
                      },
                    ),
                    if (isAuthenticated) ...[
                      _buildDrawerItem(
                        context,
                        icon: Icons.dashboard_outlined,
                        title: 'Dashboard',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const DashboardScreen()),
                          );
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        icon: Icons.person_outline,
                        title: 'Hồ Sơ Cá Nhân',
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          );
                        },
                      ),
                    ],
                    const Divider(),
                    _buildDrawerItem(
                      context,
                      icon: Icons.settings_outlined,
                      title: 'Cài Đặt',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      },
                    ),
                    
                    // Theme Toggle Item
                    Consumer<ThemeProvider>(
                      builder: (context, themeProvider, _) {
                        return SwitchListTile(
                          secondary: Icon(
                            themeProvider.isDarkMode 
                                ? Icons.dark_mode_outlined 
                                : Icons.light_mode_outlined,
                            color: AppTheme.textSecondary,
                          ),
                          title: Text(
                            themeProvider.isDarkMode ? 'Chế độ Tối' : 'Chế độ Sáng',
                            style: AppTheme.bodyMedium,
                          ),
                          value: themeProvider.isDarkMode,
                          onChanged: (value) => themeProvider.toggleTheme(),
                          activeColor: Theme.of(context).primaryColor,
                        );
                      },
                    ),

                    const Divider(),
                    _buildDrawerItem(
                      context,
                      icon: Icons.info_outline,
                      title: 'Giới Thiệu',
                      onTap: () {
                        Navigator.pop(context);
                        showAboutDialog(
                          context: context,
                          applicationName: 'TDSports',
                          applicationVersion: '1.0.0',
                          applicationIcon: const FlutterLogo(size: 48),
                          children: [
                            const Text('Ứng dụng quản lý giải đấu thể thao.'),
                          ],
                        );
                      },
                    ),
                    
                    if (isAuthenticated) ...[
                      const Divider(),
                      _buildDrawerItem(
                        context,
                        icon: Icons.logout,
                        title: 'Đăng Xuất',
                        textColor: Colors.red,
                        iconColor: Colors.red,
                        onTap: () async {
                          Navigator.pop(context);
                          await authProvider.logout();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã đăng xuất')),
                            );
                          }
                        },
                      ),
                    ] else ...[
                      const Divider(),
                      _buildDrawerItem(
                        context,
                        icon: Icons.login,
                        title: 'Đăng Nhập',
                        textColor: Theme.of(context).primaryColor,
                        iconColor: Theme.of(context).primaryColor,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              
              // Footer
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Phiên bản 1.0.0',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isAuthenticated, dynamic user) {
    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      accountName: Text(
        isAuthenticated ? (user?.fullName ?? 'Người dùng') : 'Khách',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      accountEmail: Text(
        isAuthenticated ? (user?.email ?? '') : 'Đăng nhập để sử dụng đầy đủ tính năng',
      ),
      currentAccountPicture: CircleAvatar(
        backgroundColor: Colors.white,
        backgroundImage: (isAuthenticated && user?.avatarUrl != null)
            ? NetworkImage(user.avatarUrl!)
            : null,
        child: (isAuthenticated && user?.avatarUrl != null)
            ? null
            : Icon(
                Icons.person,
                size: 40,
                color: Theme.of(context).primaryColor,
              ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppTheme.textSecondary),
      title: Text(
        title,
        style: AppTheme.bodyMedium.copyWith(
          color: textColor ?? AppTheme.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
