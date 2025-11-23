import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Gradient? gradient;
  final IconData? icon;
  final Color? color;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.gradient,
    this.icon,
    this.color,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (gradient != null) {
      return _buildGradientButton();
    } else if (isOutlined) {
      return _buildOutlinedButton(context);
    } else {
      return _buildElevatedButton(context);
    }
  }

  Widget _buildGradientButton() {
    return Container(
      width: width,
      height: height ?? 50,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: onPressed != null ? AppTheme.buttonShadow : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceLarge,
              vertical: AppTheme.spaceMedium,
            ),
            child: _buildButtonContent(Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildElevatedButton(BuildContext context) {
    return SizedBox(
      width: width,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? AppTheme.getPrimaryColor(context),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: (color ?? AppTheme.getPrimaryColor(context)).withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceLarge,
            vertical: AppTheme.spaceMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
        child: _buildButtonContent(Colors.white),
      ),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    final primaryColor = color ?? AppTheme.getPrimaryColor(context);
    return SizedBox(
      width: width,
      height: height ?? 50,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(
            color: primaryColor,
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceLarge,
            vertical: AppTheme.spaceMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
        child: _buildButtonContent(primaryColor),
      ),
    );
  }

  Widget _buildButtonContent(Color textColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: AppTheme.spaceSmall),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }
}
