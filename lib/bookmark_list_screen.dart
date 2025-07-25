import 'package:flutter/material.dart';

import 'services/bookmark_service.dart';

class BookmarkListScreen extends StatelessWidget {
  final BookmarkService service;

  const BookmarkListScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final bookmarks = service.allBookmarks();
    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: ListView.builder(
        itemCount: bookmarks.length,
        itemBuilder: (context, i) {
          final b = bookmarks[i];
          return ListTile(
            title: Text('Page ${b.pageIndex + 1}'),
            onTap: () => Navigator.of(context).pop(b.pageIndex),
          );
        },
      ),
    );
  }
}
