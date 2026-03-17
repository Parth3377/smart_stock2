// ════════════════════════════════════════════════════════════════════
//  lib/services/auth_service.dart
//
//  KEY FIX: Admin detection by EMAIL only (instant, no Firestore wait)
//  Firestore sync happens in background AFTER navigation.
// ════════════════════════════════════════════════════════════════════

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthResult {
  final bool success;
  final String? errorMessage;
  final bool isAdmin;

  const AuthResult({
    required this.success,
    this.errorMessage,
    this.isAdmin = false,
  });
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Admin emails list ──────────────────────────────────────────────
  // Add any admin email here — checked instantly, no Firestore needed
  static const List<String> _adminEmails = [
    'admin@smartstock.com',
  ];

  static bool isAdminEmail(String email) =>
      _adminEmails.contains(email.toLowerCase().trim());

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ════════════════════════════════════════════════════════════════════
  //  EMAIL / PASSWORD LOGIN — instant admin check
  // ════════════════════════════════════════════════════════════════════
  Future<AuthResult> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      // ✅ Admin check by email — INSTANT, no Firestore wait
      final admin = isAdminEmail(credential.user?.email ?? '');

      // Sync to Firestore in background (non-blocking)
      _syncUserInBackground(credential.user!, isAdmin: admin);

      return AuthResult(success: true, isAdmin: admin);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: _mapAuthError(e.code));
    } catch (e) {
      return AuthResult(success: false, errorMessage: 'Login failed. Try again.');
    }
  }

  // ════════════════════════════════════════════════════════════════════
  //  REGISTER
  // ════════════════════════════════════════════════════════════════════
  Future<AuthResult> registerWithEmail({
    required String name,
    required String email,
    required String password,
    String phone = '',
    String city = '',
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      await credential.user!.updateDisplayName(name.trim());

      // Save user to Firestore
      _db.collection('users').doc(credential.user!.uid).set({
        'uid':         credential.user!.uid,
        'name':        name.trim(),
        'email':       email.trim(),
        'phone':       phone.trim(),
        'city':        city.trim(),
        'photoUrl':    '',
        'role':        'client',
        'totalOrders': 0,
        'totalSpend':  0.0,
        'fcmToken':    '',
        'joinedAt':    FieldValue.serverTimestamp(),
        'updatedAt':   FieldValue.serverTimestamp(),
      }).catchError((_) {}); // silent if Firestore fails

      return const AuthResult(success: true, isAdmin: false);
    } on FirebaseAuthException catch (e) {
      return AuthResult(success: false, errorMessage: _mapAuthError(e.code));
    } catch (e) {
      return AuthResult(success: false, errorMessage: 'Registration failed.');
    }
  }

  // ════════════════════════════════════════════════════════════════════
  //  GOOGLE SIGN-IN — signInWithPopup for web
  // ════════════════════════════════════════════════════════════════════
  Future<AuthResult> signInWithGoogle() async {
    try {
      final googleProvider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');

      // signInWithPopup opens Google account selector in a popup
      final userCredential = await _auth.signInWithPopup(googleProvider);

      // ✅ Admin check by email — INSTANT
      final admin = isAdminEmail(userCredential.user?.email ?? '');

      // Sync to Firestore in background (non-blocking)
      _syncUserInBackground(userCredential.user!, isAdmin: admin);

      return AuthResult(success: true, isAdmin: admin);

    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        return const AuthResult(success: false, errorMessage: 'cancelled');
      }
      return AuthResult(success: false, errorMessage: _mapAuthError(e.code));
    } catch (e) {
      return AuthResult(success: false, errorMessage: 'Google sign-in failed.');
    }
  }

  // ════════════════════════════════════════════════════════════════════
  //  SIGN OUT
  // ════════════════════════════════════════════════════════════════════
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ════════════════════════════════════════════════════════════════════
  //  BACKGROUND FIRESTORE SYNC — never blocks navigation
  // ════════════════════════════════════════════════════════════════════
  void _syncUserInBackground(User user, {required bool isAdmin}) {
    final collection = isAdmin ? 'admins' : 'users';
    _db.collection(collection).doc(user.uid).set({
      'uid':       user.uid,
      'name':      user.displayName ?? (isAdmin ? 'Admin' : ''),
      'email':     user.email ?? '',
      'photoUrl':  user.photoURL ?? '',
      'role':      isAdmin ? 'Super Admin' : 'client',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)).catchError((_) {}); // completely silent
  }

  // ── Auth error messages ────────────────────────────────────────────
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':         return 'No account found. Please register first.';
      case 'wrong-password':         return 'Incorrect password. Please try again.';
      case 'invalid-credential':     return 'Wrong email or password.';
      case 'email-already-in-use':   return 'This email is already registered.';
      case 'weak-password':          return 'Password must be at least 6 characters.';
      case 'invalid-email':          return 'Please enter a valid email address.';
      case 'user-disabled':          return 'This account has been disabled.';
      case 'too-many-requests':      return 'Too many attempts. Please wait.';
      case 'network-request-failed': return 'No internet. Check your connection.';
      default:                       return 'Login failed (${code}).';
    }
  }
}


// // ════════════════════════════════════════════════════════════════════
// //  lib/services/auth_service.dart
// //
// //  Firebase Authentication — Email/Password + Google Sign-In
// //  Uses signInWithPopup for web (Chrome) compatibility.
// //  Admin detection via Firestore "admins" collection.
// // ════════════════════════════════════════════════════════════════════
//
// import 'dart:async';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class AuthResult {
//   final bool success;
//   final String? errorMessage;
//   final bool isAdmin;
//
//   const AuthResult({
//     required this.success,
//     this.errorMessage,
//     this.isAdmin = false,
//   });
// }
//
// class AuthService {
//   AuthService._();
//   static final AuthService instance = AuthService._();
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   User? get currentUser => _auth.currentUser;
//   Stream<User?> get authStateChanges => _auth.authStateChanges();
//
//   // ════════════════════════════════════════════════════════════════════
//   //  EMAIL / PASSWORD LOGIN
//   // ════════════════════════════════════════════════════════════════════
//   Future<AuthResult> loginWithEmail({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final credential = await _auth.signInWithEmailAndPassword(
//         email: email.trim(),
//         password: password.trim(),
//       );
//
//       final uid = credential.user!.uid;
//       final admin = await _checkIsAdmin(uid);
//
//       if (!admin) {
//         await _ensureUserDocument(credential.user!);
//       }
//
//       return AuthResult(success: true, isAdmin: admin);
//     } on FirebaseAuthException catch (e) {
//       return AuthResult(success: false, errorMessage: _mapAuthError(e.code));
//     } catch (e) {
//       return AuthResult(success: false, errorMessage: e.toString());
//     }
//   }
//
//   // ════════════════════════════════════════════════════════════════════
//   //  EMAIL / PASSWORD REGISTER
//   // ════════════════════════════════════════════════════════════════════
//   Future<AuthResult> registerWithEmail({
//     required String name,
//     required String email,
//     required String password,
//     String phone = '',
//     String city = '',
//   }) async {
//     try {
//       final credential = await _auth.createUserWithEmailAndPassword(
//         email: email.trim(),
//         password: password.trim(),
//       );
//
//       await credential.user!.updateDisplayName(name.trim());
//
//       await _db.collection('users').doc(credential.user!.uid).set({
//         'uid': credential.user!.uid,
//         'name': name.trim(),
//         'email': email.trim(),
//         'phone': phone.trim(),
//         'city': city.trim(),
//         'photoUrl': '',
//         'role': 'client',
//         'totalOrders': 0,
//         'totalSpend': 0.0,
//         'fcmToken': '',
//         'joinedAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//
//       return const AuthResult(success: true, isAdmin: false);
//     } on FirebaseAuthException catch (e) {
//       return AuthResult(success: false, errorMessage: _mapAuthError(e.code));
//     } catch (e) {
//       return AuthResult(success: false, errorMessage: e.toString());
//     }
//   }
//
//   // ════════════════════════════════════════════════════════════════════
//   //  GOOGLE SIGN-IN — uses signInWithPopup (works on Web/Chrome)
//   //  Does NOT use google_sign_in package (that's for Android/iOS only)
//   // ════════════════════════════════════════════════════════════════════
//   Future<AuthResult> signInWithGoogle() async {
//     try {
//       final googleProvider = GoogleAuthProvider()
//         ..addScope('email')
//         ..addScope('profile');
//
//       // signInWithPopup works in Chrome browser
//       final userCredential = await _auth.signInWithPopup(googleProvider);
//       final uid = userCredential.user!.uid;
//       final admin = await _checkIsAdmin(uid);
//
//       if (!admin) {
//         await _db.collection('users').doc(uid).set({
//           'uid': uid,
//           'name': userCredential.user!.displayName ?? '',
//           'email': userCredential.user!.email ?? '',
//           'phone': '',
//           'city': '',
//           'photoUrl': userCredential.user!.photoURL ?? '',
//           'role': 'client',
//           'totalOrders': 0,
//           'totalSpend': 0.0,
//           'fcmToken': '',
//           'joinedAt': FieldValue.serverTimestamp(),
//           'updatedAt': FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));
//       }
//
//       return AuthResult(success: true, isAdmin: admin);
//     } on FirebaseAuthException catch (e) {
//       // User closed the popup — not a real error
//       if (e.code == 'popup-closed-by-user' ||
//           e.code == 'cancelled-popup-request') {
//         return const AuthResult(
//             success: false, errorMessage: 'Sign-in cancelled');
//       }
//       return AuthResult(success: false, errorMessage: _mapAuthError(e.code));
//     } catch (e) {
//       return AuthResult(success: false, errorMessage: e.toString());
//     }
//   }
//
//   // ════════════════════════════════════════════════════════════════════
//   //  SIGN OUT
//   // ════════════════════════════════════════════════════════════════════
//   Future<void> signOut() async {
//     await _auth.signOut();
//   }
//
//   // ════════════════════════════════════════════════════════════════════
//   //  PASSWORD RESET
//   // ════════════════════════════════════════════════════════════════════
//   Future<AuthResult> sendPasswordReset(String email) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email.trim());
//       return const AuthResult(success: true);
//     } on FirebaseAuthException catch (e) {
//       return AuthResult(success: false, errorMessage: _mapAuthError(e.code));
//     }
//   }
//
//   // ── HELPERS ────────────────────────────────────────────────────────
//   Future<bool> _checkIsAdmin(String uid) async {
//     try {
//       // 5 second timeout — if Firestore is slow, default to client
//       final doc = await _db.collection('admins').doc(uid).get()
//           .timeout(const Duration(seconds: 5));
//       return doc.exists;
//     } catch (_) {
//       return false; // Timeout or offline → treat as client
//     }
//   }
//
//   Future<void> _ensureUserDocument(User user) async {
//     try {
//       final docRef = _db.collection('users').doc(user.uid);
//       final snap = await docRef.get();
//       if (!snap.exists) {
//         await docRef.set({
//           'uid': user.uid,
//           'name': user.displayName ?? '',
//           'email': user.email ?? '',
//           'phone': '',
//           'city': '',
//           'photoUrl': user.photoURL ?? '',
//           'role': 'client',
//           'totalOrders': 0,
//           'totalSpend': 0.0,
//           'fcmToken': '',
//           'joinedAt': FieldValue.serverTimestamp(),
//           'updatedAt': FieldValue.serverTimestamp(),
//         });
//       }
//     } catch (_) {}
//   }
//
//   String _mapAuthError(String code) {
//     switch (code) {
//       case 'user-not-found':         return 'No account found with this email.';
//       case 'wrong-password':         return 'Incorrect password.';
//       case 'invalid-credential':     return 'Wrong email or password.';
//       case 'email-already-in-use':   return 'This email is already registered.';
//       case 'weak-password':          return 'Password must be at least 6 characters.';
//       case 'invalid-email':          return 'Please enter a valid email address.';
//       case 'user-disabled':          return 'This account has been disabled.';
//       case 'too-many-requests':      return 'Too many attempts. Try again later.';
//       case 'network-request-failed': return 'Network error. Check your connection.';
//       default:                       return 'Login failed. Please try again.';
//     }
//   }
// }


// // ════════════════════════════════════════════════════════════════════
// //  lib/services/auth_service.dart
// //
// //  Firebase Authentication — Email/Password + Google Sign-In
// //  Uses signInWithPopup for web (Chrome) compatibility.
// //  Admin detection via Firestore "admins" collection.
// // ════════════════════════════════════════════════════════════════════
//
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class AuthResult {
//   final bool success;
//   final String? errorMessage;
//   final bool isAdmin;
//
//   const AuthResult({
//     required this.success,
//     this.errorMessage,
//     this.isAdmin = false,
//   });
// }
//
// class AuthService {
//   AuthService._();
//   static final AuthService instance = AuthService._();
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   User? get currentUser => _auth.currentUser;
//   Stream<User?> get authStateChanges => _auth.authStateChanges();
//
//   // ════════════════════════════════════════════════════════════════════
//   //  EMAIL / PASSWORD LOGIN
//   // ════════════════════════════════════════════════════════════════════
//   Future<AuthResult> loginWithEmail({
//     required String email,
//     required String password,
//   }) async {
//     try {
//       final credential = await _auth.signInWithEmailAndPassword(
//         email: email.trim(),
//         password: password.trim(),
//       );
//
//       final uid = credential.user!.uid;
//       final admin = await _checkIsAdmin(uid);
//
//       if (!admin) {
//         await _ensureUserDocument(credential.user!);
//       }
//
//       return AuthResult(success: true, isAdmin: admin);
//     } on FirebaseAuthException catch (e) {
//       return AuthResult(success: false, errorMessage: _mapAuthError(e.code));
//     } catch (e) {
//       return AuthResult(success: false, errorMessage: e.toString());
//     }
//   }
//
//   // ════════════════════════════════════════════════════════════════════
//   //  EMAIL / PASSWORD REGISTER
//   // ════════════════════════════════════════════════════════════════════
//   Future<AuthResult> registerWithEmail({
//     required String name,
//     required String email,
//     required String password,
//     String phone = '',
//     String city = '',
//   }) async {
//     try {
//       final credential = await _auth.createUserWithEmailAndPassword(
//         email: email.trim(),
//         password: password.trim(),
//       );
//
//       await credential.user!.updateDisplayName(name.trim());
//
//       await _db.collection('users').doc(credential.user!.uid).set({
//         'uid': credential.user!.uid,
//         'name': name.trim(),
//         'email': email.trim(),
//         'phone': phone.trim(),
//         'city': city.trim(),
//         'photoUrl': '',
//         'role': 'client',
//         'totalOrders': 0,
//         'totalSpend': 0.0,
//         'fcmToken': '',
//         'joinedAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//
//       return const AuthResult(success: true, isAdmin: false);
//     } on FirebaseAuthException catch (e) {
//       return AuthResult(success: false, errorMessage: _mapAuthError(e.code));
//     } catch (e) {
//       return AuthResult(success: false, errorMessage: e.toString());
//     }
//   }
//
//   // ════════════════════════════════════════════════════════════════════
//   //  GOOGLE SIGN-IN — uses signInWithPopup (works on Web/Chrome)
//   //  Does NOT use google_sign_in package (that's for Android/iOS only)
//   // ════════════════════════════════════════════════════════════════════
//   Future<AuthResult> signInWithGoogle() async {
//     try {
//       final googleProvider = GoogleAuthProvider()
//         ..addScope('email')
//         ..addScope('profile');
//
//       // signInWithPopup works in Chrome browser
//       final userCredential = await _auth.signInWithPopup(googleProvider);
//       final uid = userCredential.user!.uid;
//       final admin = await _checkIsAdmin(uid);
//
//       if (!admin) {
//         await _db.collection('users').doc(uid).set({
//           'uid': uid,
//           'name': userCredential.user!.displayName ?? '',
//           'email': userCredential.user!.email ?? '',
//           'phone': '',
//           'city': '',
//           'photoUrl': userCredential.user!.photoURL ?? '',
//           'role': 'client',
//           'totalOrders': 0,
//           'totalSpend': 0.0,
//           'fcmToken': '',
//           'joinedAt': FieldValue.serverTimestamp(),
//           'updatedAt': FieldValue.serverTimestamp(),
//         }, SetOptions(merge: true));
//       }
//
//       return AuthResult(success: true, isAdmin: admin);
//     } on FirebaseAuthException catch (e) {
//       // User closed the popup — not a real error
//       if (e.code == 'popup-closed-by-user' ||
//           e.code == 'cancelled-popup-request') {
//         return const AuthResult(
//             success: false, errorMessage: 'Sign-in cancelled');
//       }
//       return AuthResult(success: false, errorMessage: _mapAuthError(e.code));
//     } catch (e) {
//       return AuthResult(success: false, errorMessage: e.toString());
//     }
//   }
//
//   // ════════════════════════════════════════════════════════════════════
//   //  SIGN OUT
//   // ════════════════════════════════════════════════════════════════════
//   Future<void> signOut() async {
//     await _auth.signOut();
//   }
//
//   // ════════════════════════════════════════════════════════════════════
//   //  PASSWORD RESET
//   // ════════════════════════════════════════════════════════════════════
//   Future<AuthResult> sendPasswordReset(String email) async {
//     try {
//       await _auth.sendPasswordResetEmail(email: email.trim());
//       return const AuthResult(success: true);
//     } on FirebaseAuthException catch (e) {
//       return AuthResult(success: false, errorMessage: _mapAuthError(e.code));
//     }
//   }
//
//   // ── HELPERS ────────────────────────────────────────────────────────
//   Future<bool> _checkIsAdmin(String uid) async {
//     try {
//       final doc = await _db.collection('admins').doc(uid).get();
//       return doc.exists;
//     } catch (_) {
//       // Firestore offline — check by email from known admin list
//       return false;
//     }
//   }
//
//   Future<void> _ensureUserDocument(User user) async {
//     try {
//       final docRef = _db.collection('users').doc(user.uid);
//       final snap = await docRef.get();
//       if (!snap.exists) {
//         await docRef.set({
//           'uid': user.uid,
//           'name': user.displayName ?? '',
//           'email': user.email ?? '',
//           'phone': '',
//           'city': '',
//           'photoUrl': user.photoURL ?? '',
//           'role': 'client',
//           'totalOrders': 0,
//           'totalSpend': 0.0,
//           'fcmToken': '',
//           'joinedAt': FieldValue.serverTimestamp(),
//           'updatedAt': FieldValue.serverTimestamp(),
//         });
//       }
//     } catch (_) {}
//   }
//
//   String _mapAuthError(String code) {
//     switch (code) {
//       case 'user-not-found':         return 'No account found with this email.';
//       case 'wrong-password':         return 'Incorrect password.';
//       case 'invalid-credential':     return 'Wrong email or password.';
//       case 'email-already-in-use':   return 'This email is already registered.';
//       case 'weak-password':          return 'Password must be at least 6 characters.';
//       case 'invalid-email':          return 'Please enter a valid email address.';
//       case 'user-disabled':          return 'This account has been disabled.';
//       case 'too-many-requests':      return 'Too many attempts. Try again later.';
//       case 'network-request-failed': return 'Network error. Check your connection.';
//       default:                       return 'Login failed. Please try again.';
//     }
//   }
// }