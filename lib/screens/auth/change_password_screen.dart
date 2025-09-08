import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _newPwd = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  bool _ob1 = true, _ob2 = true, _ob3 = true;

  @override
  void dispose() {
    _current.dispose();
    _newPwd.dispose();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Change password')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
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
                          ? 'Please enter current password'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _newPwd,
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
                    const SizedBox(height: 14),
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
                          return 'Please confirm new password';
                        if (v != _newPwd.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 56,
                      child: FilledButton(
                        onPressed: _busy ? null : _onChange,
                        child: _busy
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Change password'),
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

  Future<void> _onChange() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await context.read<AuthService>().changePassword(
            _newPwd.text.trim(),
            currentPassword: _current.text.trim(),
            contextIfPrompt:
                context, // fallback prompt if the current password is wrong
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Password updated')));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final msg = context.read<AuthService>().friendlyError(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
