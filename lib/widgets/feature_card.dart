import 'package:flutter/material.dart';

class FeatureCard extends StatelessWidget {
  final Color color;
  final String title;
  final VoidCallback onTap;
  final IconData? icon;
  final String?
      assetIcon; // ใส่ path icon ของตัวเองได้ เช่น assets/icons/news.png

  const FeatureCard({
    super.key,
    required this.color,
    required this.title,
    required this.onTap,
    this.icon,
    this.assetIcon,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = (Theme.of(context).textTheme.titleMedium ??
            const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))
        .copyWith(color: Colors.white, height: 1.2);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          height: 140,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (assetIcon != null)
                  Image.asset(
                    assetIcon!,
                    width: 56,
                    height: 56,
                    errorBuilder: (_, __, ___) => Icon(
                        icon ?? Icons.apps_rounded,
                        size: 56,
                        color: Colors.white),
                  )
                else
                  Icon(icon ?? Icons.apps_rounded,
                      size: 56, color: Colors.white),
                const SizedBox(height: 10),
                Text(title, textAlign: TextAlign.center, style: titleStyle),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
