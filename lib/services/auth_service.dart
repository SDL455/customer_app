import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app/constants/app_constants.dart';
import '../data/models/user_model.dart';

/// Handles Firebase authentication and the linked Firestore user document.
/// In this app only customers self-register; merchants and riders are created
/// by the admin console (see the admin project) and simply sign in here.
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------------
  // Sign in (shared by all roles)
  // ---------------------------------------------------------------
  Future<Either<String, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      if (cred.user == null) {
        return const Left('Authentication failed.');
      }
      final user = await getUserModel(cred.user!.uid);
      if (user == null) {
        return const Left('Account data not found. Contact support.');
      }
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(_mapAuthError(e));
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ---------------------------------------------------------------
  // Self-registration (Customer only)
  // ---------------------------------------------------------------
  Future<Either<String, UserModel>> registerCustomer({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final uid = cred.user!.uid;
      final user = UserModel(
        uid: uid,
        email: email.trim(),
        fullName: fullName.trim(),
        phone: phone.trim(),
        role: AppConstants.roleCustomer,
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .set(user.toMap());
      await cred.user?.updateDisplayName(fullName.trim());
      return Right(user);
    } on FirebaseAuthException catch (e) {
      return Left(_mapAuthError(e));
    } catch (e) {
      return Left(e.toString());
    }
  }

  // ---------------------------------------------------------------
  // User document helpers
  // ---------------------------------------------------------------
  Future<UserModel?> getUserModel(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, id: doc.id);
  }

  Future<Either<String, void>> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update(user.toMap());
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, void>> logout() async {
    try {
      await _auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(e.toString());
    }
  }

  /// Convenience for fetching a merchant's restaurant id.
  Future<Either<String, UserModel>> refreshCurrentUser() async {
    final uid = currentUser?.uid;
    if (uid == null) return const Left('Not authenticated.');
    final user = await getUserModel(uid);
    if (user == null) return const Left('User not found.');
    return Right(user);
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'The password is too weak (min 6 characters).';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return e.message ?? 'Authentication error.';
    }
  }
}
