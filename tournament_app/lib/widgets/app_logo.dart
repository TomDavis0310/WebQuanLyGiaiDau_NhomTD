import 'package:flutter/material.dart';

/// Widget logo chính của ứng dụng
/// 
/// Có thể sử dụng ở nhiều nơi với các kích thước khác nhau
class AppLogo extends StatelessWidget {
  final double height;
  final double? width;
  final BoxFit fit;
  final bool showShadow;
  final BorderRadius? borderRadius;

  const AppLogo({
    Key? key,
    this.height = 40,
    this.width,
    this.fit = BoxFit.contain,
    this.showShadow = false,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget logo = Image.asset(
      'assets/images/LOGO.jpg',
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        // Nếu không load được logo, hiển thị placeholder
        return Container(
          height: height,
          width: width ?? height,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.sports_soccer,
            color: Colors.white,
            size: height * 0.6,
          ),
        );
      },
    );

    if (showShadow || borderRadius != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.zero,
          child: logo,
        ),
      );
    }

    return logo;
  }
}

/// Widget logo với text kèm theo
class AppLogoWithText extends StatelessWidget {
  final double logoHeight;
  final String? text;
  final TextStyle? textStyle;
  final MainAxisAlignment alignment;
  final double spacing;

  const AppLogoWithText({
    Key? key,
    this.logoHeight = 40,
    this.text,
    this.textStyle,
    this.alignment = MainAxisAlignment.center,
    this.spacing = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(height: logoHeight),
        if (text != null) ...[
          SizedBox(width: spacing),
          Text(
            text!,
            style: textStyle ??
                TextStyle(
                  fontSize: logoHeight * 0.5,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ],
    );
  }
}
