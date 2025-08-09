import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/exceptions/app_exceptions.dart';

class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<User> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (credential.user == null) {
        throw AppException('User not found.');
      }
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AppException(e.message ?? 'An unknown error occurred.');
    }
  }

  Future<User> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) {
        throw AppException('User could not be created.');
      }
      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw AppException(e.message ?? 'An unknown error occurred.');
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw AppException(e.message ?? 'An unknown error occurred.');
    }
  }
}