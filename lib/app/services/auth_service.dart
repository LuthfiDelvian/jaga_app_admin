import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  Future<void> deleteAccount({
    required String email,
    required String password,
  }) async {
    AuthCredential credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await currentUser!.reauthenticateWithCredential(credential);
    await currentUser!.delete();
    await firebaseAuth.signOut();
  }

  Future<void> changePassword({
    required String newPassword,
  }) async {
    if (currentUser != null) {
      await currentUser!.updatePassword(newPassword);
    } else {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'User not logged in.',
      );
    }
  }

  Future<void> updateUsername({
    required String newUsername,
  }) async {
    if (currentUser != null) {
      await currentUser!.updateDisplayName(newUsername);
      await currentUser!.reload();
    } else {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'User not logged in.',
      );
    }
  }
}