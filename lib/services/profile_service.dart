import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class ProfileService {
  final _db = FirebaseFirestore.instance;

  Future<void> upsert(UserProfile p) async {
    await _db.collection('users').doc(p.uid).set({
      'email': p.email,
      'firstName': p.firstName,
      'lastName': p.lastName,
      'year': p.year,
      'room': p.room,
      'department': p.department,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<UserProfile?> watch(String uid) => _db
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((d) => d.exists && d.data() != null
          ? UserProfile.fromMap(d.id, d.data()!)
          : null);

  Future<UserProfile?> getOnce(String uid) async {
    final d = await _db.collection('users').doc(uid).get();
    if (!d.exists || d.data() == null) return null;
    return UserProfile.fromMap(d.id, d.data()!);
  }
}
