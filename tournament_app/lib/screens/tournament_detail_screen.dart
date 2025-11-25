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

import '../theme/app_theme.dart';

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
  
  // Voting state
  String? selectedTeamForVoting;
  bool isSubmittingVote = false;
  Map<String, dynamic>? votingStatistics;

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
    print('=== Loading Tournament Detail ===');
    print('Tournament ID: ${widget.tournamentId}');
    
    if (!mounted) return; // Check if widget is still mounted
    
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      print('Calling API: getTournamentDetail(${widget.tournamentId})');
      final response = await ApiService.getTournamentDetail(widget.tournamentId);
      
      if (!mounted) return; // Check again after async call
      
      print('API Response Success: ${response.success}');
      print('API Response Message: ${response.message}');
      print('API Response Data: ${response.data != null ? "Has Data" : "No Data"}');

      if (response.success && response.data != null) {
        // Add null safety checks for critical fields
        final tournamentData = response.data!;
        print('Tournament Name: ${tournamentData.name}');
        print('Max Teams: ${tournamentData.maxTeams}');
        print('Teams Per Group: ${tournamentData.teamsPerGroup}');
        
        // Validate required fields (allow 0 for teamsPerGroup for certain tournament formats)
        if (tournamentData.name.isNotEmpty && 
            tournamentData.maxTeams > 0) {
          print('Tournament data validated successfully');
          
          if (!mounted) return; // Final check before setState
          
          setState(() {
            tournament = tournamentData;
            isLoading = false;
          });
          
          // Load voting statistics if voting is enabled
          if (tournamentData.allowChampionVoting == true) {
            print('Loading voting statistics...');
            loadVotingStatistics();
          }
        } else {
          print('ERROR: Tournament data validation failed');
          
          if (!mounted) return;
          
          setState(() {
            errorMessage = 'Dữ liệu giải đấu không hợp lệ';
            isLoading = false;
          });
        }
      } else {
        print('ERROR: API returned failure or no data');
        
        if (!mounted) return;
        
        setState(() {
          errorMessage = response.message.isNotEmpty 
              ? response.message 
              : 'Không thể tải thông tin giải đấu';
          isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('ERROR: Exception in loadTournamentDetail');
      print('Exception: $e');
      print('StackTrace: $stackTrace');
      
      if (!mounted) return;
      
      setState(() {
        errorMessage = 'Lỗi kết nối: $e';
        isLoading = false;
      });
    }
  }

  Future<void> loadVotingStatistics() async {
    try {
      final response = await ApiService.getTournamentVoteStatistics(
        widget.tournamentId,
      );

      if (!mounted) return; // Check if widget is still mounted

      if (response.success && response.data != null) {
        setState(() {
          votingStatistics = response.data;
        });
      }
    } catch (e) {
      // Silently fail - statistics are optional
      print('Failed to load voting statistics: $e');
    }
  }

  Future<void> submitVote() async {
    if (selectedTeamForVoting == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng chọn đội để bình chọn'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (!authProvider.isAuthenticated) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng đăng nhập để bình chọn'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Đăng nhập',
            textColor: Colors.white,
            onPressed: () {
              if (!mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    setState(() {
      isSubmittingVote = true;
    });

    try {
      final response = await ApiService.voteTournamentChampion(
        tournamentId: widget.tournamentId,
        votedTeamName: selectedTeamForVoting!,
        notes: null,
        token: authProvider.token!,
      );

      if (!mounted) return;

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isEmpty ? 'Bình chọn thành công! +5 điểm' : response.message),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reload tournament detail to update voting status
        await loadTournamentDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isEmpty ? 'Bình chọn thất bại' : response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi kết nối: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmittingVote = false;
        });
      }
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
    print('Building TournamentDetailScreen (isLoading: $isLoading, hasData: ${tournament != null}, hasError: ${errorMessage != null})');
    
    return PopScope(
      canPop: true,
      child: Scaffold(
        body: SafeArea(
          child: _buildBody(),
        ),
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
      ),
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
      backgroundColor: AppTheme.lightPrimary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
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
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                    ),
                    child: Icon(
                      Icons.sports,
                      size: 80,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  );
                },
              )
            else
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: Icon(
                  Icons.sports,
                  size: 80,
                  color: Colors.white.withOpacity(0.5),
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
                  '${tournament!.registeredTeamsCount}/${tournament!.maxTeams}',
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
                  '${tournament!.maxTeams}'),
              _buildInfoRow(Icons.grid_view, 'Đội mỗi bảng',
                  '${tournament!.teamsPerGroup}'),
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
          // Voting section
          if (tournament!.allowChampionVoting == true)
            _buildVotingCard(),
          if (tournament!.allowChampionVoting == true)
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
          SizedBox(height: 12),
          // Video Highlights button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/video-highlights',
                  arguments: {
                    'tournamentId': widget.tournamentId,
                    'searchQuery': tournament!.name,
                  },
                );
              },
              icon: Icon(Icons.video_library),
              label: Text('Video Highlights'),
              style: OutlinedButton.styleFrom(
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: AppTheme.cardDecoration(isDark: isDark),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ...children,
        ],
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

  Widget _buildVotingCard() {
    final hasVoted = tournament!.userHasVoted == true;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: AppTheme.cardDecoration(isDark: isDark),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.how_to_vote, color: Colors.amber[700], size: 24),
              SizedBox(width: 8),
              Text(
                'Bình Chọn Vô Địch',
                style: AppTheme.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          if (hasVoted) ...[
            // User has already voted
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bạn đã bình chọn',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                          ),
                        ),
                        if (tournament!.userVotedTeamName != null)
                          Text(
                            tournament!.userVotedTeamName!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // User can vote
            Text(
              'Chọn đội bạn nghĩ sẽ vô địch:',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 12),
            
            // Team selection dropdown
            DropdownButtonFormField<String>(
              value: selectedTeamForVoting,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                hintText: 'Chọn đội...',
              ),
              items: tournament!.registeredTeams.map((team) {
                return DropdownMenuItem<String>(
                  value: team.name,
                  child: Text(team.name),
                );
              }).toList(),
              onChanged: isSubmittingVote ? null : (value) {
                setState(() {
                  selectedTeamForVoting = value;
                });
              },
            ),
            SizedBox(height: 12),
            
            // Vote button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSubmittingVote ? null : submitVote,
                icon: isSubmittingVote
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.how_to_vote),
                label: Text(isSubmittingVote ? 'Đang gửi...' : 'Bình Chọn (+5 điểm)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
          
          // Voting statistics
          if (votingStatistics != null) ...[
            SizedBox(height: 16),
            Divider(),
            SizedBox(height: 8),
            Text(
              'Thống Kê Bình Chọn',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 12),
            ...((votingStatistics!['teamVotes'] as List<dynamic>?) ?? [])
                .map((vote) => _buildVoteStatItem(
                      vote['teamName'] as String,
                      vote['voteCount'] as int,
                      vote['percentage'] as double,
                    ))
                .toList(),
            SizedBox(height: 8),
            Text(
              'Tổng số phiếu: ${votingStatistics!['totalVotes']}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVoteStatItem(String teamName, int voteCount, double percentage) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  teamName,
                  style: TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}% ($voteCount)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[700]!),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(Team team) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(isDark: isDark),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.lightPrimary.withOpacity(0.1),
          ),
          child: ClipOval(
            child: team.logoUrl != null
                ? Image.network(
                    team.logoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.sports, color: AppTheme.lightPrimary);
                    },
                  )
                : Icon(Icons.sports, color: AppTheme.lightPrimary),
          ),
        ),
        title: Text(
          team.name,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: team.coach != null
            ? Text(
                'HLV: ${team.coach}',
                style: AppTheme.bodySmall,
              )
            : null,
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pushNamed(
            context,
            '/team-detail',
            arguments: {'teamId': team.teamId},
          );
        },
      ),
    );
  }

  Widget _buildMatchCard(Match match) {
    final isCompleted = match.status == 'completed';
    final isOngoing = match.status == 'ongoing';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration(isDark: isDark),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
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
                          Icon(Icons.sports, size: 40, color: AppTheme.lightPrimary),
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
                                color: AppTheme.lightPrimary,
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
                          Icon(Icons.sports, size: 40, color: AppTheme.lightPrimary),
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
