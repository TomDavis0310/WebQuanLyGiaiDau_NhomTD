import 'package:flutter/material.dart';
import 'dart:async';
import '../models/search_result.dart';
import '../services/api_service.dart';
import 'team_detail_screen.dart';
import 'player_detail_screen.dart';
import 'match_detail_screen.dart';
import 'news_detail_screen.dart';
import 'tournament_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;
  
  GlobalSearchResults? _searchResults;
  SearchSuggestionsResponse? _suggestions;
  PopularSearchesResponse? _popularSearches;
  bool _isLoading = false;
  bool _showSuggestions = false;
  String _selectedFilter = 'all';

  final Map<String, String> _filters = {
    'all': 'Tất cả',
    'teams': 'Đội bóng',
    'players': 'Cầu thủ',
    'matches': 'Trận đấu',
    'news': 'Tin tức',
    'tournaments': 'Giải đấu',
  };

  @override
  void initState() {
    super.initState();
    _loadPopularSearches();
    _searchFocusNode.addListener(() {
      setState(() {
        _showSuggestions = _searchFocusNode.hasFocus && _searchController.text.length >= 2;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadPopularSearches() async {
    try {
      final response = await ApiService.getPopularSearches();
      if (mounted && response.success && response.data != null) {
        setState(() {
          _popularSearches = response.data;
        });
      }
    } catch (e) {
      // Ignore errors for popular searches
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    if (query.length >= 2) {
      setState(() {
        _showSuggestions = true;
      });
      
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _loadSuggestions(query);
      });
    } else {
      setState(() {
        _showSuggestions = false;
        _suggestions = null;
      });
    }
  }

  Future<void> _loadSuggestions(String query) async {
    try {
      final response = await ApiService.getSearchSuggestions(query);
      if (mounted && response.success && response.data != null) {
        setState(() {
          _suggestions = response.data;
        });
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _showSuggestions = false;
      _searchResults = null;
    });

    _searchFocusNode.unfocus();

    try {
      final types = _selectedFilter == 'all' ? null : [_selectedFilter];
      final response = await ApiService.globalSearch(query, types: types);

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (response.success && response.data != null) {
            _searchResults = response.data;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tìm kiếm: $e')),
        );
      }
    }
  }

  void _onSuggestionTap(SearchSuggestion suggestion) {
    _searchController.text = suggestion.text;
    _searchFocusNode.unfocus();
    _performSearch(suggestion.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm Kiếm'),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchHeader(),
          _buildFilterChips(),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm đội, cầu thủ, trận đấu...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchResults = null;
                      _suggestions = null;
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: _onSearchChanged,
        onSubmitted: _performSearch,
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final entry = _filters.entries.elementAt(index);
          final isSelected = _selectedFilter == entry.key;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = entry.key;
                });
                if (_searchController.text.isNotEmpty) {
                  _performSearch(_searchController.text);
                }
              },
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (_showSuggestions && _suggestions != null) {
      return _buildSuggestionsList();
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchResults != null) {
      return _buildSearchResults();
    }

    return _buildEmptyState();
  }

  Widget _buildSuggestionsList() {
    if (_suggestions == null || _suggestions!.suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.builder(
      itemCount: _suggestions!.suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions!.suggestions[index];
        return ListTile(
          leading: Icon(_getIconForType(suggestion.type)),
          title: Text(suggestion.text),
          subtitle: suggestion.subtitle != null
              ? Text(suggestion.subtitle!)
              : null,
          onTap: () => _onSuggestionTap(suggestion),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    final results = _searchResults!.results;
    
    if (results.totalCount == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử từ khóa khác',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Tìm thấy ${results.totalCount} kết quả',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        if (_selectedFilter == 'all' || _selectedFilter == 'teams')
          ...?_buildTeamResults(results.teams),
        
        if (_selectedFilter == 'all' || _selectedFilter == 'players')
          ...?_buildPlayerResults(results.players),
        
        if (_selectedFilter == 'all' || _selectedFilter == 'matches')
          ...?_buildMatchResults(results.matches),
        
        if (_selectedFilter == 'all' || _selectedFilter == 'news')
          ...?_buildNewsResults(results.news),
        
        if (_selectedFilter == 'all' || _selectedFilter == 'tournaments')
          ...?_buildTournamentResults(results.tournaments),
      ],
    );
  }

  List<Widget>? _buildTeamResults(List<TeamSearchResult>? teams) {
    if (teams == null || teams.isEmpty) return null;

    return [
      _buildSectionHeader('Đội Bóng', teams.length),
      ...teams.map((team) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: team.logo != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(team.logo!),
                )
              : const CircleAvatar(
                  child: Icon(Icons.groups),
                ),
          title: Text(team.name),
          subtitle: Text('HLV: ${team.coach}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeamDetailScreen(teamId: team.id),
              ),
            );
          },
        ),
      )),
      const SizedBox(height: 16),
    ];
  }

  List<Widget>? _buildPlayerResults(List<PlayerSearchResult>? players) {
    if (players == null || players.isEmpty) return null;

    return [
      _buildSectionHeader('Cầu Thủ', players.length),
      ...players.map((player) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: player.imageUrl != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(player.imageUrl!),
                )
              : const CircleAvatar(
                  child: Icon(Icons.person),
                ),
          title: Text(player.fullName),
          subtitle: Text('${player.position} • ${player.teamName ?? "N/A"}'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '#${player.number}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayerDetailScreen(playerId: player.id),
              ),
            );
          },
        ),
      )),
      const SizedBox(height: 16),
    ];
  }

  List<Widget>? _buildMatchResults(List<MatchSearchResult>? matches) {
    if (matches == null || matches.isEmpty) return null;

    return [
      _buildSectionHeader('Trận Đấu', matches.length),
      ...matches.map((match) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          title: Row(
            children: [
              Expanded(child: Text(match.teamA, textAlign: TextAlign.right)),
              const SizedBox(width: 8),
              Text(
                '${match.scoreA ?? '-'} : ${match.scoreB ?? '-'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(match.teamB)),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(match.formattedDate),
              if (match.tournamentName != null)
                Text(match.tournamentName!),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getStatusColor(match.status),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getStatusText(match.status),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchDetailScreen(matchId: match.id),
              ),
            );
          },
        ),
      )),
      const SizedBox(height: 16),
    ];
  }

  List<Widget>? _buildNewsResults(List<NewsSearchResult>? news) {
    if (news == null || news.isEmpty) return null;

    return [
      _buildSectionHeader('Tin Tức', news.length),
      ...news.map((item) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: item.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.article),
                ),
          title: Text(
            item.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: item.category != null
              ? Text(item.category!)
              : null,
          trailing: item.isFeatured
              ? const Icon(Icons.star, color: Colors.amber)
              : null,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsDetailScreen(newsId: item.id),
              ),
            );
          },
        ),
      )),
      const SizedBox(height: 16),
    ];
  }

  List<Widget>? _buildTournamentResults(List<TournamentSearchResult>? tournaments) {
    if (tournaments == null || tournaments.isEmpty) return null;

    return [
      _buildSectionHeader('Giải Đấu', tournaments.length),
      ...tournaments.map((tournament) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: tournament.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    tournament.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.emoji_events),
                ),
          title: Text(tournament.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (tournament.sportName != null)
                Text(tournament.sportName!),
              if (tournament.location != null)
                Text(tournament.location!),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getTournamentStatusColor(tournament.status),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              tournament.status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TournamentDetailScreen(tournamentId: tournament.id),
              ),
            );
          },
        ),
      )),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$title ($count)',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tìm kiếm phổ biến',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (_popularSearches != null)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularSearches!.popularSearches.map((search) {
                return ActionChip(
                  avatar: Icon(_getIconForType(search.type), size: 18),
                  label: Text(search.text),
                  onPressed: () {
                    _searchController.text = search.text;
                    _performSearch(search.text);
                  },
                );
              }).toList(),
            ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                Icon(Icons.search, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Nhập từ khóa để tìm kiếm',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'team':
        return Icons.groups;
      case 'player':
        return Icons.person;
      case 'match':
        return Icons.sports_soccer;
      case 'news':
        return Icons.article;
      case 'tournament':
        return Icons.emoji_events;
      default:
        return Icons.search;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.grey;
      case 'InProgress':
        return Colors.green;
      case 'Upcoming':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'Completed':
        return 'Đã kết thúc';
      case 'InProgress':
        return 'Đang diễn ra';
      case 'Upcoming':
        return 'Sắp diễn ra';
      default:
        return status;
    }
  }

  Color _getTournamentStatusColor(String status) {
    if (status.contains('đang diễn ra')) return Colors.green;
    if (status.contains('đã kết thúc')) return Colors.grey;
    return Colors.blue;
  }
}
