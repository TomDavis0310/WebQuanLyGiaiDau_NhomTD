import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/sport.dart';
import '../models/tournament.dart';
import '../models/api_response.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_wrapper.dart';
import 'tournament_list_screen.dart';
import 'tournament_detail_screen.dart';
import 'search_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> 
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  List<Sport> _sports = [];
  List<Tournament> _allTournaments = [];
  List<Tournament> _openTournaments = [];
  List<Tournament> _ongoingTournaments = [];
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        ApiService.getSports(),
        ApiService.getTournaments(),
      ]);

      final sportsResponse = results[0] as ApiResponse<List<Sport>>;
      final tournamentsResponse = results[1] as ApiResponse<List<Tournament>>;

      if (mounted) {
        setState(() {
          if (sportsResponse.success) _sports = sportsResponse.data ?? [];
          if (tournamentsResponse.success) {
            final tournaments = tournamentsResponse.data ?? [];
            _allTournaments = tournaments;
            _openTournaments = tournaments
                .where((t) => t.registrationStatus == 'Mở đăng ký')
                .toList();
            _ongoingTournaments = tournaments
                .where((t) => t.registrationStatus == 'Giải đấu đang diễn ra')
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.getBackgroundColor(context),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 160,
              floating: false,
              pinned: true,
              elevation: 0,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.getPrimaryGradient(context),
                ),
                child: FlexibleSpaceBar(
                  title: const Text(
                    'Khám Phá',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  centerTitle: false,
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Container(
                  color: AppTheme.getSurfaceColor(context),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: AppTheme.getPrimaryColor(context),
                    unselectedLabelColor: AppTheme.getTextSecondaryColor(context),
                    indicatorColor: AppTheme.getPrimaryColor(context),
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Tất Cả'),
                      Tab(text: 'Mở Đăng Ký'),
                      Tab(text: 'Đang Diễn Ra'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppTheme.getPrimaryColor(context),
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(_errorMessage!),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadData,
                    color: AppTheme.getPrimaryColor(context),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAllTab(isDark),
                        _buildTournamentsList(_openTournaments, isDark),
                        _buildTournamentsList(_ongoingTournaments, isDark),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildAllTab(bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Sports Categories
          AnimatedWrapper(
            index: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Môn Thể Thao',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.getTextPrimaryColor(context),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AnimatedWrapper(
            index: 1,
            child: SizedBox(
              height: 120,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: _sports.length,
                itemBuilder: (context, index) {
                  final sport = _sports[index];
                  return _buildSportCard(sport, isDark);
                },
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // All Tournaments
          AnimatedWrapper(
            index: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tất Cả Giải Đấu',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getTextPrimaryColor(context),
                    ),
                  ),
                  Text(
                    '${_allTournaments.length} giải',
                    style: TextStyle(
                      color: AppTheme.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          ..._allTournaments.map((tournament) => AnimatedWrapper(
            index: _allTournaments.indexOf(tournament) + 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: _buildTournamentCard(tournament, isDark),
            ),
          )),
          
          const SizedBox(height: 100), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildTournamentsList(List<Tournament> tournaments, bool isDark) {
    if (tournaments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Chưa có giải đấu',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: tournaments.length,
      itemBuilder: (context, index) {
        final tournament = tournaments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildTournamentCard(tournament, isDark),
        );
      },
    );
  }

  Widget _buildSportCard(Sport sport, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TournamentListScreen(sport: sport),
        ),
      ),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark ? AppTheme.darkCardShadow : AppTheme.lightCardShadow,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: CachedNetworkImage(
                imageUrl: sport.imageUrl ?? '',
                errorWidget: (context, url, error) => Icon(
                  Icons.sports_basketball,
                  color: AppTheme.getPrimaryColor(context),
                  size: 32,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              sport.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.getTextPrimaryColor(context),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentCard(Tournament tournament, bool isDark) {
    return Container(
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
                // Tournament Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: tournament.imageUrl ?? '',
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey[300],
                      child: const Icon(Icons.emoji_events, size: 40),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Tournament Info
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
                      if (tournament.location != null) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14,
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
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
                        const SizedBox(height: 4),
                      ],
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: AppTheme.getTextSecondaryColor(context),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${tournament.startDate.day}/${tournament.startDate.month}/${tournament.startDate.year}',
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
                          color: _getStatusColor(tournament.registrationStatus).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tournament.registrationStatus,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(tournament.registrationStatus),
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
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Mở đăng ký':
        return Colors.green;
      case 'Giải đấu đang diễn ra':
        return Colors.blue;
      case 'Giải đấu sắp diễn ra':
        return Colors.orange;
      case 'Giải đấu đã kết thúc':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
