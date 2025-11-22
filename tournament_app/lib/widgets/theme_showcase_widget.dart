import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget để demo các màu pastel và gradient của theme
class ThemeShowcaseWidget extends StatelessWidget {
  const ThemeShowcaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Màu Pastel Chính', context),
          const SizedBox(height: 12),
          _buildColorRow(context, [
            _ColorItem('Primary', AppTheme.getPrimaryColor(context)),
            _ColorItem('Secondary', AppTheme.getSecondaryColor(context)),
          ]),
          const SizedBox(height: 8),
          _buildColorRow(context, [
            _ColorItem('Mint', isDark ? AppTheme.darkAccentMint : AppTheme.lightAccentMint),
            _ColorItem('Peach', isDark ? AppTheme.darkAccentPeach : AppTheme.lightAccentPeach),
          ]),
          const SizedBox(height: 8),
          _buildColorRow(context, [
            _ColorItem('Lavender', isDark ? AppTheme.darkAccentLavender : AppTheme.lightAccentLavender),
            _ColorItem('Yellow', isDark ? AppTheme.darkAccentYellow : AppTheme.lightAccentYellow),
          ]),
          const SizedBox(height: 8),
          _buildColorRow(context, [
            _ColorItem('Coral', isDark ? AppTheme.darkAccentCoral : AppTheme.lightAccentCoral),
            _ColorItem('Green', isDark ? AppTheme.darkAccentGreen : AppTheme.lightAccentGreen),
          ]),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Gradient Pastel', context),
          const SizedBox(height: 12),
          
          _buildGradientCard(
            'Primary Gradient',
            AppTheme.getPrimaryGradient(context),
            isDark,
          ),
          const SizedBox(height: 12),
          _buildGradientCard(
            'Secondary Gradient',
            AppTheme.getSecondaryGradient(context),
            isDark,
          ),
          const SizedBox(height: 12),
          _buildGradientCard(
            'Success Gradient',
            AppTheme.getSuccessGradient(context),
            isDark,
          ),
          const SizedBox(height: 12),
          _buildGradientCard(
            'Warning Gradient',
            AppTheme.getWarningGradient(context),
            isDark,
          ),
          const SizedBox(height: 12),
          _buildGradientCard(
            'Danger Gradient',
            AppTheme.getDangerGradient(context),
            isDark,
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Buttons với Pastel', context),
          const SizedBox(height: 12),
          
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.star),
            label: const Text('Elevated Button'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
            label: const Text('Outlined Button'),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.share),
            label: const Text('Text Button'),
          ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Cards với Shadow', context),
          const SizedBox(height: 12),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration(isDark: isDark),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      color: AppTheme.getPrimaryColor(context),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pastel Card',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Text(
                            'Với shadow pastel tươi sáng',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: AppTheme.getPrimaryGradient(context),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gradient Background',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  Widget _buildColorRow(BuildContext context, List<_ColorItem> colors) {
    return Row(
      children: colors.map((color) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.color,
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            boxShadow: [
              BoxShadow(
                color: color.color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              color.name,
              style: TextStyle(
                color: _getContrastColor(color.color),
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }
  
  Widget _buildGradientCard(String title, LinearGradient gradient, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: isDark ? AppTheme.darkButtonShadow : AppTheme.lightButtonShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Icon(
            Icons.arrow_forward,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
  
  Color _getContrastColor(Color color) {
    // Calculate luminance to determine if we need dark or light text
    final luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

class _ColorItem {
  final String name;
  final Color color;
  
  _ColorItem(this.name, this.color);
}
