import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/tournament.dart';
import '../models/sport.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_logo.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'tournament_detail_screen.dart';

class TournamentListScreen extends StatefulWidget {
  final Sport sport;

  const TournamentListScreen({
    super.key,
    required this.sport,
  });

  @override
  State<TournamentListScreen> createState() => _TournamentListScreenState();
}

class _TournamentListScreenState extends State<TournamentListScreen> {
  List<Tournament> tournaments = [];
  List<Tournament> filteredTournaments = [];
  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';
  String selectedStatus = 'all'; // all, upcoming, ongoing, completed

  @override
  void initState() {
    super.initState();
    loadTournaments();
  }

  Future<void> loadTournaments() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getTournamentsBySport(widget.sport.id);

      if (response.success && response.data != null) {
        setState(() {
          tournaments = response.data!;
          _applyFilters();
          isLoading = false;
        });
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

  void _applyFilters() {
    filteredTournaments = tournaments.where((tournament) {
      // Search filter
      bool matchesSearch = searchQuery.isEmpty ||
          tournament.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          (tournament.description?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);

      // Status filter
      bool matchesStatus = selectedStatus == 'all' ||
          tournament.registrationStatus.toLowerCase() == selectedStatus.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();

    // Sort by start date (newest first)
    filteredTournaments.sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      _applyFilters();
    });
  }

  void _onStatusFilterChanged(String? status) {
    if (status != null) {
      setState(() {
        selectedStatus = status;
        _applyFilters();
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
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
      appBar: AppBar(
        title: AppLogoWithText(
          logoHeight: 40,
          text: widget.sport.name,
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadTournaments,
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                icon: Icon(
                  authProvider.isAuthenticated ? Icons.person : Icons.login,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => authProvider.isAuthenticated
                          ? ProfileScreen()
                          : LoginScreen(),
                    ),
                  );
                },
                tooltip: authProvider.isAuthenticated
                    ? 'Thông tin cá nhân'
                    : 'Đăng nhập',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm giải đấu...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                searchQuery = '';
                                _applyFilters();
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                SizedBox(height: 12),

                // Status Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'Tất cả', Icons.list),
                      SizedBox(width: 8),
                      _buildFilterChip('upcoming', 'Sắp diễn ra', Icons.schedule),
                      SizedBox(width: 8),
                      _buildFilterChip('ongoing', 'Đang diễn ra', Icons.play_circle),
                      SizedBox(width: 8),
                      _buildFilterChip('completed', 'Đã kết thúc', Icons.check_circle),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tournament List
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = selectedStatus == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
          SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        if (selected) {
          _onStatusFilterChanged(value);
        }
      },
      selectedColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
            Text('Đang tải giải đấu...'),
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
              onPressed: loadTournaments,
              child: Text('Thử Lại'),
            ),
          ],
        ),
      );
    }

    if (filteredTournaments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              searchQuery.isNotEmpty || selectedStatus != 'all'
                  ? 'Không tìm thấy giải đấu phù hợp'
                  : 'Chưa có giải đấu nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            if (searchQuery.isNotEmpty || selectedStatus != 'all') ...[
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    searchQuery = '';
                    selectedStatus = 'all';
                    _applyFilters();
                  });
                },
                icon: Icon(Icons.clear_all),
                label: Text('Xóa bộ lọc'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadTournaments,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: filteredTournaments.length,
        itemBuilder: (context, index) {
          final tournament = filteredTournaments[index];
          return _buildTournamentCard(tournament);
        },
      ),
    );
  }

  Widget _buildTournamentCard(Tournament tournament) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigate to tournament detail
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TournamentDetailScreen(
                tournamentId: tournament.id,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tournament Image
            if (tournament.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  tournament.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.sports,
                        size: 64,
                        color: Theme.of(context).primaryColor,
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(tournament.registrationStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(tournament.registrationStatus),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusText(tournament.registrationStatus),
                      style: TextStyle(
                        color: _getStatusColor(tournament.registrationStatus),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SizedBox(height: 12),

                  // Tournament Name
                  Text(
                    tournament.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Description
                  if (tournament.description != null)
                    Text(
                      tournament.description!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 12),

                  // Tournament Info
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Bắt đầu: ${_formatDate(tournament.startDate)}',
                  ),
                  SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Kết thúc: ${_formatDate(tournament.endDate)}',
                  ),
                  SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.location_on,
                    tournament.location ?? 'Chưa xác định',
                  ),
                  if (tournament.maxTeams != null) ...[
                    SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.groups,
                      '${tournament.maxTeams} đội tối đa',
                    ),
                  ],
                  if (tournament.registeredTeamsCount != null) ...[
                    SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.how_to_reg,
                      '${tournament.registeredTeamsCount} đội đã đăng ký',
                    ),
                  ],
                  SizedBox(height: 12),

                  // Registration Button
                  if (tournament.registrationStatus.toLowerCase() == 'upcoming')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // TODO: Register for tournament
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );

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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đăng ký tham gia: ${tournament.name}'),
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.app_registration),
                        label: Text('Đăng Ký Tham Gia'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                  // View Details Button for ongoing/completed
                  if (tournament.registrationStatus.toLowerCase() != 'upcoming')
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Navigate to tournament detail
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Xem chi tiết: ${tournament.name}'),
                            ),
                          );
                        },
                        icon: Icon(Icons.arrow_forward),
                        label: Text('Xem Chi Tiết'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey[600],
        ),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
