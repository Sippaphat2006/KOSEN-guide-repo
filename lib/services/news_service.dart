import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart'
    as html_parser; // ต้องมีแพ็กเกจ html ใน pubspec
import 'package:intl/intl.dart';
import '../models/news_item.dart';

class NewsService {
  static const String englishRoot = 'http://www.kosen.kmitl.ac.th/en';
  static const String thaiNews =
      'http://www.kosen.kmitl.ac.th/articles?category=news';

  Future<List<NewsItem>> fetch() async {
    final List<NewsItem> items = [];

    Future<void> scrape(String url) async {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return;

      final doc = html_parser.parse(utf8.decode(res.bodyBytes));
      final cards = doc.querySelectorAll('article, .article, .card, .post');

      for (final c in cards) {
        final a = c.querySelector('a');
        if (a == null) continue;
        final link = a.attributes['href'] ?? '';
        final absolute = _absoluteUrl(url, link);
        if (absolute == null) continue; // <- กัน null

        final title =
            (a.text.trim().isNotEmpty ? a.text.trim() : c.text.trim());
        if (title.isEmpty) continue;

        final img = c.querySelector('img')?.attributes['src'];
        DateTime? date;
        final dateText = c.querySelector('time')?.text.trim() ??
            c.querySelector('.date, .posted-on, .time')?.text.trim();
        if (dateText != null && dateText.isNotEmpty) {
          try {
            date = DateFormat.yMMMMd().parse(dateText);
          } catch (_) {}
        }

        items.add(NewsItem(
          title: title,
          url: absolute,
          imageUrl: _absoluteUrl(url, img),
          date: date,
        ));
      }
    }

    await scrape(englishRoot);
    if (items.isEmpty) {
      await scrape(thaiNews);
    }

    final seen = <String>{};
    final unique = <NewsItem>[];
    for (final it in items) {
      if (seen.add(it.url)) unique.add(it);
    }
    return unique.take(30).toList();
  }

  String? _absoluteUrl(String base, String? maybe) {
    if (maybe == null || maybe.isEmpty) return null;
    if (maybe.startsWith('http')) return maybe;
    final uri = Uri.parse(base);
    if (maybe.startsWith('/')) return '${uri.scheme}://${uri.host}$maybe';
    return '${uri.scheme}://${uri.host}/${maybe.replaceAll('./', '')}';
  }
}
