import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/google_signin_button.dart';
import '../widgets/custom_button.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_wrapper.dart';
import 'register_screen.dart';
import 'sports_list_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
        _rememberMe,
      );

      if (success && mounted) {
        // Navigate to home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SportsListScreen()),
        );
      } else if (mounted) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Đăng nhập thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      // Navigate to home screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SportsListScreen()),
      );
    } else if (mounted) {
      // Show error with helpful message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Google Sign-in hiện chưa sẵn sàng',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('Vui lòng sử dụng đăng nhập với email/password'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 4),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spaceLarge),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with animation
                  AnimatedWrapper(
                    index: 0,
                    child: Hero(
                      tag: 'app_logo',
                      child: AppLogo(height: 120),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceMedium),
                  
                  // App Name
                  AnimatedWrapper(
                    index: 1,
                    child: Column(
                      children: [
                        Text(
                          'TDSports',
                          style: AppTheme.lightDisplayLarge.copyWith(
                            color: Colors.white,
                            fontSize: 36,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceSmall),
                        Text(
                          'Quản Lý Giải Đấu Thể Thao',
                          style: AppTheme.lightBodyLarge.copyWith(
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXLarge),
                  
                  // Login Form Card
                  AnimatedWrapper(
                    index: 2,
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
                              // Title
                              Text(
                                'Đăng Nhập',
                                style: AppTheme.lightHeadlineLarge.copyWith(
                                  color: AppTheme.getPrimaryColor(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppTheme.spaceLarge),
                              
                              // Email Field
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                  color: AppTheme.getTextPrimaryColor(context),
                                ),
                                decoration: AppTheme.inputDecoration(
                                  label: 'Email',
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
                              const SizedBox(height: AppTheme.spaceMedium),
                              
                              // Password Field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: TextStyle(
                                  color: AppTheme.getTextPrimaryColor(context),
                                ),
                                decoration: AppTheme.inputDecoration(
                                  label: 'Mật khẩu',
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
                              const SizedBox(height: AppTheme.spaceSmall),
                              
                              // Remember Me & Forgot Password
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          activeColor: AppTheme.getPrimaryColor(context),
                                          onChanged: (value) {
                                            setState(() {
                                              _rememberMe = value ?? false;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: AppTheme.spaceSmall),
                                      Text(
                                        'Ghi nhớ',
                                        style: TextStyle(
                                          color: AppTheme.getTextPrimaryColor(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: Text(
                                      'Quên mật khẩu?',
                                      style: TextStyle(
                                        color: AppTheme.getPrimaryColor(context),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spaceMedium),
                              
                              // Login Button
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, child) {
                                  return CustomButton(
                                    text: 'Đăng Nhập',
                                    onPressed: _handleLogin,
                                    isLoading: authProvider.isLoading,
                                    gradient: AppTheme.getPrimaryGradient(context),
                                    width: double.infinity,
                                  );
                                },
                              ),
                              const SizedBox(height: AppTheme.spaceMedium),
                              
                              // Google Sign-In Button
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, child) {
                                  return GoogleSignInButton(
                                    onPressed: _handleGoogleSignIn,
                                    isLoading: authProvider.isLoading,
                                  );
                                },
                              ),
                              const SizedBox(height: AppTheme.spaceMedium),
                              
                              // Divider
                              Row(
                                children: [
                                  Expanded(child: Divider(color: AppTheme.getDividerColor(context))),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceMedium),
                                    child: Text(
                                      'hoặc',
                                      style: TextStyle(
                                        color: AppTheme.getTextSecondaryColor(context),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: AppTheme.getDividerColor(context))),
                                ],
                              ),
                              const SizedBox(height: AppTheme.spaceMedium),
                              
                              // Register Button
                              CustomButton(
                                text: 'Tạo Tài Khoản Mới',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                isOutlined: true,
                                width: double.infinity,
                                color: AppTheme.getPrimaryColor(context),
                              ),
                              const SizedBox(height: AppTheme.spaceMedium),
                              
                              // Skip Login Button
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context) => const SportsListScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Bỏ qua đăng nhập',
                                  style: TextStyle(
                                    color: AppTheme.getTextSecondaryColor(context),
                                  ),
                                ),
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
        ),
      ),
    );
  }
}
