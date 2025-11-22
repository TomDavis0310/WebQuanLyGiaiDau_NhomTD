import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/theme_showcase_widget.dart';

class ThemePreviewScreen extends StatelessWidget {
  const ThemePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Pastel Preview'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: isDark ? 'Chế độ Sáng' : 'Chế độ Tối',
          ),
        ],
      ),
      body: const ThemeShowcaseWidget(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => themeProvider.toggleTheme(),
        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
        label: Text(isDark ? 'Light Mode' : 'Dark Mode'),
      ),
    );
  }
}
