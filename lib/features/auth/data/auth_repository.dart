import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:task_app/features/auth/data/services/firebase_auth_service.dart';
import 'models/user_model.dart';

class AuthRepository {
  final FirebaseAuthService _authService;

  AuthRepository(this._authService);

  Stream<UserModel?> get authStateChanges =>
      _authService.authStateChanges.map((firebaseUser) {
        return firebaseUser != null
            ? UserModel.fromFirebaseUser(firebaseUser)
            : null;
      });

  Future<UserModel> signInWithEmailAndPassword(
      String email, String password) async {
    final firebaseUser =
    await _authService.signInWithEmailAndPassword(email, password);
    return UserModel.fromFirebaseUser(firebaseUser);
  }

  Future<UserModel> signUpWithEmailAndPassword(
      String email, String password) async {
    final firebaseUser =
    await _authService.createUserWithEmailAndPassword(email, password);
    return UserModel.fromFirebaseUser(firebaseUser);
  }

  Future<void> signOut() => _authService.signOut();
}