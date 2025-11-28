import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/sport.dart';
import '../models/news.dart';
import '../models/tournament.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'tournament_list_screen.dart';
import 'tournament_detail_screen.dart';

class SportsListScreen extends StatefulWidget {
  final bool showAppBar;
  
  const SportsListScreen({super.key, this.showAppBar = true});
  
  @override
  _SportsListScreenState createState() => _SportsListScreenState();
}

class _SportsListScreenState extends State<SportsListScreen> {
  List<Sport> sports = [];
  List<News> featuredNews = [];
  List<Tournament> featuredTournaments = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getSports(),
        ApiService.getFeaturedNews(count: 5),
        ApiService.getTournaments(), // We'll take top 5
      ]);

      final sportsResponse = results[0] as ApiResponse<List<Sport>>;
      final newsResponse = results[1] as ApiResponse<List<News>>;
      final tournamentsResponse = results[2] as ApiResponse<List<Tournament>>;

      if (mounted) {
        setState(() {
          if (sportsResponse.success) sports = sportsResponse.data ?? [];
          if (newsResponse.success) featuredNews = newsResponse.data ?? [];
          if (tournamentsResponse.success) {
            featuredTournaments = (tournamentsResponse.data ?? []).take(5).toList();
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Lỗi kết nối: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text(
                'TDSports',
                style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Montserrat'),
              ),
              centerTitle: true,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.getPrimaryGradient(context),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => Navigator.pushNamed(context, '/search'),
                ),
              ],
            )
          : null,
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.getPrimaryColor(context)))
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage!),
                      ElevatedButton(onPressed: _loadData, child: const Text('Thử lại')),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar (Only show if no AppBar, or as a secondary search)
                        // If we have AppBar with search icon, maybe we don't need this big search bar?
                        // But the big search bar is nice for "Explore".
                        // Let's keep it but maybe make it look like a filter or "Quick Search".
                        
                        if (!widget.showAppBar)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/search'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.search, color: Colors.grey[500]),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Tìm kiếm giải đấu, đội bóng...',
                                      style: TextStyle(color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Quick Menu (New Feature)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildQuickMenuItem(context, 'Trực Tiếp', Icons.live_tv_rounded, const Color(0xFFFF6B6B), '/live-streaming'),
                              _buildQuickMenuItem(context, 'Highlights', Icons.play_circle_fill_rounded, const Color(0xFF9C27B0), '/video-highlights'),
                              _buildQuickMenuItem(context, 'Tin Nhắn', Icons.chat_bubble_rounded, const Color(0xFF4FC3F7), '/chat'),
                              _buildQuickMenuItem(context, 'Cửa Hàng', Icons.shopping_bag_rounded, const Color(0xFFFFB74D), '/shop'),
                            ],
                          ),
                        ),

                        // Sports Categories
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Môn Thể Thao',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.titleLarge?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: sports.length,
                            itemBuilder: (context, index) {
                              final sport = sports[index];
                              return GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => TournamentListScreen(sport: sport)),
                                ),
                                child: Container(
                                  width: 80,
                                  margin: const EdgeInsets.symmetric(horizontal: 5),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 60,
                                        width: 60,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).cardColor,
                                          borderRadius: BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.1),
                                              blurRadius: 5,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: sport.imageUrl ?? '',
                                          errorWidget: (context, url, error) => Icon(
                                            Icons.sports_basketball,
                                            color: AppTheme.getPrimaryColor(context),
                                          ),
                                          placeholder: (context, url) => CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        sport.name,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).textTheme.bodyMedium?.color,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 25),

                        // Featured Tournaments
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Giải Đấu Mới',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.titleLarge?.color,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Navigate to all tournaments if needed
                                },
                                child: Text('Xem tất cả'),
                              ),
                            ],
                          ),
                        ),
                        AnimationLimiter(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: featuredTournaments.length,
                            itemBuilder: (context, index) {
                              final tournament = featuredTournaments[index];
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 15),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.1),
                                            blurRadius: 5,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(15),
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => TournamentDetailScreen(tournamentId: tournament.id),
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: CachedNetworkImage(
                                                    imageUrl: tournament.imageUrl ?? '',
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.cover,
                                                    errorWidget: (context, url, error) => Container(
                                                      color: Colors.grey[200],
                                                      child: const Icon(Icons.emoji_events),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 15),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        tournament.name,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Row(
                                                        children: [
                                                          Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                                                          const SizedBox(width: 4),
                                                          Expanded(
                                                            child: Text(
                                                              tournament.location ?? 'Chưa cập nhật',
                                                              style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(5),
                                                        ),
                                                        child: Text(
                                                          tournament.registrationStatus,
                                                          style: TextStyle(
                                                            color: AppTheme.getPrimaryColor(context),
                                                            fontSize: 10,
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
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 80), // Bottom padding for nav bar
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildQuickMenuItem(BuildContext context, String label, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: color.withOpacity(0.2), width: 1),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
