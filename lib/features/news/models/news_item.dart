class NewsItem {
  final String id;
  final String title;
  final String summary;
  final String content;
  final DateTime date;
  final List<String> tags; // e.g. ["Announcement","General"]
  final String imageAssetPath; // local asset path

  const NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.date,
    required this.tags,
    required this.imageAssetPath,
  });
}
