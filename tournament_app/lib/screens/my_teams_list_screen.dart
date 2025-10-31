import 'package:flutter/material.dart';
import '../services/api_service.dart';

class MyTeamsListScreen extends StatefulWidget {
  const MyTeamsListScreen({Key? key}) : super(key: key);

  @override
  State<MyTeamsListScreen> createState() => _MyTeamsListScreenState();
}

class _MyTeamsListScreenState extends State<MyTeamsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  List<dynamic> _teams = [];
  List<dynamic> _filteredTeams = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  Future<void> _loadTeams() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getMyTeams();

      if (response.success) {
        setState(() {
          // Convert MyTeamsResponse to List of Map
          final teamsData = response.data;
          if (teamsData != null) {
            _teams = teamsData.data.map((team) => {
              'teamId': team.teamId,
              'id': team.teamId,
              'name': team.name,
              'coach': team.coach ?? 'Không có',
              'logoUrl': team.logo,
              'playerCount': team.playersCount,
            }).toList();
            _filteredTeams = _teams;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterTeams(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTeams = _teams;
      } else {
        _filteredTeams = _teams.where((team) {
          final teamName = (team['name'] ?? '').toLowerCase();
          final coach = (team['coach'] ?? '').toLowerCase();
          final searchLower = query.toLowerCase();

          return teamName.contains(searchLower) ||
              coach.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _deleteTeam(int teamId, String teamName) async {
    final confirmed = await _showDeleteConfirmation(teamName);
    if (!confirmed) return;

    try {
      final response = await ApiService.deleteTeam(teamId);

      if (response.success) {
        if (mounted) {
          _showSuccess('Đã xóa đội $teamName');
          _loadTeams(); // Reload list
        }
      } else {
        _showError(response.message);
      }
    } catch (e) {
      _showError('Lỗi: ${e.toString()}');
    }
  }

  Future<bool> _showDeleteConfirmation(String teamName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xác Nhận Xóa'),
            content: Text(
              'Bạn có chắc chắn muốn xóa đội "$teamName"?\n\nHành động này không thể hoàn tác.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Xóa'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đội Của Tôi'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTeams,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildErrorView()
                    : _filteredTeams.isEmpty
                        ? _buildEmptyView()
                        : _buildTeamsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/create-team').then((value) {
            if (value == true) {
              _loadTeams(); // Reload if team was created
            }
          });
        },
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.add),
        label: const Text('Tạo Đội Mới'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: _filterTeams,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm theo tên đội hoặc HLV...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterTeams('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blue, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Đã có lỗi xảy ra',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTeams,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử Lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    final isSearching = _searchController.text.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.groups_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isSearching ? 'Không Tìm Thấy' : 'Chưa Có Đội',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              isSearching
                  ? 'Không có đội nào phù hợp với tìm kiếm của bạn'
                  : 'Bạn chưa có đội bóng nào. Hãy tạo đội đầu tiên!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            if (!isSearching) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/create-team').then((value) {
                    if (value == true) {
                      _loadTeams();
                    }
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Tạo Đội Đầu Tiên'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTeamsList() {
    return RefreshIndicator(
      onRefresh: _loadTeams,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredTeams.length,
        itemBuilder: (context, index) {
          final team = _filteredTeams[index];
          return _buildTeamCard(team);
        },
      ),
    );
  }

  Widget _buildTeamCard(Map<String, dynamic> team) {
    final teamId = team['teamId'] ?? team['id'];
    final teamName = team['name'] ?? 'Unknown Team';
    final coach = team['coach'] ?? 'Không có HLV';
    final logoUrl = team['logoUrl'];
    final playerCount = team['playerCount'] ?? team['players']?.length ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/team-detail',
            arguments: {'teamId': teamId},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Team Logo
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: logoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              logoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.shield,
                                  size: 32,
                                  color: Colors.grey.shade400,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.shield,
                            size: 32,
                            color: Colors.grey.shade400,
                          ),
                  ),

                  const SizedBox(width: 16),

                  // Team Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          teamName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'HLV: $coach',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.groups,
                                size: 16, color: Colors.grey.shade600),
                            const SizedBox(width: 4),
                            Text(
                              '$playerCount cầu thủ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Action Buttons
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.pushNamed(
                          context,
                          '/edit-team',
                          arguments: {'team': team},
                        ).then((value) {
                          if (value == true) {
                            _loadTeams(); // Reload if edited
                          }
                        });
                      } else if (value == 'delete') {
                        _deleteTeam(teamId, teamName);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 8),
                            Text('Chỉnh sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Xóa'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/team-players',
                          arguments: {'teamId': teamId, 'teamName': teamName},
                        );
                      },
                      icon: const Icon(Icons.people, size: 18),
                      label: const Text('Cầu Thủ'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/team-statistics',
                          arguments: {'teamId': teamId, 'teamName': teamName},
                        );
                      },
                      icon: const Icon(Icons.bar_chart, size: 18),
                      label: const Text('Thống Kê'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
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
}
