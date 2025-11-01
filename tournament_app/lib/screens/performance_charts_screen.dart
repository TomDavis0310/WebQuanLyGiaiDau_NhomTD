import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/player_detail.dart';
import '../services/api_service.dart';

/// Performance Charts Screen - Display player performance charts
/// Shows points over time, match performance, and comparisons
class PerformanceChartsScreen extends StatefulWidget {
  final int playerId;
  final String playerName;

  const PerformanceChartsScreen({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  State<PerformanceChartsScreen> createState() =>
      _PerformanceChartsScreenState();
}

class _PerformanceChartsScreenState extends State<PerformanceChartsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _errorMessage = '';

  // Data
  PlayerDetail? _playerDetail;
  PlayerStatisticsSummary? _statistics;
  List<PlayerMatch> _matches = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load player detail and statistics
      final detailResponse = await ApiService.getPlayerDetail(widget.playerId);
      final statsResponse = await ApiService.getPlayerStatisticsSummary(widget.playerId);
      final matchesResponse = await ApiService.getPlayerMatches(widget.playerId, page: 1, pageSize: 50);

      setState(() {
        if (detailResponse.success && detailResponse.data != null) {
          _playerDetail = detailResponse.data;
        }
        if (statsResponse.success && statsResponse.data != null) {
          _statistics = statsResponse.data;
        }
        if (matchesResponse['success'] == true && matchesResponse['data'] != null) {
          final List<dynamic> matchesJson = matchesResponse['data']['matches'] ?? [];
          _matches = matchesJson.map((json) => PlayerMatch.fromJson(json)).toList();
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải dữ liệu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playerName),
        backgroundColor: Colors.purple,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.show_chart), text: 'Xu hướng'),
            Tab(icon: Icon(Icons.bar_chart), text: 'So sánh'),
            Tab(icon: Icon(Icons.pie_chart), text: 'Phân tích'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTrendTab(),
                    _buildComparisonTab(),
                    _buildAnalysisTab(),
                  ],
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          ),
        ],
      ),
    );
  }

  // ==================== TREND TAB ====================
  Widget _buildTrendTab() {
    if (_matches.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu trận đấu'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatsOverviewCard(),
          const SizedBox(height: 16),
          _buildPointsLineChart(),
          const SizedBox(height: 16),
          _buildRecentFormChart(),
        ],
      ),
    );
  }

  Widget _buildStatsOverviewCard() {
    if (_playerDetail == null) return const SizedBox();

    final stats = _playerDetail!.statistics;
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.purple, size: 28),
                SizedBox(width: 12),
                Text(
                  'Thống kê tổng quan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Trận', stats.totalMatches.toString(), Colors.blue),
                _buildStatItem('Tổng điểm', stats.totalPoints.toString(), Colors.orange),
                _buildStatItem('TB', stats.averagePoints.toStringAsFixed(1), Colors.green),
                _buildStatItem('Cao nhất', stats.highestScore.toString(), Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildPointsLineChart() {
    // Take last 10 matches for the chart
    final recentMatches = _matches.take(10).toList().reversed.toList();
    
    if (recentMatches.isEmpty) {
      return const SizedBox();
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < recentMatches.length; i++) {
      spots.add(FlSpot(i.toDouble(), recentMatches[i].points.toDouble()));
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Điểm số qua các trận đấu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 5,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text('${value.toInt() + 1}', style: style),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 5,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          return Text(value.toInt().toString(), style: style);
                        },
                        reservedSize: 32,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  minX: 0,
                  maxX: (recentMatches.length - 1).toDouble(),
                  minY: 0,
                  maxY: (spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 5),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.shade400,
                          Colors.purple.shade700,
                        ],
                      ),
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: Colors.purple,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.shade400.withOpacity(0.3),
                            Colors.purple.shade400.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '10 trận đấu gần nhất',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentFormChart() {
    if (_statistics == null || _statistics!.recentForm.isEmpty) {
      return const SizedBox();
    }

    final form = _statistics!.recentForm.take(5).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phong độ gần đây (5 trận)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: form.asMap().entries.map((entry) {
                final index = entry.key;
                final points = entry.value;
                final height = (points / 30 * 100).clamp(20.0, 100.0);
                
                return Column(
                  children: [
                    Container(
                      width: 50,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getFormColor(points).withOpacity(0.7),
                            _getFormColor(points),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: _getFormColor(points).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          points.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Trận ${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Color _getFormColor(int points) {
    if (points >= 20) return Colors.green;
    if (points >= 10) return Colors.orange;
    return Colors.red;
  }

  // ==================== COMPARISON TAB ====================
  Widget _buildComparisonTab() {
    if (_playerDetail == null) {
      return const Center(child: Text('Không có dữ liệu để so sánh'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPerformanceRadarChart(),
          const SizedBox(height: 16),
          _buildStatsBarsChart(),
        ],
      ),
    );
  }

  Widget _buildPerformanceRadarChart() {
    if (_statistics == null) return const SizedBox();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phân tích hiệu suất',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: RadarChart(
                RadarChartData(
                  radarShape: RadarShape.polygon,
                  radarBorderData: const BorderSide(color: Colors.grey, width: 2),
                  gridBorderData: const BorderSide(color: Colors.grey, width: 1),
                  tickBorderData: const BorderSide(color: Colors.transparent),
                  ticksTextStyle: const TextStyle(color: Colors.transparent),
                  radarBackgroundColor: Colors.transparent,
                  tickCount: 5,
                  titleTextStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  getTitle: (index, angle) {
                    switch (index) {
                      case 0:
                        return const RadarChartTitle(text: 'Điểm TB');
                      case 1:
                        return const RadarChartTitle(text: 'Tỷ lệ thắng');
                      case 2:
                        return const RadarChartTitle(text: 'Điểm cao nhất');
                      case 3:
                        return const RadarChartTitle(text: 'Chuỗi trận');
                      case 4:
                        return const RadarChartTitle(text: 'Số trận');
                      default:
                        return const RadarChartTitle(text: '');
                    }
                  },
                  dataSets: [
                    RadarDataSet(
                      fillColor: Colors.purple.withOpacity(0.3),
                      borderColor: Colors.purple,
                      borderWidth: 2,
                      dataEntries: [
                        RadarEntry(value: (_statistics!.averagePoints / 30 * 100).clamp(0, 100)),
                        RadarEntry(value: _statistics!.winRate),
                        RadarEntry(value: (_statistics!.highestScore / 40 * 100).clamp(0, 100)),
                        RadarEntry(value: (_statistics!.currentStreak / 10 * 100).clamp(0, 100)),
                        RadarEntry(value: (_statistics!.totalMatches / 50 * 100).clamp(0, 100)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBarsChart() {
    if (_playerDetail == null) return const SizedBox();

    final stats = _playerDetail!.statistics;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thống kê chi tiết',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: stats.highestScore.toDouble() + 5,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        String label;
                        switch (group.x.toInt()) {
                          case 0:
                            label = 'Tổng điểm';
                            break;
                          case 1:
                            label = 'Trung bình';
                            break;
                          case 2:
                            label = 'Cao nhất';
                            break;
                          default:
                            label = '';
                        }
                        return BarTooltipItem(
                          '$label\n${rod.toY.toStringAsFixed(1)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          String text;
                          switch (value.toInt()) {
                            case 0:
                              text = 'Tổng';
                              break;
                            case 1:
                              text = 'TB';
                              break;
                            case 2:
                              text = 'Cao nhất';
                              break;
                            default:
                              text = '';
                          }
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(text, style: style),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 10,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          const style = TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          );
                          return Text(value.toInt().toString(), style: style);
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: stats.totalPoints.toDouble(),
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade400, Colors.blue.shade700],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: 30,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: stats.averagePoints,
                          gradient: LinearGradient(
                            colors: [Colors.green.shade400, Colors.green.shade700],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: 30,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: stats.highestScore.toDouble(),
                          gradient: LinearGradient(
                            colors: [Colors.orange.shade400, Colors.orange.shade700],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: 30,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ANALYSIS TAB ====================
  Widget _buildAnalysisTab() {
    if (_statistics == null) {
      return const Center(child: Text('Không có dữ liệu phân tích'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildWinRatePieChart(),
          const SizedBox(height: 16),
          _buildStreakCard(),
          const SizedBox(height: 16),
          _buildInsightsCard(),
        ],
      ),
    );
  }

  Widget _buildWinRatePieChart() {
    final winRate = _statistics!.winRate;
    final lossRate = 100 - winRate;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tỷ lệ thắng/thua',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 50,
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: winRate,
                      title: '${winRate.toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: lossRate,
                      title: '${lossRate.toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Thắng', Colors.green),
                const SizedBox(width: 32),
                _buildLegendItem('Thua', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildStreakCard() {
    final streak = _statistics!.currentStreak;
    
    return Card(
      elevation: 4,
      color: Colors.amber.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.orange.shade700, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'Chuỗi ghi điểm',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              streak.toString(),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
            Text(
              'trận liên tiếp ghi điểm',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard() {
    final stats = _playerDetail!.statistics;
    final avgPoints = stats.averagePoints;
    
    String performance;
    Color performanceColor;
    IconData performanceIcon;
    
    if (avgPoints >= 20) {
      performance = 'Xuất sắc';
      performanceColor = Colors.green;
      performanceIcon = Icons.trending_up;
    } else if (avgPoints >= 15) {
      performance = 'Tốt';
      performanceColor = Colors.blue;
      performanceIcon = Icons.thumb_up;
    } else if (avgPoints >= 10) {
      performance = 'Trung bình';
      performanceColor = Colors.orange;
      performanceIcon = Icons.horizontal_rule;
    } else {
      performance = 'Cần cải thiện';
      performanceColor = Colors.red;
      performanceIcon = Icons.trending_down;
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Đánh giá hiệu suất',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: performanceColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(performanceIcon, color: performanceColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        performance,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: performanceColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Trung bình ${avgPoints.toStringAsFixed(1)} điểm/trận',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInsightRow(
              Icons.star,
              'Điểm mạnh',
              _getStrength(),
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildInsightRow(
              Icons.flag,
              'Mục tiêu',
              'Duy trì phong độ ổn định',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  String _getStrength() {
    if (_statistics == null) return 'Chưa có dữ liệu';
    
    final stats = _playerDetail!.statistics;
    if (stats.highestScore >= 30) {
      return 'Khả năng ghi điểm cao';
    } else if (stats.averagePoints >= 15) {
      return 'Ổn định trong nhiều trận';
    } else if (_statistics!.currentStreak >= 5) {
      return 'Chuỗi ghi điểm tốt';
    } else {
      return 'Đang phát triển';
    }
  }
}
