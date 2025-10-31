import 'package:flutter/material.dart';
import '../utils/api.dart';
import 'config_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<dynamic> categories = [];
  bool isLoading = true;

  // Search state
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final data = await Api.fetchCategories();
    setState(() {
      categories = data;
      isLoading = false;
    });
  }

  List<dynamic> get _filteredCategories {
    if (_searchQuery.trim().isEmpty) return categories;
    final q = _searchQuery.toLowerCase();
    return categories.where((c) {
      final name = (c['name'] ?? '').toString().toLowerCase();
      return name.contains(q);
    }).toList();
  }

  Widget _buildCategoryTile(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    // Show a compact icon-based tile: small circular icon + category name
    final int id = category['id'] ?? 0;
    final String name = (category['name'] ?? 'Category').toString();
    final Color color = Colors.primaries[id % Colors.primaries.length].shade600;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfigScreen(
            categoryId: category['id'],
            categoryName: name,
            categoryColor: color,
          ),
        ),
      ),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(Icons.category, color: Colors.white, size: 26),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Simplified header (no floating card, no home icon)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Title or search field
                  Expanded(
                    child: _isSearching
                        ? TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search categories...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Categories',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pick a topic and start your quiz',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(width: 12),

                  // Search button (functional)
                  IconButton(
                    icon: Icon(
                      _isSearching ? Icons.clear : Icons.search,
                      color: Colors.grey.shade700,
                    ),
                    onPressed: () {
                      if (_isSearching) {
                        if (_searchController.text.isNotEmpty) {
                          _searchController.clear();
                        } else {
                          setState(() => _isSearching = false);
                        }
                      } else {
                        setState(() => _isSearching = true);
                      }
                    },
                  ),
                ],
              ),
            ),

            // Grid content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              (MediaQuery.of(context).size.width > 1000)
                              ? 6
                              : (MediaQuery.of(context).size.width > 700)
                              ? 4
                              : (MediaQuery.of(context).size.width > 480)
                              ? 3
                              : 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category =
                              _filteredCategories[index]
                                  as Map<String, dynamic>;
                          return _buildCategoryTile(context, category);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
