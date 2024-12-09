import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:globeupdates/layouts/global_layout.dart';
import 'package:globeupdates/pages/detail_screen.dart';
import 'package:globeupdates/theme/theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> topNews = [];
  List<dynamic> categoryNews = [];
  List<dynamic> sources = [];
  List<dynamic> bookmarkedArticles = [];

  String selectedCategory = 'general';

  final List<Map<String, String>> categories = [
    {'name': 'General', 'value': 'general'},
    {'name': 'Sport', 'value': 'sports'},
    {'name': 'Tech', 'value': 'technology'},
    {'name': 'Business', 'value': 'business'},
  ];

  @override
  void initState() {
    super.initState();
    fetchTopNews();
    fetchNewsSources();
    fetchCategoryNews();
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
        'https://newsapi.org/v2/top-headlines/sources?apiKey=6f9cb84a936449fbbc9a5322dfe72375';

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
        'https://newsapi.org/v2/top-headlines?sources=$sourceIds&apiKey=6f9cb84a936449fbbc9a5322dfe72375';

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

  @override
  Widget build(BuildContext context) {
    return GlobalLayout(
      child: Scaffold(
        backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
        body: CustomScrollView(
          slivers: [
            // Header and Top News Section
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // [Previous header code remains the same]
                  SizedBox(
                    height: 250,
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
                ],
              ),
            ),

            // Category Buttons
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyHeaderDelegate(
                child: Row(
                  children: categories
                      .map((category) => Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: TextButton(
                                onPressed: () =>
                                    _onCategorySelected(category['value']!),
                                style: TextButton.styleFrom(
                                  backgroundColor:
                                      _getCategoryColor(category['value']!),
                                ),
                                child: Text(
                                  category['name']!,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),

            // Category News List
            categoryNews.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.darkTheme.primaryColor,
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _buildNewsListItem(context, categoryNews[index]),
                      childCount: categoryNews.length,
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
    final isBookmarked = bookmarkedArticles.contains(article);

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
                          setState(() {
                            if (isBookmarked) {
                              bookmarkedArticles.remove(article);
                            } else {
                              bookmarkedArticles.add(article);
                            }
                          });
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
