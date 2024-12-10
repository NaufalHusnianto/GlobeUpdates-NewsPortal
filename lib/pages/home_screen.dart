import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:globeupdates/layouts/global_layout.dart';
import 'package:globeupdates/pages/detail_screen.dart';
import 'package:globeupdates/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> topNews = [];
  List<dynamic> categoryNews = [];
  List<dynamic> filteredCategoryNews = [];
  List<dynamic> sources = [];
  List<dynamic> bookmarkedArticles = [];

  String selectedCategory = 'general';
  String searchQuery = '';

  final TextEditingController searchController = TextEditingController();

  final List<Map<String, String>> categories = [
    {'name': 'General', 'value': 'general'},
    {'name': 'Sport', 'value': 'sports'},
    {'name': 'Tech', 'value': 'technology'},
    {'name': 'Business', 'value': 'business'},
    {'name': 'Entertainment', 'value': 'entertainment'},
    {'name': 'Science', 'value': 'science'},
  ];

  @override
  void initState() {
    super.initState();
    fetchTopNews();
    fetchNewsSources();
    fetchCategoryNews();
    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      searchQuery = searchController.text.toLowerCase();
      filteredCategoryNews = categoryNews.where((article) {
        // Memeriksa apakah judul artikel mengandung kata kunci pencarian
        final title = article['title']?.toLowerCase() ?? '';
        return title.contains(searchQuery);
      }).toList();
    });
  }

  // Metode untuk mensanitasi URL
  String _sanitizeUrl(String url) {
    url = url.replaceFirst(RegExp(r'^https?://'), '');

    url = url.replaceAll('//', '/');

    url = url.replaceAll(RegExp(r'[.#$\[\]]'), '_');

    return url.length > 50 ? url.substring(0, 50) : url;
  }

  Future<void> fetchTopNews() async {
    const String apiUrl =
        'https://newsapi.org/v2/top-headlines?country=us&apiKey=0ebe6cd23c6843bc93fe9e51bde2ee4c';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          topNews = data['articles'];
        });
      } else {
        throw Exception('Failed to load top news');
      }
    } catch (e) {
      print('Error fetching top news: $e');
    }
  }

  Future<void> fetchNewsSources() async {
    final String apiUrl =
        'https://newsapi.org/v2/top-headlines/sources?apiKey=0ebe6cd23c6843bc93fe9e51bde2ee4c';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          sources = data['sources']
              .where((source) => source['category'] == selectedCategory)
              .toList();
        });
        fetchCategoryNews();
      } else {
        throw Exception('Failed to load news sources');
      }
    } catch (e) {
      print('Error fetching sources: $e');
    }
  }

  Future<void> fetchCategoryNews() async {
    if (sources.isEmpty) return;

    final sourceIds = sources.map((source) => source['id']).join(',');

    final String apiUrl =
        'https://newsapi.org/v2/top-headlines?sources=$sourceIds&apiKey=0ebe6cd23c6843bc93fe9e51bde2ee4c';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          categoryNews = data['articles'];
        });
      } else {
        throw Exception('Failed to load category news');
      }
    } catch (e) {
      print('Error fetching category news: $e');
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
    });
    fetchNewsSources();
  }

  Future<void> addBookmark(Map<String, dynamic> article) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userBookmarksRef = FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(user.uid)
        .collection('articles');

    try {
      final docId = article['id'];

      await userBookmarksRef.doc(docId).set({
        'id': article['id'] ?? '',
        'title': article['title'] ?? '',
        'description': article['description'] ?? '',
        'imageUrl': article['urlToImage'] ?? '',
        'author': article['author'] ?? '',
        'url': article['url'] ?? '',
        'content': article['content'] ?? '',
        'publishedAt': article['publishedAt'] ?? '',
      });

      // Perbarui daftar artikel yang di-bookmark di lokal
      setState(() {
        bookmarkedArticles.add(article);
      });

      print('Bookmark ditambahkan');
    } catch (e) {
      print('Error menambah bookmark: $e');
    }
  }

  Future<void> removeBookmark(String articleUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userBookmarksRef = FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(user.uid)
        .collection('articles');

    try {
      // Sanitasi URL sebelum menghapus
      final sanitizedUrl = _sanitizeUrl(articleUrl);

      await userBookmarksRef.doc(sanitizedUrl).delete();

      // Hapus dari daftar artikel yang di-bookmark di lokal
      setState(() {
        bookmarkedArticles
            .removeWhere((article) => article['url'] == articleUrl);
      });

      print('Bookmark dihapus');
    } catch (e) {
      print('Error menghapus bookmark: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getBookmarks(String userId) async {
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

  Future<bool> isBookmarked(String userId, String articleUrl) async {
    final userBookmarksRef = FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(userId)
        .collection('articles');

    try {
      // Sanitasi URL sebelum memeriksa
      final sanitizedUrl = _sanitizeUrl(articleUrl);

      final doc = await userBookmarksRef.doc(sanitizedUrl).get();
      return doc.exists;
    } catch (e) {
      print('Error memeriksa bookmark: $e');
      return false;
    }
  }

  Future<void> fetchBookmarks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final bookmarks = await getBookmarks(user.uid);
      setState(() {
        bookmarkedArticles = bookmarks;
      });
    } catch (e) {
      print('Error fetching bookmarks: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> bookmarksStream(String userId) {
    final userBookmarksRef = FirebaseFirestore.instance
        .collection('bookmarks')
        .doc(userId)
        .collection('articles');

    return userBookmarksRef.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  @override
 Widget build(BuildContext context) {
  return GlobalLayout(
    child: Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // Top News Section (PageView for top headlines)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 250, // Adjust height for top news
              child: topNews.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.darkTheme.primaryColor,
                      ),
                    )
                  : PageView.builder(
                      itemCount: topNews.length,
                      itemBuilder: (context, index) {
                        return _buildTopNewsItem(context, topNews[index]);
                      },
                    ),
            ),
          ),

          // Search Bar Section (if it's visible, above the category buttons)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextField(
                controller: searchController,
                onChanged: (query) {
                  setState(() {
                    searchQuery = query.toLowerCase();
                    filteredCategoryNews = categoryNews.where((article) {
                      final title = article['title']?.toLowerCase() ?? '';
                      return title.contains(searchQuery);
                    }).toList();
                  });
                },
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search news...',
                  hintStyle: TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.6),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                ),
              ),
            ),
          ),

          // Category Buttons (always visible below search bar)
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: TextButton(
                      onPressed: () => _onCategorySelected(category['value']!),
                      style: TextButton.styleFrom(
                        backgroundColor: _getCategoryColor(category['value']!),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        category['name']!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Show search results below categories (if search query exists)
          if (searchQuery.isNotEmpty) 
            SliverToBoxAdapter(
              child: SizedBox(
                height: 250, // Adjust the height based on the content
                child: filteredCategoryNews.isEmpty
                    ? Center(
                        child: Text(
                          'No articles found for "$searchQuery"',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredCategoryNews.length,
                        itemBuilder: (context, index) {
                          return _buildNewsListItem(context, filteredCategoryNews[index]);
                        },
                      ),
              ),
            ),
          
          // Show category news (if search query is empty)
          if (searchQuery.isEmpty) 
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final article = categoryNews[index];
                  return _buildNewsListItem(context, article);
                },
                childCount: categoryNews.length,
              ),
            ),
          
          // Loading or Empty State for Category News (if search query is empty)
          if (searchQuery.isEmpty && categoryNews.isEmpty)
            SliverToBoxAdapter(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.darkTheme.primaryColor,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}


  Color _getCategoryColor(String category) {
    switch (category) {
      case 'general':
        return Colors.red;
      case 'sports':
        return Colors.blue;
      case 'technology':
        return Colors.cyan;
      case 'business':
        return Colors.indigo;
      case 'science':
        return Colors.amberAccent;
      case 'entertainment':
        return Colors.tealAccent;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTopNewsItem(BuildContext context, dynamic article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              title: article['title'] ?? 'No Title',
              description: article['description'] ?? 'No Description',
              imageUrl: article['urlToImage'] ?? '',
              author: article['author'] ?? 'Unknown Author',
              url: article['url'] ?? '',
              content: article['content'] ?? '',
              publishedAt: article['publishedAt'] ?? '',
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppTheme.darkTheme.primaryColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  width: 1,
                  color: Colors.grey.shade600,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  article['urlToImage'] ?? '',
                  fit: BoxFit.cover,
                  height: 300,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return Center(
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          color: AppTheme.darkTheme.primaryColor,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article['title'] ?? 'No Title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    article['description'] ?? 'No Description',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsListItem(BuildContext context, dynamic article) {
    final isBookmarked = bookmarkedArticles
        .any((bookmarkedArticle) => bookmarkedArticle['url'] == article['url']);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              title: article['title'] ?? 'No Title',
              description: article['description'] ?? 'No Description',
              imageUrl: article['urlToImage'] ?? '',
              author: article['author'] ?? 'Unknown Author',
              url: article['url'] ?? '',
              content: article['content'] ?? '',
              publishedAt: article['publishedAt'] ?? '',
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                article['urlToImage'] ?? '',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          article['title'] ?? 'No Title',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked ? Colors.yellow : Colors.grey,
                        ),
                        onPressed: () {
                          if (isBookmarked) {
                            removeBookmark(article['url']);
                          } else {
                            addBookmark(article);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    article['description'] ?? 'No Description',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyHeaderDelegate({required this.child});

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.darkTheme.scaffoldBackgroundColor,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
