import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth_repository.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';

final firebaseAuthProvider =
Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>(
        (ref) => FirebaseAuthService(ref.watch(firebaseAuthProvider)));

final authRepositoryProvider = Provider<AuthRepository>(
        (ref) => AuthRepository(ref.watch(firebaseAuthServiceProvider)));

final authStateChangesProvider = StreamProvider<UserModel?>(
        (ref) => ref.watch(authRepositoryProvider).authStateChanges);