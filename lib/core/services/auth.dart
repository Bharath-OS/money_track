import 'package:cash_flow/data/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthServices {
  late final FirebaseAuth _auth;
  AuthServices() {
    _auth = FirebaseAuth.instance;
  }

  User? get currentUser => _auth.currentUser;

  void signOut() async {
    await _auth.signOut();
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
        userCredential.user!.updateDisplayName(userName);
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

  Future<Map<AppUser?, String>> signInWithGoogle(BuildContext context) async {
    String message = '';

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

      // Check if user cancelled the sign-in
      if (googleUser == null) {
        message = 'Sign in cancelled';
        return {null: message};
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      // Return user data on success
      if (userCredential.user != null) {
        message = 'Success';
        return {
          AppUser(
            uid: userCredential.user?.uid,
            username: userCredential.user?.displayName,
            email: userCredential.user?.email,
            photoURL: userCredential.user?.photoURL,
          ): message,
        };
      }

      message = 'Failed to get user data';
      return {null: message};
    } on PlatformException catch (e) {
      // Handle Google Sign-In specific errors
      if (e.code == 'sign_in_canceled' || e.code == 'sign_in_aborted') {
        message = 'Sign in cancelled';
      } else if (e.code == 'network_error') {
        message = 'Network error. Check your internet connection';
      } else {
        message = 'Google sign in failed: ${e.message}';
      }
      return {null: message};
    } on FirebaseAuthException catch (e) {
      // Handle Firebase auth errors
      switch (e.code) {
        case 'account-exists-with-different-credential':
          message = 'Account exists with different sign-in method';
          break;
        case 'invalid-credential':
          message = 'Invalid credentials';
          break;
        case 'operation-not-allowed':
          message = 'Google sign-in not enabled in Firebase';
          break;
        case 'user-not-found':
          message = 'User not found';
          break;
        case 'network-request-failed':
          message = 'Network error. Check your internet connection';
          break;
        default:
          message = 'Authentication failed: ${e.message}';
      }
      return {null: message};
    } catch (e) {
      // Catch any other unexpected errors
      if (e.toString().contains('network') ||
          e.toString().contains('Network')) {
        message = 'Network error. Check your internet connection';
      } else {
        message = 'An error occurred: $e';
      }
      return {null: message};
    }
  }
}
