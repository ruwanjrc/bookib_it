class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'customer' or 'vendor'

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });

  // 1. Data Firebase එකට යවන්න (Map එකක් විදිහට)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
    };
  }

  // 2. Firebase වලින් එන Data, App එකට ගන්න
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'customer',
    );
  }
}