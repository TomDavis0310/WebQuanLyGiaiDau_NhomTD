import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/news.dart';
import '../models/tournament.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_wrapper.dart';
import 'tournament_detail_screen.dart';
import 'news_detail_screen.dart';
import 'match_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  List<News> _featuredNews = [];
  List<Tournament> _liveTournaments = [];
  List<Tournament> _upcomingTournaments = [];
  List<dynamic> _liveMatches = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getFeaturedNews(count: 5),
        ApiService.getTournaments(),
      ]);

      final newsResponse = results[0] as ApiResponse<List<News>>;
      final tournamentsResponse = results[1] as ApiResponse<List<Tournament>>;

      if (mounted) {
        setState(() {
          if (newsResponse.success) _featuredNews = newsResponse.data ?? [];
          if (tournamentsResponse.success) {
            final tournaments = tournamentsResponse.data ?? [];
            _liveTournaments = tournaments
                .where((t) => t.registrationStatus == 'Giải đấu đang diễn ra')
                .take(3)
                .toList();
            _upcomingTournaments = tournaments
                .where((t) =>
                    t.registrationStatus != 'Giải đấu đang diễn ra' &&
                    t.registrationStatus != 'Giải đấu đã kết thúc')
                .take(5)
                .toList();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Lỗi kết nối: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App Bar with gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.getPrimaryGradient(context),
              ),
              child: FlexibleSpaceBar(
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authProvider.isAuthenticated 
                        ? 'Chào ${authProvider.user?.userName ?? "bạn"}!' 
                        : 'TDSports',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (authProvider.isAuthenticated)
                      const Text(
                        'Khám phá thế giới thể thao',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/search'),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
              ),
            ],
          ),

          // Loading or Error
          if (_isLoading)
            SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.getPrimaryColor(context),
                ),
              ),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(_errorMessage!, style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadHomeData,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: RefreshIndicator(
                onRefresh: _loadHomeData,
                color: AppTheme.getPrimaryColor(context),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      
                      // Quick Actions
                      AnimatedWrapper(
                        index: 0,
                        child: _buildQuickActions(context),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Live Matches/Tournaments
                      if (_liveTournaments.isNotEmpty) ...[
                        AnimatedWrapper(
                          index: 1,
                          child: _buildSection(
                            context,
                            'Đang Diễn Ra',
                            Icons.live_tv_rounded,
                            Colors.red,
                            () {},
                          ),
                        ),
                        AnimatedWrapper(
                          index: 2,
                          child: _buildLiveTournaments(isDark),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Featured News
                      if (_featuredNews.isNotEmpty) ...[
                        AnimatedWrapper(
                          index: 3,
                          child: _buildSection(
                            context,
                            'Tin Tức Nổi Bật',
                            Icons.newspaper_rounded,
                            AppTheme.lightSecondary,
                            () => Navigator.pushNamed(context, '/news'),
                          ),
                        ),
                        AnimatedWrapper(
                          index: 4,
                          child: _buildFeaturedNews(isDark),
                        ),
                        const SizedBox(height: 24),
                      ],
                      
                      // Upcoming Tournaments
                      if (_upcomingTournaments.isNotEmpty) ...[
                        AnimatedWrapper(
                          index: 5,
                          child: _buildSection(
                            context,
                            'Giải Đấu Sắp Diễn Ra',
                            Icons.emoji_events_rounded,
                            AppTheme.lightAccentYellow,
                            () {},
                          ),
                        ),
                        AnimatedWrapper(
                          index: 6,
                          child: _buildUpcomingTournaments(isDark),
                        ),
                      ],
                      
                      const SizedBox(height: 100), // Bottom padding for nav bar
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = authProvider.isAuthenticated;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickActionCard(
              'Trực Tiếp',
              Icons.play_circle_fill_rounded,
              const Color(0xFFFF6B6B),
              const Color(0xFFFFE5E5),
              () => Navigator.pushNamed(context, '/live-streaming'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              'Highlights',
              Icons.video_library_rounded,
              const Color(0xFF9C27B0),
              const Color(0xFFF3E5F5),
              () => Navigator.pushNamed(context, '/video-highlights'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              isAuthenticated ? 'Hoạt Động' : 'Tìm Kiếm',
              isAuthenticated ? Icons.dashboard_rounded : Icons.search_rounded,
              const Color(0xFF00BCD4),
              const Color(0xFFE0F7FA),
              () => isAuthenticated 
                ? Navigator.pushNamed(context, '/dashboard')
                : Navigator.pushNamed(context, '/search'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              'Cửa Hàng',
              Icons.shopping_bag_rounded,
              const Color(0xFF4CAF50),
              const Color(0xFFE8F5E9),
              () => Navigator.pushNamed(context, '/shop'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String label,
    IconData icon,
    Color iconColor,
    Color bgColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimaryColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onSeeAll,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: onSeeAll,
            child: const Text('Xem tất cả'),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTournaments(bool isDark) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _liveTournaments.length,
        itemBuilder: (context, index) {
          final tournament = _liveTournaments[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TournamentDetailScreen(tournamentId: tournament.id),
              ),
            ),
            child: Container(
              width: 280,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? AppTheme.darkCardShadow : AppTheme.lightCardShadow,
              ),
              child: Stack(
                children: [
                  // Background Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: tournament.imageUrl ?? '',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.emoji_events, size: 64),
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),
                  // Live Badge
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.circle, color: Colors.white, size: 8),
                          SizedBox(width: 6),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Tournament Info
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tournament.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (tournament.location != null)
                            Row(
                              children: [
                                const Icon(Icons.location_on, color: Colors.white70, size: 14),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    tournament.location!,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedNews(bool isDark) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _featuredNews.length,
        itemBuilder: (context, index) {
          final news = _featuredNews[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NewsDetailScreen(newsId: news.newsId),
              ),
            ),
            child: Container(
              width: 300,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDark ? AppTheme.darkCardShadow : AppTheme.lightCardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    // News Image
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: CachedNetworkImage(
                      imageUrl: news.imageUrl,
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.newspaper, size: 48),
                      ),
                    ),
                  ),
                  // News Info
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            news.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getTextPrimaryColor(context),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Icon(Icons.access_time, 
                                size: 12, 
                                color: AppTheme.getTextSecondaryColor(context)),
                              const SizedBox(width: 4),
                              Text(
                                news.timeAgo,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.getTextSecondaryColor(context),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingTournaments(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _upcomingTournaments.map((tournament) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDark ? AppTheme.darkCardShadow : AppTheme.lightCardShadow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TournamentDetailScreen(tournamentId: tournament.id),
                  ),
                ),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: tournament.imageUrl ?? '',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.emoji_events),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tournament.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppTheme.getTextPrimaryColor(context),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            if (tournament.location != null)
                              Row(
                                children: [
                                  Icon(Icons.location_on, 
                                    size: 14, 
                                    color: AppTheme.getTextSecondaryColor(context)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      tournament.location!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.getTextSecondaryColor(context),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                tournament.registrationStatus,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.getPrimaryColor(context),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.getTextSecondaryColor(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
