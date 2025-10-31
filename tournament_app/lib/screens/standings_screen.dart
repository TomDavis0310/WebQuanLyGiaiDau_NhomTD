import 'package:flutter/material.dart';
import '../models/standings.dart';
import '../services/api_service.dart';
import 'team_detail_screen.dart';

class StandingsScreen extends StatefulWidget {
  final int tournamentId;
  final String tournamentName;

  const StandingsScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
  });

  @override
  State<StandingsScreen> createState() => _StandingsScreenState();
}

class _StandingsScreenState extends State<StandingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TournamentStandings? _standings;
  TournamentBracket? _bracket;
  bool _isLoadingStandings = false;
  bool _isLoadingBracket = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadStandings();
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && _bracket == null && !_isLoadingBracket) {
      _loadBracket();
    }
  }

  Future<void> _loadStandings() async {
    setState(() {
      _isLoadingStandings = true;
      _errorMessage = null;
    });

    try {
      final response =
          await ApiService.getTournamentStandings(widget.tournamentId);

      if (mounted) {
        setState(() {
          _isLoadingStandings = false;
          if (response.success && response.data != null) {
            _standings = response.data;
          } else {
            _errorMessage = response.message;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStandings = false;
          _errorMessage = 'Lỗi: $e';
        });
      }
    }
  }

  Future<void> _loadBracket() async {
    setState(() {
      _isLoadingBracket = true;
    });

    try {
      final response =
          await ApiService.getTournamentBracket(widget.tournamentId);

      if (mounted) {
        setState(() {
          _isLoadingBracket = false;
          if (response.success && response.data != null) {
            _bracket = response.data;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingBracket = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tournamentName),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.table_chart), text: 'Bảng Xếp Hạng'),
            Tab(icon: Icon(Icons.account_tree), text: 'Sơ Đồ Đấu'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStandingsTab(),
          _buildBracketTab(),
        ],
      ),
    );
  }

  Widget _buildStandingsTab() {
    if (_isLoadingStandings) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStandings,
              child: const Text('Thử Lại'),
            ),
          ],
        ),
      );
    }

    if (_standings == null) {
      return const Center(child: Text('Không có dữ liệu'));
    }

    return RefreshIndicator(
      onRefresh: _loadStandings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _standings!.groups.length,
        itemBuilder: (context, index) {
          final group = _standings!.groups[index];
          return _buildStandingGroup(group);
        },
      ),
    );
  }

  Widget _buildStandingGroup(StandingGroup group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              group.groupName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 32, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                const SizedBox(width: 12),
                const Expanded(child: Text('Đội', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                const SizedBox(width: 32, child: Text('ST', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                const SizedBox(width: 32, child: Text('T', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                const SizedBox(width: 32, child: Text('H', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                const SizedBox(width: 32, child: Text('B', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                const SizedBox(width: 40, child: Text('HS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
                const SizedBox(width: 32, child: Text('Đ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center)),
              ],
            ),
          ),

          // Team rows
          ...group.teams.map((team) => _buildTeamRow(team)).toList(),
        ],
      ),
    );
  }

  Widget _buildTeamRow(TeamStanding team) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TeamDetailScreen(teamId: team.teamId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            // Rank
            SizedBox(
              width: 32,
              child: Text(
                '${team.rank ?? '-'}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getRankColor(team.rank),
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Team logo and name
            Expanded(
              child: Row(
                children: [
                  if (team.teamLogo != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.network(
                        team.teamLogo!,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 24,
                            height: 24,
                            color: Colors.grey[300],
                            child: const Icon(Icons.groups, size: 16),
                          );
                        },
                      ),
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      team.teamName ?? 'Unknown',
                      style: const TextStyle(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Stats
            SizedBox(
              width: 32,
              child: Text(
                '${team.played}',
                style: const TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 32,
              child: Text(
                '${team.won}',
                style: const TextStyle(fontSize: 13, color: Colors.green),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 32,
              child: Text(
                '${team.drawn}',
                style: const TextStyle(fontSize: 13, color: Colors.orange),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 32,
              child: Text(
                '${team.lost}',
                style: const TextStyle(fontSize: 13, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                '${team.goalDifference ?? 0}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: (team.goalDifference ?? 0) >= 0
                      ? Colors.green
                      : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 32,
              child: Text(
                '${team.points ?? 0}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int? rank) {
    if (rank == null) return Colors.grey;
    if (rank <= 2) return Colors.green;
    if (rank <= 4) return Colors.blue;
    return Colors.grey;
  }

  Widget _buildBracketTab() {
    if (_isLoadingBracket) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bracket == null || _bracket!.rounds.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_tree_outlined,
                size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có sơ đồ đấu loại',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Sơ đồ sẽ hiển thị khi vào vòng đấu loại',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBracket,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _bracket!.rounds.map((round) {
              return _buildBracketRound(round);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildBracketRound(BracketRound round) {
    return Container(
      margin: const EdgeInsets.only(right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Round title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              round.roundName ?? 'Vòng ${round.round}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Matches
          ...round.matches.map((match) => _buildBracketMatch(match)).toList(),
        ],
      ),
    );
  }

  Widget _buildBracketMatch(BracketMatch match) {
    final isCompleted = match.status == 'Completed';
    final hasWinner = match.winnerId != null;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted ? Colors.green : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Team A
          _buildBracketTeam(
            match.teamA,
            match.teamAId,
            match.scoreA,
            hasWinner && match.winnerId == match.teamAId,
          ),

          // VS Divider
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  match.formattedDate,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                if (match.formattedTime.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(
                    match.formattedTime,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),

          // Team B
          _buildBracketTeam(
            match.teamB,
            match.teamBId,
            match.scoreB,
            hasWinner && match.winnerId == match.teamBId,
          ),
        ],
      ),
    );
  }

  Widget _buildBracketTeam(
      String teamName, int? teamId, int? score, bool isWinner) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWinner
            ? Colors.green.withOpacity(0.1)
            : Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              teamName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: score != null
                  ? (isWinner ? Colors.green : Colors.grey[300])
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              score?.toString() ?? '-',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: score != null
                    ? (isWinner ? Colors.white : Colors.black87)
                    : Colors.grey[600],
              ),
            ),
          ),
          if (isWinner)
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.emoji_events, color: Colors.amber, size: 20),
            ),
        ],
      ),
    );
  }
}
