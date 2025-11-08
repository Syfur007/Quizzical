import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final bool isAdmin;
  final DateTime createdAt;
  final String? profilePicUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.isAdmin,
    required this.createdAt,
    this.profilePicUrl,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      profilePicUrl: data['profilePicUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'isAdmin': isAdmin,
      'createdAt': Timestamp.fromDate(createdAt),
      if (profilePicUrl != null) 'profilePicUrl': profilePicUrl,
    };
  }
}

