import 'package:flutter/material.dart';

class AppTheme {
  // ============ LIGHT MODE COLORS - Pastel Palette ============
  // Primary Colors - Soft Blue Pastel
  static const Color lightPrimary = Color(0xFF7FB3D5);      // Pastel Blue
  static const Color lightPrimaryVariant = Color(0xFFAED6F1); // Lighter Blue
  static const Color lightPrimaryDark = Color(0xFF5499C7);   // Deeper Blue
  
  // Secondary Colors - Soft Pink Pastel
  static const Color lightSecondary = Color(0xFFF8B4D9);     // Pastel Pink
  static const Color lightSecondaryVariant = Color(0xFFFAD7E6); // Lighter Pink
  
  // Accent Colors - Pastel Palette
  static const Color lightAccentMint = Color(0xFF98D8C8);    // Pastel Mint
  static const Color lightAccentPeach = Color(0xFFFFCBA4);   // Pastel Peach
  static const Color lightAccentLavender = Color(0xFFD5AAFF); // Pastel Lavender
  static const Color lightAccentYellow = Color(0xFFF7DC6F);  // Pastel Yellow
  static const Color lightAccentCoral = Color(0xFFFF9A9A);   // Pastel Coral
  static const Color lightAccentGreen = Color(0xFFA8E6CF);   // Pastel Green
  
  // Background & Surface
  static const Color lightBackground = Color(0xFFFAFBFC);    // Very Light Blue-Gray
  static const Color lightSurface = Color(0xFFFFFFFF);       // Pure White
  static const Color lightCard = Color(0xFFFFFFFF);          // Pure White
  
  // Text Colors
  static const Color lightTextPrimary = Color(0xFF2C3E50);   // Dark Blue-Gray
  static const Color lightTextSecondary = Color(0xFF7F8C8D); // Medium Gray
  static const Color lightTextHint = Color(0xFFBDC3C7);      // Light Gray
  
  // Borders & Dividers
  static const Color lightBorder = Color(0xFFE8F0F7);        // Very Light Blue
  static const Color lightDivider = Color(0xFFECF0F1);       // Light Gray
  
  // ============ DARK MODE COLORS - Pastel Palette ============
  // Primary Colors - Soft Blue Pastel (adjusted for dark)
  static const Color darkPrimary = Color(0xFF85C1E2);        // Bright Pastel Blue
  static const Color darkPrimaryVariant = Color(0xFFB3D9EC); // Lighter variant
  static const Color darkPrimaryDark = Color(0xFF5A9DBF);    // Deeper variant
  
  // Secondary Colors - Soft Pink Pastel (adjusted for dark)
  static const Color darkSecondary = Color(0xFFFFB3D9);      // Bright Pastel Pink
  static const Color darkSecondaryVariant = Color(0xFFFFCCE5); // Lighter variant
  
  // Accent Colors - Pastel Palette (adjusted for dark)
  static const Color darkAccentMint = Color(0xFF7FD4C1);     // Bright Pastel Mint
  static const Color darkAccentPeach = Color(0xFFFFD4A8);    // Bright Pastel Peach
  static const Color darkAccentLavender = Color(0xFFDDB3FF); // Bright Pastel Lavender
  static const Color darkAccentYellow = Color(0xFFFDE992);   // Bright Pastel Yellow
  static const Color darkAccentCoral = Color(0xFFFFADAD);    // Bright Pastel Coral
  static const Color darkAccentGreen = Color(0xFFB8F0D9);    // Bright Pastel Green
  
  // Background & Surface - Dark mode with warmth
  static const Color darkBackground = Color(0xFF1A1F2E);     // Deep Navy Blue
  static const Color darkSurface = Color(0xFF252B3B);        // Slightly lighter Navy
  static const Color darkCard = Color(0xFF2D3548);           // Card background
  
  // Text Colors - High contrast for readability
  static const Color darkTextPrimary = Color(0xFFF0F3F7);    // Almost White
  static const Color darkTextSecondary = Color(0xFFB8BCC8);  // Light Gray
  static const Color darkTextHint = Color(0xFF7A7E8A);       // Medium Gray
  
  // Borders & Dividers
  static const Color darkBorder = Color(0xFF3D4557);         // Subtle border
  static const Color darkDivider = Color(0xFF35394A);        // Divider line
  
  // ============ GRADIENTS ============
  // Light Mode Gradients
  static const LinearGradient lightPrimaryGradient = LinearGradient(
    colors: [Color(0xFF7FB3D5), Color(0xFF5499C7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient lightSecondaryGradient = LinearGradient(
    colors: [Color(0xFFF8B4D9), Color(0xFFFFCBA4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient lightSuccessGradient = LinearGradient(
    colors: [Color(0xFFA8E6CF), Color(0xFF98D8C8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient lightWarningGradient = LinearGradient(
    colors: [Color(0xFFF7DC6F), Color(0xFFFFCBA4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient lightDangerGradient = LinearGradient(
    colors: [Color(0xFFFF9A9A), Color(0xFFFFB3D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Dark Mode Gradients
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFF85C1E2), Color(0xFF5A9DBF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkSecondaryGradient = LinearGradient(
    colors: [Color(0xFFFFB3D9), Color(0xFFFFD4A8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkSuccessGradient = LinearGradient(
    colors: [Color(0xFFB8F0D9), Color(0xFF7FD4C1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkWarningGradient = LinearGradient(
    colors: [Color(0xFFFDE992), Color(0xFFFFD4A8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkDangerGradient = LinearGradient(
    colors: [Color(0xFFFFADAD), Color(0xFFFFB3D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Color divider = Color(0xFFE0E0E0);
  static const Color border = Color(0xFFE0E0E0);
  
  // ============ LEGACY COMPATIBILITY PROPERTIES ============
  // These are used by existing widgets and screens
  static const Color primaryBlue = lightPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textPrimary = lightTextPrimary;
  static const Color textHint = lightTextHint;
  static const Color cardBackground = lightCard;
  static const Color accentRed = lightAccentCoral;
  static const LinearGradient primaryGradient = lightPrimaryGradient;
  
  // ============ SHADOWS ============
  static List<BoxShadow> get lightCardShadow => [
    BoxShadow(
      color: const Color(0xFF7FB3D5).withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: const Color(0xFF7FB3D5).withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get darkCardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 8,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get lightButtonShadow => [
    BoxShadow(
      color: const Color(0xFF7FB3D5).withValues(alpha: 0.25),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get darkButtonShadow => [
    BoxShadow(
      color: const Color(0xFF85C1E2).withValues(alpha: 0.3),
      blurRadius: 16,
      offset: const Offset(0, 6),
      spreadRadius: 0,
    ),
  ];
  
  // Shadows - Legacy
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: const Color(0xFF7FB3D5).withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  // ============ SPACING & RADIUS ============
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 24.0;
  static const double radiusRound = 100.0;
  
  // Spacing
  static const double spaceXSmall = 4.0;
  static const double spaceSmall = 8.0;
  static const double spaceMedium = 16.0;
  static const double spaceLarge = 24.0;
  static const double spaceXLarge = 32.0;
  static const double spaceXXLarge = 48.0;
  
  // ============ TYPOGRAPHY ============
  static const String fontFamily = 'Roboto';
  
  // Light Mode Typography
  static TextStyle get lightDisplayLarge => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: lightTextPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static TextStyle get lightDisplayMedium => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: lightTextPrimary,
    height: 1.2,
    letterSpacing: -0.3,
  );
  
  static TextStyle get lightHeadlineLarge => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: lightTextPrimary,
    height: 1.3,
  );
  
  static TextStyle get lightHeadlineMedium => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: lightTextPrimary,
    height: 1.3,
  );
  
  static TextStyle get lightTitleLarge => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: lightTextPrimary,
    height: 1.4,
  );
  
  static TextStyle get lightTitleMedium => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: lightTextPrimary,
    height: 1.4,
  );
  
  static TextStyle get lightBodyLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: lightTextPrimary,
    height: 1.5,
  );
  
  static TextStyle get lightBodyMedium => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: lightTextPrimary,
    height: 1.5,
  );
  
  static TextStyle get lightBodySmall => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: lightTextSecondary,
    height: 1.5,
  );
  
  static TextStyle get lightLabelLarge => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: lightTextSecondary,
    height: 1.2,
  );
  
  static TextStyle get lightLabelMedium => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: lightTextSecondary,
    height: 1.2,
  );
  
  // Dark Mode Typography
  static TextStyle get darkDisplayLarge => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: darkTextPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static TextStyle get darkDisplayMedium => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: darkTextPrimary,
    height: 1.2,
    letterSpacing: -0.3,
  );
  
  static TextStyle get darkHeadlineLarge => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: darkTextPrimary,
    height: 1.3,
  );
  
  static TextStyle get darkHeadlineMedium => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: darkTextPrimary,
    height: 1.3,
  );
  
  static TextStyle get darkTitleLarge => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: darkTextPrimary,
    height: 1.4,
  );
  
  static TextStyle get darkTitleMedium => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: darkTextPrimary,
    height: 1.4,
  );
  
  static TextStyle get darkBodyLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: darkTextPrimary,
    height: 1.5,
  );
  
  static TextStyle get darkBodyMedium => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: darkTextPrimary,
    height: 1.5,
  );
  
  static TextStyle get darkBodySmall => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: darkTextSecondary,
    height: 1.5,
  );
  
  static TextStyle get darkLabelLarge => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: darkTextSecondary,
    height: 1.2,
  );
  
  static TextStyle get darkLabelMedium => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: darkTextSecondary,
    height: 1.2,
  );
  
  // Legacy Typography (for backward compatibility)
  static TextStyle get displayLarge => lightDisplayLarge;
  static TextStyle get displayMedium => lightDisplayMedium;
  static TextStyle get headlineLarge => lightHeadlineLarge;
  static TextStyle get headlineMedium => lightHeadlineMedium;
  static TextStyle get titleLarge => lightTitleLarge;
  static TextStyle get titleMedium => lightTitleMedium;
  static TextStyle get bodyLarge => lightBodyLarge;
  static TextStyle get bodyMedium => lightBodyMedium;
  static TextStyle get bodySmall => lightBodySmall;
  static TextStyle get labelLarge => lightLabelLarge;
  static TextStyle get labelMedium => lightLabelMedium;
  
  // ============ LIGHT THEME ============
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: Brightness.light,
      
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        primaryContainer: lightPrimaryVariant,
        secondary: lightSecondary,
        secondaryContainer: lightSecondaryVariant,
        surface: lightSurface,
        surfaceContainerHighest: lightCard,
        background: lightBackground,
        error: lightAccentCoral,
        onPrimary: Colors.white,
        onSecondary: lightTextPrimary,
        onSurface: lightTextPrimary,
        onBackground: lightTextPrimary,
        onError: Colors.white,
        outline: lightBorder,
      ),
      
      scaffoldBackgroundColor: lightBackground,
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shadowColor: lightPrimary.withValues(alpha: 0.1),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          letterSpacing: 0.15,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 24,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 0,
        shadowColor: lightPrimary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        margin: const EdgeInsets.all(0),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: lightBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: lightBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: lightAccentCoral, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: lightAccentCoral, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMedium,
          vertical: spaceMedium,
        ),
        hintStyle: TextStyle(color: lightTextHint),
        labelStyle: TextStyle(color: lightTextSecondary),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: lightPrimary.withValues(alpha: 0.25),
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLarge,
            vertical: spaceMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightPrimary,
          side: const BorderSide(color: lightPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLarge,
            vertical: spaceMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: lightPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceMedium,
            vertical: spaceSmall,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.25,
          ),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lightSecondary,
        foregroundColor: lightTextPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: lightTextSecondary,
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: lightDivider,
        thickness: 1,
        space: 1,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: lightPrimary,
        unselectedItemColor: lightTextSecondary,
        selectedIconTheme: const IconThemeData(size: 28),
        unselectedIconTheme: const IconThemeData(size: 24),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: lightPrimaryVariant,
        selectedColor: lightPrimary,
        disabledColor: lightBorder,
        labelStyle: TextStyle(color: lightTextPrimary),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: lightTextPrimary,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: lightSurface,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        titleTextStyle: lightHeadlineMedium,
        contentTextStyle: lightBodyMedium,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: lightPrimary,
        circularTrackColor: lightBorder,
      ),
    );
  }
  
  // ============ DARK THEME ============
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: fontFamily,
      brightness: Brightness.dark,
      
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        primaryContainer: darkPrimaryVariant,
        secondary: darkSecondary,
        secondaryContainer: darkSecondaryVariant,
        surface: darkSurface,
        surfaceContainerHighest: darkCard,
        background: darkBackground,
        error: darkAccentCoral,
        onPrimary: darkBackground,
        onSecondary: darkTextPrimary,
        onSurface: darkTextPrimary,
        onBackground: darkTextPrimary,
        onError: darkBackground,
        outline: darkBorder,
      ),
      
      scaffoldBackgroundColor: darkBackground,
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
        foregroundColor: darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkTextPrimary,
          letterSpacing: 0.15,
        ),
        iconTheme: const IconThemeData(
          color: darkTextPrimary,
          size: 24,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        margin: const EdgeInsets.all(0),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: darkBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: darkBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: darkAccentCoral, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: darkAccentCoral, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMedium,
          vertical: spaceMedium,
        ),
        hintStyle: TextStyle(color: darkTextHint),
        labelStyle: TextStyle(color: darkTextSecondary),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: darkBackground,
          elevation: 0,
          shadowColor: darkPrimary.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLarge,
            vertical: spaceMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkPrimary,
          side: const BorderSide(color: darkPrimary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLarge,
            vertical: spaceMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceMedium,
            vertical: spaceSmall,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.25,
          ),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: darkSecondary,
        foregroundColor: darkBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
      ),
      
      // Icon Theme
      iconTheme: IconThemeData(
        color: darkTextSecondary,
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: darkDivider,
        thickness: 1,
        space: 1,
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: darkPrimary,
        unselectedItemColor: darkTextSecondary,
        selectedIconTheme: const IconThemeData(size: 28),
        unselectedIconTheme: const IconThemeData(size: 24),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: darkSurface,
        selectedColor: darkPrimary,
        disabledColor: darkBorder,
        labelStyle: TextStyle(color: darkTextPrimary),
        secondaryLabelStyle: TextStyle(color: darkBackground),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCard,
        contentTextStyle: TextStyle(color: darkTextPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: darkCard,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
        ),
        titleTextStyle: darkHeadlineMedium,
        contentTextStyle: darkBodyMedium,
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: darkPrimary,
        circularTrackColor: darkBorder,
      ),
    );
  }
  
  // ============ HELPER METHODS ============
  static BoxDecoration cardDecoration({Color? color, bool isDark = false}) {
    return BoxDecoration(
      color: color ?? (isDark ? darkCard : lightCard),
      borderRadius: BorderRadius.circular(radiusMedium),
      boxShadow: isDark ? darkCardShadow : lightCardShadow,
    );
  }
  
  static BoxDecoration gradientDecoration(Gradient gradient, {bool isDark = false}) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(radiusMedium),
      boxShadow: isDark ? darkButtonShadow : lightButtonShadow,
    );
  }
  
  static InputDecoration inputDecoration({
    required String label,
    String? hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool isDark = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
    );
  }
  
  // Get theme-aware colors
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkBackground 
        : lightBackground;
  }
  
  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkSurface 
        : lightSurface;
  }
  
  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkCard 
        : lightCard;
  }
  
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkPrimary 
        : lightPrimary;
  }
  
  static Color getSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkSecondary 
        : lightSecondary;
  }
  
  static Color getTextPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkTextPrimary 
        : lightTextPrimary;
  }
  
  static Color getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkTextSecondary 
        : lightTextSecondary;
  }
  
  static LinearGradient getPrimaryGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkPrimaryGradient 
        : lightPrimaryGradient;
  }
  
  static LinearGradient getSecondaryGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkSecondaryGradient 
        : lightSecondaryGradient;
  }
  
  static LinearGradient getSuccessGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkSuccessGradient 
        : lightSuccessGradient;
  }
  
  static LinearGradient getWarningGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkWarningGradient 
        : lightWarningGradient;
  }
  
  static LinearGradient getDangerGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkDangerGradient 
        : lightDangerGradient;
  }
}
