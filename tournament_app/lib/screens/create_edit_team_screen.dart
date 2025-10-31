import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateEditTeamScreen extends StatefulWidget {
  final Map<String, dynamic>? team; // null = create, not null = edit

  const CreateEditTeamScreen({
    Key? key,
    this.team,
  }) : super(key: key);

  @override
  State<CreateEditTeamScreen> createState() => _CreateEditTeamScreenState();
}

class _CreateEditTeamScreenState extends State<CreateEditTeamScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _teamNameController = TextEditingController();
  final _coachController = TextEditingController();

  // State
  bool _isLoading = false;
  String? _logoUrl;
  String? _selectedSport;
  final List<String> _sports = [
    'Bóng đá',
    'Bóng rổ',
    'Bóng chuyền',
    'Cầu lông',
    'Bóng bàn',
  ];

  bool get _isEditing => widget.team != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadTeamData();
    }
  }

  void _loadTeamData() {
    final team = widget.team!;
    _teamNameController.text = team['name'] ?? '';
    _coachController.text = team['coach'] ?? '';
    _logoUrl = team['logoUrl'];
    _selectedSport = team['sport'] ?? _sports.first;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final teamData = {
        'name': _teamNameController.text.trim(),
        'coach': _coachController.text.trim(),
        'sport': _selectedSport ?? _sports.first,
        if (_logoUrl != null) 'logoUrl': _logoUrl,
      };

      final response = _isEditing
          ? await ApiService.updateTeam(
              widget.team!['teamId'] ?? widget.team!['id'],
              teamData,
            )
          : await ApiService.createTeam(teamData);

      if (response.success) {
        if (mounted) {
          _showSuccess(
            _isEditing
                ? 'Cập nhật đội thành công'
                : 'Tạo đội mới thành công',
          );
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.pop(context, true); // Return true for success
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
    _teamNameController.dispose();
    _coachController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh Sửa Đội' : 'Tạo Đội Mới'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Logo Section
              _buildLogoSection(),

              const SizedBox(height: 24),

              // Team Name
              _buildTeamNameField(),

              const SizedBox(height: 16),

              // Coach Name
              _buildCoachField(),

              const SizedBox(height: 16),

              // Sport Selection
              _buildSportSelection(),

              const SizedBox(height: 32),

              // Submit Button
              _buildSubmitButton(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: _logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      _logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.shield,
                          size: 60,
                          color: Colors.grey.shade400,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.shield,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement image picker
              _showError('Chức năng tải ảnh sẽ được thêm sau');
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Chọn Logo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Logo đội (Tùy chọn)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamNameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Tên Đội',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _teamNameController,
            decoration: InputDecoration(
              hintText: 'Ví dụ: FC Barcelona, Lakers...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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
              prefixIcon: const Icon(Icons.sports_soccer),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tên đội';
              }
              if (value.trim().length < 3) {
                return 'Tên đội phải có ít nhất 3 ký tự';
              }
              if (value.trim().length > 50) {
                return 'Tên đội không được quá 50 ký tự';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCoachField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Huấn Luyện Viên',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _coachController,
            decoration: InputDecoration(
              hintText: 'Nhập tên huấn luyện viên...',
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
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
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tên HLV';
              }
              if (value.trim().length < 3) {
                return 'Tên HLV phải có ít nhất 3 ký tự';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSportSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.sports, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Môn Thể Thao',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              children: _sports.map((sport) {
                final isSelected = _selectedSport == sport;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedSport = sport;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color: sport != _sports.last
                              ? Colors.grey.shade200
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getSportIcon(sport),
                          color: isSelected ? Colors.blue : Colors.grey,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            sport,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected ? Colors.blue : Colors.black87,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.blue,
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

  IconData _getSportIcon(String sport) {
    switch (sport) {
      case 'Bóng đá':
        return Icons.sports_soccer;
      case 'Bóng rổ':
        return Icons.sports_basketball;
      case 'Bóng chuyền':
        return Icons.sports_volleyball;
      case 'Cầu lông':
        return Icons.sports_tennis;
      case 'Bóng bàn':
        return Icons.sports_tennis;
      default:
        return Icons.sports;
    }
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
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
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isEditing ? Icons.save : Icons.add_circle),
                    const SizedBox(width: 12),
                    Text(
                      _isEditing ? 'Lưu Thay Đổi' : 'Tạo Đội',
                      style: const TextStyle(
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
