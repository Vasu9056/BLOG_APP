import 'package:flutter/material.dart';

class searchblogs extends StatelessWidget {
  const searchblogs({
    super.key,
    required SearchController searchbar,
  }) : _searchbar = searchbar;

  final SearchController _searchbar;

  @override
  Widget build(BuildContext context) {
    return SearchAnchor(
        viewHintText: "Search...",
        viewTrailing: [
          IconButton(
            onPressed: () {
              _searchbar.clear();
            },
            icon: Icon(Icons.clear),
          )
        ],
        builder: (context, _searchbar) {
          return SearchBar(
            controller: _searchbar,
            hintText: "Search",
            leading: IconButton(onPressed: () {}, icon: Icon(Icons.search)),
            onTap: () => {
              _searchbar.openView(),
            },
          );
        },
        suggestionsBuilder: (context, _searchbar) {
          return [];
        });
  }
}
