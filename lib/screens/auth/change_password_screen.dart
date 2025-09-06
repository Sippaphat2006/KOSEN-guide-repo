import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _ob1 = true, _ob2 = true, _ob3 = true, _busy = false;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  InputDecoration _deco(BuildContext ctx, String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            BorderSide(color: Theme.of(ctx).colorScheme.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: const Text('Change password'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'REGISTER',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              letterSpacing: 2,
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Current password
                    TextFormField(
                      controller: _current,
                      obscureText: _ob1,
                      decoration: _deco(context, 'Current password').copyWith(
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _ob1 = !_ob1),
                          icon: Icon(
                              _ob1 ? Icons.visibility_off : Icons.visibility),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Enter current password'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // New password
                    TextFormField(
                      controller: _new,
                      obscureText: _ob2,
                      decoration: _deco(context, 'New password').copyWith(
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _ob2 = !_ob2),
                          icon: Icon(
                              _ob2 ? Icons.visibility_off : Icons.visibility),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? 'Min 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Confirm new password
                    TextFormField(
                      controller: _confirm,
                      obscureText: _ob3,
                      decoration:
                          _deco(context, 'Confirm new password').copyWith(
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _ob3 = !_ob3),
                          icon: Icon(
                              _ob3 ? Icons.visibility_off : Icons.visibility),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Please confirm password';
                        if (v != _new.text) return 'Passwords do not match';
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 56,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _busy ? null : _onChangePassword,
                        child: _busy
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Change password',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first')),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      // 1) re-authenticate with current password
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _current.text.trim(),
      );
      await user.reauthenticateWithCredential(cred);

      // 2) update password
      await user.updatePassword(_new.text.trim());
      await user.reload();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
      Navigator.pop(context); // กลับหน้าก่อนหน้า
    } on FirebaseAuthException catch (e) {
      String msg = 'Change failed: ${e.code}';
      if (e.code == 'wrong-password') msg = 'Current password is incorrect';
      if (e.code == 'weak-password') msg = 'New password is too weak';
      if (e.code == 'requires-recent-login') {
        msg = 'Please sign in again and retry';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Change failed: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
