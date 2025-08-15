import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Service responsible for all direct interactions with the 'users' collection in Firestore.
class UserFirestoreService {
  final FirebaseFirestore _firestore;

  UserFirestoreService(this._firestore);

  // A private getter for the users collection reference to reduce boilerplate.
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Adds a new user document to Firestore.
  /// The user's UID from Firebase Authentication is used as the document ID
  /// for easy lookups.
  Future<void> addUser(UserModel user) async {
    await _usersCollection.doc(user.id).set(user.toMap());
  }

  /// Gets a real-time stream of a user's document from Firestore.
  /// This will automatically update the app UI when the user's data changes.
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUserStream(String uid) {
    return _usersCollection.doc(uid).snapshots();
  }
}