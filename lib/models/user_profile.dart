class UserProfile {
  final String uid;
  final String email;

  // ใหม่
  final String? firstName;
  final String? lastName;

  final int year; // 1..5
  final int room; // 1..2
  final String department; // Mechatronic | Computer

  const UserProfile({
    required this.uid,
    required this.email,
    this.firstName,
    this.lastName,
    required this.year,
    required this.room,
    required this.department,
  });

  String get fullName {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    return (f.isEmpty && l.isEmpty) ? '' : '$f $l'.trim();
  }

  Map<String, dynamic> toMap() => {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'year': year,
        'room': room,
        'department': department,
        'createdAt': DateTime.now().toUtc(),
        'updatedAt': DateTime.now().toUtc(),
      };

  factory UserProfile.fromMap(String uid, Map<String, dynamic> m) {
    // เผื่อเอกสารเก่าเคยเก็บเป็น 'name' อย่างเดียว
    String? fn = m['firstName'] as String?;
    String? ln = m['lastName'] as String?;
    if ((fn == null && ln == null) && m['name'] != null) {
      final parts = (m['name'] as String).trim().split(RegExp(r'\s+'));
      if (parts.isNotEmpty) fn = parts.first;
      if (parts.length > 1) ln = parts.sublist(1).join(' ');
    }

    return UserProfile(
      uid: uid,
      email: (m['email'] ?? '') as String,
      firstName: fn,
      lastName: ln,
      year: (m['year'] ?? 1) as int,
      room: (m['room'] ?? 1) as int,
      department: (m['department'] ?? 'Mechatronic') as String,
    );
  }
}
