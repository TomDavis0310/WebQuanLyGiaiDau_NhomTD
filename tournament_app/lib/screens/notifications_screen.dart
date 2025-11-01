import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/api_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  List<NotificationModel> _notifications = [];
  List<NotificationType> _types = [];
  
  int _total = 0;
  int _unreadCount = 0;
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  
  String? _selectedType;
  bool? _selectedReadStatus;
  
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('vi', timeago.ViMessages());
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _scrollController.addListener(_handleScroll);
    _loadNotifications();
    _loadTypes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        // All
        if (_tabController.index == 0) {
          _selectedReadStatus = null;
        }
        // Unread
        else if (_tabController.index == 1) {
          _selectedReadStatus = false;
        }
        // Read
        else if (_tabController.index == 2) {
          _selectedReadStatus = true;
        }
        _currentPage = 1;
        _notifications.clear();
      });
      _loadNotifications();
    }
  }

  void _handleScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadTypes() async {
    try {
      final response = await ApiService.getNotificationTypes();
      if (response.success && response.data != null) {
        setState(() {
          _types = response.data!;
        });
      }
    } catch (e) {
      // Ignore type loading errors
    }
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _notifications.clear();
        _hasMore = true;
      });
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getNotifications(
        type: _selectedType,
        isRead: _selectedReadStatus,
        page: _currentPage,
        pageSize: _pageSize,
      );

      if (response.success && response.data != null) {
        setState(() {
          if (refresh || _currentPage == 1) {
            _notifications = response.data!.data;
          } else {
            _notifications.addAll(response.data!.data);
          }
          _total = response.data!.total;
          _unreadCount = response.data!.unreadCount;
          _hasMore = _currentPage < response.data!.totalPages;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message.isNotEmpty
              ? response.message
              : 'Không thể tải thông báo';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi kết nối: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _currentPage++;
    });

    await _loadNotifications();
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    if (notification.isRead) return;

    final response = await ApiService.markNotificationAsRead(notification.id);

    if (response.success) {
      setState(() {
        final index =
            _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = NotificationModel(
            id: notification.id,
            title: notification.title,
            message: notification.message,
            type: notification.type,
            relatedId: notification.relatedId,
            relatedType: notification.relatedType,
            isRead: true,
            createdAt: notification.createdAt,
            readAt: DateTime.now(),
            imageUrl: notification.imageUrl,
            actionUrl: notification.actionUrl,
            priority: notification.priority,
          );
          _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        }
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final response = await ApiService.markAllNotificationsAsRead();

    if (response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response.message)),
      );
      _loadNotifications(refresh: true);
    }
  }

  Future<void> _deleteNotification(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa thông báo này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await ApiService.deleteNotification(id);

      if (response.success) {
        setState(() {
          _notifications.removeWhere((n) => n.id == id);
          _total--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa thông báo')),
        );
      }
    }
  }

  Future<void> _deleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận xóa tất cả'),
        content: Text('Bạn có chắc muốn xóa tất cả thông báo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Xóa tất cả'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await ApiService.deleteAllNotifications();

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
        _loadNotifications(refresh: true);
      }
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'match':
        return Icons.sports_soccer;
      case 'tournament':
        return Icons.emoji_events;
      case 'team':
        return Icons.group;
      case 'player':
        return Icons.person;
      case 'system':
        return Icons.settings;
      default:
        return Icons.info;
    }
  }

  Color _getColorForType(String type) {
    final typeData = _types.firstWhere(
      (t) => t.value == type,
      orElse: () => NotificationType(
        value: type,
        label: type,
        icon: 'info',
        color: '#607D8B',
      ),
    );

    return Color(int.parse(typeData.color.replaceFirst('#', '0xFF')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thông báo', style: TextStyle(fontSize: 18)),
            if (_unreadCount > 0)
              Text(
                '$_unreadCount chưa đọc',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
        actions: [
          if (_unreadCount > 0)
            IconButton(
              icon: Icon(Icons.done_all),
              tooltip: 'Đánh dấu tất cả đã đọc',
              onPressed: _markAllAsRead,
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete_all') {
                _deleteAll();
              } else if (value == 'filter') {
                _showFilterDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'filter',
                child: Row(
                  children: [
                    Icon(Icons.filter_list, size: 20),
                    SizedBox(width: 8),
                    Text('Lọc theo loại'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Xóa tất cả', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Tất cả ($_total)'),
            Tab(text: 'Chưa đọc ($_unreadCount)'),
            Tab(
                text:
                    'Đã đọc (${_total - _unreadCount})'),
          ],
        ),
      ),
      body: _isLoading && _notifications.isEmpty
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null && _notifications.isEmpty
              ? _buildErrorView()
              : _buildNotificationsList(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Đã xảy ra lỗi',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _loadNotifications(refresh: true),
              icon: Icon(Icons.refresh),
              label: Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (_notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadNotifications(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(8),
        itemCount: _notifications.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _notifications.length) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          return _buildNotificationItem(_notifications[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    String message = 'Chưa có thông báo nào';
    if (_selectedReadStatus == false) {
      message = 'Không có thông báo chưa đọc';
    } else if (_selectedReadStatus == true) {
      message = 'Không có thông báo đã đọc';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final color = _getColorForType(notification.type);
    final icon = _getIconForType(notification.type);
    final timeAgo = timeago.format(notification.createdAt, locale: 'vi');

    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: Colors.red,
        child: Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Xác nhận xóa'),
            content: Text('Bạn có chắc muốn xóa thông báo này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Xóa'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        ApiService.deleteNotification(notification.id);
        setState(() {
          _notifications.removeWhere((n) => n.id == notification.id);
          _total--;
          if (!notification.isRead) {
            _unreadCount--;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xóa thông báo')),
        );
      },
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: notification.isRead ? 0 : 2,
        color: notification.isRead ? Colors.grey[50] : Colors.white,
        child: InkWell(
          onTap: () {
            _markAsRead(notification);
            // TODO: Navigate based on notification type and relatedId
          },
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            timeAgo,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          if (notification.priority > 0) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: notification.priority == 2
                                    ? Colors.red
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                notification.priority == 2
                                    ? 'URGENT'
                                    : 'HIGH',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Actions menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: 20),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _deleteNotification(notification.id);
                    } else if (value == 'mark_read' && !notification.isRead) {
                      _markAsRead(notification);
                    } else if (value == 'mark_unread' && notification.isRead) {
                      ApiService.markNotificationAsUnread(notification.id);
                      _loadNotifications(refresh: true);
                    }
                  },
                  itemBuilder: (context) => [
                    if (!notification.isRead)
                      PopupMenuItem(
                        value: 'mark_read',
                        child: Row(
                          children: [
                            Icon(Icons.done, size: 18),
                            SizedBox(width: 8),
                            Text('Đánh dấu đã đọc'),
                          ],
                        ),
                      ),
                    if (notification.isRead)
                      PopupMenuItem(
                        value: 'mark_unread',
                        child: Row(
                          children: [
                            Icon(Icons.mark_email_unread, size: 18),
                            SizedBox(width: 8),
                            Text('Đánh dấu chưa đọc'),
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Lọc theo loại'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Tất cả'),
              leading: Radio<String?>(
                value: null,
                groupValue: _selectedType,
                onChanged: (value) {
                  Navigator.pop(context);
                  setState(() {
                    _selectedType = value;
                  });
                  _loadNotifications(refresh: true);
                },
              ),
            ),
            ..._types.map((type) {
              return ListTile(
                title: Text(type.label),
                leading: Radio<String?>(
                  value: type.value,
                  groupValue: _selectedType,
                  onChanged: (value) {
                    Navigator.pop(context);
                    setState(() {
                      _selectedType = value;
                    });
                    _loadNotifications(refresh: true);
                  },
                ),
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
