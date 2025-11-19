import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/player_model.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class PlayerFormScreen extends StatefulWidget {
  final int teamId;
  final PlayerModel? player;

  const PlayerFormScreen({
    Key? key,
    required this.teamId,
    this.player,
  }) : super(key: key);

  @override
  State<PlayerFormScreen> createState() => _PlayerFormScreenState();
}

class _PlayerFormScreenState extends State<PlayerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _jerseyNumberController = TextEditingController();
  final _positionController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _photoUrlController = TextEditingController();
  
  DateTime? _dateOfBirth;
  bool _isLoading = false;
  bool get _isEditMode => widget.player != null;
  File? _selectedPhotoFile;
  bool _isUploadingPhoto = false;

  final List<String> _positions = [
    'Point Guard',
    'Shooting Guard',
    'Small Forward',
    'Power Forward',
    'Center',
  ];

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final player = widget.player!;
      _nameController.text = player.name;
      _jerseyNumberController.text = player.jerseyNumber?.toString() ?? '';
      _positionController.text = player.position ?? '';
      _nationalityController.text = player.nationality ?? '';
      _heightController.text = player.height?.toString() ?? '';
      _weightController.text = player.weight?.toString() ?? '';
      _photoUrlController.text = player.photoUrl ?? '';
      _dateOfBirth = player.dateOfBirth;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _jerseyNumberController.dispose();
    _positionController.dispose();
    _nationalityController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'Chọn ngày sinh',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );

    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Chọn nguồn ảnh'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Thư viện'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Máy ảnh'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          );
        },
      );

      if (source == null) return;

      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      setState(() {
        _selectedPhotoFile = File(pickedFile.path);
      });

      await _uploadPhoto();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi chọn ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadPhoto() async {
    if (_selectedPhotoFile == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final token = authProvider.token;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      final response = await ApiService.uploadImage(
        file: _selectedPhotoFile!,
        uploadType: 'PlayerPhoto',
        token: token,
      );

      if (response.success && response.data != null) {
        final imageUrl = response.data!['imageUrl'] as String?;
        
        if (imageUrl != null) {
          setState(() {
            _photoUrlController.text = imageUrl;
            _isUploadingPhoto = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Upload ảnh thành công'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception('Không nhận được URL ảnh');
        }
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      setState(() {
        _isUploadingPhoto = false;
        _selectedPhotoFile = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload ảnh thất bại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _savePlayer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final playerData = {
        'name': _nameController.text.trim(),
        'jerseyNumber': _jerseyNumberController.text.trim().isEmpty
            ? null
            : int.tryParse(_jerseyNumberController.text.trim()),
        'position': _positionController.text.trim().isEmpty
            ? null
            : _positionController.text.trim(),
        'dateOfBirth': _dateOfBirth?.toIso8601String(),
        'nationality': _nationalityController.text.trim().isEmpty
            ? null
            : _nationalityController.text.trim(),
        'height': _heightController.text.trim().isEmpty
            ? null
            : double.tryParse(_heightController.text.trim()),
        'weight': _weightController.text.trim().isEmpty
            ? null
            : double.tryParse(_weightController.text.trim()),
        'photoUrl': _photoUrlController.text.trim().isEmpty
            ? null
            : _photoUrlController.text.trim(),
        if (!_isEditMode) 'teamId': widget.teamId,
      };

      final response = _isEditMode
          ? await ApiService.updatePlayer(widget.player!.id, playerData)
          : await ApiService.addPlayer(playerData);

      setState(() => _isLoading = false);

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode
                ? 'Đã cập nhật cầu thủ thành công'
                : 'Đã thêm cầu thủ thành công'),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
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
        title: Text(_isEditMode ? 'Sửa thông tin cầu thủ' : 'Thêm cầu thủ'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Photo Preview
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue[50],
                      border: Border.all(color: Colors.blue[200]!, width: 2),
                      image: _selectedPhotoFile != null
                          ? DecorationImage(
                              image: FileImage(_selectedPhotoFile!),
                              fit: BoxFit.cover,
                            )
                          : (_photoUrlController.text.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(_photoUrlController.text),
                                  fit: BoxFit.cover,
                                  onError: (_, __) {},
                                )
                              : null),
                    ),
                    child: _selectedPhotoFile == null && _photoUrlController.text.isEmpty
                        ? Icon(Icons.person, size: 60, color: Colors.blue[300])
                        : null,
                  ),
                  if (_isUploadingPhoto)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 18,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        onPressed: _isUploadingPhoto ? null : _pickPhoto,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: _isUploadingPhoto ? null : _pickPhoto,
                icon: const Icon(Icons.upload),
                label: Text(_isUploadingPhoto ? 'Đang upload...' : 'Tải lên ảnh cầu thủ'),
              ),
            ),
            const SizedBox(height: 24),

            // Player Name
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên cầu thủ *',
                hintText: 'Nhập tên cầu thủ',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên cầu thủ';
                }
                return null;
              },
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Jersey Number
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _jerseyNumberController,
                    decoration: InputDecoration(
                      labelText: 'Số áo',
                      hintText: 'Số',
                      prefixIcon: const Icon(Icons.tag),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(2),
                    ],
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        final number = int.tryParse(value);
                        if (number == null || number < 0 || number > 99) {
                          return 'Số áo từ 0-99';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _positionController.text.isEmpty 
                        ? null 
                        : _positionController.text,
                    decoration: InputDecoration(
                      labelText: 'Vị trí',
                      prefixIcon: const Icon(Icons.sports),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: _positions.map((position) {
                      return DropdownMenuItem(
                        value: position,
                        child: Text(position),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _positionController.text = value ?? '';
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Date of Birth
            InkWell(
              onTap: _selectDateOfBirth,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Ngày sinh',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                child: Text(
                  _dateOfBirth != null
                      ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                      : 'Chọn ngày sinh',
                  style: TextStyle(
                    color: _dateOfBirth != null ? Colors.black : Colors.grey[600],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Nationality
            TextFormField(
              controller: _nationalityController,
              decoration: InputDecoration(
                labelText: 'Quốc tịch',
                hintText: 'VD: Việt Nam',
                prefixIcon: const Icon(Icons.flag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),

            // Height and Weight
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: InputDecoration(
                      labelText: 'Chiều cao',
                      hintText: 'cm',
                      prefixIcon: const Icon(Icons.height),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: 'Cân nặng',
                      hintText: 'kg',
                      prefixIcon: const Icon(Icons.monitor_weight),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Photo URL
            TextFormField(
              controller: _photoUrlController,
              decoration: InputDecoration(
                labelText: 'URL ảnh',
                hintText: 'Nhập URL ảnh cầu thủ',
                prefixIcon: const Icon(Icons.image),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {}); // Refresh preview
                  },
                  tooltip: 'Xem trước',
                ),
              ),
              keyboardType: TextInputType.url,
              onChanged: (value) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) setState(() {});
                });
              },
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Hủy', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _savePlayer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _isEditMode ? 'Cập nhật' : 'Thêm',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
