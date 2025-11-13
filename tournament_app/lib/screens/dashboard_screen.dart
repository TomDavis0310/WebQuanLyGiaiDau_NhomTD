import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/dashboard.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'team_detail_screen.dart';
import 'tournament_detail_screen.dart';
import 'match_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard', 
          style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Tổng Quan'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Giải Đấu'),
            Tab(icon: Icon(Icons.sports_soccer), text: 'Trận Đấu'),
            Tab(icon: Icon(Icons.history), text: 'Hoạt Động'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Có lỗi xảy ra',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboard,
              child: const Text('Thử Lại'),
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
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Cards
              _buildStatsGrid(_overview!.stats),
              const SizedBox(height: 24),

              // My Teams Section
              if (_overview!.myTeams.isNotEmpty) ...[
                _buildSectionHeader('Đội Của Tôi', Icons.group),
                const SizedBox(height: 12),
                ..._overview!.myTeams.map((team) => _buildTeamCard(team)),
                const SizedBox(height: 24),
              ],

              // Upcoming Matches Section
              if (_overview!.upcomingMatches.isNotEmpty) ...[
                _buildSectionHeader('Trận Đấu Sắp Tới', Icons.event),
                const SizedBox(height: 12),
                ..._overview!.upcomingMatches.take(3).map(
                  (match) => _buildMatchCard(match)),
                const SizedBox(height: 24),
              ],

              // My Tournaments Section
              if (_overview!.myTournaments.isNotEmpty) ...[
                _buildSectionHeader('Giải Đấu Đã Đăng Ký', Icons.emoji_events),
                const SizedBox(height: 12),
                ..._overview!.myTournaments.take(3).map(
                  (tournament) => _buildTournamentCard(tournament)),
              ],
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
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Đội Của Tôi',
          stats.totalTeams.toString(),
          Icons.group,
          Colors.blue,
        ),
        _buildStatCard(
          'Giải Đấu',
          stats.totalTournaments.toString(),
          Icons.emoji_events,
          Colors.orange,
        ),
        _buildStatCard(
          'Trận Sắp Tới',
          stats.upcomingMatchesCount.toString(),
          Icons.event,
          Colors.green,
        ),
        _buildStatCard(
          'Đang Thi Đấu',
          stats.activeTournaments.toString(),
          Icons.sports_soccer,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCard(UserTeam team) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: team.logo != null && team.logo!.isNotEmpty
              ? NetworkImage(team.logo!)
              : null,
          child: team.logo == null || team.logo!.isEmpty
              ? const Icon(Icons.group)
              : null,
        ),
        title: Text(
          team.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          team.coach != null && team.coach!.isNotEmpty
              ? 'HLV: ${team.coach}'
              : 'Chưa có HLV',
        ),
        trailing: Chip(
          label: Text('${team.playersCount} cầu thủ'),
          backgroundColor: Colors.blue[50],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamDetailScreen(teamId: team.teamId),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMatchCard(UpcomingMatch match) {
    final isMyTeamA = match.isMyTeamA ?? false;
    final isMyTeamB = match.isMyTeamB ?? false;

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
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      match.teamA ?? 'TBA',
                      style: TextStyle(
                        fontWeight: isMyTeamA ? FontWeight.bold : FontWeight.normal,
                        color: isMyTeamA ? Colors.blue : Colors.black,
                      ),
                    ),
                  ),
                  Text(
                    match.scoreA != null && match.scoreB != null
                        ? '${match.scoreA} - ${match.scoreB}'
                        : 'vs',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      match.teamB ?? 'TBA',
                      style: TextStyle(
                        fontWeight: isMyTeamB ? FontWeight.bold : FontWeight.normal,
                        color: isMyTeamB ? Colors.blue : Colors.black,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    match.formattedDateTime,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  if (match.location != null && match.location!.isNotEmpty) ...[
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        match.location!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              if (match.tournamentName != null) ...[
                const SizedBox(height: 4),
                Text(
                  match.tournamentName!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTournamentCard(UserTournament tournament) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: tournament.imageUrl != null && tournament.imageUrl!.isNotEmpty
            ? Image.network(
                tournament.imageUrl!,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.emoji_events, size: 40),
              )
            : const Icon(Icons.emoji_events, size: 40),
        title: Text(
          tournament.tournamentName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Đội: ${tournament.teamName}'),
            if (tournament.tournamentStatus != null)
              Text(
                tournament.tournamentStatus!,
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
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
      ),
    );
  }

  // ========== TOURNAMENTS TAB ==========
  Widget _buildTournamentsTab() {
    return MyTournamentsTab();
  }

  // ========== MATCHES TAB ==========
  Widget _buildMatchesTab() {
    return MyMatchesTab();
  }

  // ========== ACTIVITY TAB ==========
  Widget _buildActivityTab() {
    return MyActivityTab();
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_tournaments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa đăng ký giải đấu nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tournaments.length,
        itemBuilder: (context, index) {
          final tournament = _tournaments[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
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
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    if (tournament.imageUrl != null && tournament.imageUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          tournament.imageUrl!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: const Icon(Icons.emoji_events),
                              ),
                        ),
                      )
                    else
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.emoji_events, size: 40),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tournament.tournamentName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (tournament.teamLogo != null && tournament.teamLogo!.isNotEmpty)
                                CircleAvatar(
                                  radius: 10,
                                  backgroundImage: NetworkImage(tournament.teamLogo!),
                                ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  tournament.teamName,
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (tournament.sportName != null)
                            Text(
                              tournament.sportName!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          const SizedBox(height: 4),
                          if (tournament.tournamentStatus != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
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
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          );
        },
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
        TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Sắp Tới'),
            Tab(text: 'Lịch Sử'),
          ],
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
      return const Center(child: CircularProgressIndicator());
    }

    if (matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              isUpcoming ? 'Chưa có trận đấu sắp tới' : 'Chưa có lịch sử trận đấu',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: isUpcoming ? _loadUpcomingMatches : _loadPastMatches,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          final match = matches[index];
          final isMyTeamA = match.isMyTeamA ?? false;
          final isMyTeamB = match.isMyTeamB ?? false;

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
                                  color: isMyTeamA ? Colors.blue : Colors.black,
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            match.scoreA != null && match.scoreB != null
                                ? '${match.scoreA} - ${match.scoreB}'
                                : 'vs',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
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
                                  color: isMyTeamB ? Colors.blue : Colors.black,
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
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          match.formattedDateTime,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    if (match.location != null && match.location!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              match.location!,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                          Icon(Icons.emoji_events, size: 14, color: Colors.orange),
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
          );
        },
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có hoạt động nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadActivity,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final activity = _activities[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getActivityColor(activity.type),
                child: Icon(
                  _getActivityIcon(activity.type),
                  color: Colors.white,
                ),
              ),
              title: Text(
                activity.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (activity.description != null)
                    Text(activity.description!),
                  const SizedBox(height: 4),
                  Text(
                    activity.relativeTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              trailing: activity.status != null
                  ? Chip(
                      label: Text(
                        activity.status!,
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: _getStatusColor(activity.status!),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'tournament_registration':
        return Icons.emoji_events;
      default:
        return Icons.info;
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
        return Colors.green[100]!;
      case 'Pending':
      case 'Chờ duyệt':
        return Colors.orange[100]!;
      case 'Rejected':
      case 'Từ chối':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
}
