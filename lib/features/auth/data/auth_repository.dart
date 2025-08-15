import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:task_app/features/auth/data/services/firebase_auth_service.dart';
import 'package:task_app/features/auth/data/services/user_firestore_service.dart';
import 'models/user_model.dart';

class AuthRepository {
  final FirebaseAuthService _authService;
  final UserFirestoreService _firestoreService; // New dependency

  AuthRepository(this._authService, this._firestoreService);

  /// Provides a stream of the raw Firebase User object to check auth state.
  Stream<firebase_auth.User?> get authStateChanges =>
      _authService.authStateChanges;

  /// Signs in a user with email and password.
  Future<firebase_auth.User> signInWithEmailAndPassword(
      String email, String password) async {
    return await _authService.signInWithEmailAndPassword(email, password);
  }

  /// Signs up a new user and creates their profile in Firestore.
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    String? mobileNumber,
  }) async {
    // 1. Create the user in Firebase Authentication
    final firebaseUser =
    await _authService.createUserWithEmailAndPassword(email, password);

    // 2. Create our custom UserModel with all the required data
    final newUser = UserModel(
      id: firebaseUser.uid,
      username: username,
      email: email,
      mobileNumber: mobileNumber?.isNotEmpty ?? false ? mobileNumber : null,
    );

    // 3. Save the new user's complete profile to our Firestore database
    await _firestoreService.addUser(newUser);
  }

  /// Signs out the current user.
  Future<void> signOut() => _authService.signOut();
}