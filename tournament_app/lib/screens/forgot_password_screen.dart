import 'package:flutter/material.dart';
import 'dart:async';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/animated_wrapper.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 0; // 0: Email, 1: Code, 2: New Password
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String? _successMessage;
  
  // Resend code timer
  int _resendCountdown = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 60;
    });

    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCountdown > 0) {
          _resendCountdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await ApiService.forgotPassword(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.success) {
          setState(() {
            _currentStep = 1;
            _successMessage = 'Mã xác nhận đã được gửi đến email của bạn';
          });
          _startResendTimer();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Mã xác nhận đã được gửi đến email'),
              backgroundColor: Theme.of(context).brightness == Brightness.dark 
                  ? AppTheme.darkAccentGreen 
                  : AppTheme.lightAccentGreen,
            ),
          );
        } else {
          setState(() {
            _errorMessage = response.message;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Lỗi: $e';
        });
      }
    }
  }

  Future<void> _verifyAndResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await ApiService.resetPassword(
        email: _emailController.text.trim(),
        resetCode: _codeController.text.trim(),
        newPassword: _newPasswordController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (response.success) {
          setState(() {
            _currentStep = 2;
            _successMessage = 'Đặt lại mật khẩu thành công';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Đặt lại mật khẩu thành công'),
              backgroundColor: Theme.of(context).brightness == Brightness.dark 
                  ? AppTheme.darkAccentGreen 
                  : AppTheme.lightAccentGreen,
            ),
          );

          // Auto navigate back after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              Navigator.pop(context);
            }
          });
        } else {
          setState(() {
            _errorMessage = response.message;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Lỗi: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    
    final successColor = isDark ? AppTheme.darkAccentGreen : AppTheme.lightAccentGreen;
    final errorColor = isDark ? AppTheme.darkAccentCoral : AppTheme.lightAccentCoral;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Quên Mật Khẩu',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress Indicator
              AnimatedWrapper(
                index: 0,
                child: _buildProgressIndicator(context),
              ),
              const SizedBox(height: 32),

              // Success Message
              if (_successMessage != null)
                AnimatedWrapper(
                  index: 1,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: successColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: successColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline, 
                          color: isDark ? Colors.green[300] : Colors.green[700]
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _successMessage!,
                            style: TextStyle(
                              color: isDark ? Colors.green[300] : Colors.green[700]
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Error Message
              if (_errorMessage != null)
                AnimatedWrapper(
                  index: 1,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: errorColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: errorColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline, 
                          color: isDark ? Colors.red[300] : Colors.red[700]
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: isDark ? Colors.red[300] : Colors.red[700]
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Step Content
              AnimatedWrapper(
                index: 2,
                child: _buildCurrentStep(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context) {
    if (_currentStep == 0) return _buildEmailStep(context);
    if (_currentStep == 1) return _buildCodeStep(context);
    if (_currentStep == 2) return _buildSuccessStep(context);
    return const SizedBox.shrink();
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? Colors.grey[700] : Colors.grey[300];
    final activeColor = AppTheme.getPrimaryColor(context);

    return Row(
      children: [
        _buildProgressStep(context, 1, 'Email', _currentStep >= 0),
        Expanded(
          child: Container(
            height: 2,
            color: _currentStep >= 1 ? activeColor : inactiveColor,
          ),
        ),
        _buildProgressStep(context, 2, 'Mã xác nhận', _currentStep >= 1),
        Expanded(
          child: Container(
            height: 2,
            color: _currentStep >= 2 ? activeColor : inactiveColor,
          ),
        ),
        _buildProgressStep(context, 3, 'Hoàn thành', _currentStep >= 2),
      ],
    );
  }

  Widget _buildProgressStep(BuildContext context, int step, String label, bool isActive) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = AppTheme.getPrimaryColor(context);
    final inactiveColor = isDark ? Colors.grey[700] : Colors.grey[300];
    final secondaryTextColor = AppTheme.getTextSecondaryColor(context);

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? activeColor : inactiveColor,
            boxShadow: isActive ? [
              BoxShadow(
                color: activeColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              )
            ] : null,
          ),
          child: Center(
            child: isActive && _currentStep > step - 1
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text(
                    '$step',
                    style: TextStyle(
                      color: isActive ? Colors.white : (isDark ? Colors.grey[400] : Colors.grey[600]),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? activeColor : secondaryTextColor,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmailStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = AppTheme.getTextSecondaryColor(context);
    final inputFillColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey[50];
    final borderColor = AppTheme.getBorderColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Nhập địa chỉ email',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Chúng tôi sẽ gửi mã xác nhận đến email của bạn',
          style: TextStyle(
            fontSize: 14,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: 32),

        // Email Field
        TextFormField(
          controller: _emailController,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: 'Email *',
            hintText: 'Nhập email của bạn',
            labelStyle: TextStyle(color: secondaryTextColor),
            hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.7)),
            prefixIcon: Icon(Icons.email_outlined, color: secondaryTextColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppTheme.getPrimaryColor(context)),
            ),
            filled: true,
            fillColor: inputFillColor,
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập email';
            }
            if (!value.contains('@') || !value.contains('.')) {
              return 'Email không hợp lệ';
            }
            return null;
          },
          enabled: !_isLoading,
        ),
        const SizedBox(height: 24),

        // Send Code Button
        CustomButton(
          text: 'Gửi Mã Xác Nhận',
          gradient: AppTheme.getPrimaryGradient(context),
          isLoading: _isLoading,
          onPressed: _sendResetCode,
        ),
      ],
    );
  }

  Widget _buildCodeStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = AppTheme.getTextSecondaryColor(context);
    final inputFillColor = isDark ? const Color(0xFF2C2C2C) : Colors.grey[50];
    final borderColor = AppTheme.getBorderColor(context);
    final primaryColor = AppTheme.getPrimaryColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Nhập mã xác nhận',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Mã xác nhận đã được gửi đến ${_emailController.text}',
          style: TextStyle(
            fontSize: 14,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: 32),

        // Verification Code
        TextFormField(
          controller: _codeController,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: 'Mã xác nhận *',
            hintText: 'Nhập mã xác nhận',
            labelStyle: TextStyle(color: secondaryTextColor),
            hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.7)),
            prefixIcon: Icon(Icons.pin_outlined, color: secondaryTextColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor),
            ),
            filled: true,
            fillColor: inputFillColor,
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập mã xác nhận';
            }
            if (value.length < 6) {
              return 'Mã xác nhận phải có 6 chữ số';
            }
            return null;
          },
          enabled: !_isLoading,
        ),
        const SizedBox(height: 16),

        // New Password
        TextFormField(
          controller: _newPasswordController,
          obscureText: _obscurePassword,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: 'Mật khẩu mới *',
            hintText: 'Nhập mật khẩu mới',
            labelStyle: TextStyle(color: secondaryTextColor),
            hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.7)),
            prefixIcon: Icon(Icons.lock_outline, color: secondaryTextColor),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: secondaryTextColor,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor),
            ),
            filled: true,
            fillColor: inputFillColor,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập mật khẩu mới';
            }
            if (value.length < 8) {
              return 'Mật khẩu phải có ít nhất 8 ký tự';
            }
            return null;
          },
          enabled: !_isLoading,
        ),
        const SizedBox(height: 16),

        // Confirm Password
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            labelText: 'Xác nhận mật khẩu *',
            hintText: 'Nhập lại mật khẩu mới',
            labelStyle: TextStyle(color: secondaryTextColor),
            hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.7)),
            prefixIcon: Icon(Icons.lock_outline, color: secondaryTextColor),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: secondaryTextColor,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor),
            ),
            filled: true,
            fillColor: inputFillColor,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng xác nhận mật khẩu';
            }
            if (value != _newPasswordController.text) {
              return 'Mật khẩu xác nhận không khớp';
            }
            return null;
          },
          enabled: !_isLoading,
        ),
        const SizedBox(height: AppTheme.spaceLarge),

        // Reset Password Button
        CustomButton(
          text: 'Đặt Lại Mật Khẩu',
          gradient: AppTheme.getPrimaryGradient(context),
          isLoading: _isLoading,
          onPressed: _verifyAndResetPassword,
        ),
        const SizedBox(height: AppTheme.spaceMedium),

        // Resend Code
        Center(
          child: TextButton(
            onPressed: _resendCountdown > 0 || _isLoading
                ? null
                : _sendResetCode,
            child: Text(
              _resendCountdown > 0
                  ? 'Gửi lại mã sau ${_resendCountdown}s'
                  : 'Gửi lại mã xác nhận',
              style: TextStyle(
                color: _resendCountdown > 0 ? secondaryTextColor : primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor = AppTheme.getTextSecondaryColor(context);
    final successColor = isDark ? AppTheme.darkAccentGreen : AppTheme.lightAccentGreen;

    return Column(
      children: [
        const SizedBox(height: 32),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: successColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: 60,
            color: successColor,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Thành công!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Mật khẩu của bạn đã được đặt lại',
          style: TextStyle(
            fontSize: 16,
            color: secondaryTextColor,
          ),
        ),
        const SizedBox(height: 32),
        CustomButton(
          text: 'Quay Lại Đăng Nhập',
          gradient: AppTheme.getPrimaryGradient(context),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
