import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tournament_registration_model.dart';
import '../models/team_model.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class AvailableTournamentsScreen extends StatefulWidget {
  const AvailableTournamentsScreen({Key? key}) : super(key: key);

  @override
  State<AvailableTournamentsScreen> createState() =>
      _AvailableTournamentsScreenState();
}

class _AvailableTournamentsScreenState
    extends State<AvailableTournamentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<TournamentForRegistration> _availableTournaments = [];
  List<MyTournamentRegistration> _myRegistrations = [];
  List<TeamModel> _myTeams = [];
  
  bool _isLoadingAvailable = true;
  bool _isLoadingRegistrations = true;
  // ignore: unused_field
  bool _isLoadingTeams = true;
  
  String? _errorMessageAvailable;
  String? _errorMessageRegistrations;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    _loadAvailableTournaments();
    _loadMyRegistrations();
    _loadMyTeams();
  }

  Future<void> _loadAvailableTournaments() async {
    setState(() {
      _isLoadingAvailable = true;
      _errorMessageAvailable = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        setState(() {
          _errorMessageAvailable = 'Vui lòng đăng nhập';
          _isLoadingAvailable = false;
        });
        return;
      }

      final response = await ApiService.getAvailableTournaments();

      if (response.success && response.data != null) {
        setState(() {
          _availableTournaments = (response.data as List)
              .map((json) => TournamentForRegistration.fromJson(json))
              .toList();
          _isLoadingAvailable = false;
        });
      } else {
        setState(() {
          _errorMessageAvailable = response.message;
          _isLoadingAvailable = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessageAvailable = 'Lỗi: $e';
        _isLoadingAvailable = false;
      });
    }
  }

  Future<void> _loadMyRegistrations() async {
    setState(() {
      _isLoadingRegistrations = true;
      _errorMessageRegistrations = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        setState(() {
          _errorMessageRegistrations = 'Vui lòng đăng nhập';
          _isLoadingRegistrations = false;
        });
        return;
      }

      final response = await ApiService.getMyRegistrations();

      if (response.success && response.data != null) {
        setState(() {
          _myRegistrations = (response.data as List)
              .map((json) => MyTournamentRegistration.fromJson(json))
              .toList();
          _isLoadingRegistrations = false;
        });
      } else {
        setState(() {
          _errorMessageRegistrations = response.message;
          _isLoadingRegistrations = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessageRegistrations = 'Lỗi: $e';
        _isLoadingRegistrations = false;
      });
    }
  }

  Future<void> _loadMyTeams() async {
    setState(() => _isLoadingTeams = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token != null) {
        final response = await ApiService.getMyTeams(token: token);
        if (response.success && response.data != null) {
          setState(() {
            _myTeams = response.data!.data
                .map((userTeam) => TeamModel(
                      id: userTeam.teamId,
                      name: userTeam.name,
                      description: userTeam.coach,
                      logoUrl: userTeam.logo,
                      userId: null,
                      createdAt: DateTime.now(),
                      playerCount: userTeam.playersCount,
                    ))
                .toList();
            _isLoadingTeams = false;
          });
          return;
        }
      }
      setState(() => _isLoadingTeams = false);
    } catch (e) {
      setState(() => _isLoadingTeams = false);
    }
  }

  Future<void> _registerTournament(int tournamentId, String tournamentName) async {
    if (_myTeams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần tạo đội trước khi đăng ký giải đấu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show team selection dialog
    final selectedTeamId = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn đội tham gia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _myTeams.map((team) {
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: team.logoUrl != null 
                    ? NetworkImage(team.logoUrl!)
                    : null,
                child: team.logoUrl == null 
                    ? const Icon(Icons.groups, size: 20)
                    : null,
              ),
              title: Text(team.name),
              subtitle: Text('${team.playerCount} cầu thủ'),
              onTap: () => Navigator.pop(context, team.id),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );

    if (selectedTeamId == null) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập')),
        );
        return;
      }

      final response = await ApiService.registerForTournament(
        tournamentId,
        selectedTeamId,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã đăng ký "$tournamentName" thành công')),
        );
        _loadData(); // Reload all data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _unregisterTournament(
    int tournamentId,
    int teamId,
    String tournamentName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận hủy đăng ký'),
        content: Text('Bạn có chắc muốn hủy đăng ký "$tournamentName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hủy đăng ký'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập')),
        );
        return;
      }

      final response = await ApiService.unregisterFromTournament(
        tournamentId,
        teamId,
      );

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã hủy đăng ký "$tournamentName"')),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký giải đấu'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Giải đấu mở', icon: Icon(Icons.list)),
            Tab(text: 'Đã đăng ký', icon: Icon(Icons.check_circle)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvailableTournaments(),
          _buildMyRegistrations(),
        ],
      ),
    );
  }

  Widget _buildAvailableTournaments() {
    if (_isLoadingAvailable) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessageAvailable != null) {
      return _buildErrorView(_errorMessageAvailable!, _loadAvailableTournaments);
    }

    if (_availableTournaments.isEmpty) {
      return _buildEmptyView(
        Icons.event_busy,
        'Không có giải đấu nào',
        'Hiện tại không có giải đấu mở đăng ký',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAvailableTournaments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _availableTournaments.length,
        itemBuilder: (context, index) {
          final tournament = _availableTournaments[index];
          return _buildAvailableTournamentCard(tournament);
        },
      ),
    );
  }

  Widget _buildMyRegistrations() {
    if (_isLoadingRegistrations) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessageRegistrations != null) {
      return _buildErrorView(_errorMessageRegistrations!, _loadMyRegistrations);
    }

    if (_myRegistrations.isEmpty) {
      return _buildEmptyView(
        Icons.assignment_outlined,
        'Chưa đăng ký giải nào',
        'Hãy đăng ký tham gia các giải đấu',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMyRegistrations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myRegistrations.length,
        itemBuilder: (context, index) {
          final registration = _myRegistrations[index];
          return _buildRegistrationCard(registration);
        },
      ),
    );
  }

  Widget _buildAvailableTournamentCard(TournamentForRegistration tournament) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tournament.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                tournament.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 64),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tournament.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatDate(tournament.startDate)} - ${_formatDate(tournament.endDate)}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                if (tournament.location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        tournament.location!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ],
                if (tournament.format != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.sports, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        tournament.format!,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đã đăng ký: ${tournament.registeredTeamsCount}/${tournament.maxTeams ?? "∞"}',
                      style: TextStyle(
                        color: tournament.hasAvailableSlots 
                            ? Colors.green 
                            : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: tournament.hasAvailableSlots
                          ? () => _registerTournament(tournament.id, tournament.name)
                          : null,
                      icon: const Icon(Icons.app_registration, size: 18),
                      label: const Text('Đăng ký'),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
    );
  }

  Widget _buildRegistrationCard(MyTournamentRegistration registration) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          registration.tournamentName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.groups, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Đội: ${registration.teamName}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${_formatDate(registration.startDate)} - ${_formatDate(registration.endDate)}',
                ),
              ],
            ),
            if (registration.location != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(registration.location!),
                ],
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red),
          onPressed: () => _unregisterTournament(
            registration.id,
            registration.teamId,
            registration.tournamentName,
          ),
          tooltip: 'Hủy đăng ký',
        ),
      ),
    );
  }

  Widget _buildErrorView(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[600])),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
