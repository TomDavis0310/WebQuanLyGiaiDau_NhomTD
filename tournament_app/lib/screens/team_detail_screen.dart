import 'package:flutter/material.dart';
import '../models/team_detail.dart';
import '../models/player_scoring.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import 'match_detail_screen.dart';
import 'player_detail_screen.dart';

/// Team Detail Screen - Hiển thị chi tiết đội bóng và cầu thủ
class TeamDetailScreen extends StatefulWidget {
  final int teamId;
  final String? teamName; // Optional: for title before loading

  const TeamDetailScreen({
    Key? key,
    required this.teamId,
    this.teamName,
  }) : super(key: key);

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen>
    with SingleTickerProviderStateMixin {
  TeamDetail? _teamDetail;
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTeamDetail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTeamDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getTeamDetail(widget.teamId);

      if (response.success && response.data != null) {
        setState(() {
          _teamDetail = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage != null
              ? _buildErrorState()
              : _buildTeamDetail(),
    );
  }

  Widget _buildLoadingState() {
    return const LoadingWidget(
      message: 'Đang tải thông tin đội bóng...',
    );
  }

  Widget _buildErrorState() {
    return CustomErrorWidget(
      message: _errorMessage ?? 'Đã xảy ra lỗi',
      onRetry: _loadTeamDetail,
    );
  }

  Widget _buildTeamDetail() {
    if (_teamDetail == null) return const SizedBox();

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _teamDetail!.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              background: _buildTeamHeader(),
            ),
          ),
          SliverPersistentHeader(
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
                tabs: const [
                  Tab(text: 'Danh Sách Cầu Thủ'),
                  Tab(text: 'Lịch Sử Thi Đấu'),
                ],
              ),
            ),
            pinned: true,
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPlayersTab(),
          _buildMatchHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildTeamHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            // Team Logo
            _buildTeamLogo(),
            const SizedBox(height: 16),
            // Team Stats
            _buildTeamStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamLogo() {
    return Hero(
      tag: 'team_logo_${widget.teamId}',
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipOval(
          child: _teamDetail!.logoUrl != null && _teamDetail!.logoUrl!.isNotEmpty
              ? Image.network(
                  _teamDetail!.logoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildDefaultLogo(),
                )
              : _buildDefaultLogo(),
        ),
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return Icon(
      Icons.groups,
      size: 50,
      color: AppTheme.lightPrimary,
    );
  }

  Widget _buildTeamStats() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLarge),
      padding: const EdgeInsets.all(AppTheme.spaceMedium),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Coach
          if (_teamDetail!.coach != null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.sports,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: AppTheme.spaceSmall),
                Text(
                  'HLV: ${_teamDetail!.coach}',
                  style: AppTheme.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppTheme.spaceMedium),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                '${_teamDetail!.playerCount}',
                'Cầu thủ',
                Icons.people,
              ),
              _buildStatItem(
                '${_teamDetail!.totalMatches}',
                'Trận đấu',
                Icons.sports_soccer,
              ),
              _buildStatItem(
                '${_teamDetail!.wins}',
                'Thắng',
                Icons.emoji_events,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.white,
        ),
        const SizedBox(height: AppTheme.spaceXSmall),
        Text(
          value,
          style: AppTheme.headlineMedium.copyWith(
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayersTab() {
    if (_teamDetail!.players.isEmpty) {
      return _buildEmptyPlayers();
    }

    return RefreshIndicator(
      onRefresh: _loadTeamDetail,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _teamDetail!.players.length,
        itemBuilder: (context, index) {
          final player = _teamDetail!.players[index];
          return _buildPlayerCard(player);
        },
      ),
    );
  }

  Widget _buildPlayerCard(Player player) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(isDark: isDark),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          onTap: () {
            // Navigate to player detail
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerDetailScreen(playerId: player.playerId),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Player Avatar
                _buildPlayerAvatar(player),
                const SizedBox(width: 16),
                // Player Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.fullName,
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (player.position != null)
                        Row(
                          children: [
                            Icon(
                              Icons.sports_handball,
                              size: 14,
                              color: AppTheme.getTextSecondaryColor(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              player.position!,
                              style: AppTheme.bodySmall,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // Jersey Number
                if (player.number != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppTheme.getPrimaryColor(context).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '#${player.number}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getPrimaryColor(context),
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

  Widget _buildPlayerAvatar(Player player) {
    return Hero(
      tag: 'player_avatar_${player.playerId}',
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
          border: Border.all(
            color: AppTheme.lightPrimary,
            width: 2,
          ),
        ),
        child: ClipOval(
          child: player.imageUrl != null && player.imageUrl!.isNotEmpty
              ? Image.network(
                  player.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildDefaultPlayerAvatar(),
                )
              : _buildDefaultPlayerAvatar(),
        ),
      ),
    );
  }

  Widget _buildDefaultPlayerAvatar() {
    return Icon(
      Icons.person,
      size: 30,
      color: Colors.grey[400],
    );
  }

  Widget _buildEmptyPlayers() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có cầu thủ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đội bóng chưa có cầu thủ nào',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchHistoryTab() {
    if (_teamDetail!.matchHistory == null ||
        _teamDetail!.matchHistory!.isEmpty) {
      return _buildEmptyMatchHistory();
    }

    return RefreshIndicator(
      onRefresh: _loadTeamDetail,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _teamDetail!.matchHistory!.length,
        itemBuilder: (context, index) {
          final match = _teamDetail!.matchHistory![index];
          return _buildMatchCard(match);
        },
      ),
    );
  }

  Widget _buildMatchCard(MatchHistory match) {
    final result = match.getResult(_teamDetail!.name);
    final opponent = match.getOpponent(_teamDetail!.name);
    final score = match.getScore(_teamDetail!.name);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(isDark: isDark),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchDetailScreen(matchId: match.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tournament & Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        match.tournament.name,
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatDate(match.matchDate),
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Match Result
                Row(
                  children: [
                    // Result Badge
                    _buildResultBadge(result),
                    const SizedBox(width: 12),
                    // Opponent
                    Expanded(
                      child: Text(
                        'vs $opponent',
                        style: AppTheme.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Score
                    Text(
                      score,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getResultColor(result),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultBadge(String result) {
    Color color;
    String text;

    switch (result) {
      case 'W':
        color = AppTheme.lightAccentGreen;
        text = 'THẮNG';
        break;
      case 'L':
        color = AppTheme.lightAccentCoral;
        text = 'THUA';
        break;
      case 'D':
        color = AppTheme.lightAccentYellow;
        text = 'HÒA';
        break;
      default:
        color = Colors.grey;
        text = 'TBD';
    }

    // Use darker shade for text if using pastel background
    Color textColor = result == 'D' ? Colors.brown : (result == 'TBD' ? Colors.grey[700]! : Colors.white);
    if (result == 'W') textColor = Colors.green[800]!;
    if (result == 'L') textColor = Colors.red[800]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Color _getResultColor(String result) {
    switch (result) {
      case 'W':
        return Colors.green[700]!;
      case 'L':
        return Colors.red[700]!;
      case 'D':
        return Colors.orange[800]!;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyMatchHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Chưa có lịch sử thi đấu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đội bóng chưa tham gia trận đấu nào',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Th1',
      'Th2',
      'Th3',
      'Th4',
      'Th5',
      'Th6',
      'Th7',
      'Th8',
      'Th9',
      'Th10',
      'Th11',
      'Th12'
    ];
    return '${date.day} ${months[date.month - 1]}, ${date.year}';
  }
}

// Custom SliverPersistentHeaderDelegate for TabBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
