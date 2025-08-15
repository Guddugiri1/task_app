import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth_repository.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_app/features/auth/data/services/user_firestore_service.dart';


// --- CORE FIREBASE PROVIDERS ---
final firebaseAuthProvider =
Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firestoreProvider =
Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// --- SERVICE PROVIDERS ---
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>(
        (ref) => FirebaseAuthService(ref.watch(firebaseAuthProvider)));

final userFirestoreServiceProvider = Provider<UserFirestoreService>(
        (ref) => UserFirestoreService(ref.watch(firestoreProvider)));

// --- REPOSITORY PROVIDER ---
// FIX #1: The repository now correctly receives BOTH services it depends on.
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(
  ref.watch(firebaseAuthServiceProvider),
  ref.watch(userFirestoreServiceProvider),
));

// --- APP STATE PROVIDERS ---

// FIX #2: This provider now correctly states that it returns the raw Firebase User object.
// Its only job is to tell the app IF a user is logged in or not.
final authStateChangesProvider = StreamProvider<User?>(
        (ref) => ref.watch(authRepositoryProvider).authStateChanges);

/// Provides the full, custom UserModel from Firestore for the currently logged-in user.
/// This is the provider the UI should use to get username, mobile, etc.
final userProfileProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  final userFirestoreService = ref.watch(userFirestoreServiceProvider);
  final user = authState.value;

  if (user != null) {
    // If a user is logged in, listen to their document in Firestore
    return userFirestoreService.getUserStream(user.uid).map(
          (snapshot) =>
      snapshot.exists ? UserModel.fromFirestore(snapshot) : null,
    );
  }
  // If no user is logged in, provide a null value
  return Stream.value(null);
});