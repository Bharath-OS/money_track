import 'package:cash_flow/data/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthServices {
  late final FirebaseAuth _auth;
  AuthServices() {
    _auth = FirebaseAuth.instance;
  }

  AppUser? _getUserFromFirebase(User? user, [String password = '']) {
    return user != null
        ? AppUser(
            uid: user.uid,
            username: user.displayName,
            email: user.email,
            password: password,
          )
        : null;
  }

  Stream<User?> get user => _auth.authStateChanges();

  Future<AppUser?> signInWithEmailAndPassword(
    String email,
    String password,
    BuildContext context,
  ) async {
    String message = '';
    try {
      UserCredential user = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (user.user != null) {
        return AppUser(
          uid: user.user?.uid,
          username: user.user?.displayName,
          photoURL: user.user?.photoURL,
        );
      }
      message = 'Something went wrong, Try agian later.';
    } on FirebaseAuthException catch (err) {
      switch (err.code) {
        case 'invalid-email':
          message = 'Provide a valid email address';
          break;
        case 'user-not-found':
          message = 'Account not found, try creating a new one';
          break;
        case 'network-request-failed':
          message = 'Check your internet connection';
          break;
        case 'wrong-password':
          message = 'The password you entered is incorrect';
          break;
        default:
          message = 'Something went wrong, Try again later';
          break;
      }
      return null;
    } finally {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    return null;
  }

  Future<AppUser?> createUserWithEmailAndPassword(
    String userName,
    String email,
    String password,
    BuildContext context,
  ) async {
    String message = '';
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        return AppUser(
          uid: userCredential.user?.uid,
          username: userCredential.user?.displayName ?? userName,
          email: userCredential.user?.email,
          photoURL: userCredential.user?.photoURL,
          password: password,
        );
      }
      message = 'Something went wrong. Please try again later';
    } on FirebaseAuthException catch (err) {
      switch (err.code) {
        case 'email-already-in-use':
          message =
              'The email you entered is already existing, Try login instead';
          break;
        case 'invalid-email':
          message = 'Enter a valid email address';
          break;
        case 'network-request-failed':
          message = 'Check your internet connection.';
          break;
        case 'weak-password':
          message = 'Enter a strong password';
          break;
      }
    } catch (_) {
      message = 'Something went wrong. Try again later';
    } finally {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
    return null;
  }
}
