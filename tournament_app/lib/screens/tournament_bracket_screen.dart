import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/tournament_detail.dart';
import '../models/match.dart';
import '../utils/standings_helper.dart';
import 'match_detail_screen.dart';

class TournamentBracketScreen extends StatefulWidget {
  final TournamentDetail tournament;

  const TournamentBracketScreen({
    super.key,
    required this.tournament,
  });

  @override
  State<TournamentBracketScreen> createState() => _TournamentBracketScreenState();
}

class _TournamentBracketScreenState extends State<TournamentBracketScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasGroups = false;
  bool _hasKnockout = false;

  @override
  void initState() {
    super.initState();
    _analyzeMatches();
    _tabController = TabController(
      length: _hasGroups && _hasKnockout ? 2 : 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _analyzeMatches() {
    // Check if tournament has group stages
    _hasGroups = widget.tournament.matches.any((m) => m.groupName != null && m.groupName!.isNotEmpty);
    
    // Check if tournament has knockout stages
    _hasKnockout = widget.tournament.matches.any((m) => m.round != null && m.round! > 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng Xếp Hạng & Sơ Đồ'),
        bottom: (_hasGroups && _hasKnockout)
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Bảng Xếp Hạng'),
                  Tab(text: 'Sơ Đồ Loại Trực Tiếp'),
                ],
              )
            : null,
      ),
      body: (_hasGroups && _hasKnockout)
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildStandingsView(),
                _buildBracketView(),
              ],
            )
          : _hasGroups
              ? _buildStandingsView()
              : _hasKnockout
                  ? _buildBracketView()
                  : _buildEmptyState(),
    );
  }

  Widget _buildStandingsView() {
    final groupedMatches = StandingsHelper.groupMatchesByGroup(widget.tournament.matches);
    final groupedTeams = StandingsHelper.groupTeamsByGroup(
      teams: widget.tournament.registeredTeams,
      matches: widget.tournament.matches,
    );

    if (groupedTeams.isEmpty) {
      return _buildEmptyState();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Text(
          'Bảng Xếp Hạng Vòng Bảng',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Cập nhật: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),

        // Groups
        ...groupedTeams.entries.map((entry) {
          final groupName = entry.key;
          final teams = entry.value;
          final matches = groupedMatches[groupName] ?? [];
          final standings = StandingsHelper.computeStandings(
            teams: teams,
            matches: matches,
            groupName: groupName,
          );

          return _buildGroupStanding(groupName, standings);
        }),
      ],
    );
  }

  Widget _buildGroupStanding(String groupName, List<TeamStanding> standings) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              groupName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
            ),
            child: Row(
              children: [
                const SizedBox(width: 30, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                const Expanded(flex: 3, child: Text('Đội', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                const SizedBox(width: 35, child: Text('ST', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                const SizedBox(width: 35, child: Text('T', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                const SizedBox(width: 35, child: Text('H', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                const SizedBox(width: 35, child: Text('B', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                const SizedBox(width: 50, child: Text('HS', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                const SizedBox(width: 40, child: Text('Đ', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
          ),

          // Table Rows
          ...standings.map((standing) => _buildStandingRow(standing)),
        ],
      ),
    );
  }

  Widget _buildStandingRow(TeamStanding standing) {
    final rankColor = standing.rank == 1
        ? Colors.amber
        : standing.rank == 2
            ? Colors.grey[400]
            : standing.rank == 3
                ? Colors.brown[300]
                : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 30,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: rankColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${standing.rank}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: rankColor != null ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),

          // Team
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: standing.team.logoUrl != null
                      ? NetworkImage(standing.team.logoUrl!)
                      : null,
                  child: standing.team.logoUrl == null
                      ? const Icon(Icons.sports, size: 16)
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    standing.team.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Stats
          SizedBox(width: 35, child: Text('${standing.matchesPlayed}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13))),
          SizedBox(width: 35, child: Text('${standing.wins}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold))),
          SizedBox(width: 35, child: Text('${standing.draws}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.orange))),
          SizedBox(width: 35, child: Text('${standing.losses}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: Colors.red))),
          SizedBox(
            width: 50,
            child: Text(
              standing.goalDifference >= 0 ? '+${standing.goalDifference}' : '${standing.goalDifference}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: standing.goalDifference > 0
                    ? Colors.green
                    : standing.goalDifference < 0
                        ? Colors.red
                        : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${standing.points}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBracketView() {
    final knockoutMatches = widget.tournament.matches.where((m) => m.round != null && m.round! > 0).toList();

    if (knockoutMatches.isEmpty) {
      return _buildEmptyState();
    }

    final groupedByRound = StandingsHelper.groupMatchesByRound(knockoutMatches);
    final rounds = groupedByRound.keys.toList()..sort();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header
        Text(
          'Sơ Đồ Loại Trực Tiếp',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 24),

        // Rounds
        ...rounds.map((round) {
          final matches = groupedByRound[round]!;
          final roundName = StandingsHelper.getRoundName(round, rounds.length);

          return _buildBracketRound(roundName, matches);
        }),
      ],
    );
  }

  Widget _buildBracketRound(String roundName, List<Match> matches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Round Title
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.blue[700],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                roundName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Text(
                '${matches.length} trận',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),

        // Matches
        ...matches.map((match) => _buildBracketMatch(match)),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildBracketMatch(Match match) {
    final isCompleted = match.status.toLowerCase() == 'completed';
    final isOngoing = match.status.toLowerCase() == 'ongoing';

    String? winner;
    if (isCompleted && match.scoreTeamA != null && match.scoreTeamB != null) {
      if (match.scoreTeamA! > match.scoreTeamB!) {
        winner = match.teamA;
      } else if (match.scoreTeamB! > match.scoreTeamA!) {
        winner = match.teamB;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
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
            children: [
              // Match Info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(match.matchDate),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (match.matchTime != null) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      match.matchTime!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Live Badge
              if (isOngoing)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: Colors.white),
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

              // Teams
              Row(
                children: [
                  // Team A
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: winner == match.teamA ? Colors.green[50] : Colors.grey[50],
                        border: Border.all(
                          color: winner == match.teamA ? Colors.green : Colors.grey[300]!,
                          width: winner == match.teamA ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.sports, size: 24),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              match.teamA,
                              style: TextStyle(
                                fontWeight: winner == match.teamA ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCompleted || isOngoing)
                            Text(
                              '${match.scoreTeamA ?? 0}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: winner == match.teamA ? Colors.green : Colors.black87,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // VS or Score separator
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      isCompleted || isOngoing ? '-' : 'VS',
                      style: TextStyle(
                        fontSize: isCompleted || isOngoing ? 20 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),

                  // Team B
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: winner == match.teamB ? Colors.green[50] : Colors.grey[50],
                        border: Border.all(
                          color: winner == match.teamB ? Colors.green : Colors.grey[300]!,
                          width: winner == match.teamB ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          if (isCompleted || isOngoing)
                            Text(
                              '${match.scoreTeamB ?? 0}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: winner == match.teamB ? Colors.green : Colors.black87,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              match.teamB,
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontWeight: winner == match.teamB ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.sports, size: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Location
              if (match.location != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      match.location!,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Chưa có dữ liệu bảng xếp hạng',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Dữ liệu sẽ được cập nhật khi có trận đấu',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
