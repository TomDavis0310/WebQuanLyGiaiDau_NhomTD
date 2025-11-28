import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> _chats = [
    {
      'id': '1',
      'name': 'BTC Giải Bóng Đá Mùa Hè',
      'lastMessage': 'Lịch thi đấu đã được cập nhật nhé mọi người.',
      'time': '10:30',
      'unread': 2,
      'avatar': null,
      'isGroup': true,
    },
    {
      'id': '2',
      'name': 'FC Những Chú Hổ',
      'lastMessage': 'Tối nay 7h tập trung sân số 2 nhé.',
      'time': '09:15',
      'unread': 0,
      'avatar': null,
      'isGroup': true,
    },
    {
      'id': '3',
      'name': 'Nguyễn Văn A (Admin)',
      'lastMessage': 'Bạn cần hỗ trợ gì thêm không?',
      'time': 'Hôm qua',
      'unread': 0,
      'avatar': null,
      'isGroup': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin Nhắn'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.getPrimaryGradient(context),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: _chats.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: chat['isGroup'] ? Colors.orange.shade100 : Colors.blue.shade100,
              child: Icon(
                chat['isGroup'] ? Icons.group : Icons.person,
                color: chat['isGroup'] ? Colors.orange : Colors.blue,
              ),
            ),
            title: Text(
              chat['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                chat['lastMessage'],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: chat['unread'] > 0 ? Colors.black87 : Colors.grey,
                  fontWeight: chat['unread'] > 0 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  chat['time'],
                  style: TextStyle(
                    fontSize: 12,
                    color: chat['unread'] > 0 ? AppTheme.getPrimaryColor(context) : Colors.grey,
                  ),
                ),
                if (chat['unread'] > 0) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${chat['unread']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng chat chi tiết đang phát triển')),
              );
            },
          );
        },
      ),
    );
  }
}
