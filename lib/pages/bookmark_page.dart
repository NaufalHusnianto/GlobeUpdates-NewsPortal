import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:globeupdates/pages/detail_screen.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({Key? key}) : super(key: key); 

  @override
  _BookmarkPageState createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  List<Map<String, dynamic>> bookmarkedArticles = [];

  @override
  void initState() {
    super.initState();
    _fetchBookmarks();
  }

  Future<void> _fetchBookmarks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final bookmarks = await _getBookmarks(user.uid);
      setState(() {
        bookmarkedArticles = bookmarks;
      });
    } catch (e) {
      print('Error fetching bookmarks: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getBookmarks(String userId) async {
    final userBookmarksRef = FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(userId)
        .collection('articles');

    try {
      final snapshot = await userBookmarksRef.get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error fetching bookmarks: $e');
      return [];
    }
  }

  void _removeBookmark(String articleUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userBookmarksRef = FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(user.uid)
        .collection('articles');

    try {
      final sanitizedUrl = _sanitizeUrl(articleUrl);
      await userBookmarksRef.doc(sanitizedUrl).delete();

      setState(() {
        bookmarkedArticles
            .removeWhere((article) => article['url'] == articleUrl);
      });
    } catch (e) {
      print('Error removing bookmark: $e');
    }
  }

  // Metode untuk mensanitasi URL (sama seperti di HomeScreen)
  String _sanitizeUrl(String url) {
    url = url.replaceFirst(RegExp(r'^https?://'), '');
    url = url.replaceAll('//', '/');
    url = url.replaceAll(RegExp(r'[.#$\[\]]'), '_');
    return url.length > 50 ? url.substring(0, 50) : url;
  }

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
                return Dismissible(
                  key: Key(article['url']),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) {
                    _removeBookmark(article['url']);
                  },
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        article['imageUrl'] ?? '',
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            title: article['title'] ?? 'No Title',
                            description:
                                article['description'] ?? 'No Description',
                            imageUrl: article['imageUrl'] ?? '',
                            author: article['author'] ?? 'Unknown Author',
                            url: article['url'] ?? '',
                            content: article['content'] ?? '',
                            publishedAt: article['publishedAt'] ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      backgroundColor: Colors.black,
    );
  }
}
