import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_service.dart';

class VideoHighlightsScreen extends StatefulWidget {
  final int? tournamentId;
  final String? searchQuery;

  const VideoHighlightsScreen({
    Key? key,
    this.tournamentId,
    this.searchQuery,
  }) : super(key: key);

  @override
  State<VideoHighlightsScreen> createState() => _VideoHighlightsScreenState();
}

class _VideoHighlightsScreenState extends State<VideoHighlightsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  List<dynamic> _searchResults = [];
  List<dynamic> _tournamentHighlights = [];
  bool _isLoadingSearch = false;
  bool _isLoadingTournament = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      _searchController.text = widget.searchQuery!;
      _searchQuery = widget.searchQuery!;
      _performSearch();
    }
    
    if (widget.tournamentId != null) {
      _loadTournamentHighlights();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập từ khóa tìm kiếm')),
      );
      return;
    }

    setState(() {
      _isLoadingSearch = true;
      _searchQuery = _searchController.text.trim();
    });

    try {
      final response = await ApiService.searchHighlights(
        query: _searchQuery,
        maxResults: 20,
      );

      if (response.success && response.data != null) {
        final videos = response.data!['videos'] as List<dynamic>? ?? [];
        setState(() {
          _searchResults = videos;
          _isLoadingSearch = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isLoadingSearch = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.message.isEmpty ? 'Không tìm thấy video' : response.message)),
          );
        }
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _isLoadingSearch = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tìm kiếm: $e')),
        );
      }
    }
  }

  Future<void> _loadTournamentHighlights() async {
    if (widget.tournamentId == null) return;

    setState(() {
      _isLoadingTournament = true;
    });

    try {
      final response = await ApiService.getTournamentHighlights(widget.tournamentId!);

      if (response.success && response.data != null) {
        setState(() {
          _tournamentHighlights = response.data!;
          _isLoadingTournament = false;
        });
      } else {
        setState(() {
          _tournamentHighlights = [];
          _isLoadingTournament = false;
        });
      }
    } catch (e) {
      setState(() {
        _tournamentHighlights = [];
        _isLoadingTournament = false;
      });
    }
  }

  Future<void> _openVideo(String videoId) async {
    final url = 'https://www.youtube.com/watch?v=$videoId';
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở video')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Highlights'),
        elevation: 0,
        bottom: widget.tournamentId != null
            ? TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Giải đấu'),
                  Tab(text: 'Tìm kiếm'),
                ],
              )
            : null,
      ),
      body: widget.tournamentId != null
          ? TabBarView(
              controller: _tabController,
              children: [
                _buildTournamentTab(),
                _buildSearchTab(),
              ],
            )
          : _buildSearchTab(),
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm video highlights...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchResults = [];
                    _searchQuery = '';
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (_) => _performSearch(),
          ),
        ),

        // Search button
        if (_searchController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoadingSearch ? null : _performSearch,
                icon: _isLoadingSearch
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: Text(_isLoadingSearch ? 'Đang tìm...' : 'Tìm kiếm'),
              ),
            ),
          ),

        // Search results
        Expanded(
          child: _isLoadingSearch
              ? const Center(child: CircularProgressIndicator())
              : _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.video_library_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'Nhập từ khóa để tìm kiếm video'
                                : 'Không tìm thấy video',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final video = _searchResults[index];
                        return _buildVideoCard(video);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildTournamentTab() {
    if (_isLoadingTournament) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_tournamentHighlights.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có video highlights',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _tournamentHighlights.length,
      itemBuilder: (context, index) {
        final video = _tournamentHighlights[index];
        return _buildVideoCard(video);
      },
    );
  }

  Widget _buildVideoCard(Map<String, dynamic> video) {
    final videoId = video['videoId'] as String? ?? '';
    final title = video['title'] as String? ?? 'No title';
    final channelTitle = video['channelTitle'] as String? ?? '';
    final description = video['description'] as String? ?? '';
    final thumbnailUrl = video['thumbnailUrl'] as String? ?? '';
    final publishedAt = video['publishedAt'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _openVideo(videoId),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  if (thumbnailUrl.isNotEmpty)
                    Image.network(
                      thumbnailUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.video_library,
                            size: 60,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                  else
                    Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.video_library,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  
                  // Play button overlay
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Video info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (channelTitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            channelTitle,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (publishedAt.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(publishedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} năm trước';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} tháng trước';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} ngày trước';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} phút trước';
      } else {
        return 'Vừa xong';
      }
    } catch (e) {
      return dateString;
    }
  }
}
