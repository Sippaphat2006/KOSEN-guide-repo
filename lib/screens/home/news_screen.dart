import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../services/news_service.dart';
import '../../models/news_item.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<NewsItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<NewsService>().fetch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News & Announcements')),
      body: FutureBuilder<List<NewsItem>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Could not fetch news. You can open the website instead.',
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () => _open('http://www.kosen.kmitl.ac.th/en'),
                      child: const Text('Open kosen.kmitl.ac.th'),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (ctx, i) {
              final n = items[i];
              return Card(
                child: ListTile(
                  title: Text(n.title),
                  subtitle: Text(
                    n.date?.toIso8601String().split('T').first ?? n.url,
                  ),
                  onTap: () => _open(n.url),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open link')));
    }
  }
}
