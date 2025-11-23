import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reward_product.dart';
import '../services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final RewardProduct product;
  final int userPoints;
  final Function(int) onPointsUpdated;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.userPoints,
    required this.onPointsUpdated,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  bool _isRedeeming = false;
  late int _currentUserPoints;

  @override
  void initState() {
    super.initState();
    _currentUserPoints = widget.userPoints;
  }

  Future<void> _redeemProduct() async {
    if (_currentUserPoints < widget.product.pointsCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn không đủ điểm để đổi sản phẩm này!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận đổi quà'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bạn có chắc muốn đổi:'),
            const SizedBox(height: 8),
            Text(
              widget.product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Giá: ${widget.product.pointsCost} điểm'),
            Text('Điểm còn lại: ${_currentUserPoints - widget.product.pointsCost} điểm'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isRedeeming = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/Shop/redeem/${widget.product.id}'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final result = json.decode(response.body);
        final redemptionCode = result['data']['redemptionCode'] ?? '';
        
        // Update local points
        setState(() {
          _currentUserPoints -= widget.product.pointsCost;
        });
        widget.onPointsUpdated(_currentUserPoints);

        // Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('🎉 Đổi quà thành công!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Mã quà tặng của bạn:'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    redemptionCode,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng lưu lại mã này để sử dụng quà tặng',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushNamed(context, '/my-rewards'); // Go to rewards
                },
                child: const Text('Xem túi quà'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context), // Close dialog
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Failed to redeem product');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi đổi quà: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRedeeming = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAfford = _currentUserPoints >= widget.product.pointsCost;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Product Image
                  if (widget.product.imageUrl != null)
                    Hero(
                      tag: 'product_${widget.product.id}',
                      child: Image.network(
                        ApiService.convertImageUrl(widget.product.imageUrl)!,
                        height: 300,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) => Container(
                          height: 300,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 300,
                      color: Colors.grey[200],
                      child: const Icon(Icons.card_giftcard, size: 80, color: Colors.grey),
                    ),
                  
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Points Cost
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars, color: Colors.amber, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                '${widget.product.pointsCost} điểm',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 16),
                        
                        // Description
                        const Text(
                          'Mô tả sản phẩm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.description ?? 'Chưa có mô tả cho sản phẩm này.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Điểm của bạn:',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Text(
                        '$_currentUserPoints',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: canAfford && !_isRedeeming
                          ? _redeemProduct
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canAfford ? Colors.blue : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isRedeeming
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              canAfford
                                  ? 'Đổi quà ngay'
                                  : 'Không đủ điểm (Thiếu ${widget.product.pointsCost - _currentUserPoints})',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
