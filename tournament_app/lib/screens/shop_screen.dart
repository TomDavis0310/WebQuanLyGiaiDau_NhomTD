import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reward_product.dart';
import '../services/api_service.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<RewardProduct> _products = [];
  int _userPoints = 0;
  bool _isLoading = true;
  String? _error;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _authToken = prefs.getString('auth_token');
    });
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load products
      final productsResponse = await http.get(
        Uri.parse('${ApiService.baseUrl}/Shop/products'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (productsResponse.statusCode == 200) {
        final productsData = json.decode(productsResponse.body);
        final products = (productsData['data'] as List)
            .map((json) => RewardProduct.fromJson(json))
            .toList();

        // Load user points if logged in
        if (_authToken != null) {
          try {
            final pointsResponse = await http.get(
              Uri.parse('${ApiService.baseUrl}/Shop/my-points'),
              headers: {
                'Content-Type': 'application/json; charset=utf-8',
                'Authorization': 'Bearer $_authToken',
              },
            );
            if (pointsResponse.statusCode == 200) {
              final pointsData = json.decode(pointsResponse.body);
              _userPoints = pointsData['data']['points'] ?? 0;
            }
          } catch (e) {
            _userPoints = 0;
          }
        }

        setState(() {
          _products = products;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      setState(() {
        _error = 'Không thể tải danh sách sản phẩm: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _redeemProduct(RewardProduct product) async {
    if (_userPoints < product.pointsCost) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bạn không đủ điểm để đổi sản phẩm này!'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận đổi quà'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn có chắc muốn đổi:'),
            SizedBox(height: 8),
            Text(
              product.name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Giá: ${product.pointsCost} điểm'),
            Text('Điểm còn lại: ${_userPoints - product.pointsCost} điểm'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/Shop/redeem/${product.id}'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (response.statusCode == 200 && mounted) {
        final result = json.decode(response.body);
        final redemptionCode = result['data']['redemptionCode'] ?? '';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đổi quà thành công! Mã: $redemptionCode'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );

        // Reload data
        _loadData();

        // Show redemption code dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('🎉 Đổi quà thành công!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Mã quà tặng của bạn:'),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    redemptionCode,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                SizedBox(height: 8),
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
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/my-rewards');
                },
                child: Text('Xem túi quà'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Đóng'),
              ),
            ],
          ),
        );
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cửa hàng điểm'),
        actions: [
          // Points display
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.stars, color: Colors.amber, size: 20),
                SizedBox(width: 4),
                Text(
                  '$_userPoints',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(_error!),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: _products.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_bag_outlined,
                                  size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('Chưa có sản phẩm nào'),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            final canAfford = _userPoints >= product.pointsCost;

                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: () => _showProductDetail(product),
                                borderRadius: BorderRadius.circular(12),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Product image
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(12),
                                        ),
                                        child: product.imageUrl != null
                                            ? Image.network(
                                                ApiService.convertImageUrl(
                                                    product.imageUrl!),
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error, stack) =>
                                                        _buildPlaceholder(),
                                              )
                                            : _buildPlaceholder(),
                                      ),
                                    ),
                                    // Product info
                                    Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.stars,
                                                  color: Colors.amber, size: 16),
                                              SizedBox(width: 4),
                                              Text(
                                                '${product.pointsCost}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: canAfford
                                                ? () => _redeemProduct(product)
                                                : null,
                                            style: ElevatedButton.styleFrom(
                                              minimumSize: Size.fromHeight(36),
                                              backgroundColor: canAfford
                                                  ? Colors.blue
                                                  : Colors.grey,
                                            ),
                                            child: Text(
                                              canAfford ? 'Đổi ngay' : 'Không đủ điểm',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.card_giftcard, size: 64, color: Colors.grey[400]),
    );
  }

  void _showProductDetail(RewardProduct product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product image
              if (product.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    ApiService.convertImageUrl(product.imageUrl!),
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => _buildPlaceholder(),
                  ),
                ),
              SizedBox(height: 16),
              // Product name
              Text(
                product.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              // Price
              Row(
                children: [
                  Icon(Icons.stars, color: Colors.amber, size: 24),
                  SizedBox(width: 8),
                  Text(
                    '${product.pointsCost} điểm',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Description
              if (product.description != null && product.description!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mô tả',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      product.description!,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              // Redeem button
              ElevatedButton(
                onPressed: _userPoints >= product.pointsCost
                    ? () {
                        Navigator.pop(context);
                        _redeemProduct(product);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(48),
                  backgroundColor: _userPoints >= product.pointsCost
                      ? Colors.blue
                      : Colors.grey,
                ),
                child: Text(
                  _userPoints >= product.pointsCost
                      ? 'Đổi ngay'
                      : 'Không đủ điểm (Còn thiếu ${product.pointsCost - _userPoints})',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
