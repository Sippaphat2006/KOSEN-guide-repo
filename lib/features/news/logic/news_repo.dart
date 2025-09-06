import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import '../models/news_item.dart';

class NewsRepo {
  static const String kosenArticleUrl =
      'https://www.kosen.kmitl.ac.th/en/articles/KOSEN-KMITL-Industrial-Forum-2025-ENG';

  // พยายามดึงข้อมูลจากเว็บ ถ้าไม่ได้ให้คืนค่า fallback
  Future<List<NewsItem>> fetchNews() async {
    try {
      final item = await _fetchIndustrialForum();
      return [item];
    } catch (_) {
      return [_fallbackIndustrialForum()];
    }
  }

  // ------- private -------

  Future<NewsItem> _fetchIndustrialForum() async {
    final r = await http
        .get(Uri.parse(kosenArticleUrl))
        .timeout(const Duration(seconds: 8));
    if (r.statusCode != 200) throw Exception('status ${r.statusCode}');

    final doc = html.parse(utf8.decode(r.bodyBytes));

    // พยายามดึง title
    final title = (doc.querySelector('h1')?.text ??
            doc.querySelector('title')?.text ??
            'KOSEN-KMITL Industrial Forum 2025')
        .trim();

    // พยายามดึงวันที่ (มักอยู่ใน time, .date, meta ฯลฯ) ไม่เจอจะ default เป็น 2025-06-20
    String dateText = doc.querySelector('time')?.attributes['datetime'] ??
        doc.querySelector('time')?.text ??
        doc.querySelector('.date')?.text ??
        '';
    DateTime date = _tryParseDate(dateText) ?? DateTime(2025, 6, 20);

    // Summary: ย่อบรรทัดแรก ๆ ของบทความ
    final paragraphs =
        doc.querySelectorAll('article p, .article p, .content p');
    final pText = paragraphs
        .map((e) => e.text.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final summary = (pText.isNotEmpty)
        ? _truncate(pText.first, 180)
        : 'An international event aimed at strengthening collaboration between the education and industrial sectors.';

    final content =
        (pText.isNotEmpty) ? pText.join('\n\n') : _fallbackContent();

    return NewsItem(
      id: 'industrial_forum_2025',
      title: title,
      summary: summary,
      content: content,
      date: date,
      tags: const ['Announcement', 'General'],
      imageAssetPath: 'assets/picture/Industrial Forum 2025.png',
    );
  }

  NewsItem _fallbackIndustrialForum() {
    return NewsItem(
      id: 'industrial_forum_2025',
      title: 'KOSEN-KMITL Industrial Forum 2025',
      summary:
          'An international event aimed at strengthening collaboration between the education and industrial sectors.',
      content: _fallbackContent(),
      date: DateTime(2025, 6, 20),
      tags: const ['Announcement', 'General'],
      imageAssetPath: 'assets/picture/Industrial Forum 2025.png',
    );
  }

  static String _truncate(String s, int n) =>
      (s.length <= n) ? s : s.substring(0, n).trimRight() + '...';

  static DateTime? _tryParseDate(String raw) {
    if (raw.isEmpty) return null;
    // รูปแบบง่าย ๆ ที่เจอบ่อย: 2025-06-20, June 20, 2025, 20 Jun 2025
    final tryList = <String>[
      raw,
      // เดิม: replaceAll(..., (m) => '${m[1]} ')
      raw.replaceAllMapped(
        RegExp(r'(\d{1,2})(st|nd|rd|th)\b', caseSensitive: false),
        (m) => m.group(1)!, // ตัด st/nd/rd/th ออก -> เหลือเลขวันอย่างเดียว
      ),
    ];

    // ดึงตัวเลขแบบ day month year
    final m = RegExp(
            r'(\d{1,2})\s*(Jan|Feb|Mar|Apr|May|Jun|July|Jul|Aug|Sep|Oct|Nov|Dec)\w*\s*(\d{4})',
            caseSensitive: false)
        .firstMatch(raw);
    if (m != null) {
      final day = int.parse(m.group(1)!);
      final mon = _monthStrToInt(m.group(2)!);
      final year = int.parse(m.group(3)!);
      return DateTime(year, mon, day);
    }
    return null;
  }

  static int _monthStrToInt(String s) {
    const map = {
      'jan': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'july': 7,
      'aug': 8,
      'sep': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12
    };
    return map[s.toLowerCase()] ?? 1;
  }

  static String _fallbackContent() {
    return 'KOSEN-KMITL Industrial Forum 2025 is an international forum that builds a bridge between education and the industrial sector. '
        'The event features keynote sessions, panel talks, and showcases from partner companies to strengthen collaboration, internships, and future workforce development.';
  }
}
