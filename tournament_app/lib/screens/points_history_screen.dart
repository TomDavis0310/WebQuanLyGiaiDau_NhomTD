import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/points_history.dart';
import '../services/api_service.dart';

class PointsHistoryScreen extends StatefulWidget {
  const PointsHistoryScreen({super.key});

  @override
  State<PointsHistoryScreen> createState() => _PointsHistoryScreenState();
}

class _PointsHistoryScreenState extends State<PointsHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<PointsHistory> _history = [];
  PointsStatistics? _statistics;
  bool _isLoading = true;
  String? _error;
  String? _authToken;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAuthToken();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      if (_authToken == null) {
        throw Exception('Please login first');
      }

      // Load history
      final historyResponse = await http.get(
        Uri.parse('${ApiService.baseUrl}/PointsApi/history'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (historyResponse.statusCode == 200) {
        final historyData = json.decode(historyResponse.body);
        // API trả về có thể có wrapper 'data' hoặc trực tiếp là object với field 'history'
        final historyList = (historyData['history'] ?? historyData['data']) as List?;
        if (historyList != null) {
          setState(() {
            _history = historyList
                .map((json) => PointsHistory.fromJson(json))
                .toList();
          });
        }
      }

      // Load statistics
      final statsResponse = await http.get(
        Uri.parse('${ApiService.baseUrl}/PointsApi/statistics'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_authToken',
        },
      );

      if (statsResponse.statusCode == 200) {
        final statsData = json.decode(statsResponse.body);
        // API trả về trực tiếp object, không có wrapper 'data'
        setState(() {
          _statistics = PointsStatistics.fromJson(statsData);
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Không thể tải lịch sử điểm: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử điểm'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Thống kê', icon: Icon(Icons.bar_chart)),
            Tab(text: 'Lịch sử', icon: Icon(Icons.history)),
          ],
        ),
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
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildStatisticsTab(),
                    _buildHistoryTab(),
                  ],
                ),
    );
  }

  Widget _buildStatisticsTab() {
    if (_statistics == null) {
      return Center(child: Text('Không có dữ liệu thống kê'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Current points card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.blue.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.stars, color: Colors.white, size: 48),
                    SizedBox(height: 8),
                    Text(
                      'Điểm hiện tại',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_statistics!.currentPoints}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Statistics grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Tổng tích lũy',
                    '${_statistics!.totalEarned}',
                    Icons.add_circle,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Đã sử dụng',
                    '${_statistics!.totalSpent}',
                    Icons.remove_circle,
                    Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Quà đã đổi',
                    '${_statistics!.totalRewards}',
                    Icons.card_giftcard,
                    Colors.purple,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Lần bình chọn',
                    '${_statistics!.totalVotes}',
                    Icons.how_to_vote,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            // User rank card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.amber,
                  child: Icon(Icons.emoji_events, color: Colors.white),
                ),
                title: Text(
                  'Xếp hạng của bạn',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Text(
                  '#${_statistics!.userRank}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Chưa có lịch sử giao dịch'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
          return _buildHistoryItem(item);
        },
      ),
    );
  }

  Widget _buildHistoryItem(PointsHistory item) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isEarn = item.isEarn;

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isEarn
              ? Colors.green.withOpacity(0.2)
              : Colors.red.withOpacity(0.2),
          child: Icon(
            isEarn ? Icons.add : Icons.remove,
            color: isEarn ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          item.description,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 4),
            Text(
              dateFormat.format(item.date),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (item.details != null && item.details!.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                _formatDetails(item.details!),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEarn ? '+' : '',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isEarn ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  '${item.points}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isEarn ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars, color: Colors.amber, size: 14),
                SizedBox(width: 2),
                Text(
                  'điểm',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDetails(Map<String, dynamic> details) {
    final buffer = StringBuffer();
    details.forEach((key, value) {
      if (buffer.isNotEmpty) buffer.write(' • ');
      buffer.write('$value');
    });
    return buffer.toString();
  }
}
