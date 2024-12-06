import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final String author;
  final String url;
  final String content;
  final String publishedAt;

  const DetailScreen({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.author,
    required this.url,
    required this.content,
    required this.publishedAt,
  });

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('EEEE, MMMM d, y • h:mm a').format(parsedDate);
    } catch (e) {
      return "Unknown date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail News"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Berita
            imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  )
                : const SizedBox(
                    height: 200,
                    child: Center(child: Text('No Image Available')),
                  ),

            // Padding konten
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Berita
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Author dan Tanggal
                  Row(
                    children: [
                      if (author.isNotEmpty) ...[
                        Text(
                          "By $author",
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Text(
                        _formatDate(publishedAt),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Deskripsi Berita
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    content,
                    style: const TextStyle(fontSize: 16),
                  ),

                  // Sumber Berita
                  GestureDetector(
                    onTap: () {
                      if (url.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("External Link"),
                            content: const Text(
                                "You will be redirected to the original news website."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  // Launch URL (require `url_launcher` package)
                                },
                                child: const Text("Open"),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Text(
                      "Read more on Axios",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
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
