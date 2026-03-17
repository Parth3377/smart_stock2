// ════════════════════════════════════════════════════════════════════
//  lib/providers/auth_provider.dart
// ════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

enum AuthState { idle, loading, success, error }

class FirebaseAuthProvider extends ChangeNotifier {
  AuthState state = AuthState.idle;
  String? errorMessage;
  bool isAdmin = false;

  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future<AuthResult> login(String email, String password) async {
    state = AuthState.loading;
    errorMessage = null;
    notifyListeners();

    final result = await AuthService.instance
        .loginWithEmail(email: email, password: password);

    isAdmin = result.isAdmin;
    state = result.success ? AuthState.success : AuthState.error;
    errorMessage = result.errorMessage;
    notifyListeners();
    return result;
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
    String city = '',
  }) async {
    state = AuthState.loading;
    errorMessage = null;
    notifyListeners();

    final result = await AuthService.instance.registerWithEmail(
      name: name, email: email, password: password,
      phone: phone, city: city,
    );

    isAdmin = false;
    state = result.success ? AuthState.success : AuthState.error;
    errorMessage = result.errorMessage;
    notifyListeners();
    return result;
  }

  Future<AuthResult> signInWithGoogle() async {
    state = AuthState.loading;
    errorMessage = null;
    notifyListeners();

    final result = await AuthService.instance.signInWithGoogle();

    isAdmin = result.isAdmin;
    state = result.success ? AuthState.success : AuthState.error;
    errorMessage = result.errorMessage;
    notifyListeners();
    return result;
  }

  Future<void> logout() async {
    await AuthService.instance.signOut();
    isAdmin = false;
    state = AuthState.idle;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    state = AuthState.idle;
    notifyListeners();
  }
}



// // ════════════════════════════════════════════════════════════════════
// //  lib/providers/auth_provider.dart
// //
// //  Firebase-backed auth provider.
// //  Exposes login/register/google/logout and isAdmin flag to UI.
// // ════════════════════════════════════════════════════════════════════
//
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../services/auth_service.dart';
//
// enum AuthState { idle, loading, success, error }
//
// class FirebaseAuthProvider extends ChangeNotifier {
//   AuthState state = AuthState.idle;
//   String? errorMessage;
//   bool isAdmin = false;
//   User? get currentUser => FirebaseAuth.instance.currentUser;
//
//   // ── EMAIL / PASSWORD LOGIN ─────────────────────────────────────────
//   Future<AuthResult> login(String email, String password) async {
//     state = AuthState.loading;
//     errorMessage = null;
//     notifyListeners();
//
//     final result = await AuthService.instance
//         .loginWithEmail(email: email, password: password);
//
//     if (result.success) {
//       isAdmin = result.isAdmin;
//       state = AuthState.success;
//     } else {
//       errorMessage = result.errorMessage;
//       state = AuthState.error;
//     }
//     notifyListeners();
//     return result;
//   }
//
//   // ── REGISTER ──────────────────────────────────────────────────────
//   Future<AuthResult> register({
//     required String name,
//     required String email,
//     required String password,
//     String phone = '',
//     String city = '',
//   }) async {
//     state = AuthState.loading;
//     errorMessage = null;
//     notifyListeners();
//
//     final result = await AuthService.instance.registerWithEmail(
//       name: name,
//       email: email,
//       password: password,
//       phone: phone,
//       city: city,
//     );
//
//     if (result.success) {
//       isAdmin = false;
//       state = AuthState.success;
//     } else {
//       errorMessage = result.errorMessage;
//       state = AuthState.error;
//     }
//     notifyListeners();
//     return result;
//   }
//
//   // ── GOOGLE SIGN-IN ────────────────────────────────────────────────
//   Future<AuthResult> signInWithGoogle() async {
//     state = AuthState.loading;
//     errorMessage = null;
//     notifyListeners();
//
//     final result = await AuthService.instance.signInWithGoogle();
//
//     if (result.success) {
//       isAdmin = result.isAdmin;
//       state = AuthState.success;
//     } else {
//       errorMessage = result.errorMessage;
//       state = AuthState.error;
//     }
//     notifyListeners();
//     return result;
//   }
//
//   // ── LOGOUT ────────────────────────────────────────────────────────
//   Future<void> logout() async {
//     await AuthService.instance.signOut();
//     isAdmin = false;
//     state = AuthState.idle;
//     notifyListeners();
//   }
//
//   void clearError() {
//     errorMessage = null;
//     state = AuthState.idle;
//     notifyListeners();
//   }
// }
