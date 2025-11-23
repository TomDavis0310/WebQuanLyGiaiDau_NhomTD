import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/magnifying_nav_bar.dart';
import 'sports_list_screen.dart';
import 'news_list_screen.dart';
import 'dashboard_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'search_screen.dart';
import 'shop_screen.dart';

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
  bool _isExtended = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  List<CustomNavigationDestination> _getNavigationItems(bool isAuthenticated) {
    final List<CustomNavigationDestination> items = [
      const CustomNavigationDestination(
        icon: Icon(Icons.sports_basketball_outlined),
        selectedIcon: Icon(Icons.sports_basketball),
        iconData: Icons.sports_basketball_rounded,
        label: 'Trang Chủ',
      ),
      const CustomNavigationDestination(
        icon: Icon(Icons.newspaper_outlined),
        selectedIcon: Icon(Icons.newspaper),
        iconData: Icons.newspaper_rounded,
        label: 'Tin Tức',
      ),
      const CustomNavigationDestination(
        icon: Icon(Icons.search_outlined),
        selectedIcon: Icon(Icons.search),
        iconData: Icons.search_rounded,
        label: 'Tìm Kiếm',
      ),
    ];

    if (isAuthenticated) {
      items.addAll([
        const CustomNavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          iconData: Icons.dashboard_rounded,
          label: 'Dashboard',
        ),
        const CustomNavigationDestination(
          icon: Icon(Icons.shopping_bag_outlined),
          selectedIcon: Icon(Icons.shopping_bag),
          iconData: Icons.shopping_bag_rounded,
          label: 'Cửa Hàng',
        ),
        const CustomNavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          iconData: Icons.person_rounded,
          label: 'Cá Nhân',
        ),
      ]);
    } else {
      items.add(
        const CustomNavigationDestination(
          icon: Icon(Icons.login_outlined),
          selectedIcon: Icon(Icons.login),
          iconData: Icons.login_rounded,
          label: 'Đăng Nhập',
        ),
      );
    }

    return items;
  }

  Widget _getScreen(int index, bool isAuthenticated, {bool showAppBar = false}) {
    if (isAuthenticated) {
      switch (index) {
        case 0:
          return SportsListScreen(showAppBar: showAppBar);
        case 1:
          return NewsListScreen(showAppBar: showAppBar);
        case 2:
          return SearchScreen(showAppBar: showAppBar);
        case 3:
          return DashboardScreen(showAppBar: showAppBar);
        case 4:
          return ShopScreen(showAppBar: showAppBar);
        case 5:
          return ProfileScreen(showAppBar: showAppBar);
        default:
          return SportsListScreen(showAppBar: showAppBar);
      }
    } else {
      switch (index) {
        case 0:
          return SportsListScreen(showAppBar: showAppBar);
        case 1:
          return NewsListScreen(showAppBar: showAppBar);
        case 2:
          return SearchScreen(showAppBar: showAppBar);
        case 3:
          return const LoginScreen();
        default:
          return SportsListScreen(showAppBar: showAppBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final isAuthenticated = authProvider.isAuthenticated;
        final navigationItems = _getNavigationItems(isAuthenticated);
        
        // Đảm bảo selectedIndex không vượt quá số lượng items
        if (_selectedIndex >= navigationItems.length) {
          _selectedIndex = 0;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 640) {
              // Mobile layout with MagnifyingNavBar
              return Scaffold(
                body: _getScreen(_selectedIndex, isAuthenticated, showAppBar: true),
                bottomNavigationBar: MagnifyingNavBar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  icons: navigationItems.map((item) => item.iconData).toList(),
                  selectedItemColor: Theme.of(context).primaryColor,
                  unselectedItemColor: Colors.grey,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                ),
              );
            } else {
              // Desktop/Tablet layout with NavigationRail
              return Scaffold(
                body: Row(
                  children: [
                    // Navigation Rail ở bên trái
                    NavigationRail(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (int index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      extended: _isExtended,
                      labelType: _isExtended 
                          ? NavigationRailLabelType.none 
                          : NavigationRailLabelType.selected,
                      leading: Column(
                        children: [
                          const SizedBox(height: 8),
                          // Logo
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                'TD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                      trailing: Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Theme Toggle Button
                                Consumer<ThemeProvider>(
                                  builder: (context, themeProvider, child) {
                                    return IconButton(
                                      icon: Icon(
                                        themeProvider.isDarkMode 
                                            ? Icons.light_mode 
                                            : Icons.dark_mode,
                                      ),
                                      onPressed: () => themeProvider.toggleTheme(),
                                      tooltip: themeProvider.isDarkMode 
                                          ? 'Chế độ Sáng' 
                                          : 'Chế độ Tối',
                                      color: Theme.of(context).primaryColor,
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),
                                const Divider(height: 1),
                                const SizedBox(height: 8),
                                // Toggle button để mở rộng/thu nhỏ
                                IconButton(
                                  icon: Icon(_isExtended 
                                      ? Icons.arrow_back_ios 
                                      : Icons.arrow_forward_ios),
                                  onPressed: () {
                                    setState(() {
                                      _isExtended = !_isExtended;
                                    });
                                  },
                                  tooltip: _isExtended ? 'Thu nhỏ' : 'Mở rộng',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      destinations: navigationItems.map((item) {
                        return NavigationRailDestination(
                          icon: item.icon,
                          selectedIcon: item.selectedIcon,
                          label: Text(item.label),
                        );
                      }).toList(),
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      selectedIconTheme: IconThemeData(
                        color: Theme.of(context).primaryColor,
                        size: 28,
                      ),
                      unselectedIconTheme: IconThemeData(
                        color: Colors.grey[600],
                        size: 24,
                      ),
                      selectedLabelTextStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      unselectedLabelTextStyle: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    
                    // Vertical divider
                    const VerticalDivider(thickness: 1, width: 1),
                    
                    // Main content area
                    Expanded(
                      child: _getScreen(_selectedIndex, isAuthenticated, showAppBar: false),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }
}

// Helper class cho NavigationDestination
class CustomNavigationDestination {
  final Widget icon;
  final Widget selectedIcon;
  final IconData iconData;
  final String label;

  const CustomNavigationDestination({
    required this.icon,
    required this.selectedIcon,
    required this.iconData,
    required this.label,
  });
}
