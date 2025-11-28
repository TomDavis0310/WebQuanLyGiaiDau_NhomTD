import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reward_product.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';

class ShopScreen extends StatefulWidget {
  final bool showAppBar;
  
  const ShopScreen({super.key, this.showAppBar = true});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  List<RewardProduct> _products = [];
  List<RewardProduct> _filteredProducts = [];
  int _userPoints = 0;
  bool _isLoading = true;
  String? _error;
  String? _authToken;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _authToken = prefs.getString('auth_token');
    });
    _loadData();
  }

  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredProducts = _products;
      });
    } else {
      setState(() {
        _filteredProducts = _products
            .where((product) =>
                product.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load products
      final productsResponse = await http.get(
        Uri.parse('${ApiService.baseUrl}/ShopApi/products'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      );

      if (productsResponse.statusCode == 200) {
        final productsData = json.decode(productsResponse.body);
        // Backend trả về trực tiếp array, không có wrapper
        final products = (productsData as List)
            .map((json) => RewardProduct.fromJson(json))
            .toList();

        // Load user points if logged in
        if (_authToken != null) {
          try {
            final pointsResponse = await http.get(
              Uri.parse('${ApiService.baseUrl}/ShopApi/my-points'),
              headers: {
                'Content-Type': 'application/json; charset=utf-8',
                'Authorization': 'Bearer $_authToken',
              },
            );
            if (pointsResponse.statusCode == 200) {
              final pointsData = json.decode(pointsResponse.body);
              // Backend trả về trực tiếp object {points, username, fullName}
              // Convert to int to handle both int and double from JSON
              final points = pointsData['points'];
              _userPoints = points is int ? points : (points is double ? points.toInt() : (points is String ? int.tryParse(points) ?? 0 : 0));
            } else {
              print('Points API Error: ${pointsResponse.statusCode}');
              print('Response body: ${pointsResponse.body}');
            }
          } catch (e) {
            print('Error loading user points: $e');
            _userPoints = 0;
          }
        }

        setState(() {
          _products = products;
          _filteredProducts = products;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error loading shop data: $e');
      setState(() {
        _error = 'Không thể tải danh sách sản phẩm: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToDetail(RewardProduct product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          product: product,
          userPoints: _userPoints,
          onPointsUpdated: (newPoints) {
            setState(() {
              _userPoints = newPoints;
            });
          },
        ),
      ),
    );
  }

  void _showDebugInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    // Try to get user info from API
    String userInfo = 'Đang tải...';
    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('${ApiService.baseUrl}/ShopApi/my-points'),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Authorization': 'Bearer $token',
          },
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          userInfo = 'Username: ${data['username']}\nFullName: ${data['fullName']}\nPoints: ${data['points']}';
        } else {
          userInfo = 'Lỗi: ${response.statusCode}\n${response.body}';
        }
      } catch (e) {
        userInfo = 'Lỗi: $e';
      }
    } else {
      userInfo = 'Chưa đăng nhập (không có token)';
    }

    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin tài khoản'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Điểm hiện tại trên app: $_userPoints'),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              const Text('Thông tin từ server:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(userInfo),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Text('Token: ${token != null ? '${token.substring(0, 20)}...' : 'Không có'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('Làm mới'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar ? AppBar(
        title: const Text('Cửa hàng điểm'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Thông tin tài khoản',
            onPressed: _showDebugInfo,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Cách kiếm điểm',
            onPressed: () {
              Navigator.pushNamed(context, '/earn-points-guide');
            },
          ),
          // Points display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.stars, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '$_userPoints',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ) : null,
      body: Column(
        children: [
          // Points Badge (when no AppBar)
          if (!widget.showAppBar)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cửa Hàng Điểm',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Đổi điểm lấy quà',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/earn-points-guide');
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.help_outline,
                                      color: Colors.white,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Cách kiếm',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.stars, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '$_userPoints',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: _filterProducts,
            ),
          ),
          
          // Product Grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(_error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadData,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: _filteredProducts.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.shopping_bag_outlined,
                                        size: 64, color: Colors.grey),
                                    const SizedBox(height: 16),
                                    Text(_searchController.text.isEmpty 
                                      ? 'Chưa có sản phẩm nào' 
                                      : 'Không tìm thấy sản phẩm nào'),
                                  ],
                                ),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.7,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: _filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = _filteredProducts[index];
                                  final canAfford = _userPoints >= product.pointsCost;

                                  return Card(
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: InkWell(
                                      onTap: () => _navigateToDetail(product),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          // Product image
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(12),
                                              ),
                                              child: product.imageUrl != null
                                                  ? Hero(
                                                      tag: 'product_${product.id}',
                                                      child: Image.network(
                                                        ApiService.convertImageUrl(
                                                            product.imageUrl!)!,
                                                        fit: BoxFit.cover,
                                                        errorBuilder:
                                                            (context, error, stack) =>
                                                                _buildPlaceholder(),
                                                      ),
                                                    )
                                                  : _buildPlaceholder(),
                                            ),
                                          ),
                                          // Product info
                                          Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  product.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.stars,
                                                        color: Colors.amber, size: 16),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '${product.pointsCost}',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.blue,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Container(
                                                  width: double.infinity,
                                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: canAfford ? Colors.blue : Colors.grey[300],
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    canAfford ? 'Đổi ngay' : 'Không đủ điểm',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: canAfford ? Colors.white : Colors.grey[700],
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
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
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.card_giftcard, size: 64, color: Colors.grey[400]),
    );
  }
}
