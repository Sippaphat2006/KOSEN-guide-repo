import 'package:flutter/material.dart';
import '../logic/news_repo.dart';
import '../models/news_item.dart';
import 'news_detail_screen.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({super.key});
  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final _repo = NewsRepo();
  final _search = TextEditingController();
  String _activeTag = 'All';
  List<NewsItem> _all = [];
  List<NewsItem> _view = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final xs = await _repo.fetchNews();
    setState(() {
      _all = xs;
      _applyFilter();
      _loading = false;
    });
  }

  void _applyFilter() {
    String q = _search.text.trim().toLowerCase();
    setState(() {
      _view = _all.where((e) {
        final tagOk = (_activeTag == 'All') ||
            e.tags
                .map((t) => t.toLowerCase())
                .contains(_activeTag.toLowerCase());
        final qOk = q.isEmpty ||
            e.title.toLowerCase().contains(q) ||
            e.summary.toLowerCase().contains(q);
        return tagOk && qOk;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('News & Announcement')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _SearchBar(
                      controller: _search, onChanged: (_) => _applyFilter()),
                  const SizedBox(height: 8),
                  _TagsRow(
                    tags: const ['All', 'General', 'Announcement'],
                    active: _activeTag,
                    onTap: (t) {
                      setState(() => _activeTag = t);
                      _applyFilter();
                    },
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _view.isEmpty
                        ? const Center(child: Text('No news found'))
                        : ListView.separated(
                            itemCount: _view.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final n = _view[i];
                              return _NewsCard(
                                  item: n,
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              NewsDetailScreen(item: n),
                                        ));
                                  });
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
      ),
    );
  }
}

class _TagsRow extends StatelessWidget {
  final List<String> tags;
  final String active;
  final ValueChanged<String> onTap;
  const _TagsRow(
      {required this.tags, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: tags.map((t) {
        final sel = (t == active);
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            label: Text(t),
            selected: sel,
            onSelected: (_) => onTap(t),
          ),
        );
      }).toList(),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsItem item;
  final VoidCallback onTap;
  const _NewsCard({required this.item, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(item.imageAssetPath,
                    height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
              const SizedBox(height: 8),
              Text(item.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 4),
              Text(item.summary, maxLines: 3, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(
                children: [
                  Flexible(
                    child: Text(item.tags.join(', '),
                        style: TextStyle(
                            color: Colors.grey.shade700, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month, size: 14),
                      const SizedBox(width: 4),
                      Text(_fmtDate(item.date),
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmtDate(DateTime d) => '${d.month}/${d.day}/${d.year}';
}
