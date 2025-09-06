import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kosen_guide/widgets/feature_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the website')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.headlineMedium?.copyWith(
          color: const Color(0xFF1E88E5), // ฟ้า
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          children: [
            // Header กล่องกรอบตามดีไซน์
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(child: Text('KOSEN guide', style: titleStyle)),
            ),
            const SizedBox(height: 20),

            // การ์ด 1: News
            FeatureCard(
              color: const Color(0xFFFF8A80),
              title: 'News &\nAnnouncement',
              icon: Icons.campaign_rounded,
              onTap: () => Navigator.of(context).pushNamed('/news'),
            ),
            const SizedBox(height: 16),

            // การ์ด 2: Calendar
            FeatureCard(
              color: const Color(0xFFB2FF59),
              title: 'Academic\nCalendar',
              icon: Icons.calendar_month_rounded,
              onTap: () => Navigator.of(context).pushNamed('/calendar'),
            ),
            const SizedBox(height: 16),

            // การ์ด 3: About -> เปิดเว็บ
            FeatureCard(
              color: const Color(0xFF9FA8DA),
              title: 'About KOSEN',
              icon: Icons.info_rounded,
              onTap: () =>
                  _openUrl(context, 'https://www.kosen.kmitl.ac.th/en'),
            ),
          ],
        ),
      ),
    );
  }
}
