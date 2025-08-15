import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id; // This is the UID from Firebase Auth
  final String username;
  final String email;
  final String? mobileNumber;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.mobileNumber,
  });

  /// Converts this UserModel instance into a Map<String, dynamic>.
  /// This is used for writing data to Firestore.
  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'username': username,
      'email': email,
      'mobileNumber': mobileNumber,
    };
  }

  /// Creates a UserModel instance from a Firestore document snapshot.
  /// This is used for reading data from Firestore.
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    // Use a default value or handle potential null data gracefully
    return UserModel(
      id: data?['uid'] ?? doc.id,
      username: data?['username'] ?? 'No Username',
      email: data?['email'] ?? 'No Email',
      mobileNumber: data?['mobileNumber'],
    );
  }
}