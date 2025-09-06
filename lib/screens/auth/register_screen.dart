import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/profile_service.dart';
import '../../models/user_profile.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // ใหม่: ชื่อจริง/นามสกุล
  final _first = TextEditingController();
  final _last = TextEditingController();

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  int _year = 1;
  int _room = 1;
  String _dept = 'Mechatronic';

  bool _ob1 = true, _ob2 = true, _busy = false;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  InputDecoration _deco(BuildContext ctx, String label) => InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade200,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              BorderSide(color: Theme.of(ctx).colorScheme.primary, width: 2),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: LayoutBuilder(
              builder: (ctx, cts) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: cts.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context)
                                  .pushReplacementNamed('/login'),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text('CANCEL'),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Text('Create Account',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                          color: primary,
                                          fontWeight: FontWeight.w800)),
                              const SizedBox(height: 8),
                              Text('REGISTER',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                          letterSpacing: 2,
                                          color: Colors.grey.shade600)),
                            ],
                          ),

                          // ===== ชื่อจริง/นามสกุล =====
                          Column(children: [
                            TextFormField(
                              controller: _first,
                              textInputAction: TextInputAction.next,
                              decoration: _deco(context, 'First name'),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Please enter first name'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _last,
                              textInputAction: TextInputAction.next,
                              decoration: _deco(context, 'Last name'),
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Please enter last name'
                                  : null,
                            ),
                          ]),

                          // ===== อีเมล/รหัสผ่าน =====
                          Column(children: [
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: _deco(context, 'Email'),
                              validator: (v) => (v == null || !v.contains('@'))
                                  ? 'Enter a valid email'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _password,
                              obscureText: _ob1,
                              textInputAction: TextInputAction.next,
                              decoration: _deco(context, 'Password').copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _ob1 = !_ob1),
                                  icon: Icon(_ob1
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                ),
                              ),
                              validator: (v) => (v == null || v.length < 6)
                                  ? 'Min 6 characters'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _confirm,
                              obscureText: _ob2,
                              decoration:
                                  _deco(context, 'Confirm password').copyWith(
                                suffixIcon: IconButton(
                                  onPressed: () => setState(() => _ob2 = !_ob2),
                                  icon: Icon(_ob2
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Please confirm password';
                                if (v != _password.text)
                                  return 'Passwords do not match';
                                return null;
                              },
                            ),
                          ]),

                          // ===== Year / Room / Department =====
                          Column(children: [
                            const SizedBox(height: 14),
                            Row(children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: _year,
                                  decoration: _deco(context, 'Year'),
                                  items: [1, 2, 3, 4, 5]
                                      .map((v) => DropdownMenuItem(
                                          value: v, child: Text('$v')))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _year = v ?? 1),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  value: _room,
                                  decoration: _deco(context, 'Room'),
                                  items: [1, 2]
                                      .map((v) => DropdownMenuItem(
                                          value: v, child: Text('$v')))
                                      .toList(),
                                  onChanged: (v) =>
                                      setState(() => _room = v ?? 1),
                                ),
                              ),
                            ]),
                            const SizedBox(height: 14),
                            DropdownButtonFormField<String>(
                              value: _dept,
                              decoration: _deco(context, 'Department'),
                              items: const ['Mechatronic', 'Computer']
                                  .map((v) => DropdownMenuItem(
                                      value: v, child: Text(v)))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _dept = v ?? 'Mechatronic'),
                            ),
                          ]),

                          SizedBox(
                            height: 56,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: _busy ? null : _onRegister,
                              child: _busy
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Text('Sign up',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _busy = true);
    try {
      // 1) สมัครด้วย Email/Password
      await context.read<AuthService>().register(
            _email.text.trim(),
            _password.text.trim(),
          );

      final user = FirebaseAuth.instance.currentUser!;
      final fullName = '${_first.text.trim()} ${_last.text.trim()}'.trim();

      // 2) อัปเดต displayName ใน Firebase Auth (ไว้ใช้ในอนาคต)
      await user.updateDisplayName(fullName);

      // 3) บันทึกโปรไฟล์ลง Firestore
      final profile = UserProfile(
        uid: user.uid,
        email: user.email ?? _email.text.trim(),
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        year: _year,
        room: _room,
        department: _dept,
      );
      await context.read<ProfileService>().upsert(profile);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/');
    } on FirebaseAuthException catch (e) {
      var msg = 'Register failed: ${e.code}';
      if (e.code == 'email-already-in-use')
        msg = 'This email is already in use';
      if (e.code == 'invalid-email') msg = 'Invalid email';
      if (e.code == 'weak-password') msg = 'Password is too weak';
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile save failed: ${e.message ?? e.code}')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
