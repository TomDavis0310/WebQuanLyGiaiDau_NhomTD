import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class AddEditPlayerScreen extends StatefulWidget {
  final int teamId;
  final String teamName;
  final Map<String, dynamic>? player; // null = add, not null = edit

  const AddEditPlayerScreen({
    Key? key,
    required this.teamId,
    required this.teamName,
    this.player,
  }) : super(key: key);

  @override
  State<AddEditPlayerScreen> createState() => _AddEditPlayerScreenState();
}

class _AddEditPlayerScreenState extends State<AddEditPlayerScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _fullNameController = TextEditingController();
  final _numberController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // State
  bool _isLoading = false;
  String? _imageUrl;
  String? _selectedPosition;
  final List<String> _positions = [
    'Thủ môn',
    'Hậu vệ',
    'Tiền vệ',
    'Tiền đạo',
  ];

  bool get _isEditing => widget.player != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadPlayerData();
    } else {
      _selectedPosition = _positions.first;
    }
  }

  void _loadPlayerData() {
    final player = widget.player!;
    _fullNameController.text = player['fullName'] ?? player['name'] ?? '';
    _numberController.text = (player['number'] ?? '').toString();
    _selectedPosition = player['position'] ?? _positions.first;
    _imageUrl = player['imageUrl'];
    _heightController.text = (player['height'] ?? '').toString();
    _weightController.text = (player['weight'] ?? '').toString();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final playerData = {
        'fullName': _fullNameController.text.trim(),
        'number': int.tryParse(_numberController.text.trim()) ?? 0,
        'position': _selectedPosition ?? _positions.first,
        'teamId': widget.teamId,
        if (_imageUrl != null) 'imageUrl': _imageUrl,
        if (_heightController.text.isNotEmpty)
          'height': double.tryParse(_heightController.text.trim()),
        if (_weightController.text.isNotEmpty)
          'weight': double.tryParse(_weightController.text.trim()),
      };

      final response = _isEditing
          ? await ApiService.updatePlayer(
              widget.player!['playerId'] ?? widget.player!['id'],
              playerData,
            )
          : await ApiService.addPlayer(playerData);

      if (response.success) {
        if (mounted) {
          _showSuccess(
            _isEditing
                ? 'Cập nhật cầu thủ thành công'
                : 'Thêm cầu thủ mới thành công',
          );
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.pop(context, true);
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
    _fullNameController.dispose();
    _numberController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh Sửa Cầu Thủ' : 'Thêm Cầu Thủ'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Team Info Banner
              _buildTeamBanner(),

              const SizedBox(height: 24),

              // Player Photo
              _buildPhotoSection(),

              const SizedBox(height: 24),

              // Full Name
              _buildFullNameField(),

              const SizedBox(height: 16),

              // Number and Position Row
              _buildNumberPositionRow(),

              const SizedBox(height: 16),

              // Height and Weight Row
              _buildHeightWeightRow(),

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

  Widget _buildTeamBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.shield, color: Colors.green.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.teamName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
                Text(
                  _isEditing ? 'Cập nhật thông tin cầu thủ' : 'Thêm cầu thủ mới',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: _imageUrl != null
                ? ClipOval(
                    child: Image.network(
                      _imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey.shade400,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    size: 50,
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
            label: const Text('Chọn Ảnh'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: const BorderSide(color: Colors.green),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ảnh cầu thủ (Tùy chọn)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullNameField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Họ và Tên',
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
            controller: _fullNameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'Ví dụ: Nguyễn Văn A',
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
                borderSide: const BorderSide(color: Colors.green, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: const Icon(Icons.badge),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập họ tên';
              }
              if (value.trim().length < 3) {
                return 'Họ tên phải có ít nhất 3 ký tự';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPositionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number Field
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.tag, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Số Áo',
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
                  controller: _numberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    hintText: '10',
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
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    prefixIcon: const Icon(Icons.numbers),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nhập số áo';
                    }
                    final number = int.tryParse(value);
                    if (number == null || number < 1 || number > 99) {
                      return 'Số áo: 1-99';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Position Field
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sports, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Vị Trí',
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
                DropdownButtonFormField<String>(
                  value: _selectedPosition,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                  items: _positions.map((position) {
                    return DropdownMenuItem(
                      value: position,
                      child: Text(position),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPosition = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Chọn vị trí';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeightWeightRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Height Field
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.height, color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Chiều Cao (cm)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                  ],
                  decoration: InputDecoration(
                    hintText: '175',
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
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Weight Field
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monitor_weight,
                        color: Colors.green, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Cân Nặng (kg)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                  ],
                  decoration: InputDecoration(
                    hintText: '70',
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
                      borderSide:
                          const BorderSide(color: Colors.green, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ],
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
          onPressed: _isLoading ? null : _submitForm,
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
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_isEditing ? Icons.save : Icons.person_add),
                    const SizedBox(width: 12),
                    Text(
                      _isEditing ? 'Lưu Thay Đổi' : 'Thêm Cầu Thủ',
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
