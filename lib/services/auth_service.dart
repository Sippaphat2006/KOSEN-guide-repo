import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  // ─────────────────────────────
  // OG auth methods
  // ─────────────────────────────
  Future<UserCredential> register(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  User? get currentUser => _auth.currentUser;

  /// Change password and handle `requires-recent-login` seamlessly.
  /// If [currentPassword] is provided, we re-auth silently; otherwise
  /// we show a minimal prompt (if [contextIfPrompt] is given).
  Future<void> changePassword(
    String newPassword, {
    String? currentPassword,
    BuildContext? contextIfPrompt,
  }) async {
    try {
      await _auth.currentUser!.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        final ok = await _ensureRecentLogin(
          currentPassword: currentPassword,
          contextIfPrompt: contextIfPrompt,
        );
        if (!ok) {
          throw FirebaseAuthException(
            code: 'reauth-cancelled',
            message: 'Re-authentication was cancelled',
          );
        }
        await _auth.currentUser!.updatePassword(newPassword); // retry
      } else {
        rethrow;
      }
    }
  }

  /// Ensure we have a recent login either by using the given password
  /// or prompting the user for it (if context provided).
  Future<bool> _ensureRecentLogin({
    String? currentPassword,
    BuildContext? contextIfPrompt,
  }) async {
    String? pwd = currentPassword;

    if ((pwd == null || pwd.isEmpty) && contextIfPrompt != null) {
      pwd = await _promptPassword(contextIfPrompt);
    }
    if (pwd == null || pwd.isEmpty) return false;

    return _reauthWithPassword(pwd);
  }

  Future<bool> _reauthWithPassword(String password) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) return false;

    final cred = EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(cred);
    return true;
  }

  Future<String?> _promptPassword(BuildContext context) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Re-authenticate'),
        content: TextField(
          controller: ctrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Enter your current password',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  // Map Firebase errors to user-friendly messages (optional helper)
  String friendlyError(Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-email':
          return 'Invalid email address';
        case 'user-not-found':
          return 'No account found for this email';
        case 'wrong-password':
          return 'Incorrect password';
        case 'email-already-in-use':
          return 'This email is already in use';
        case 'weak-password':
          return 'Password is too weak';
        case 'requires-recent-login':
          return 'Please confirm your password to continue';
        case 'reauth-cancelled':
          return 'Re-authentication was cancelled';
      }
      return e.message ?? e.code;
    }
    return e.toString();
  }

  Stream<User?> authState() => _auth.authStateChanges();
}
