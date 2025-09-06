// ...imports เดิม...
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:kosen_guide/models/facility.dart';
import 'package:kosen_guide/widgets/facility_card.dart';
import 'package:latlong2/latlong.dart';

class CampusMapScreen extends StatefulWidget {
  const CampusMapScreen({super.key});
  @override
  State<CampusMapScreen> createState() => _CampusMapScreenState();
}

class _CampusMapScreenState extends State<CampusMapScreen> {
  // ★ เพิ่มคอนสแตนต์ Dorm
  static const Facility _kmitlDorm = Facility(
    id: 'kmitl_dorm',
    name: 'KMITL Student Dormitory',
    lat: 13.7292445,
    lng: 100.7739666,
    description: 'On-campus housing at KMITL',
  );

  List<Facility> facilities = const [];

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    try {
      final raw = await rootBundle.loadString('assets/data/facilities.json');
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final loaded = list.map((m) => Facility.fromJson(m)).toList();

      // ★ ใส่ Dorm เข้าไป ถ้ายังไม่มี (กันซ้ำด้วยชื่อ)
      final hasDorm = loaded.any((f) =>
          f.name.toLowerCase().contains('kmitl') &&
          f.name.toLowerCase().contains('dorm'));
      facilities = [
        ...loaded,
        if (!hasDorm) _kmitlDorm,
      ];
    } catch (_) {
      // ถ้าอ่าน assets ไม่ได้ ให้แสดงเฉพาะ Dorm อย่างน้อยไม่ว่างเปล่า
      facilities = [_kmitlDorm];
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final center = facilities.isNotEmpty
        ? LatLng(facilities.first.lat, facilities.first.lng)
        : const LatLng(13.7317, 100.7786);

    return Scaffold(
      appBar: AppBar(title: const Text('Campus Map')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: FlutterMap(
              options: MapOptions(initialCenter: center, initialZoom: 16),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'kosen_guide',
                ),
                MarkerLayer(
                  markers: facilities
                      .map<Marker>((f) => Marker(
                            point: LatLng(f.lat, f.lng),
                            width: 40,
                            height: 40,
                            child: IconButton(
                              onPressed: () => _showFacility(context, f),
                              icon: Icon(
                                Icons.location_on,
                                size: 36,
                                color: f.id == 'kmitl_dorm'
                                    ? Colors.orange // ★ ให้ Dorm เป็นสีส้มเด่น
                                    : Colors.redAccent,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: ListView(
              children:
                  facilities.map<Widget>((f) => FacilityCard(f: f)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showFacility(BuildContext context, Facility f) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(12), child: FacilityCard(f: f)),
      ),
    );
  }
}
