import 'package:flutter/material.dart';

class EarnPointsGuideScreen extends StatelessWidget {
  const EarnPointsGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cách kiếm điểm'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildSectionTitle('Hoạt động giải đấu'),
          _buildPointItem(
            icon: Icons.app_registration,
            color: Colors.blue,
            title: 'Đăng ký tham gia giải đấu',
            points: '+100',
            description: 'Nhận điểm khi đội của bạn đăng ký tham gia một giải đấu mới.',
          ),
          _buildPointItem(
            icon: Icons.emoji_events,
            color: Colors.amber,
            title: 'Vô địch giải đấu',
            points: '+500',
            description: 'Phần thưởng lớn dành cho nhà vô địch của giải đấu.',
          ),
          _buildPointItem(
            icon: Icons.military_tech,
            color: Colors.grey,
            title: 'Á quân giải đấu',
            points: '+300',
            description: 'Phần thưởng dành cho đội về nhì.',
          ),
          
          const SizedBox(height: 16),
          _buildSectionTitle('Hoạt động trận đấu'),
          _buildPointItem(
            icon: Icons.sports_soccer,
            color: Colors.green,
            title: 'Thắng trận đấu',
            points: '+50',
            description: 'Nhận điểm mỗi khi đội của bạn giành chiến thắng.',
          ),
          _buildPointItem(
            icon: Icons.how_to_vote,
            color: Colors.purple,
            title: 'Bình chọn trận đấu',
            points: '+10',
            description: 'Tham gia dự đoán kết quả trận đấu.',
          ),
          
          const SizedBox(height: 16),
          _buildSectionTitle('Hoạt động khác'),
          _buildPointItem(
            icon: Icons.login,
            color: Colors.orange,
            title: 'Đăng nhập hàng ngày',
            points: '+5',
            description: 'Nhận điểm thưởng khi mở ứng dụng mỗi ngày.',
          ),
          _buildPointItem(
            icon: Icons.share,
            color: Colors.indigo,
            title: 'Chia sẻ giải đấu',
            points: '+20',
            description: 'Chia sẻ thông tin giải đấu lên mạng xã hội.',
          ),
          
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 32),
                const SizedBox(height: 8),
                const Text(
                  'Lưu ý',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Điểm thưởng sẽ được cộng tự động vào tài khoản của bạn ngay sau khi hoàn thành hoạt động. Trong một số trường hợp, có thể mất vài phút để hệ thống cập nhật.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blue[900]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: const [
          Icon(Icons.stars, color: Colors.amber, size: 48),
          SizedBox(height: 16),
          Text(
            'Hệ thống điểm thưởng',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Tích lũy điểm để đổi lấy những phần quà hấp dẫn từ cửa hàng!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPointItem({
    required IconData icon,
    required Color color,
    required String title,
    required String points,
    required String description,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              points,
                              style: TextStyle(
                                color: Colors.orange[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
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
