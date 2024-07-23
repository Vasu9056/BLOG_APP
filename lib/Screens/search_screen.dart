import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchController extends ChangeNotifier {
  String _query = '';
  String get query => _query;

  void updateQuery(String newQuery) {
    _query = newQuery;
    notifyListeners();
  }

  void clear() {
    _query = '';
    notifyListeners();
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchController _searchController = SearchController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchQueryChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchQueryChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchQueryChanged() {
    setState(() {});
  }

  Future<void> _searchBlogPosts(String query) async {
    if (query.isEmpty) return;

    final results = await FirebaseFirestore.instance
        .collection('blog_posts')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    setState(() {
      _searchController.updateQuery(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              controller: _searchController,
              hintText: "Search",
              leading: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                _searchBlogPosts(value);
              },
              viewHintText: "Search...",
              viewTrailing: [
                IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.clear),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('blog_posts').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final data = snapshot.data?.docs ?? [];
                final filteredData = data.where((doc) {
                  final title = doc['title'] as String;
                  return title.toLowerCase().contains(_searchController.query.toLowerCase());
                }).toList();

                return ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final blogPost = filteredData[index];
                    return ListTile(
                      title: Text(blogPost['title']),
                      subtitle: Text(blogPost['content']),
                      onTap: () {
                        // Handle blog post tap
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({
    super.key,
    required this.controller,
    this.hintText,
    this.leading,
    this.onTap,
    this.onChanged,
    this.viewHintText,
    this.viewTrailing,
  });

  final SearchController controller;
  final String? hintText;
  final Widget? leading;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final String? viewHintText;
  final List<Widget>? viewTrailing;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: TextEditingController(text: controller.query),
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: leading,
        suffixIcon: viewTrailing != null ? Row(mainAxisSize: MainAxisSize.min, children: viewTrailing!) : null,
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        controller.updateQuery(value);
        if (onChanged != null) {
          onChanged!(value);
        }
      },
      onTap: onTap,
    );
  }
}
