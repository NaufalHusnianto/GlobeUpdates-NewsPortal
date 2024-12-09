import 'package:flutter/material.dart';

class BookmarkPage extends StatelessWidget {
  final List<dynamic> bookmarkedArticles;

  const BookmarkPage({Key? key, required this.bookmarkedArticles})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked News'),
        backgroundColor: Colors.black,
      ),
      body: bookmarkedArticles.isEmpty
          ? const Center(
              child: Text(
                'No bookmarks yet!',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: bookmarkedArticles.length,
              itemBuilder: (context, index) {
                final article = bookmarkedArticles[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      article['urlToImage'] ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 50,
                        height: 50,
                        color: Colors.grey,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  title: Text(
                    article['title'] ?? 'No Title',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    article['description'] ?? 'No Description',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () {
                    // Add navigation to detail screen if needed
                  },
                );
              },
            ),
      backgroundColor: Colors.black,
    );
  }
}
