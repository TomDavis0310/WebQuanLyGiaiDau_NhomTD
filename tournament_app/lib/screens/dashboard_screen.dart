import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/dashboard.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'team_detail_screen.dart';
import 'tournament_detail_screen.dart';
import 'match_detail_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_wrapper.dart';

class DashboardScreen extends StatefulWidget {
  final bool showAppBar;
  
  const DashboardScreen({Key? key, this.showAppBar = true}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DashboardOverview? _overview;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Vui lòng đăng nhập để xem dashboard';
      });
      return;
    }

    final response = await ApiService.getDashboardOverview(token: token);

    if (response.success && response.data != null) {
      setState(() {
        _overview = response.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = response.message;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showAppBar) {
      // Khi không có AppBar, hiển thị TabBar ở trong body
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: AppTheme.getPrimaryColor(context),
              unselectedLabelColor: AppTheme.getTextSecondaryColor(context),
              indicatorColor: AppTheme.getPrimaryColor(context),
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: const [
                Tab(icon: Icon(Icons.dashboard_rounded), text: 'Tổng Quan'),
                Tab(icon: Icon(Icons.emoji_events_rounded), text: 'Giải Đấu'),
                Tab(icon: Icon(Icons.sports_soccer_rounded), text: 'Trận Đấu'),
                Tab(icon: Icon(Icons.history_rounded), text: 'Hoạt Động'),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: AppTheme.getPrimaryColor(context)))
                : _errorMessage != null
                    ? _buildErrorWidget()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildOverviewTab(),
                          _buildTournamentsTab(),
                          _buildMatchesTab(),
                          _buildActivityTab(),
                        ],
                      ),
          ),
        ],
      );
    }
    
    // Với AppBar bình thường
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', 
          style: AppTheme.lightHeadlineMedium.copyWith(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.getPrimaryGradient(context),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.dashboard_rounded), text: 'Tổng Quan'),
            Tab(icon: Icon(Icons.emoji_events_rounded), text: 'Giải Đấu'),
            Tab(icon: Icon(Icons.sports_soccer_rounded), text: 'Trận Đấu'),
            Tab(icon: Icon(Icons.history_rounded), text: 'Hoạt Động'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.getPrimaryColor(context)))
          : _errorMessage != null
              ? _buildErrorWidget()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildTournamentsTab(),
                    _buildMatchesTab(),
                    _buildActivityTab(),
                  ],
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 80, color: AppTheme.lightAccentCoral),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Có lỗi xảy ra',
              style: AppTheme.lightTitleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Thử Lại'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== OVERVIEW TAB ==========
  Widget _buildOverviewTab() {
    if (_overview == null) {
      return const Center(child: Text('Không có dữ liệu'));
    }

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      color: AppTheme.getPrimaryColor(context),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards
              AnimatedWrapper(
                index: 0,
                child: _buildStatsGrid(_overview!.stats),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              AnimatedWrapper(
                index: 1,
                child: Column(
                  children: [
                    _buildSectionHeader('Truy Cập Nhanh', Icons.flash_on_rounded),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(
                            'Video Highlights',
                            Icons.play_circle_fill_rounded,
                            const Color(0xFF9C27B0),
                            const Color(0xFFE1BEE7),
                            () {
                              Navigator.pushNamed(
                                context,
                                '/video-highlights',
                                arguments: {
                                  'searchQuery': 'basketball highlights',
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickAction(
                            'Tìm Kiếm',
                            Icons.search_rounded,
                            const Color(0xFF009688),
                            const Color(0xFFB2DFDB),
                            () {
                              Navigator.pushNamed(context, '/search');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(
                            'Cửa Hàng',
                            Icons.shopping_bag_rounded,
                            const Color(0xFFFF9800),
                            const Color(0xFFFFE0B2),
                            () {
                              Navigator.pushNamed(context, '/shop');
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildQuickAction(
                            'Túi Quà',
                            Icons.card_giftcard_rounded,
                            const Color(0xFFE91E63),
                            const Color(0xFFF8BBD0),
                            () {
                              Navigator.pushNamed(context, '/my-rewards');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickAction(
                            'Lịch Sử Điểm',
                            Icons.history_rounded,
                            const Color(0xFF3F51B5),
                            const Color(0xFFC5CAE9),
                            () {
                              Navigator.pushNamed(context, '/points-history');
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: Container()), // Empty space for alignment
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // My Teams Section
              if (_overview!.myTeams.isNotEmpty) ...[
                AnimatedWrapper(
                  index: 2,
                  child: Column(
                    children: [
                      _buildSectionHeader('Đội Của Tôi', Icons.group_rounded),
                      const SizedBox(height: 16),
                      ..._overview!.myTeams.map((team) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildTeamCard(team),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Upcoming Matches Section
              if (_overview!.upcomingMatches.isNotEmpty) ...[
                AnimatedWrapper(
                  index: 3,
                  child: Column(
                    children: [
                      _buildSectionHeader('Trận Đấu Sắp Tới', Icons.event_rounded),
                      const SizedBox(height: 16),
                      ..._overview!.upcomingMatches.take(3).map(
                        (match) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildMatchCard(match),
                        )),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // My Tournaments Section
              if (_overview!.myTournaments.isNotEmpty) ...[
                AnimatedWrapper(
                  index: 4,
                  child: Column(
                    children: [
                      _buildSectionHeader('Giải Đấu Đã Đăng Ký', Icons.emoji_events_rounded),
                      const SizedBox(height: 16),
                      ..._overview!.myTournaments.take(3).map(
                        (tournament) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: _buildTournamentCard(tournament),
                        )),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 80), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(DashboardStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard(
          'Đội Của Tôi',
          stats.totalTeams.toString(),
          Icons.group_rounded,
          AppTheme.lightPrimary,
          AppTheme.lightPrimaryVariant.withValues(alpha: 0.3),
        ),
        _buildStatCard(
          'Giải Đấu',
          stats.totalTournaments.toString(),
          Icons.emoji_events_rounded,
          const Color(0xFFFF9800),
          const Color(0xFFFFE0B2),
        ),
        _buildStatCard(
          'Trận Sắp Tới',
          stats.upcomingMatchesCount.toString(),
          Icons.event_rounded,
          AppTheme.lightAccentMint,
          AppTheme.lightAccentMint.withValues(alpha: 0.3),
        ),
        _buildStatCard(
          'Đang Thi Đấu',
          stats.activeTournaments.toString(),
          Icons.sports_soccer_rounded,
          AppTheme.lightAccentCoral,
          AppTheme.lightAccentCoral.withValues(alpha: 0.3),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, Color bgColor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? AppTheme.darkCardShadow : AppTheme.lightCardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color, Color bgColor, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? AppTheme.darkCardShadow : AppTheme.lightCardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppTheme.getPrimaryColor(context)),
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
    );
  }

  Widget _buildTeamCard(UserTeam team) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? AppTheme.darkCardShadow : AppTheme.lightCardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamDetailScreen(teamId: team.teamId),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: team.logo != null && team.logo!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(team.logo!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: team.logo == null || team.logo!.isEmpty
                      ? Icon(Icons.group_rounded, color: Colors.grey[400], size: 30)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.person_outline_rounded, 
                            size: 14, color: AppTheme.getTextSecondaryColor(context)),
                          const SizedBox(width: 4),
                          Text(
                            team.coach != null && team.coach!.isNotEmpty
                                ? 'HLV: ${team.coach}'
                                : 'Chưa có HLV',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${team.playersCount} TV',
                    style: TextStyle(
                      color: AppTheme.getPrimaryColor(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCard(UpcomingMatch match) {
    final isMyTeamA = match.isMyTeamA ?? false;
    final isMyTeamB = match.isMyTeamB ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? AppTheme.darkCardShadow : AppTheme.lightCardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchDetailScreen(matchId: match.matchId),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Tournament Name Badge
                if (match.tournamentName != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      match.tournamentName!,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            match.teamA ?? 'TBA',
                            style: TextStyle(
                              fontWeight: isMyTeamA ? FontWeight.bold : FontWeight.w500,
                              color: isMyTeamA ? AppTheme.getPrimaryColor(context) : AppTheme.getTextPrimaryColor(context),
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.getBackgroundColor(context),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.getPrimaryColor(context).withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        match.scoreA != null && match.scoreB != null
                            ? '${match.scoreA} - ${match.scoreB}'
                            : 'VS',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.getPrimaryColor(context),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            match.teamB ?? 'TBA',
                            style: TextStyle(
                              fontWeight: isMyTeamB ? FontWeight.bold : FontWeight.w500,
                              color: isMyTeamB ? AppTheme.getPrimaryColor(context) : AppTheme.getTextPrimaryColor(context),
                              fontSize: 15,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.getTextSecondaryColor(context)),
                    const SizedBox(width: 4),
                    Text(
                      match.formattedDateTime,
                      style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context)),
                    ),
                    if (match.location != null && match.location!.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      Icon(Icons.location_on_rounded, size: 14, color: AppTheme.getTextSecondaryColor(context)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          match.location!,
                          style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentCard(UserTournament tournament) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? AppTheme.darkCardShadow : AppTheme.lightCardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TournamentDetailScreen(
                  tournamentId: tournament.tournamentId,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: tournament.imageUrl != null && tournament.imageUrl!.isNotEmpty
                      ? Image.network(
                          tournament.imageUrl!,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[300],
                                child: const Icon(Icons.emoji_events_rounded, color: Colors.white),
                              ),
                        )
                      : Container(
                          width: 70,
                          height: 70,
                          color: AppTheme.lightAccentYellow.withValues(alpha: 0.3),
                          child: const Icon(Icons.emoji_events_rounded, color: Colors.orange, size: 32),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournament.tournamentName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Đội: ${tournament.teamName}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.getTextSecondaryColor(context),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (tournament.tournamentStatus != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tournament.tournamentStatus!,
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppTheme.getTextSecondaryColor(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== TOURNAMENTS TAB ==========
  Widget _buildTournamentsTab() {
    return const MyTournamentsTab();
  }

  // ========== MATCHES TAB ==========
  Widget _buildMatchesTab() {
    return const MyMatchesTab();
  }

  // ========== ACTIVITY TAB ==========
  Widget _buildActivityTab() {
    return const MyActivityTab();
  }
}

// ========== MY TOURNAMENTS TAB ==========
class MyTournamentsTab extends StatefulWidget {
  const MyTournamentsTab({Key? key}) : super(key: key);

  @override
  State<MyTournamentsTab> createState() => _MyTournamentsTabState();
}

class _MyTournamentsTabState extends State<MyTournamentsTab> {
  List<UserTournament> _tournaments = [];
  bool _isLoading = true;
  int _currentPage = 1;
  // ignore: unused_field
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _loadTournaments();
  }

  Future<void> _loadTournaments() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    final response = await ApiService.getMyTournaments(
      page: _currentPage,
      pageSize: 10,
      token: token,
    );

    if (response.success && response.data != null) {
      setState(() {
        _tournaments = response.data!.data;
        _totalPages = response.data!.totalPages;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppTheme.getPrimaryColor(context)));
    }

    if (_tournaments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Chưa đăng ký giải đấu nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _currentPage = 1;
        await _loadTournaments();
      },
      color: AppTheme.getPrimaryColor(context),
      child: AnimatedListWrapper(
        padding: const EdgeInsets.all(16),
        itemCount: _tournaments.length,
        itemBuilder: (context, index) {
          final tournament = _tournaments[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildTournamentCard(tournament),
          );
        },
      ),
    );
  }

  Widget _buildTournamentCard(UserTournament tournament) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? AppTheme.darkCardShadow : AppTheme.lightCardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TournamentDetailScreen(
                  tournamentId: tournament.tournamentId,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: tournament.imageUrl != null && tournament.imageUrl!.isNotEmpty
                      ? Image.network(
                          tournament.imageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.emoji_events_rounded),
                              ),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          color: AppTheme.lightAccentYellow.withValues(alpha: 0.3),
                          child: const Icon(Icons.emoji_events_rounded, color: Colors.orange, size: 36),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tournament.tournamentName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.getTextPrimaryColor(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (tournament.teamLogo != null && tournament.teamLogo!.isNotEmpty)
                            CircleAvatar(
                              radius: 10,
                              backgroundImage: NetworkImage(tournament.teamLogo!),
                            ),
                          if (tournament.teamLogo != null && tournament.teamLogo!.isNotEmpty)
                            const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              tournament.teamName,
                              style: TextStyle(
                                color: AppTheme.getPrimaryColor(context),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (tournament.sportName != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tournament.sportName!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                          if (tournament.tournamentStatus != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(tournament.tournamentStatus!),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                tournament.tournamentStatus!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
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
      case 'Giải đấu đang diễn ra':
        return Colors.green;
      case 'Mở đăng ký':
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

// ========== MY MATCHES TAB ==========
class MyMatchesTab extends StatefulWidget {
  const MyMatchesTab({Key? key}) : super(key: key);

  @override
  State<MyMatchesTab> createState() => _MyMatchesTabState();
}

class _MyMatchesTabState extends State<MyMatchesTab> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<UpcomingMatch> _upcomingMatches = [];
  List<UpcomingMatch> _pastMatches = [];
  bool _isLoadingUpcoming = true;
  bool _isLoadingPast = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMatches();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    _loadUpcomingMatches();
    _loadPastMatches();
  }

  Future<void> _loadUpcomingMatches() async {
    setState(() => _isLoadingUpcoming = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    final response = await ApiService.getUpcomingMatches(token: token);

    if (response.success && response.data != null) {
      setState(() {
        _upcomingMatches = response.data!.data;
        _isLoadingUpcoming = false;
      });
    } else {
      setState(() => _isLoadingUpcoming = false);
    }
  }

  Future<void> _loadPastMatches() async {
    setState(() => _isLoadingPast = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    final response = await ApiService.getMatchHistory(token: token);

    if (response.success && response.data != null) {
      setState(() {
        _pastMatches = response.data!.data;
        _isLoadingPast = false;
      });
    } else {
      setState(() => _isLoadingPast = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(25),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[600],
            indicator: BoxDecoration(
              color: AppTheme.getPrimaryColor(context),
              borderRadius: BorderRadius.circular(25),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'Sắp Tới'),
              Tab(text: 'Lịch Sử'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMatchesList(_upcomingMatches, _isLoadingUpcoming, true),
              _buildMatchesList(_pastMatches, _isLoadingPast, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMatchesList(List<UpcomingMatch> matches, bool isLoading, bool isUpcoming) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator(color: AppTheme.getPrimaryColor(context)));
    }

    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'Chưa có trận đấu sắp tới' : 'Chưa có lịch sử trận đấu',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: isUpcoming ? _loadUpcomingMatches : _loadPastMatches,
      color: AppTheme.getPrimaryColor(context),
      child: AnimatedListWrapper(
        padding: const EdgeInsets.all(16),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: _buildMatchCard(match),
          );
        },
      ),
    );
  }

  Widget _buildMatchCard(UpcomingMatch match) {
    final isMyTeamA = match.isMyTeamA ?? false;
    final isMyTeamB = match.isMyTeamB ?? false;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? AppTheme.darkCardShadow : AppTheme.lightCardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchDetailScreen(matchId: match.matchId),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Teams and Score
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            match.teamA ?? 'TBA',
                            style: TextStyle(
                              fontWeight: isMyTeamA ? FontWeight.bold : FontWeight.w500,
                              color: isMyTeamA ? AppTheme.getPrimaryColor(context) : AppTheme.getTextPrimaryColor(context),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.getBackgroundColor(context),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          match.scoreA != null && match.scoreB != null
                              ? '${match.scoreA} - ${match.scoreB}'
                              : 'VS',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppTheme.getPrimaryColor(context),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            match.teamB ?? 'TBA',
                            style: TextStyle(
                              fontWeight: isMyTeamB ? FontWeight.bold : FontWeight.w500,
                              color: isMyTeamB ? AppTheme.getPrimaryColor(context) : AppTheme.getTextPrimaryColor(context),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Match Info
                Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, size: 14, color: AppTheme.getTextSecondaryColor(context)),
                    const SizedBox(width: 4),
                    Text(
                      match.formattedDateTime,
                      style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context)),
                    ),
                  ],
                ),
                if (match.location != null && match.location!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded, size: 14, color: AppTheme.getTextSecondaryColor(context)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          match.location!,
                          style: TextStyle(fontSize: 12, color: AppTheme.getTextSecondaryColor(context)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (match.tournamentName != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.emoji_events_rounded, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          match.tournamentName!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ========== MY ACTIVITY TAB ==========
class MyActivityTab extends StatefulWidget {
  const MyActivityTab({Key? key}) : super(key: key);

  @override
  State<MyActivityTab> createState() => _MyActivityTabState();
}

class _MyActivityTabState extends State<MyActivityTab> {
  List<ActivityItem> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivity();
  }

  Future<void> _loadActivity() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    final response = await ApiService.getActivity(token: token);

    if (response.success && response.data != null) {
      setState(() {
        _activities = response.data!.data;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: AppTheme.getPrimaryColor(context)));
    }

    if (_activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Chưa có hoạt động nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadActivity,
      color: AppTheme.getPrimaryColor(context),
      child: AnimatedListWrapper(
        padding: const EdgeInsets.all(16),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final activity = _activities[index];
          return _buildActivityCard(activity);
        },
      ),
    );
  }

  Widget _buildActivityCard(ActivityItem activity) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkCard : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? AppTheme.darkCardShadow : AppTheme.lightCardShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _getActivityColor(activity.type).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getActivityIcon(activity.type),
            color: _getActivityColor(activity.type),
            size: 24,
          ),
        ),
        title: Text(
          activity.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.getTextPrimaryColor(context),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (activity.description != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  activity.description!,
                  style: TextStyle(color: AppTheme.getTextSecondaryColor(context)),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              activity.relativeTime,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
        trailing: activity.status != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(activity.status!).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  activity.status!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(activity.status!),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'tournament_registration':
        return Icons.emoji_events_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'tournament_registration':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Approved':
      case 'Đã duyệt':
        return Colors.green;
      case 'Pending':
      case 'Chờ duyệt':
        return Colors.orange;
      case 'Rejected':
      case 'Từ chối':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
