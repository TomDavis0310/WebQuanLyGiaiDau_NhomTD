import 'package:flutter/material.dart';
import '../models/player_detail.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_widget.dart';
import 'match_detail_screen.dart';

class PlayerDetailScreen extends StatefulWidget {
  final int playerId;

  const PlayerDetailScreen({Key? key, required this.playerId}) : super(key: key);

  @override
  State<PlayerDetailScreen> createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen>
    with SingleTickerProviderStateMixin {
  PlayerDetail? _playerDetail;
  PlayerStatisticsSummary? _statistics;
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPlayerData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPlayerData() async {
    setState(() => _isLoading = true);

    try {
      final detailResponse = await ApiService.getPlayerDetail(widget.playerId);
      final statsResponse =
          await ApiService.getPlayerStatisticsSummary(widget.playerId);

      if (detailResponse.success && detailResponse.data != null) {
        setState(() {
          _playerDetail = detailResponse.data;
          _statistics = statsResponse.data;
          _isLoading = false;
        });
      } else {
        throw Exception(detailResponse.message);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const LoadingWidget(message: 'Đang tải thông tin cầu thủ...')
          : _playerDetail == null
              ? Center(
                  child: Text(
                    'Không tìm thấy thông tin cầu thủ',
                    style: AppTheme.bodyLarge,
                  ),
                )
              : NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverAppBar(
                      expandedHeight: 300,
                      floating: false,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: _buildHeader(),
                      ),
                      bottom: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Tổng Quan'),
                          Tab(text: 'Thống Kê'),
                          Tab(text: 'Trận Đấu'),
                        ],
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        indicatorColor: Colors.white,
                      ),
                    ),
                  ],
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildStatisticsTab(),
                      _buildMatchesTab(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    final player = _playerDetail!;
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          // Player image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.26),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 58,
              backgroundImage: player.imageUrl != null
                  ? NetworkImage(player.imageUrl!)
                  : null,
              backgroundColor: Colors.blue[300],
              child: player.imageUrl == null
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMedium),
          // Player name
          Text(
            player.fullName,
            style: AppTheme.headlineLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceSmall),
          // Jersey number and position
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMedium,
                  vertical: AppTheme.spaceSmall,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: Text(
                  '#${player.number}',
                  style: AppTheme.titleLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spaceMedium),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  player.position,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (player.team != null) ...[
            const SizedBox(height: 12),
            Text(
              player.team!.name,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final player = _playerDetail!;
    return RefreshIndicator(
      onRefresh: _loadPlayerData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick stats
            _buildQuickStats(),
            const SizedBox(height: 24),
            
            // Team info
            if (player.team != null) _buildTeamSection(),
            const SizedBox(height: 24),
            
            // Recent matches
            if (player.recentMatches.isNotEmpty) _buildRecentMatchesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    final stats = _playerDetail!.statistics;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thống Kê Nhanh',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Trận Đấu',
                    stats.totalMatches.toString(),
                    Icons.sports_basketball,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Tổng Điểm',
                    stats.totalPoints.toString(),
                    Icons.star,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'TB/Trận',
                    stats.averagePoints.toStringAsFixed(1),
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Cao Nhất',
                    stats.highestScore.toString(),
                    Icons.emoji_events,
                    Colors.amber,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection() {
    final team = _playerDetail!.team!;
    return Card(
      child: ListTile(
        leading: team.logo != null
            ? Image.network(team.logo!, width: 50, height: 50)
            : Icon(Icons.shield, size: 50),
        title: Text(
          team.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: team.sport != null ? Text(team.sport!.name) : null,
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to team detail
        },
      ),
    );
  }

  Widget _buildRecentMatchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trận Đấu Gần Đây',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...(_playerDetail!.recentMatches.take(5).map((match) => _buildMatchCard(match))),
      ],
    );
  }

  Widget _buildMatchCard(PlayerMatch match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MatchDetailScreen(matchId: match.matchId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    match.formattedDate,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: match.status == 'Đã kết thúc'
                          ? Colors.grey[300]
                          : Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      match.status,
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      match.teamA,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${match.scoreA ?? '-'} : ${match.scoreB ?? '-'}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      match.teamB,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${match.points} điểm',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsTab() {
    if (_statistics == null) {
      return Center(child: Text('Chưa có dữ liệu thống kê'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Advanced stats
          _buildAdvancedStats(),
          const SizedBox(height: 24),
          
          // Recent form
          _buildRecentForm(),
          const SizedBox(height: 24),
          
          // Performance chart (placeholder)
          _buildPerformanceChart(),
        ],
      ),
    );
  }

  Widget _buildAdvancedStats() {
    final stats = _statistics!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thống Kê Chi Tiết',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Tỷ lệ thắng', '${stats.winRate.toStringAsFixed(1)}%'),
            _buildStatRow('Chuỗi trận ghi điểm', '${stats.currentStreak} trận'),
            _buildStatRow('Trung bình điểm', stats.averagePoints.toStringAsFixed(2)),
            _buildStatRow('Điểm cao nhất', stats.highestScore.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentForm() {
    final form = _statistics!.recentForm;
    if (form.isEmpty) return SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phong Độ Gần Đây',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: form.map((points) {
                return Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: points > 0 ? Colors.green : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    points.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    final performance = _playerDetail!.performanceData;
    if (performance.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Chưa có dữ liệu biểu đồ'),
        ),
      );
    }

    // Simple bar chart representation
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Biểu Đồ Hiệu Suất',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Dữ liệu ${performance.length} trận đấu gần nhất'),
            const SizedBox(height: 8),
            // Placeholder for chart
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text('Biểu đồ sẽ hiển thị ở đây'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchesTab() {
    return _PlayerMatchesListView(playerId: widget.playerId);
  }
}

// Separate widget for matches tab with pagination
class _PlayerMatchesListView extends StatefulWidget {
  final int playerId;

  const _PlayerMatchesListView({required this.playerId});

  @override
  State<_PlayerMatchesListView> createState() =>
      _PlayerMatchesListViewState();
}

class _PlayerMatchesListViewState extends State<_PlayerMatchesListView> {
  final List<PlayerMatch> _matches = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMatches();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMatches();
      }
    }
  }

  Future<void> _loadMatches() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.getPlayerMatches(
        widget.playerId,
        page: _currentPage,
        pageSize: 10,
      );

      if (result['success'] == true) {
        final newMatches = result['data'] as List<PlayerMatch>;
        final pagination = result['pagination'];

        setState(() {
          _matches.addAll(newMatches);
          _currentPage++;
          _hasMore = pagination['hasNextPage'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_matches.isEmpty && _isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_matches.isEmpty) {
      return Center(child: Text('Chưa có trận đấu nào'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _matches.clear();
          _currentPage = 1;
          _hasMore = true;
        });
        await _loadMatches();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _matches.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _matches.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final match = _matches[index];
          return _buildMatchCard(match);
        },
      ),
    );
  }

  Widget _buildMatchCard(PlayerMatch match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MatchDetailScreen(matchId: match.matchId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    match.formattedDate,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: match.status == 'Đã kết thúc'
                          ? Colors.grey[300]
                          : Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      match.status,
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      match.teamA,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${match.scoreA ?? '-'} : ${match.scoreB ?? '-'}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      match.teamB,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              if (match.location != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      match.location!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${match.points} điểm (${match.scoringCount} lần ghi)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
