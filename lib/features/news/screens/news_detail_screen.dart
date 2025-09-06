import 'package:flutter/material.dart';
import '../models/news_item.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsItem item;
  const NewsDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News & Announcement')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            Text(item.title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(item.imageAssetPath, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            Text('----- info -----',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700)),
            const SizedBox(height: 12),
            Text(item.content),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.calendar_month, size: 16),
                const SizedBox(width: 6),
                Text('${item.date.month}/${item.date.day}/${item.date.year}'),
                const Spacer(),
                Text(item.tags.join('  •  '),
                    style: TextStyle(color: Colors.grey.shade700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
