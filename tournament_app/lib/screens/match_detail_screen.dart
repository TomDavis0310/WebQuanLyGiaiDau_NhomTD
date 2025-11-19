import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../models/match_detail.dart';
import '../services/api_service.dart';
import '../services/signalr_service.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../widgets/custom_button.dart';
import 'team_detail_screen.dart';
import 'login_screen.dart';

class MatchDetailScreen extends StatefulWidget {
  final int matchId;

  const MatchDetailScreen({
    super.key,
    required this.matchId,
  });

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> with SingleTickerProviderStateMixin {
  MatchDetail? _matchDetail;
  bool _isLoading = true;
  String? _error;
  final SignalRService _signalRService = SignalRService();
  late TabController _tabController;
  
  // Voting state
  String? selectedTeamForVoting; // 'TeamA' or 'TeamB'
  bool isSubmittingVote = false;
  Map<String, dynamic>? votingStatistics;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMatchDetail();
    _initializeSignalR();
  }

  @override
  void dispose() {
    _signalRService.leaveMatchGroup(widget.matchId.toString());
    _signalRService.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeSignalR() async {
    try {
      await _signalRService.connect();
      await _signalRService.joinMatchGroup(widget.matchId.toString());
      
      // Listen to score updates
      _signalRService.scoreUpdates.listen((update) {
        if (update.matchId == widget.matchId.toString()) {
          setState(() {
            if (_matchDetail != null) {
              // Update scores in real-time
              _matchDetail = MatchDetail(
                id: _matchDetail!.id,
                teamA: _matchDetail!.teamA,
                teamB: _matchDetail!.teamB,
                matchDate: _matchDetail!.matchDate,
                matchTime: _matchDetail!.matchTime,
                location: _matchDetail!.location,
                scoreTeamA: update.scoreA,
                scoreTeamB: update.scoreB,
                groupName: _matchDetail!.groupName,
                round: _matchDetail!.round,
                status: _matchDetail!.status,
                tournament: _matchDetail!.tournament,
                teamAInfo: _matchDetail!.teamAInfo,
                teamBInfo: _matchDetail!.teamBInfo,
                playerScorings: _matchDetail!.playerScorings,
                highlightsVideoUrl: _matchDetail!.highlightsVideoUrl,
                liveStreamUrl: _matchDetail!.liveStreamUrl,
                videoDescription: _matchDetail!.videoDescription,
              );
            }
          });
          
          // Show snackbar notification
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('🔴 Cập nhật tỷ số: ${update.teamA} ${update.scoreA} - ${update.scoreB} ${update.teamB}'),
                backgroundColor: Colors.red[700],
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      });

      // Listen to status updates
      _signalRService.statusUpdates.listen((update) {
        if (update.matchId == widget.matchId.toString()) {
          setState(() {
            if (_matchDetail != null) {
              _matchDetail = MatchDetail(
                id: _matchDetail!.id,
                teamA: _matchDetail!.teamA,
                teamB: _matchDetail!.teamB,
                matchDate: _matchDetail!.matchDate,
                matchTime: _matchDetail!.matchTime,
                location: _matchDetail!.location,
                scoreTeamA: _matchDetail!.scoreTeamA,
                scoreTeamB: _matchDetail!.scoreTeamB,
                groupName: _matchDetail!.groupName,
                round: _matchDetail!.round,
                status: update.status,
                tournament: _matchDetail!.tournament,
                teamAInfo: _matchDetail!.teamAInfo,
                teamBInfo: _matchDetail!.teamBInfo,
                playerScorings: _matchDetail!.playerScorings,
                highlightsVideoUrl: _matchDetail!.highlightsVideoUrl,
                liveStreamUrl: _matchDetail!.liveStreamUrl,
                videoDescription: _matchDetail!.videoDescription,
              );
            }
          });
        }
      });
    } catch (e) {
      print('SignalR initialization error: $e');
      // Continue without real-time updates
    }
  }

  Future<void> _loadMatchDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final response = await ApiService.getMatchDetail(widget.matchId);

    if (response.success && response.data != null) {
      setState(() {
        _matchDetail = response.data;
        _isLoading = false;
      });
      
      // Load voting statistics if voting is enabled
      if (_matchDetail!.allowWinnerVoting == true) {
        _loadVotingStatistics();
      }
    } else {
      setState(() {
        _error = response.message;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadVotingStatistics() async {
    try {
      final response = await ApiService.getMatchVoteStatistics(widget.matchId);

      if (response.success && response.data != null) {
        setState(() {
          votingStatistics = response.data;
        });
      }
    } catch (e) {
      print('Failed to load voting statistics: $e');
    }
  }

  Future<void> _submitVote() async {
    if (selectedTeamForVoting == null) {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng đăng nhập để bình chọn'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Đăng nhập',
            textColor: Colors.white,
            onPressed: () {
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

    setState(() {
      isSubmittingVote = true;
    });

    try {
      final response = await ApiService.voteMatchWinner(
        matchId: widget.matchId,
        votedTeam: selectedTeamForVoting!,
        notes: null,
        token: authProvider.token!,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isEmpty ? 'Bình chọn thành công! +3 điểm' : response.message),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reload match detail
        await _loadMatchDetail();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isEmpty ? 'Bình chọn thất bại' : response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi kết nối: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSubmittingVote = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const LoadingWidget(message: 'Đang tải thông tin trận đấu...')
          : _error != null
              ? CustomErrorWidget(
                  message: _error!,
                  onRetry: _loadMatchDetail,
                )
              : _matchDetail != null
                  ? _buildMatchContent()
                  : const Center(child: Text('Không có dữ liệu')),
    );
  }

  Widget _buildMatchContent() {
    final match = _matchDetail!;
    
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 280,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildMatchHeader(match),
            ),
          ),
        ];
      },
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.blue[700],
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue[700],
              tabs: const [
                Tab(text: 'Chi tiết'),
                Tab(text: 'Thống kê ghi bàn'),
              ],
            ),
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(match),
                _buildStatsTab(match),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchHeader(MatchDetail match) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue[900]!,
            Colors.blue[700]!,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Live badge
            if (match.isLive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[600],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'ĐANG DIỄN RA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

            // Teams
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Team A
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: match.teamAInfo?.logoUrl != null
                            ? NetworkImage(match.teamAInfo!.logoUrl!)
                            : null,
                        child: match.teamAInfo?.logoUrl == null
                            ? const Icon(Icons.sports_soccer, size: 40)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        match.teamA,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Score or VS
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: match.isCompleted || match.isLive
                      ? Text(
                          '${match.scoreTeamA ?? 0} - ${match.scoreTeamB ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : const Text(
                          'VS',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),

                // Team B
                Expanded(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: match.teamBInfo?.logoUrl != null
                            ? NetworkImage(match.teamBInfo!.logoUrl!)
                            : null,
                        child: match.teamBInfo?.logoUrl == null
                            ? const Icon(Icons.sports_soccer, size: 40)
                            : null,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        match.teamB,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Match info
            Text(
              '${DateFormat('dd/MM/yyyy').format(match.matchDate)}${match.matchTime != null ? ' - ${match.matchTime}' : ''}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            if (match.location != null)
              Text(
                '📍 ${match.location}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoSection(MatchDetail match) {
    return Card(
      elevation: 3,
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.play_circle_fill, size: 28, color: Colors.red[700]),
                const SizedBox(width: 12),
                Text(
                  'Video trận đấu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[900],
                  ),
                ),
              ],
            ),
            if (match.videoDescription != null) ...[
              const SizedBox(height: 8),
              Text(
                match.videoDescription!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
            const SizedBox(height: 16),
            
            // Live Stream Button
            if (match.hasLiveStream)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchVideo(match.liveStreamUrl!),
                  icon: const Icon(Icons.live_tv, size: 24),
                  label: const Text(
                    'XEM TRỰC TIẾP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            
            // Spacing between buttons
            if (match.hasLiveStream && match.hasHighlights)
              const SizedBox(height: 12),
            
            // Highlights Button
            if (match.hasHighlights)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchVideo(match.highlightsVideoUrl!),
                  icon: const Icon(Icons.movie, size: 24),
                  label: const Text(
                    'XEM HIGHLIGHTS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchVideo(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể mở video'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi mở video: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildDetailsTab(MatchDetail match) {
    return RefreshIndicator(
      onRefresh: _loadMatchDetail,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Voting section
          if (match.allowWinnerVoting == true)
            _buildVotingCard(match),
          
          if (match.allowWinnerVoting == true)
            const SizedBox(height: 16),
          
          // Video section
          if (match.hasHighlights || match.hasLiveStream)
            _buildVideoSection(match),
          
          if (match.hasHighlights || match.hasLiveStream)
            const SizedBox(height: 16),

          // Tournament info
          _buildInfoCard(
            title: 'Giải đấu',
            items: [
              _buildInfoRow(Icons.emoji_events, 'Giải đấu', match.tournament.name),
              _buildInfoRow(Icons.sports, 'Môn thể thao', match.tournament.sports.name),
              if (match.groupName != null)
                _buildInfoRow(Icons.group, 'Bảng đấu', match.groupName!),
              if (match.round != null)
                _buildInfoRow(Icons.calendar_today, 'Vòng', 'Vòng ${match.round}'),
            ],
          ),

          const SizedBox(height: 16),

          // Team A details
          if (match.teamAInfo != null)
            _buildTeamCard(match.teamAInfo!, 'Đội A'),

          const SizedBox(height: 16),

          // Team B details
          if (match.teamBInfo != null)
            _buildTeamCard(match.teamBInfo!, 'Đội B'),

          const SizedBox(height: 16),

          // Match status
          _buildInfoCard(
            title: 'Trạng thái trận đấu',
            items: [
              _buildInfoRow(
                Icons.info_outline,
                'Trạng thái',
                match.isLive
                    ? 'Đang diễn ra'
                    : match.isCompleted
                        ? 'Đã kết thúc'
                        : 'Sắp diễn ra',
                color: match.isLive
                    ? Colors.red
                    : match.isCompleted
                        ? Colors.green
                        : Colors.orange,
              ),
              if (match.isCompleted && match.winner != null)
                _buildInfoRow(
                  Icons.emoji_events,
                  'Kết quả',
                  match.winner == 'Hòa' ? 'Hòa' : 'Thắng: ${match.winner}',
                  color: Colors.amber,
                ),
            ],
          ),

          // SignalR connection status
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _signalRService.isConnected ? Colors.green[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _signalRService.isConnected ? Colors.green : Colors.orange,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _signalRService.isConnected ? Icons.wifi : Icons.wifi_off,
                  color: _signalRService.isConnected ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 12),
                Text(
                  _signalRService.isConnected
                      ? '✅ Cập nhật trực tiếp đang hoạt động'
                      : '⚠️ Không có cập nhật trực tiếp',
                  style: TextStyle(
                    color: _signalRService.isConnected ? Colors.green[800] : Colors.orange[800],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(MatchDetail match) {
    if (match.playerScorings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có thống kê ghi bàn',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Danh sách ghi bàn',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 16),
        ...match.playerScorings.map((scoring) => _buildScoringCard(scoring)),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> items}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 16),
            ...items,
          ],
        ),
      ),
    );
  }

  Widget _buildVotingCard(MatchDetail match) {
    final hasVoted = match.userHasVoted == true;
    final isMatchNotStarted = !match.isLive && !match.isCompleted;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.how_to_vote, color: Colors.amber[700], size: 24),
                const SizedBox(width: 8),
                Text(
                  'Dự Đoán Kết Quả',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (hasVoted) ...[
              // User has already voted
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
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
                          if (match.userVotedTeam != null)
                            Text(
                              match.userVotedTeam == 'TeamA' ? match.teamA : match.teamB,
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
            ] else if (isMatchNotStarted) ...[
              // User can vote
              Text(
                'Chọn đội bạn nghĩ sẽ thắng:',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 12),
              
              // Team selection
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: isSubmittingVote ? null : () {
                        setState(() {
                          selectedTeamForVoting = 'TeamA';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selectedTeamForVoting == 'TeamA'
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selectedTeamForVoting == 'TeamA'
                                ? Colors.blue
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (match.teamAInfo?.logoUrl != null)
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(match.teamAInfo!.logoUrl!),
                              )
                            else
                              const CircleAvatar(
                                radius: 30,
                                child: Icon(Icons.sports_soccer),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              match.teamA,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selectedTeamForVoting == 'TeamA'
                                    ? Colors.blue[900]
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: isSubmittingVote ? null : () {
                        setState(() {
                          selectedTeamForVoting = 'TeamB';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selectedTeamForVoting == 'TeamB'
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selectedTeamForVoting == 'TeamB'
                                ? Colors.blue
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (match.teamBInfo?.logoUrl != null)
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(match.teamBInfo!.logoUrl!),
                              )
                            else
                              const CircleAvatar(
                                radius: 30,
                                child: Icon(Icons.sports_soccer),
                              ),
                            const SizedBox(height: 8),
                            Text(
                              match.teamB,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: selectedTeamForVoting == 'TeamB'
                                    ? Colors.blue[900]
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Vote button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSubmittingVote ? null : _submitVote,
                  icon: isSubmittingVote
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.how_to_vote),
                  label: Text(isSubmittingVote ? 'Đang gửi...' : 'Bình Chọn (+3 điểm)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ] else ...[
              // Match has started or completed
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Không thể bình chọn khi trận đấu đang diễn ra hoặc đã kết thúc',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Voting statistics
            if (votingStatistics != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Thống Kê Dự Đoán',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),
              _buildVoteStatItem(
                match.teamA,
                (votingStatistics!['teamAVotes'] as int?) ?? 0,
                (votingStatistics!['teamAPercentage'] as num?)?.toDouble() ?? 0.0,
              ),
              const SizedBox(height: 8),
              _buildVoteStatItem(
                match.teamB,
                (votingStatistics!['teamBVotes'] as int?) ?? 0,
                (votingStatistics!['teamBPercentage'] as num?)?.toDouble() ?? 0.0,
              ),
              const SizedBox(height: 8),
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
      ),
    );
  }

  Widget _buildVoteStatItem(String teamName, int voteCount, double percentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                teamName,
                style: const TextStyle(fontSize: 13),
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
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[700]!),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.blue[700]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: color ?? Colors.black87,
                fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(dynamic team, String label) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to team detail
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamDetailScreen(
                teamId: team.teamId,
                teamName: team.name,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: team.logoUrl != null
                        ? NetworkImage(team.logoUrl!)
                        : null,
                    child: team.logoUrl == null
                        ? const Icon(Icons.sports_soccer, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          team.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (team.coach != null)
                          Text(
                            'HLV: ${team.coach}',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoringCard(dynamic scoring) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[700],
          child: Text(
            '⚽',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          scoring.player.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (scoring.player.position != null)
              Text('Vị trí: ${scoring.player.position}'),
            if (scoring.scoringTime != null)
              Text('Thời gian: ${scoring.scoringTime}'),
            if (scoring.notes != null)
              Text('Ghi chú: ${scoring.notes}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${scoring.points} điểm',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
