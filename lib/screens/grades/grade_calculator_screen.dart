import 'package:flutter/material.dart';
import 'dart:math';

class GradePart {
  String name;
  double? score; // null = ยังไม่ใส่
  double max;
  double weight; // 0–100 (รวมทุกส่วนแล้วแนะนำ ~100)
  GradePart({required this.name, this.score, this.max = 100, this.weight = 0});
  double get percent => (score == null || max <= 0) ? 0 : (score! / max) * 100;
}

class GradeClass {
  String name;
  double target; // เป้าหมายเป็น %
  List<GradePart> parts;
  GradeClass({required this.name, this.target = 90, List<GradePart>? parts})
      : parts = parts ?? [];
}

class GradeCalculatorScreen extends StatefulWidget {
  const GradeCalculatorScreen({super.key});
  @override
  State<GradeCalculatorScreen> createState() => _GradeCalculatorScreenState();
}

class _GradeCalculatorScreenState extends State<GradeCalculatorScreen> {
  final List<GradeClass> classes = [
    GradeClass(
      name: 'Chemistry',
      target: 90,
      parts: [
        GradePart(name: 'Exam 1', score: 86, max: 100, weight: 25),
        GradePart(name: 'Exam 2', score: 79, max: 100, weight: 25),
        GradePart(name: 'Final Exam', score: null, max: 100, weight: 30),
        GradePart(name: 'Labs', score: 97, max: 100, weight: 10),
        GradePart(name: 'Homework', score: 100, max: 100, weight: 10),
      ],
    ),
  ];

  int selected = 0;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 800;
    return Scaffold(
      appBar: AppBar(title: const Text('Grades')),
      body: wide
          ? Row(
              children: [
                SizedBox(width: 360, child: _buildClassList()),
                const VerticalDivider(width: 1),
                Expanded(
                    child: _buildDetailPane(
                        context, classes.isEmpty ? null : classes[selected])),
              ],
            )
          : _buildClassList(pushDetail: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addClassDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add class'),
      ),
    );
  }

  Widget _buildClassList({bool pushDetail = false}) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
      itemCount: classes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (ctx, i) {
        final gc = classes[i];
        final current = _weightedPercent(gc);
        return Dismissible(
          key: ValueKey(gc.name + i.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.red.shade400,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            setState(() {
              classes.removeAt(i);
              if (selected >= classes.length)
                selected = max(0, classes.length - 1);
            });
          },
          child: Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange.shade200,
                child: Text('${current.toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 12)),
              ),
              title: Text(gc.name),
              subtitle: Text('Target ${gc.target.toStringAsFixed(0)}%'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _renameClassDialog(i),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDeleteClass(i),
                  ),
                ],
              ),
              onTap: () {
                if (pushDetail) {
                  Navigator.of(ctx).push(MaterialPageRoute(
                      builder: (_) => _ClassDetailPage(
                            gc: gc,
                            onChanged: () => setState(() {}),
                          )));
                } else {
                  setState(() => selected = i);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailPane(BuildContext context, GradeClass? gc) {
    if (gc == null) {
      return const Center(child: Text('No class. Tap "Add class"'));
    }
    return _ClassDetail(gc: gc, onChanged: () => setState(() {}));
  }

  void _addClassDialog() {
    final name = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New class'),
        content: TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Class name')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () {
                if (name.text.trim().isEmpty) return;
                setState(() {
                  classes.add(GradeClass(name: name.text.trim(), target: 90));
                  selected = classes.length - 1;
                });
                Navigator.pop(context);
              },
              child: const Text('Add')),
        ],
      ),
    );
  }

  void _renameClassDialog(int i) {
    final name = TextEditingController(text: classes[i].name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename class'),
        content: TextField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Class name')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () {
                setState(() => classes[i].name = name.text.trim().isEmpty
                    ? classes[i].name
                    : name.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Save')),
        ],
      ),
    );
  }

  void _confirmDeleteClass(int i) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete class?'),
        content:
            Text('This will remove "${classes[i].name}" and all its parts.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton.tonal(
            onPressed: () {
              setState(() {
                classes.removeAt(i);
                if (selected >= classes.length)
                  selected = max(0, classes.length - 1);
              });
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  double _weightedPercent(GradeClass gc) {
    final w = gc.parts.fold<double>(0, (s, e) => s + e.weight);
    if (w <= 0) return 0;
    double sum = 0;
    for (final p in gc.parts) {
      final pct =
          (p.score == null || p.max <= 0) ? 0 : (p.score! / p.max) * 100;
      sum += pct * (p.weight / w);
    }
    return sum;
  }
}

class _ClassDetail extends StatefulWidget {
  final GradeClass gc;
  final VoidCallback onChanged;
  const _ClassDetail({required this.gc, required this.onChanged});

  @override
  State<_ClassDetail> createState() => _ClassDetailState();
}

class _ClassDetailState extends State<_ClassDetail> {
  @override
  Widget build(BuildContext context) {
    final current = _weightedPercent(widget.gc);
    return Column(
      children: [
        _header(current),
        Expanded(child: _partsList()),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _addPartDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add part'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(double current) {
    final needInfo = _firstNeed(widget.gc, widget.gc.target);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('current grade'),
                      Text('${current.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w800,
                          )),
                    ]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        const Text('target grade'),
                        IconButton(
                          tooltip: 'Edit target',
                          icon: const Icon(Icons.edit),
                          onPressed: _editTargetDialog,
                        ),
                      ]),
                      Text('${widget.gc.target.toStringAsFixed(0)}%',
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w800)),
                    ]),
              ),
            ],
          ),
        ),
      ),
    ).copyWith(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: needInfo == null
                  ? const SizedBox.shrink()
                  : Chip(
                      label: Text(
                          '${needInfo.$1}  need ${needInfo.$2.toStringAsFixed(0)}%'),
                      backgroundColor: Colors.green.shade50,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _partsList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      itemCount: widget.gc.parts.length,
      itemBuilder: (ctx, i) {
        final p = widget.gc.parts[i];
        final need = _neededForPart(widget.gc, p, widget.gc.target);
        final right = (p.score != null)
            ? 'got ${p.score!.toStringAsFixed(0)} / ${p.max.toStringAsFixed(0)}'
            : (need == null ? '—' : 'need ${need.toStringAsFixed(0)}%');
        return Dismissible(
          key: ValueKey('${p.name}-$i'),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.red.shade400,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            setState(() => widget.gc.parts.removeAt(i));
            widget.onChanged();
          },
          child: Card(
            child: ListTile(
              title: Text(p.name),
              subtitle: Text('weight ${p.weight.toStringAsFixed(0)}%'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(right,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    tooltip: 'More',
                    onSelected: (v) {
                      if (v == 'edit') {
                        _editPartDialog(i);
                      } else if (v == 'delete') {
                        _confirmDeletePart(i);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                            leading: Icon(Icons.edit), title: Text('Edit')),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                            leading: Icon(Icons.delete_outline),
                            title: Text('Delete')),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () => _editPartDialog(i),
            ),
          ),
        );
      },
    );
  }

  void _addPartDialog() {
    final name = TextEditingController(text: 'New Part');
    final score = TextEditingController();
    final max = TextEditingController(text: '100');
    final weight = TextEditingController(text: '0');

    InputDecoration deco(String label, {String? hint, String? suffix}) =>
        InputDecoration(
          labelText: label,
          hintText: hint,
          floatingLabelBehavior:
              FloatingLabelBehavior.always, // ★ ป้องกัน label ทับค่า
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 14), // ★ เพิ่มระยะ
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          suffixText: suffix,
          filled: true,
          fillColor: Colors.grey.shade200,
        );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add part'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: name, decoration: deco('Name')),
              const SizedBox(height: 12),
              TextFormField(
                controller: score,
                decoration: deco('Score', hint: 'optional'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: max,
                decoration: deco('Max'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: weight,
                decoration: deco('Weight', suffix: '%'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final s = double.tryParse(score.text.trim());
              final m = double.tryParse(max.text.trim()) ?? 100;
              final w = double.tryParse(weight.text.trim()) ?? 0;
              setState(() => widget.gc.parts.add(GradePart(
                    name: name.text.trim(),
                    score: s,
                    max: m,
                    weight: w,
                  )));
              widget.onChanged();
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editPartDialog(int i) {
    final p = widget.gc.parts[i];
    final name = TextEditingController(text: p.name);
    final score =
        TextEditingController(text: p.score?.toStringAsFixed(0) ?? '');
    final max = TextEditingController(text: p.max.toStringAsFixed(0));
    final weight = TextEditingController(text: p.weight.toStringAsFixed(0));

    InputDecoration deco(String label, {String? hint, String? suffix}) =>
        InputDecoration(
          labelText: label,
          hintText: hint,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          suffixText: suffix,
          filled: true,
          fillColor: Colors.grey.shade200,
        );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit part'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: name, decoration: deco('Name')),
              const SizedBox(height: 12),
              TextFormField(
                controller: score,
                decoration: deco('Score', hint: 'leave blank = unknown'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: max,
                decoration: deco('Max'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: weight,
                decoration: deco('Weight', suffix: '%'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              setState(() {
                p.name = name.text.trim().isEmpty ? p.name : name.text.trim();
                p.score = score.text.trim().isEmpty
                    ? null
                    : double.tryParse(score.text.trim());
                p.max = double.tryParse(max.text.trim()) ?? p.max;
                p.weight = double.tryParse(weight.text.trim()) ?? p.weight;
              });
              widget.onChanged();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editTargetDialog() {
    final ctrl =
        TextEditingController(text: widget.gc.target.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Target grade (%)'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(suffixText: '%'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              setState(() => widget.gc.target =
                  double.tryParse(ctrl.text.trim()) ?? widget.gc.target);
              widget.onChanged();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePart(int i) {
    final name = widget.gc.parts[i].name;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete part?'),
        content: Text('Remove "$name" from ${widget.gc.name}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton.tonal(
            onPressed: () {
              setState(() => widget.gc.parts.removeAt(i));
              widget.onChanged();
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  double _weightedPercent(GradeClass gc) {
    final w = gc.parts.fold<double>(0, (s, e) => s + e.weight);
    if (w <= 0) return 0;
    double sum = 0;
    for (final p in gc.parts) {
      final pct =
          (p.score == null || p.max <= 0) ? 0 : (p.score! / p.max) * 100;
      sum += pct * (p.weight / w);
    }
    return sum;
  }

  // คืนชื่อส่วน + เปอร์เซ็นต์ที่ "ต้องได้" ของส่วนนั้น เพื่อให้ถึง target (คำนวณจากส่วนที่ยังไม่ใส่คะแนน ส่วนแรกที่หาได้)
  (String, double)? _firstNeed(GradeClass gc, double target) {
    for (final p in gc.parts) {
      if (p.score == null) {
        final need = _neededForPart(gc, p, target);
        if (need != null) return (p.name, need);
      }
    }
    return null;
  }

  // ถ้าต้องการให้ถึง target และ “ปล่อยให้ส่วน p ยังว่าง” ควรได้กี่ % ในส่วน p
  double? _neededForPart(GradeClass gc, GradePart p, double target) {
    final w = gc.parts.fold<double>(0, (s, e) => s + e.weight);
    if (w <= 0 || p.weight <= 0) return null;

    double known = 0;
    for (final e in gc.parts) {
      if (e == p) continue;
      final pct =
          (e.score == null || e.max <= 0) ? 0 : (e.score! / e.max) * 100;
      known += pct * (e.weight / w);
    }
    // target = known + r*(p.weight/w)  => r = (target - known) / (p.weight/w)
    final r = (target - known) / (p.weight / w);
    return r.isFinite ? r.clamp(0, 100) : null;
  }
}

// หน้าแยกสำหรับมือถือ (push)
class _ClassDetailPage extends StatelessWidget {
  final GradeClass gc;
  final VoidCallback onChanged;
  const _ClassDetailPage({required this.gc, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(gc.name)),
      body: _ClassDetail(gc: gc, onChanged: onChanged),
    );
  }
}

// helper: .copyWith สำหรับ Widget (เฉพาะตรง header ที่ต่อเพิ่ม Chip)
extension _CopyWith on Widget {
  Widget copyWith({Widget? child}) {
    if (this is Padding && child != null) {
      final p = this as Padding;
      return Column(
        children: [p, child],
      );
    }
    return this;
  }
}
