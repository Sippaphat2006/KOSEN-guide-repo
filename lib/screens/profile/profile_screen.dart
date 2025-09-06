import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../models/user_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: StreamBuilder<UserProfile?>(
        stream: context.read<ProfileService>().watch(uid),
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.active) {
            return const Center(child: CircularProgressIndicator());
          }

          final p = snap.data;
          final email =
              FirebaseAuth.instance.currentUser?.email ?? p?.email ?? '—';

          // ใช้ชื่อจาก Firestore ก่อน (firstName + lastName) -> ถ้าไม่มีใช้ displayName -> ถ้าไม่มีใช้หน้าอีเมล
          final fullNameFromProfile =
              (p?.fullName.isNotEmpty ?? false) ? p!.fullName : null;
          final displayName = fullNameFromProfile ??
              (FirebaseAuth.instance.currentUser?.displayName?.trim()) ??
              email.split('@').first;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              const SizedBox(height: 8),
              // Avatar + Name
              Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.grey.shade300,
                    child:
                        const Icon(Icons.person, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text(
                'Personal Information',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),

              // Card กลมมนแบบในภาพ
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _infoRow('Email', email),
                    _divider(),
                    _infoRow('Class', '${p?.year ?? '-'} / ${p?.room ?? '-'}',
                        trailingLabel: 'Year/Room'),
                    _divider(),
                    _infoRow('Department', p?.department ?? '—'),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'Utilities',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),

              // Utilities card
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock_outline),
                      title: const Text('Reset password'),
                      onTap: () =>
                          Navigator.of(context).pushNamed('/change-password'),
                    ),
                    _divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Logout'),
                      onTap: () => context.read<AuthService>().signOut(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value, {String? trailingLabel}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          if (trailingLabel != null)
            Text(trailingLabel,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
        height: 1,
        color: Colors.grey.shade300,
        indent: 16,
        endIndent: 16,
      );
}
