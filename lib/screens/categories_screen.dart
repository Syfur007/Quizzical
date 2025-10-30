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

  Widget _buildCategoryTile(BuildContext context, Map<String, dynamic> category) {
    // Create a simple hero image using gradient + icon. Use category id to vary color.
    final int id = category['id'] ?? 0;
    final Color start = Colors.primaries[id % Colors.primaries.length].shade700;
    final Color end = Colors.primaries[(id + 3) % Colors.primaries.length].shade400;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfigScreen(categoryId: category['id']),
        ),
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Slightly smaller hero image (reduced flex and constraints)
            Expanded(
              flex: 2,
              child: Container(
                constraints: BoxConstraints(minHeight: 70),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [start, end]),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.category,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Slightly larger title but still compact
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
              child: Text(
                category['name'] ?? 'Unknown',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
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
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Categories',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pick a topic and start your quiz',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(width: 12),

                  // Search button (functional)
                  IconButton(
                    icon: Icon(_isSearching ? Icons.clear : Icons.search, color: Colors.grey.shade700),
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
                    ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 3 / 4,
                        ),
                        itemCount: _filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = _filteredCategories[index] as Map<String, dynamic>;
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
