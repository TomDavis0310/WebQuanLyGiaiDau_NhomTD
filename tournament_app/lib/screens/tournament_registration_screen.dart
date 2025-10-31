import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TournamentRegistrationScreen extends StatefulWidget {
  final int tournamentId;
  final String tournamentName;

  const TournamentRegistrationScreen({
    Key? key,
    required this.tournamentId,
    required this.tournamentName,
  }) : super(key: key);

  @override
  State<TournamentRegistrationScreen> createState() =>
      _TournamentRegistrationScreenState();
}

class _TournamentRegistrationScreenState
    extends State<TournamentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingData = true;
  Map<String, dynamic>? _tournamentDetails;
  List<dynamic> _myTeams = [];
  int? _selectedTeamId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoadingData = true;
      _error = null;
    });

    try {
      // Load tournament details
      final tournamentResponse =
          await ApiService.getTournamentDetail(widget.tournamentId);

      if (!tournamentResponse.success) {
        throw Exception(tournamentResponse.message);
      }

      // Load user's teams - convert to Map for compatibility
      final teamsResponse = await ApiService.getMyTeams();

      if (!teamsResponse.success) {
        throw Exception(teamsResponse.message);
      }

      setState(() {
        // Convert TournamentDetail to Map
        final tournament = tournamentResponse.data;
        if (tournament != null) {
          _tournamentDetails = {
            'id': tournament.id,
            'name': tournament.name,
            'location': tournament.location,
            'registrationStatus': tournament.registrationStatus,
            'maxTeams': tournament.maxTeams,
            'startDate': tournament.startDate.toIso8601String(),
            'endDate': tournament.endDate.toIso8601String(),
          };
        }
        // Get teams from response - data is List<UserTeam>
        final teamsData = teamsResponse.data;
        if (teamsData != null) {
          _myTeams = teamsData.data.map((team) => {
            'teamId': team.teamId,
            'id': team.teamId,
            'name': team.name,
            'coach': team.coach ?? 'Không có',
            'logoUrl': team.logo,
            'playerCount': team.playersCount,
          }).toList();
        }
        _isLoadingData = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingData = false;
      });
    }
  }

  Future<void> _submitRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedTeamId == null) {
      _showError('Vui lòng chọn đội để đăng ký');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.registerTournament(
        tournamentId: widget.tournamentId,
        teamId: _selectedTeamId!,
        notes: _notesController.text.trim(),
      );

      if (response.success) {
        if (mounted) {
          _showSuccess(response.message);
          // Wait a bit before navigating back
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            Navigator.pop(context, true); // Return true to indicate success
          }
        }
      } else {
        _showError(response.message);
      }
    } catch (e) {
      _showError('Lỗi: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
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
        duration: const Duration(seconds: 3),
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
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng Ký Giải Đấu'),
        backgroundColor: Colors.green,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _buildContent(),
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
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử Lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_myTeams.isEmpty) {
      return _buildNoTeamsView();
    }

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tournament Info Card
            _buildTournamentInfoCard(),

            const SizedBox(height: 16),

            // Team Selection Section
            _buildTeamSelectionSection(),

            const SizedBox(height: 16),

            // Notes Section
            _buildNotesSection(),

            const SizedBox(height: 24),

            // Submit Button
            _buildSubmitButton(),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTeamsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 80,
              color: Colors.orange.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa Có Đội Bóng',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn cần tạo đội bóng trước khi đăng ký giải đấu',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to create team screen
                Navigator.pushNamed(context, '/create-team').then((value) {
                  if (value == true) {
                    _loadData(); // Reload data if team was created
                  }
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Tạo Đội Mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTournamentInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Thông Tin Giải Đấu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  Icons.sports_soccer,
                  'Tên giải',
                  widget.tournamentName,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Thời gian',
                  _getTournamentDates(),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.location_on,
                  'Địa điểm',
                  _tournamentDetails?['location'] ?? 'Chưa xác định',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.info_outline,
                  'Trạng thái',
                  _tournamentDetails?['registrationStatus'] ?? 'Mở đăng ký',
                  valueColor: Colors.green,
                ),
                if (_tournamentDetails?['maxTeams'] != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    Icons.groups,
                    'Số đội tối đa',
                    '${_tournamentDetails!['maxTeams']} đội',
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getTournamentDates() {
    if (_tournamentDetails == null) return 'Chưa xác định';

    final startDate = _tournamentDetails!['startDate'];
    final endDate = _tournamentDetails!['endDate'];

    if (startDate == null || endDate == null) return 'Chưa xác định';

    return '$startDate - $endDate';
  }

  Widget _buildTeamSelectionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.groups, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chọn Đội Tham Gia',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Team List
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _myTeams.map((team) {
                final teamId = team['teamId'] ?? team['id'];
                final isSelected = _selectedTeamId == teamId;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTeamId = teamId;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.shade50
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Team Logo
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: team['logoUrl'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    team['logoUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(Icons.shield,
                                          color: Colors.grey.shade400);
                                    },
                                  ),
                                )
                              : Icon(Icons.shield,
                                  color: Colors.grey.shade400),
                        ),

                        const SizedBox(width: 12),

                        // Team Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                team['name'] ?? 'Unknown Team',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.blue.shade900
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'HLV: ${team['coach'] ?? 'Không có'}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              if (team['playerCount'] != null ||
                                  team['players'] != null)
                                Text(
                                  '${team['playerCount'] ?? team['players']?.length ?? 0} cầu thủ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Selection Indicator
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: isSelected ? Colors.blue : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.note_alt, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ghi Chú (Tùy Chọn)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notes Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextFormField(
              controller: _notesController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText:
                    'Nhập ghi chú hoặc thông tin bổ sung (nếu có)...\n\nVí dụ: Đội của tôi có kinh nghiệm thi đấu...',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitRegistration,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Xác Nhận Đăng Ký',
                      style: TextStyle(
                        fontSize: 18,
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
