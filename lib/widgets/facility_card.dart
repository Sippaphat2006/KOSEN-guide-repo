import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kosen_guide/models/facility.dart';

class FacilityCard extends StatelessWidget {
  final Facility f;
  const FacilityCard({super.key, required this.f});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(f.name, style: Theme.of(context).textTheme.titleMedium),
            if (f.description != null) Text(f.description!),
            if (f.hours != null) Text('Hours: ${f.hours}'),
            if (f.contact != null) Text('Contact: ${f.contact}'),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => _openGoogleMaps(f.lat, f.lng, f.name),
              icon: const Icon(Icons.map),
              label: const Text('Open in Google Maps'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps(double lat, double lng, String label) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=${Uri.encodeComponent(label)}',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }
}
