import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'explore_screen.dart';
import 'video_highlights_screen.dart';
import 'shop_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  
  const MainNavigationScreen({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  List<NavigationItem> _getNavigationItems(bool isAuthenticated) {
    // New tab structure: Home | Explore | Videos | Shop | Profile/Login
    return [
      // Tab 0: Home (For everyone)
      NavigationItem(
        icon: Icons.home_outlined,
        selectedIcon: Icons.home_rounded,
        label: 'Trang Chủ',
        screen: const HomeScreen(),
      ),
      // Tab 1: Explore (For everyone)
      NavigationItem(
        icon: Icons.explore_outlined,
        selectedIcon: Icons.explore_rounded,
        label: 'Khám Phá',
        screen: const ExploreScreen(),
      ),
      // Tab 2: Videos (For everyone)
      NavigationItem(
        icon: Icons.play_circle_outline_rounded,
        selectedIcon: Icons.play_circle_rounded,
        label: 'Video',
        screen: const VideoHighlightsScreen(),
      ),
      // Tab 3: Shop (For everyone)
      NavigationItem(
        icon: Icons.shopping_bag_outlined,
        selectedIcon: Icons.shopping_bag_rounded,
        label: 'Cửa Hàng',
        screen: const ShopScreen(showAppBar: false),
      ),
      // Tab 4: Profile or Login
      NavigationItem(
        icon: isAuthenticated ? Icons.person_outline : Icons.login_outlined,
        selectedIcon: isAuthenticated ? Icons.person_rounded : Icons.login_rounded,
        label: isAuthenticated ? 'Cá Nhân' : 'Đăng Nhập',
        screen: isAuthenticated 
          ? const ProfileScreen(showAppBar: false) 
          : const LoginScreen(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isAuthenticated = authProvider.isAuthenticated;
        final navigationItems = _getNavigationItems(isAuthenticated);
        
        // Ensure selected index is within bounds
        if (_selectedIndex >= navigationItems.length) {
          _selectedIndex = 0;
        }

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: navigationItems.map((item) => item.screen).toList(),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              destinations: navigationItems.map((item) {
                return NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                );
              }).toList(),
              backgroundColor: AppTheme.getSurfaceColor(context),
              indicatorColor: AppTheme.getPrimaryColor(context).withOpacity(0.2),
              elevation: 0,
              height: 65,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            ),
          ),
        );
      },
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget screen;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.screen,
  });
}
