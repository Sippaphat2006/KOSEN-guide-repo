import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AcademicEvent {
  final String title;
  final DateTime start;
  final DateTime? end; // null = one-day
  final Color color; // theme color by category
  final String? tag; // e.g., LHR / CLUB

  const AcademicEvent({
    required this.title,
    required this.start,
    this.end,
    required this.color,
    this.tag,
  });

  bool get isRange => end != null;
  bool occursOn(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = isRange ? DateTime(end!.year, end!.month, end!.day) : s;
    return (day.isAtSameMomentAs(s) || day.isAtSameMomentAs(e)) ||
        (day.isAfter(s) && day.isBefore(e));
  }

  String get dateLabel {
    final df = DateFormat('d MMM');
    if (!isRange) return df.format(start);
    return '${df.format(start)} – ${df.format(end!)}';
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // สีอ้างอิงธีมฟ้า/ส้ม + เสริมเขียว/แดงสำหรับช่วงสอบ
  late final Color blue = Theme.of(context).colorScheme.primary;
  final Color orange = const Color(0xFFFF9800);
  final Color green = const Color(0xFF4CAF50);
  final Color red = const Color(0xFFE53935);

  late final List<AcademicEvent> events = [
    AcademicEvent(
      title: 'Start 2nd-Semester AY2025',
      start: DateTime(2025, 11, 3),
      color: blue,
      tag: 'LHR',
    ),
    AcademicEvent(
      title: 'Wednesday Class',
      start: DateTime(2025, 12, 8),
      color: blue,
      tag: 'CLUB',
    ),
    AcademicEvent(
      title: 'Friday Class',
      start: DateTime(2025, 12, 30),
      color: blue,
      tag: 'LHR',
    ),
    AcademicEvent(
      title: 'Midterm Exam',
      start: DateTime(2026, 1, 5),
      end: DateTime(2026, 1, 12),
      color: green,
    ),
    AcademicEvent(
      title: 'New Year Party, Market, Teacher’s Day, KOSEN-KMITL Ambassador',
      start: DateTime(2026, 1, 16),
      color: orange,
      tag: 'Club/LHR',
    ),
    AcademicEvent(
      title: 'Friday Class',
      start: DateTime(2026, 2, 4),
      color: blue,
      tag: 'LHR',
    ),
    AcademicEvent(
      title: 'Valen Vibes (Club)',
      start: DateTime(2026, 2, 12),
      color: orange,
      tag: 'Club',
    ),
    AcademicEvent(
      title: 'Final Exam',
      start: DateTime(2026, 3, 9),
      end: DateTime(2026, 3, 17),
      color: red,
    ),
    AcademicEvent(
      title: 'End 2nd-Semester',
      start: DateTime(2026, 3, 21),
      color: red,
      tag: 'LHR',
    ),
  ];

  // เดือนที่ให้เลื่อนดู: Oct-2025 → Mar-2026
  final List<DateTime> months = List<DateTime>.generate(
    6,
    (i) => DateTime(2025, 10 + i, 1),
  );

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Academic Calendar'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Month View'),
          ]),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(primary: primary, events: events),
            _MonthTab(events: events, months: months),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final Color primary;
  final List<AcademicEvent> events;
  const _OverviewTab({required this.primary, required this.events});

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<AcademicEvent>>{};
    final headerFmt = DateFormat('MMMM yyyy');

    for (final e in events) {
      final key = headerFmt.format(e.start);
      grouped.putIfAbsent(key, () => []).add(e);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _heroHeader(primary),
        const SizedBox(height: 12),
        _legend(context),
        const SizedBox(height: 8),
        for (final month in grouped.keys)
          _monthSection(context, month, grouped[month]!),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _heroHeader(Color primary) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: primary, width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          'AY2025 • Semester 2',
          style: TextStyle(
            color: primary,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
      ),
    );
  }

  Widget _legend(BuildContext context) {
    final swatch = [
      _legendDot(context,
          color: Theme.of(context).colorScheme.primary, label: 'Class/Term'),
      _legendDot(context, color: const Color(0xFF4CAF50), label: 'Midterm'),
      _legendDot(context, color: const Color(0xFFE53935), label: 'Final/End'),
      _legendDot(context, color: const Color(0xFFFF9800), label: 'Activities'),
    ];
    return Wrap(spacing: 12, runSpacing: 8, children: swatch);
  }

  Widget _legendDot(BuildContext context,
      {required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _monthSection(
      BuildContext context, String title, List<AcademicEvent> list) {
    final df = DateFormat('EEE d MMM');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                )),
        const SizedBox(height: 8),
        ...list.map((e) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: e.color,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.event),
                ),
                title: Text(e.title),
                subtitle: Text(e.isRange ? e.dateLabel : df.format(e.start)),
                trailing: (e.tag != null) ? Chip(label: Text(e.tag!)) : null,
              ),
            )),
      ],
    );
  }
}

class _MonthTab extends StatefulWidget {
  final List<AcademicEvent> events;
  final List<DateTime> months;
  const _MonthTab({required this.events, required this.months});

  @override
  State<_MonthTab> createState() => _MonthTabState();
}

class _MonthTabState extends State<_MonthTab> {
  final PageController _pc = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _monthPagerHeader(context),
        Expanded(
          child: PageView.builder(
            controller: _pc,
            itemCount: widget.months.length,
            itemBuilder: (_, i) {
              final m = widget.months[i];
              return _MonthGrid(
                month: m,
                events: widget.events,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _monthPagerHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _pc.previousPage(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut),
          ),
          Expanded(
            child: Center(
              child: AnimatedBuilder(
                animation: _pc,
                builder: (_, __) {
                  final page = (_pc.hasClients ? _pc.page : 0.0) ?? 0.0;
                  final idx = page.round().clamp(0, widget.months.length - 1);
                  final m = widget.months[idx];
                  return Text(DateFormat('MMMM yyyy').format(m),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ));
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _pc.nextPage(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut),
          ),
        ],
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime month; // first day of month
  final List<AcademicEvent> events;
  const _MonthGrid({required this.month, required this.events});

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final firstWeekday = first.weekday; // 1=Mon..7=Sun
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

    // เราจะเริ่มกริดตั้งแต่วันจันทร์ของสัปดาห์แรก
    final startOffset = (firstWeekday - DateTime.monday) % 7;
    final totalCells = 42; // 6 rows * 7 cols
    final firstCellDate = first.subtract(Duration(days: startOffset));

    final headerStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        );

    final weekdayLabels = const [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun'
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        children: [
          // weekday header
          Row(
            children: [
              for (final w in weekdayLabels)
                Expanded(
                  child: Center(child: Text(w, style: headerStyle)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemCount: totalCells,
              itemBuilder: (ctx, i) {
                final d = firstCellDate.add(Duration(days: i));
                final inThisMonth = d.month == month.month;
                final dayEvents = events.where((e) => e.occursOn(d)).toList();

                final bg = _cellBackground(dayEvents, inThisMonth);

                return GestureDetector(
                  onTap: dayEvents.isEmpty
                      ? null
                      : () => _showDayEvents(ctx, d, dayEvents),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: inThisMonth
                            ? Colors.grey.shade300
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 6,
                          right: 8,
                          child: Opacity(
                            opacity: inThisMonth ? 1 : 0.35,
                            child: Text(
                              '${d.day}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        if (dayEvents.isNotEmpty)
                          Positioned(
                            left: 8,
                            bottom: 6,
                            right: 8,
                            child: _eventDots(dayEvents),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color? _cellBackground(List<AcademicEvent> dayEvents, bool inThisMonth) {
    if (dayEvents.isEmpty) return null;
    // ถ้ามีช่วงสอบ (สีแรง) ให้จางพื้นหลังเพื่อเน้น
    final hasFinal =
        dayEvents.any((e) => e.color.value == const Color(0xFFE53935).value);
    final hasMid =
        dayEvents.any((e) => e.color.value == const Color(0xFF4CAF50).value);
    if (hasFinal) return const Color(0xFFFFEBEE); // red-50
    if (hasMid) return const Color(0xFFE8F5E9); // green-50
    return inThisMonth ? const Color(0xFFE3F2FD) : const Color(0xFFEDE7F6);
  }

  Widget _eventDots(List<AcademicEvent> dayEvents) {
    // แสดง dot ตามจำนวนประเภทของสี (สูงสุด 3 จุด)
    final colors = <int, Color>{};
    for (final e in dayEvents) {
      colors[e.color.value] = e.color;
      if (colors.length >= 3) break;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: colors.values
          .map((c) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(color: c, shape: BoxShape.circle),
              ))
          .toList(),
    );
  }

  void _showDayEvents(
      BuildContext context, DateTime d, List<AcademicEvent> list) {
    final df = DateFormat('EEEE, d MMM yyyy');
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(df.format(d),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      )),
              const SizedBox(height: 8),
              ...list.map((e) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: e.color,
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.event),
                    ),
                    title: Text(e.title),
                    subtitle: Text(e.isRange ? e.dateLabel : ''),
                    trailing:
                        (e.tag != null) ? Chip(label: Text(e.tag!)) : null,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
