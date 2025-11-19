import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sport.dart';
import '../services/api_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_widget.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'tournament_list_screen.dart';
import 'news_list_screen.dart';
import 'search_screen.dart';
import 'dashboard_screen.dart';

class SportsListScreen extends StatefulWidget {
  const SportsListScreen({super.key});
  @override
  _SportsListScreenState createState() => _SportsListScreenState();
}

class _SportsListScreenState extends State<SportsListScreen> {
  List<Sport> sports = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadSports();
  }

  Future<void> loadSports() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getSports();
      
      if (response.success && response.data != null) {
        setState(() {
          sports = response.data!;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response.message;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi kết nối: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppLogoWithText(
          logoHeight: 40,
          text: 'Danh Sách Môn Thể Thao',
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
            tooltip: 'Tìm kiếm',
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (!authProvider.isAuthenticated) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.dashboard),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ),
                  );
                },
                tooltip: 'Dashboard',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.newspaper),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NewsListScreen(),
                ),
              );
            },
            tooltip: 'Tin tức',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadSports,
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                icon: Icon(
                  authProvider.isAuthenticated 
                      ? Icons.person 
                      : Icons.login,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => authProvider.isAuthenticated
                          ? const ProfileScreen()
                          : const LoginScreen(),
                    ),
                  );
                },
                tooltip: authProvider.isAuthenticated 
                    ? 'Thông tin cá nhân' 
                    : 'Đăng nhập',
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F7FA),
              Colors.white,
            ],
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const LoadingWidget(message: 'Đang tải dữ liệu...');
    }

    if (errorMessage != null) {
      return CustomErrorWidget(
        message: errorMessage!,
        onRetry: loadSports,
      );
    }

    if (sports.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.sports,
        title: 'Chưa có môn thể thao',
        message: 'Hiện tại chưa có môn thể thao nào được thêm vào hệ thống',
      );
    }

    return RefreshIndicator(
      onRefresh: loadSports,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spaceMedium),
        itemCount: sports.length,
        itemBuilder: (context, index) {
          final sport = sports[index];
          return _buildSportCard(sport);
        },
      ),
    );
  }

  Widget _buildSportCard(Sport sport) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TournamentListScreen(sport: sport),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMedium),
            child: Row(
              children: [
                // Sport Icon/Image with Hero animation
                Hero(
                  tag: 'sport_${sport.id}',
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: sport.imageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            child: Image.network(
                              sport.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.sports_basketball,
                                  size: 36,
                                  color: Colors.white,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.sports_basketball,
                            size: 36,
                            color: Colors.white,
                          ),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMedium),
                
                // Sport Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sport.name,
                        style: AppTheme.titleLarge,
                      ),
                      const SizedBox(height: AppTheme.spaceXSmall),
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: AppTheme.spaceXSmall),
                          Text(
                            '${sport.tournamentCount} giải đấu',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.textHint,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
