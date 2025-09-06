class NewsItem {
  final String title;
  final String url;
  final String? imageUrl;
  final DateTime? date;

  NewsItem({required this.title, required this.url, this.imageUrl, this.date});
}
