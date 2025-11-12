import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/tournament_detail.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'match_detail_screen.dart';
import 'tournament_bracket_screen.dart';
import 'standings_screen.dart';

class TournamentDetailScreen extends StatefulWidget {
  final int tournamentId;

  const TournamentDetailScreen({
    super.key,
    required this.tournamentId,
  });

  @override
  State<TournamentDetailScreen> createState() => _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen>
    with SingleTickerProviderStateMixin {
  TournamentDetail? tournament;
  bool isLoading = true;
  String? errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadTournamentDetail();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadTournamentDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getTournamentDetail(widget.tournamentId);

      if (response.success && response.data != null) {
        // Add null safety checks for critical fields
        final tournamentData = response.data!;
        
        // Validate required fields
        if (tournamentData.name.isNotEmpty && 
            tournamentData.maxTeams > 0 &&
            tournamentData.teamsPerGroup > 0) {
          setState(() {
            tournament = tournamentData;
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Dữ liệu giải đấu không hợp lệ';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = response.message;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi kết nối: $e';
        isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatDateTime(DateTime date, String? time) {
    final dateStr = DateFormat('dd/MM/yyyy').format(date);
    return time != null ? '$dateStr $time' : dateStr;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return Colors.blue;
      case 'ongoing':
        return Colors.green;
      case 'completed':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return 'Sắp diễn ra';
      case 'ongoing':
        return 'Đang diễn ra';
      case 'completed':
        return 'Đã kết thúc';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: tournament != null &&
              tournament!.registrationStatus.toLowerCase() == 'upcoming'
          ? _buildBottomBar()
          : null,
      floatingActionButton: tournament != null
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TournamentBracketScreen(tournament: tournament!),
                  ),
                );
              },
              icon: const Icon(Icons.emoji_events),
              label: const Text('Bảng Xếp Hạng'),
              backgroundColor: Colors.amber[700],
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải thông tin giải đấu...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Lỗi: $errorMessage',
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadTournamentDetail,
              child: Text('Thử Lại'),
            ),
          ],
        ),
      );
    }

    if (tournament == null) {
      return Center(
        child: Text('Không tìm thấy thông tin giải đấu'),
      );
    }

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildTournamentInfo(),
              _buildTabBar(),
            ],
          ),
        ),
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildTeamsTab(),
              _buildMatchesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          tournament!.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (tournament!.imageUrl != null)
              Image.network(
                tournament!.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(
                      Icons.sports,
                      size: 80,
                      color: Theme.of(context).primaryColor,
                    ),
                  );
                },
              )
            else
              Container(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.sports,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(tournament!.registrationStatus)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _getStatusColor(tournament!.registrationStatus),
                width: 1,
              ),
            ),
            child: Text(
              _getStatusText(tournament!.registrationStatus),
              style: TextStyle(
                color: _getStatusColor(tournament!.registrationStatus),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(height: 16),

          // Description
          if (tournament!.description != null) ...[
            Text(
              tournament!.description!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
          ],

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  Icons.groups,
                  '${tournament!.registeredTeamsCount}/${tournament!.maxTeams ?? 0}',
                  'Đội',
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  Icons.sports_soccer,
                  '${tournament!.totalMatches}',
                  'Trận đấu',
                  Colors.green,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  Icons.calendar_today,
                  '${tournament!.endDate.difference(tournament!.startDate).inDays + 1}',
                  'Ngày',
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
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

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
        tabs: [
          Tab(text: 'Tổng quan'),
          Tab(text: 'Đội (${tournament!.registeredTeamsCount})'),
          Tab(text: 'Trận đấu (${tournament!.totalMatches})'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            'Thông Tin Giải Đấu',
            [
              _buildInfoRow(Icons.sports, 'Môn thể thao',
                  tournament!.sports.name),
              _buildInfoRow(Icons.calendar_today, 'Ngày bắt đầu',
                  _formatDate(tournament!.startDate)),
              _buildInfoRow(Icons.calendar_today, 'Ngày kết thúc',
                  _formatDate(tournament!.endDate)),
              _buildInfoRow(Icons.location_on, 'Địa điểm',
                  tournament!.location ?? 'Chưa xác định'),
              _buildInfoRow(Icons.groups, 'Số đội tối đa',
                  '${tournament!.maxTeams ?? 'Chưa xác định'}'),
              _buildInfoRow(Icons.grid_view, 'Đội mỗi bảng',
                  '${tournament!.teamsPerGroup ?? 'Chưa xác định'}'),
            ],
          ),
          SizedBox(height: 16),
          _buildInfoCard(
            'Thống Kê',
            [
              _buildInfoRow(Icons.how_to_reg, 'Đội đã đăng ký',
                  '${tournament!.registeredTeamsCount}'),
              _buildInfoRow(Icons.sports_soccer, 'Tổng số trận',
                  '${tournament!.totalMatches}'),
              _buildInfoRow(Icons.check_circle, 'Đã hoàn thành',
                  '${tournament!.completedMatches}'),
              _buildInfoRow(Icons.schedule, 'Sắp diễn ra',
                  '${tournament!.upcomingMatches}'),
            ],
          ),
          SizedBox(height: 16),
          // Standings button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StandingsScreen(
                      tournamentId: widget.tournamentId,
                      tournamentName: tournament!.name,
                    ),
                  ),
                );
              },
              icon: Icon(Icons.table_chart),
              label: Text('Xem Bảng Xếp Hạng & Sơ Đồ Đấu'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsTab() {
    if (tournament!.registeredTeams.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có đội nào đăng ký',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: tournament!.registeredTeams.length,
      itemBuilder: (context, index) {
        final team = tournament!.registeredTeams[index];
        return _buildTeamCard(team);
      },
    );
  }

  Widget _buildMatchesTab() {
    if (tournament!.matches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có trận đấu nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: tournament!.matches.length,
      itemBuilder: (context, index) {
        final match = tournament!.matches[index];
        return _buildMatchCard(match);
      },
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(Team team) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          backgroundImage:
              team.logoUrl != null ? NetworkImage(team.logoUrl!) : null,
          child: team.logoUrl == null
              ? Icon(Icons.sports, color: Theme.of(context).primaryColor)
              : null,
        ),
        title: Text(
          team.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: team.coach != null
            ? Text(
                'HLV: ${team.coach}',
                style: TextStyle(fontSize: 14),
              )
            : null,
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // TODO: Navigate to team detail
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chi tiết đội: ${team.name}')),
          );
        },
      ),
    );
  }

  Widget _buildMatchCard(Match match) {
    final isCompleted = match.status == 'completed';
    final isOngoing = match.status == 'ongoing';

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to match detail screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MatchDetailScreen(matchId: match.id),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Match Status Badge
              if (isOngoing)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: Colors.white, size: 8),
                      SizedBox(width: 4),
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
              if (isOngoing) SizedBox(height: 12),

              // Teams and Score
              Row(
                children: [
                  // Team A
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.sports, size: 40),
                        SizedBox(height: 8),
                        Text(
                          match.teamA,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Score or VS
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: isCompleted && match.scoreTeamA != null && match.scoreTeamB != null
                        ? Text(
                            '${match.scoreTeamA} - ${match.scoreTeamB}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : Text(
                            'VS',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                  ),

                  // Team B
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.sports, size: 40),
                        SizedBox(height: 8),
                        Text(
                          match.teamB,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 8),

              // Match Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                      SizedBox(width: 4),
                      Text(
                        _formatDateTime(match.matchDate, match.matchTime),
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (match.location != null && match.location!.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          match.location!,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);

            if (!authProvider.isAuthenticated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Vui lòng đăng nhập để đăng ký'),
                  action: SnackBarAction(
                    label: 'Đăng nhập',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LoginScreen(),
                        ),
                      );
                    },
                  ),
                ),
              );
            } else {
              // TODO: Show team selection dialog
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đăng ký tham gia: ${tournament!.name}'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.app_registration),
              SizedBox(width: 8),
              Text(
                'Đăng Ký Tham Gia Giải Đấu',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
