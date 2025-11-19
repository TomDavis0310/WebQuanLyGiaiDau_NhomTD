import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final Gradient? gradient;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;

  const CustomCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(AppTheme.spaceSmall),
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppTheme.cardBackground) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppTheme.radiusMedium,
        ),
        boxShadow: boxShadow ?? AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppTheme.radiusMedium,
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppTheme.spaceMedium),
            child: child,
          ),
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? color;
  final Gradient? gradient;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      gradient: gradient,
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceSmall),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: Icon(
                  icon,
                  color: gradient != null ? Colors.white : (color ?? AppTheme.primaryBlue),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMedium),
          Text(
            value,
            style: AppTheme.headlineLarge.copyWith(
              color: gradient != null ? Colors.white : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: AppTheme.spaceXSmall),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              color: gradient != null 
                  ? Colors.white.withValues(alpha: 0.9) 
                  : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
