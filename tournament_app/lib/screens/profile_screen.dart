import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_card.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông Tin Cá Nhân'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (!authProvider.isAuthenticated) {
            return _buildNotLoggedIn(context);
          }

          final user = authProvider.user!;
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // Header with gradient
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: AppTheme.spaceXLarge),
                      
                      // Avatar
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.white,
                          child: user.avatarUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    user.avatarUrl!,
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: AppTheme.primaryBlue,
                                      );
                                    },
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: AppTheme.primaryBlue,
                                ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceMedium),
                      
                      // User Name
                      Text(
                        user.fullName ?? user.userName,
                        style: AppTheme.headlineLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceSmall),
                      
                      // Email
                      Text(
                        user.email,
                        style: AppTheme.bodyLarge.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceXLarge),
                    ],
                  ),
                ),
                
                // User Info Cards
                Padding(
                  padding: const EdgeInsets.all(AppTheme.spaceMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Account Info Section
                      Text(
                        'Thông Tin Tài Khoản',
                        style: AppTheme.titleLarge.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceMedium),
                      
                      _buildInfoCard(
                        context,
                        icon: Icons.person_outline,
                        title: 'Tên đăng nhập',
                        value: user.userName,
                      ),
                      
                      _buildInfoCard(
                        context,
                        icon: Icons.badge_outlined,
                        title: 'Họ và tên',
                        value: user.fullName ?? 'Chưa cập nhật',
                      ),
                      
                      _buildInfoCard(
                        context,
                        icon: Icons.email_outlined,
                        title: 'Email',
                        value: user.email,
                      ),
                      
                      _buildInfoCard(
                        context,
                        icon: Icons.phone_outlined,
                        title: 'Số điện thoại',
                        value: user.phoneNumber ?? 'Chưa cập nhật',
                      ),
                      
                      _buildInfoCard(
                        context,
                        icon: Icons.verified_user_outlined,
                        title: 'Vai trò',
                        value: user.role ?? 'User',
                      ),
                      
                      if (user.createdAt != null)
                        _buildInfoCard(
                          context,
                          icon: Icons.calendar_today_outlined,
                          title: 'Ngày đăng ký',
                          value: _formatDate(user.createdAt!),
                        ),
                      
                      const SizedBox(height: AppTheme.spaceLarge),
                      
                      // Action Buttons
                      CustomButton(
                        text: 'Chỉnh Sửa Thông Tin',
                        icon: Icons.edit,
                        gradient: AppTheme.primaryGradient,
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                          // Refresh data after edit
                          if (context.mounted) {
                            Provider.of<AuthProvider>(context, listen: false).refreshUserInfo();
                          }
                        },
                      ),
                      const SizedBox(height: AppTheme.spaceMedium),
                      
                      CustomButton(
                        text: 'Đổi Mật Khẩu',
                        icon: Icons.lock_outline,
                        isOutlined: true,
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ChangePasswordScreen(),
                            ),
                          );
                          if (result == true && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đổi mật khẩu thành công'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: AppTheme.spaceMedium),
                      
                      CustomButton(
                        text: 'Đăng Xuất',
                        icon: Icons.logout,
                        color: Colors.red,
                        onPressed: () => _handleLogout(context, authProvider),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotLoggedIn(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppTheme.spaceLarge),
            Text(
              'Chưa Đăng Nhập',
              style: AppTheme.headlineLarge.copyWith(
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: AppTheme.spaceMedium),
            Text(
              'Đăng nhập để sử dụng đầy đủ tính năng của ứng dụng',
              textAlign: TextAlign.center,
              style: AppTheme.bodyLarge.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: AppTheme.spaceXLarge),
            CustomButton(
              text: 'Đăng Nhập Ngay',
              gradient: AppTheme.primaryGradient,
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return CustomCard(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMedium),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceMedium),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spaceMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _handleLogout(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận đăng xuất'),
        content: Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Đăng Xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await authProvider.logout();
      
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã đăng xuất thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
