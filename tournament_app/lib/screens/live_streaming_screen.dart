import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

class LiveStreamingScreen extends StatefulWidget {
  const LiveStreamingScreen({Key? key}) : super(key: key);

  @override
  State<LiveStreamingScreen> createState() => _LiveStreamingScreenState();
}

class _LiveStreamingScreenState extends State<LiveStreamingScreen> {
  // Mock data for live streams
  final List<Map<String, dynamic>> _liveMatches = [
    {
      'id': '1',
      'title': 'Chung kết Bóng đá Nam: Đội A vs Đội B',
      'viewers': 1250,
      'thumbnail': 'https://images.unsplash.com/photo-1522778119026-d647f0565c6a?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'sport': 'Bóng đá',
      'status': 'LIVE',
    },
    {
      'id': '2',
      'title': 'Bán kết Bóng rổ: Team X vs Team Y',
      'viewers': 850,
      'thumbnail': 'https://images.unsplash.com/photo-1546519638-68e109498ffc?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'sport': 'Bóng rổ',
      'status': 'LIVE',
    },
    {
      'id': '3',
      'title': 'Vòng loại Cầu lông: Nguyễn Văn A vs Trần Văn B',
      'viewers': 320,
      'thumbnail': 'https://images.unsplash.com/photo-1626224583764-847890e058f5?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'sport': 'Cầu lông',
      'status': 'LIVE',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trực Tiếp'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.getPrimaryGradient(context),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _liveMatches.length,
        itemBuilder: (context, index) {
          final match = _liveMatches[index];
          return _buildStreamCard(match);
        },
      ),
    );
  }

  Widget _buildStreamCard(Map<String, dynamic> match) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tính năng đang phát triển')),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with Live badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: CachedNetworkImage(
                    imageUrl: match['thumbnail'],
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 8, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          match['status'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.remove_red_eye, size: 12, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${match['viewers']} người xem',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Positioned.fill(
                  child: Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      size: 60,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
            
            // Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.getPrimaryColor(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          match['sport'],
                          style: TextStyle(
                            color: AppTheme.getPrimaryColor(context),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    match['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
