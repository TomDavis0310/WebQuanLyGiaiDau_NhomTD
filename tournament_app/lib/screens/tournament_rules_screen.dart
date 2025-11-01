import 'package:flutter/material.dart';
import '../models/tournament_rules.dart';
import '../services/api_service.dart';

class TournamentRulesScreen extends StatefulWidget {
  final int tournamentId;
  final String tournamentName;

  const TournamentRulesScreen({
    Key? key,
    required this.tournamentId,
    required this.tournamentName,
  }) : super(key: key);

  @override
  State<TournamentRulesScreen> createState() => _TournamentRulesScreenState();
}

class _TournamentRulesScreenState extends State<TournamentRulesScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  TournamentRulesResponse? _rulesData;
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadRules();
  }

  Future<void> _loadRules() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ApiService.getTournamentRules(widget.tournamentId);

      if (response.success && response.data != null) {
        setState(() {
          _rulesData = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message.isNotEmpty 
              ? response.message 
              : 'Không thể tải luật giải đấu';
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

  List<RuleCategory> _getFilteredCategories() {
    if (_rulesData == null) return [];

    var categories = _rulesData!.rules;

    // Filter by selected category
    if (_selectedCategory != null) {
      categories = categories
          .where((cat) => cat.category == _selectedCategory)
          .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      categories = categories.where((category) {
        // Search in category name
        if (category.categoryName
            .toLowerCase()
            .contains(_searchQuery.toLowerCase())) {
          return true;
        }
        // Search in rules
        return category.rules.any((rule) =>
            rule.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            rule.content.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    return categories;
  }

  IconData _getIconForCategory(String icon) {
    switch (icon.toLowerCase()) {
      case 'info':
        return Icons.info_outline;
      case 'score':
        return Icons.star_outline;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'sports':
        return Icons.sports_soccer_outlined;
      case 'assignment':
        return Icons.assignment_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  Color _getColorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'general':
        return Colors.blue;
      case 'scoring':
        return Colors.green;
      case 'penalties':
        return Colors.red;
      case 'equipment':
        return Colors.orange;
      case 'registration':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Luật giải đấu',
              style: TextStyle(fontSize: 18),
            ),
            if (_rulesData != null)
              Text(
                _rulesData!.tournamentName,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
              ),
          ],
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildRulesView(),
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
              onPressed: _loadRules,
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

  Widget _buildRulesView() {
    if (_rulesData == null) {
      return Center(child: Text('Không có dữ liệu'));
    }

    final filteredCategories = _getFilteredCategories();

    return Column(
      children: [
        _buildSearchBar(),
        _buildCategoryFilter(),
        Expanded(
          child: filteredCategories.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadRules,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      return _buildCategoryCard(filteredCategories[index]);
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm luật...',
          prefixIcon: Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    if (_rulesData == null) return SizedBox.shrink();

    return Container(
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Tất cả', null),
          ..._rulesData!.rules.map((category) {
            return _buildFilterChip(
              category.categoryName,
              category.category,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? category) {
    final isSelected = _selectedCategory == category;
    final color = category != null
        ? _getColorForCategory(category)
        : Colors.deepPurple;

    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: color.withOpacity(0.2),
        checkmarkColor: color,
        labelStyle: TextStyle(
          color: isSelected ? color : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'Không tìm thấy luật nào',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _selectedCategory = null;
              });
            },
            child: Text('Xóa bộ lọc'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(RuleCategory category) {
    final color = _getColorForCategory(category.category);
    final icon = _getIconForCategory(category.icon);

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            category.categoryName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            category.description,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          children: [
            Divider(height: 1),
            ...category.rules.map((rule) => _buildRuleItem(rule, color)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRuleItem(Rule rule, Color categoryColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (rule.isImportant)
                Container(
                  margin: EdgeInsets.only(right: 8),
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'QUAN TRỌNG',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  rule.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: categoryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            rule.content,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
