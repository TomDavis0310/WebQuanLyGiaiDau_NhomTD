import 'package:flutter/material.dart';
import '../models/tournament_statistics.dart';
import '../services/api_service.dart';

/// Statistics Screen - Display tournament statistics
/// Shows top scorers, team stats, and match statistics
class StatisticsScreen extends StatefulWidget {
  final int tournamentId;
  final String tournamentName;

  const StatisticsScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _errorMessage = '';

  // Data
  TournamentOverview? _overview;
  List<TopScorer> _topScorers = [];
  List<TeamStatistics> _teamStats = [];
  MatchStatistics? _matchStats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load all data in parallel
      final results = await Future.wait([
        ApiService.getTournamentOverview(widget.tournamentId),
        ApiService.getTopScorers(widget.tournamentId, limit: 20),
        ApiService.getTeamStatistics(widget.tournamentId),
        ApiService.getMatchStatistics(widget.tournamentId),
      ]);

      setState(() {
        if (results[0].success && results[0].data != null) {
          _overview = results[0].data as TournamentOverview;
        }
        if (results[1].success && results[1].data != null) {
          _topScorers = results[1].data as List<TopScorer>;
        }
        if (results[2].success && results[2].data != null) {
          _teamStats = results[2].data as List<TeamStatistics>;
        }
        if (results[3].success && results[3].data != null) {
          _matchStats = results[3].data as MatchStatistics;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải dữ liệu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tournamentName),
        backgroundColor: Colors.teal,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Tổng quan'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Vua phá lưới'),
            Tab(icon: Icon(Icons.groups), text: 'Thống kê đội'),
            Tab(icon: Icon(Icons.sports_soccer), text: 'Thống kê trận'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildTopScorersTab(),
                    _buildTeamStatsTab(),
                    _buildMatchStatsTab(),
                  ],
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadAllData,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
          ),
        ],
      ),
    );
  }

  // ==================== OVERVIEW TAB ====================
  Widget _buildOverviewTab() {
    if (_overview == null) {
      return const Center(child: Text('Không có dữ liệu tổng quan'));
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOverviewCard(),
          const SizedBox(height: 16),
          _buildQuickStatsGrid(),
          const SizedBox(height: 16),
          if (_overview!.topScorer != null) _buildTopScorerCard(),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.emoji_events, size: 32, color: Colors.teal),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _overview!.tournamentName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _overview!.sportName ?? 'N/A',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Trạng thái:', style: TextStyle(color: Colors.grey[600])),
              Chip(
                label: Text(_overview!.status),
                backgroundColor: _getStatusColor(_overview!.status),
                labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Bắt đầu', _formatDate(_overview!.startDate)),
          _buildInfoRow('Kết thúc', _formatDate(_overview!.endDate)),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Đội tham gia',
          _overview!.totalTeams.toString(),
          Icons.groups,
          Colors.blue,
        ),
        _buildStatCard(
          'Cầu thủ',
          _overview!.totalPlayers.toString(),
          Icons.person,
          Colors.green,
        ),
        _buildStatCard(
          'Trận đấu',
          '${_overview!.completedMatches}/${_overview!.totalMatches}',
          Icons.sports_soccer,
          Colors.orange,
        ),
        _buildStatCard(
          'Tổng bàn thắng',
          _overview!.totalGoals.toString(),
          Icons.sports_score,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
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
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopScorerCard() {
    final topScorer = _overview!.topScorer!;
    return Card(
      elevation: 4,
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
              const SizedBox(width: 12),
              const Text(
                'Vua phá lưới',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person, size: 40),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topScorer.playerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${topScorer.totalPoints} điểm',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }

  // ==================== TOP SCORERS TAB ====================
  Widget _buildTopScorersTab() {
    if (_topScorers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Chưa có thống kê ghi điểm'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _topScorers.length,
        itemBuilder: (context, index) {
          final scorer = _topScorers[index];
          return _buildScorerCard(scorer, index + 1);
        },
      ),
    );
  }

  Widget _buildScorerCard(TopScorer scorer, int rank) {
    Color rankColor;
    if (rank == 1) {
      rankColor = Colors.amber;
    } else if (rank == 2) {
      rankColor = Colors.grey;
    } else if (rank == 3) {
      rankColor = Colors.brown;
    } else {
      rankColor = Colors.blue;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: rankColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: rankColor,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          scorer.playerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.groups, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(scorer.teamName, style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${scorer.matchesPlayed} trận • TB: ${scorer.averagePoints} điểm',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              scorer.totalPoints.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),
            const Text(
              'điểm',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== TEAM STATS TAB ====================
  Widget _buildTeamStatsTab() {
    if (_teamStats.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Chưa có thống kê đội'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _teamStats.length,
        itemBuilder: (context, index) {
          final team = _teamStats[index];
          return _buildTeamCard(team, index + 1);
        },
      ),
    );
  }

  Widget _buildTeamCard(TeamStatistics team, int rank) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text(
            '#$rank',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        title: Text(
          team.teamName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Điểm: ${team.points} • Tỷ lệ thắng: ${team.winRate}%',
          style: TextStyle(color: Colors.grey[600]),
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTeamStat('Trận', team.matchesPlayed, Colors.blue),
                    _buildTeamStat('Thắng', team.wins, Colors.green),
                    _buildTeamStat('Hòa', team.draws, Colors.orange),
                    _buildTeamStat('Thua', team.losses, Colors.red),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTeamStat('Ghi', team.goalsScored, Colors.teal),
                    _buildTeamStat('Thủng', team.goalsConceded, Colors.pink),
                    _buildTeamStat('Hiệu số', team.goalDifference,
                        team.goalDifference >= 0 ? Colors.green : Colors.red),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // ==================== MATCH STATS TAB ====================
  Widget _buildMatchStatsTab() {
    if (_matchStats == null) {
      return const Center(child: Text('Không có dữ liệu thống kê trận đấu'));
    }

    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMatchOverviewCard(),
          const SizedBox(height: 16),
          _buildGoalsCard(),
          const SizedBox(height: 16),
          if (_matchStats!.highestScoringMatch != null)
            _buildHighestScoringMatchCard(),
        ],
      ),
    );
  }

  Widget _buildMatchOverviewCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
            children: [
              Icon(Icons.sports_soccer, color: Colors.teal, size: 28),
              SizedBox(width: 12),
              Text(
                'Tổng quan trận đấu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildMatchStatRow('Tổng số trận', _matchStats!.totalMatches, Colors.blue),
          _buildMatchStatRow('Đã kết thúc', _matchStats!.completedMatches, Colors.green),
          _buildMatchStatRow('Sắp diễn ra', _matchStats!.upcomingMatches, Colors.orange),
          _buildMatchStatRow('Đang diễn ra', _matchStats!.ongoingMatches, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsCard() {
    return Card(
      elevation: 4,
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
            children: [
              Icon(Icons.sports_score, color: Colors.orange.shade700, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Thống kê bàn thắng',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    _matchStats!.totalGoals.toString(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  Text(
                    'Tổng bàn thắng',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              Container(
                height: 60,
                width: 1,
                color: Colors.grey[300],
              ),
              Column(
                children: [
                  Text(
                    _matchStats!.averageGoalsPerMatch.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  Text(
                    'TB/trận',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighestScoringMatchCard() {
    final match = _matchStats!.highestScoringMatch!;
    return Card(
      elevation: 4,
      color: Colors.purple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
            children: [
              Icon(Icons.star, color: Colors.purple.shade700, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Trận đấu nhiều bàn thắng nhất',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  match.teamA,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade700,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${match.scoreTeamA} - ${match.scoreTeamB}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  match.teamB,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                _formatDate(match.matchDate),
                style: TextStyle(color: Colors.grey[700]),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepOrange,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${match.totalGoals} bàn thắng',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchStatRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER METHODS ====================

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'mở đăng ký':
        return Colors.blue;
      case 'giải đấu đang diễn ra':
        return Colors.green;
      case 'đã kết thúc':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }
}
