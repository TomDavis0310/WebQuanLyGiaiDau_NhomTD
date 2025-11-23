import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_logo.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/animated_wrapper.dart';
import 'sports_list_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _userNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _userNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.register(
        email: _emailController.text.trim(),
        userName: _userNameController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        fullName: _fullNameController.text.trim().isEmpty 
            ? null 
            : _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
      );

      if (success && mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đăng ký thành công!'),
            backgroundColor: AppTheme.getPrimaryColor(context),
          ),
        );
        
        // Navigate to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SportsListScreen()),
        );
      } else if (mounted) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Đăng ký thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.getPrimaryGradient(context),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(AppTheme.spaceMedium),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'Đăng Ký Tài Khoản',
                      style: AppTheme.lightHeadlineMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Logo
                      AnimatedWrapper(
                        index: 0,
                        child: AppLogo(height: 80),
                      ),
                      const SizedBox(height: 24),
                      
                      // Register Form Card
                      AnimatedWrapper(
                        index: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                            boxShadow: isDark ? AppTheme.darkCardShadow : AppTheme.lightCardShadow,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spaceLarge),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Email Field
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
                                    decoration: AppTheme.inputDecoration(
                                      label: 'Email *',
                                      hint: 'example@email.com',
                                      prefixIcon: Icons.email_outlined,
                                    ).copyWith(
                                      labelStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
                                      hintStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.5)),
                                      prefixIconColor: AppTheme.getPrimaryColor(context),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Vui lòng nhập email';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Email không hợp lệ';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Username Field
                                  TextFormField(
                                    controller: _userNameController,
                                    style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
                                    decoration: AppTheme.inputDecoration(
                                      label: 'Tên đăng nhập *',
                                      hint: 'username',
                                      prefixIcon: Icons.person_outlined,
                                    ).copyWith(
                                      labelStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
                                      hintStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.5)),
                                      prefixIconColor: AppTheme.getPrimaryColor(context),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Vui lòng nhập tên đăng nhập';
                                      }
                                      if (value.length < 3) {
                                        return 'Tên đăng nhập phải có ít nhất 3 ký tự';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Full Name Field (Optional)
                                  TextFormField(
                                    controller: _fullNameController,
                                    style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
                                    decoration: AppTheme.inputDecoration(
                                      label: 'Họ và tên',
                                      hint: 'Nguyễn Văn A',
                                      prefixIcon: Icons.badge_outlined,
                                    ).copyWith(
                                      labelStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
                                      hintStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.5)),
                                      prefixIconColor: AppTheme.getPrimaryColor(context),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Phone Field (Optional)
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
                                    decoration: AppTheme.inputDecoration(
                                      label: 'Số điện thoại',
                                      hint: '0123456789',
                                      prefixIcon: Icons.phone_outlined,
                                    ).copyWith(
                                      labelStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
                                      hintStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.5)),
                                      prefixIconColor: AppTheme.getPrimaryColor(context),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Password Field
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
                                    decoration: AppTheme.inputDecoration(
                                      label: 'Mật khẩu *',
                                      hint: '••••••••',
                                      prefixIcon: Icons.lock_outlined,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword 
                                              ? Icons.visibility_outlined 
                                              : Icons.visibility_off_outlined,
                                          color: AppTheme.getTextSecondaryColor(context),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ).copyWith(
                                      labelStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
                                      hintStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.5)),
                                      prefixIconColor: AppTheme.getPrimaryColor(context),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Vui lòng nhập mật khẩu';
                                      }
                                      if (value.length < 6) {
                                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Confirm Password Field
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    style: TextStyle(color: AppTheme.getTextPrimaryColor(context)),
                                    decoration: AppTheme.inputDecoration(
                                      label: 'Xác nhận mật khẩu *',
                                      hint: '••••••••',
                                      prefixIcon: Icons.lock_outlined,
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword 
                                              ? Icons.visibility_outlined 
                                              : Icons.visibility_off_outlined,
                                          color: AppTheme.getTextSecondaryColor(context),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword = 
                                                !_obscureConfirmPassword;
                                          });
                                        },
                                      ),
                                    ).copyWith(
                                      labelStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
                                      hintStyle: TextStyle(color: AppTheme.getTextSecondaryColor(context).withValues(alpha: 0.5)),
                                      prefixIconColor: AppTheme.getPrimaryColor(context),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Vui lòng xác nhận mật khẩu';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Mật khẩu xác nhận không khớp';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppTheme.spaceLarge),
                                  
                                  // Register Button
                                  Consumer<AuthProvider>(
                                    builder: (context, authProvider, child) {
                                      return CustomButton(
                                        text: 'Đăng Ký',
                                        gradient: AppTheme.getPrimaryGradient(context),
                                        isLoading: authProvider.isLoading,
                                        onPressed: _handleRegister,
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  // Already have account
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Đã có tài khoản? ',
                                        style: TextStyle(
                                          color: AppTheme.getTextSecondaryColor(context),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'Đăng nhập',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.getPrimaryColor(context),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
