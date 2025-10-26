import 'package:flutter/material.dart';
import '../models/sport.dart';
import '../services/api_service.dart';

class SportsListScreen extends StatefulWidget {
  const SportsListScreen({super.key});
  @override
  _SportsListScreenState createState() => _SportsListScreenState();
}

class _SportsListScreenState extends State<SportsListScreen> {
  List<Sport> sports = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadSports();
  }

  Future<void> loadSports() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getSports();
      
      if (response.success && response.data != null) {
        setState(() {
          sports = response.data!;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response.message;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi kết nối: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh Sách Môn Thể Thao'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadSports,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải dữ liệu...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Lỗi: $errorMessage',
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: loadSports,
              child: Text('Thử Lại'),
            ),
          ],
        ),
      );
    }

    if (sports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_basketball, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Không có môn thể thao nào'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadSports,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: sports.length,
        itemBuilder: (context, index) {
          final sport = sports[index];
          return _buildSportCard(sport);
        },
      ),
    );
  }

  Widget _buildSportCard(Sport sport) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to tournaments by sport
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xem giải đấu ${sport.name}'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // Sport Icon/Image
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: sport.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          sport.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.sports_basketball,
                              size: 32,
                              color: Theme.of(context).primaryColor,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.sports_basketball,
                        size: 32,
                        color: Theme.of(context).primaryColor,
                      ),
              ),
              SizedBox(width: 16),
              
              // Sport Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sport.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${sport.tournamentCount} giải đấu',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow Icon
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
