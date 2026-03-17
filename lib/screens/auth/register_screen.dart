import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

  final nameController            = TextEditingController();
  final emailController           = TextEditingController();
  final passwordController        = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;
  bool obscure  = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  //  REGISTER — Firebase Auth is awaited (fast), Firestore is NOT
  // ═══════════════════════════════════════════════════════════════
  Future<void> registerUser() async {
    final name    = nameController.text.trim();
    final email   = emailController.text.trim();
    final pass    = passwordController.text.trim();
    final confirm = confirmPasswordController.text.trim();

    // Validation
    if (name.isEmpty || email.isEmpty || pass.isEmpty) {
      _showError('Please fill in all fields.'); return;
    }
    if (pass != confirm) {
      _showError('Passwords do not match.'); return;
    }
    if (pass.length < 6) {
      _showError('Password must be at least 6 characters.'); return;
    }

    setState(() => loading = true);

    try {
      // Step 1 — Create Firebase Auth user (fast ~1s)
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);

      // Step 2 — Update display name (fast, local)
      await cred.user!.updateDisplayName(name);

      // Step 3 — Navigate IMMEDIATELY — don't wait for Firestore
      setState(() => loading = false);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', (r) => false);

      // Step 4 — Save to Firestore in background (non-blocking)
      // App is already on dashboard by the time this runs
      _saveUserToFirestoreBackground(
        uid:   cred.user!.uid,
        name:  name,
        email: email,
      );

    } on FirebaseAuthException catch (e) {
      setState(() => loading = false);
      switch (e.code) {
        case 'email-already-in-use':
          _showError('This email is already registered. Try logging in.'); break;
        case 'invalid-email':
          _showError('Please enter a valid email address.'); break;
        case 'weak-password':
          _showError('Password must be at least 6 characters.'); break;
        case 'network-request-failed':
          _showError('No internet connection. Please try again.'); break;
        default:
          _showError('Registration failed (${e.code}). Please try again.');
      }
    } catch (e) {
      setState(() => loading = false);
      _showError('Registration failed. Please try again.');
    }
  }

  // Saves to Firestore silently in background — never blocks UI
  void _saveUserToFirestoreBackground({
    required String uid,
    required String name,
    required String email,
  }) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({
      'uid':         uid,
      'name':        name,
      'email':       email,
      'phone':       '',
      'city':        '',
      'photoUrl':    '',
      'role':        'client',
      'totalOrders': 0,
      'totalSpend':  0.0,
      'fcmToken':    '',
      'joinedAt':    FieldValue.serverTimestamp(),
      'updatedAt':   FieldValue.serverTimestamp(),
    })
        .catchError((_) {
      // Silent — user is already on dashboard, Firestore failure is non-critical
    });
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    ));
  }

  // ═══════════════════════════════════════════════════════════════
  //  UI
  // ═══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B0E14), Color(0xFF101626), Color(0xFF0B0E14)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              width: size.width > 600 ? 420 : size.width * 0.92,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFF161A22),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(children: [

                const Text('Create Account',
                    style: TextStyle(fontSize: 22,
                        fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 6),
                const Text('Join SmartStock to start ordering',
                    style: TextStyle(color: Color(0xFFA1A6B3), fontSize: 13)),
                const SizedBox(height: 24),

                _field('Full Name',         nameController),
                const SizedBox(height: 16),
                _field('Email Address',     emailController,
                    keyboard: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _field('Password',          passwordController,
                    isPassword: true),
                const SizedBox(height: 16),
                _field('Confirm Password',  confirmPasswordController,
                    isPassword: true),
                const SizedBox(height: 28),

                // Create Account button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: loading ? null : registerUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E6CF6),
                      disabledBackgroundColor: Colors.white10,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: loading
                        ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white70, strokeWidth: 2))
                        : const Text('Create Account',
                        style: TextStyle(fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: Colors.black)),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Already have an account? Login',
                      style: TextStyle(color: Color(0xFFA1A6B3))),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {bool isPassword = false,
        TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword && obscure,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFA1A6B3)),
        filled: true,
        fillColor: const Color(0xFF0F1218),
        suffixIcon: isPassword
            ? IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFFA1A6B3),
            ),
            onPressed: () => setState(() => obscure = !obscure))
            : null,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
      ),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});
//
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//   final nameController = TextEditingController();
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmpasswordController = TextEditingController();
//
//   bool loading = false;
//   bool obscure = true;
//
//   @override
//   void dispose() {
//     nameController.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     confirmpasswordController.dispose();
//     super.dispose();
//   }
//
//   /// 🆕 FIREBASE REGISTER → CLIENT DASHBOARD
//   Future<void> registerUser() async {
//     final name    = nameController.text.trim();
//     final email   = emailController.text.trim();
//     final pass    = passwordController.text.trim();
//     final confirm = confirmpasswordController.text.trim();
//
//     if (name.isEmpty || email.isEmpty || pass.isEmpty) {
//       _showError('Please fill in all fields.'); return;
//     }
//     if (pass != confirm) { _showError('Passwords do not match.'); return; }
//     if (pass.length < 6) { _showError('Password must be at least 6 characters.'); return; }
//
//     setState(() => loading = true);
//
//     try {
//       final cred = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(email: email, password: pass);
//       await cred.user!.updateDisplayName(name);
//
//       // Save to Firestore users collection
//       await FirebaseFirestore.instance
//           .collection('users').doc(cred.user!.uid).set({
//         'uid': cred.user!.uid, 'name': name, 'email': email,
//         'phone': '', 'city': '', 'photoUrl': '', 'role': 'client',
//         'totalOrders': 0, 'totalSpend': 0.0, 'fcmToken': '',
//         'joinedAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//
//       setState(() => loading = false);
//       if (!mounted) return;
//
//       // Named route — stays inside MultiProvider tree
//       Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (r) => false);
//
//     } on FirebaseAuthException catch (e) {
//       setState(() => loading = false);
//       switch (e.code) {
//         case 'email-already-in-use': _showError('This email is already registered.'); break;
//         case 'invalid-email':        _showError('Please enter a valid email.'); break;
//         case 'weak-password':        _showError('Password must be at least 6 characters.'); break;
//         default:                     _showError('Registration failed. Please try again.');
//       }
//     } catch (e) {
//       setState(() => loading = false);
//       _showError('Registration failed. Please try again.');
//     }
//   }
//
//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(msg), backgroundColor: Colors.redAccent,
//       behavior: SnackBarBehavior.floating,
//     ));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
//
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF0B0E14),
//               Color(0xFF101626),
//               Color(0xFF0B0E14),
//             ],
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Container(
//               width: size.width > 600 ? 420 : size.width * 0.92,
//               padding:
//               const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF161A22),
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               child: Column(
//                 children: [
//                   const Text(
//                     "Create Account",
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//
//                   _inputField("Full Name", nameController),
//                   const SizedBox(height: 16),
//
//                   _inputField("Email Address", emailController),
//                   const SizedBox(height: 16),
//
//                   _inputField("Password", passwordController,
//                       isPassword: true),
//                   const SizedBox(height: 24),
//
//                   _inputField("Confirm Password", confirmpasswordController,
//                       isPassword: true),
//                   const SizedBox(height: 24),
//
//                   SizedBox(
//                     width: double.infinity,
//                     height: 48,
//                     child: ElevatedButton(
//                       onPressed: loading ? null : registerUser,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF2E6CF6),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: loading
//                           ? const CircularProgressIndicator(
//                           color: Colors.white)
//                           : const Text("Create Account" , style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black),),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _inputField(String label, TextEditingController controller,
//       {bool isPassword = false}) {
//     return TextField(
//       controller: controller,
//       obscureText: isPassword && obscure,
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Color(0xFFA1A6B3)),
//         filled: true,
//         fillColor: const Color(0xFF0F1218),
//         suffixIcon: isPassword
//             ? IconButton(
//           icon: Icon(
//             obscure ? Icons.visibility_off : Icons.visibility,
//             color: const Color(0xFFA1A6B3),
//           ),
//           onPressed: () => setState(() => obscure = !obscure),
//         )
//             : null,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../routes/app_routes.dart';
//
// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//   final nameController            = TextEditingController();
//   final emailController           = TextEditingController();
//   final passwordController        = TextEditingController();
//   final confirmPasswordController = TextEditingController();
//   bool loading = false;
//   bool obscure  = true;
//
//   @override
//   void dispose() {
//     nameController.dispose(); emailController.dispose();
//     passwordController.dispose(); confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> registerUser() async {
//     final name    = nameController.text.trim();
//     final email   = emailController.text.trim();
//     final pass    = passwordController.text.trim();
//     final confirm = confirmPasswordController.text.trim();
//
//     if (name.isEmpty || email.isEmpty || pass.isEmpty) {
//       _showError('Please fill in all fields.'); return;
//     }
//     if (pass != confirm) { _showError('Passwords do not match.'); return; }
//     if (pass.length < 6) { _showError('Password must be at least 6 characters.'); return; }
//
//     setState(() => loading = true);
//     try {
//       final cred = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(email: email, password: pass);
//       await cred.user!.updateDisplayName(name);
//       await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
//         'uid': cred.user!.uid, 'name': name, 'email': email,
//         'phone': '', 'city': '', 'photoUrl': '', 'role': 'client',
//         'totalOrders': 0, 'totalSpend': 0.0, 'fcmToken': '',
//         'joinedAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//       setState(() => loading = false);
//       if (!mounted) return;
//       // KEY FIX: named route — stays inside MultiProvider
//       Navigator.pushNamedAndRemoveUntil(context, AppRoutes.dashboard, (r) => false);
//     } on FirebaseAuthException catch (e) {
//       setState(() => loading = false);
//       switch (e.code) {
//         case 'email-already-in-use': _showError('This email is already registered.'); break;
//         case 'invalid-email':        _showError('Please enter a valid email.'); break;
//         case 'weak-password':        _showError('Password must be at least 6 characters.'); break;
//         default:                     _showError('Registration failed. Please try again.');
//       }
//     } catch (e) {
//       setState(() => loading = false);
//       _showError('Registration failed. Please try again.');
//     }
//   }
//
//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content: Text(msg), backgroundColor: Colors.redAccent,
//         behavior: SnackBarBehavior.floating));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//       appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
//       body: Container(
//         width: double.infinity, height: double.infinity,
//         decoration: const BoxDecoration(gradient: LinearGradient(
//           begin: Alignment.topLeft, end: Alignment.bottomRight,
//           colors: [Color(0xFF0B0E14), Color(0xFF101626), Color(0xFF0B0E14)],
//         )),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Container(
//               width: size.width > 600 ? 420 : size.width * 0.92,
//               padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
//               decoration: BoxDecoration(color: const Color(0xFF161A22), borderRadius: BorderRadius.circular(18)),
//               child: Column(children: [
//                 const Text('Create Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
//                 const SizedBox(height: 6),
//                 const Text('Join SmartStock to start ordering', style: TextStyle(color: Color(0xFFA1A6B3), fontSize: 13)),
//                 const SizedBox(height: 24),
//                 _field('Full Name', nameController),
//                 const SizedBox(height: 16),
//                 _field('Email Address', emailController),
//                 const SizedBox(height: 16),
//                 _field('Password', passwordController, isPassword: true),
//                 const SizedBox(height: 16),
//                 _field('Confirm Password', confirmPasswordController, isPassword: true),
//                 const SizedBox(height: 24),
//                 SizedBox(width: double.infinity, height: 48,
//                   child: ElevatedButton(
//                     onPressed: loading ? null : registerUser,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF2E6CF6),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     ),
//                     child: loading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Already have an account? Login', style: TextStyle(color: Color(0xFFA1A6B3))),
//                 ),
//               ]),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _field(String label, TextEditingController ctrl, {bool isPassword = false}) {
//     return TextField(
//       controller: ctrl, obscureText: isPassword && obscure,
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         labelText: label, labelStyle: const TextStyle(color: Color(0xFFA1A6B3)),
//         filled: true, fillColor: const Color(0xFF0F1218),
//         suffixIcon: isPassword ? IconButton(
//             icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFA1A6B3)),
//             onPressed: () => setState(() => obscure = !obscure)) : null,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../../routes/app_routes.dart';
//
// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//
//   final nameController            = TextEditingController();
//   final emailController           = TextEditingController();
//   final passwordController        = TextEditingController();
//   final confirmPasswordController = TextEditingController();
//
//   bool loading = false;
//   bool obscure  = true;
//
//   @override
//   void dispose() {
//     nameController.dispose();
//     emailController.dispose();
//     passwordController.dispose();
//     confirmPasswordController.dispose();
//     super.dispose();
//   }
//
//   Future<void> registerUser() async {
//     final name     = nameController.text.trim();
//     final email    = emailController.text.trim();
//     final password = passwordController.text.trim();
//     final confirm  = confirmPasswordController.text.trim();
//
//     if (name.isEmpty || email.isEmpty || password.isEmpty) {
//       _showError('Please fill in all fields.'); return;
//     }
//     if (password != confirm) {
//       _showError('Passwords do not match.'); return;
//     }
//     if (password.length < 6) {
//       _showError('Password must be at least 6 characters.'); return;
//     }
//
//     setState(() => loading = true);
//
//     try {
//       final cred = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(email: email, password: password);
//
//       await cred.user!.updateDisplayName(name);
//
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(cred.user!.uid)
//           .set({
//         'uid':         cred.user!.uid,
//         'name':        name,
//         'email':       email,
//         'phone':       '',
//         'city':        '',
//         'photoUrl':    '',
//         'role':        'client',
//         'totalOrders': 0,
//         'totalSpend':  0.0,
//         'fcmToken':    '',
//         'joinedAt':    FieldValue.serverTimestamp(),
//         'updatedAt':   FieldValue.serverTimestamp(),
//       });
//
//       setState(() => loading = false);
//       if (!mounted) return;
//
//       // Use named route — stays inside MultiProvider tree
//       Navigator.pushNamedAndRemoveUntil(
//           context, AppRoutes.dashboard, (r) => false);
//
//     } on FirebaseAuthException catch (e) {
//       setState(() => loading = false);
//       switch (e.code) {
//         case 'email-already-in-use':
//           _showError('This email is already registered.'); break;
//         case 'invalid-email':
//           _showError('Please enter a valid email.'); break;
//         case 'weak-password':
//           _showError('Password must be at least 6 characters.'); break;
//         default:
//           _showError('Registration failed. Please try again.');
//       }
//     } catch (e) {
//       setState(() => loading = false);
//       _showError('Registration failed. Please try again.');
//     }
//   }
//
//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(msg),
//       backgroundColor: Colors.redAccent,
//       behavior: SnackBarBehavior.floating,
//     ));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//       appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
//       body: Container(
//         width: double.infinity, height: double.infinity,
//         decoration: const BoxDecoration(gradient: LinearGradient(
//           begin: Alignment.topLeft, end: Alignment.bottomRight,
//           colors: [Color(0xFF0B0E14), Color(0xFF101626), Color(0xFF0B0E14)],
//         )),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Container(
//               width: size.width > 600 ? 420 : size.width * 0.92,
//               padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF161A22),
//                 borderRadius: BorderRadius.circular(18),
//               ),
//               child: Column(children: [
//                 const Text('Create Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white)),
//                 const SizedBox(height: 6),
//                 const Text('Join SmartStock to start ordering', style: TextStyle(color: Color(0xFFA1A6B3), fontSize: 13)),
//                 const SizedBox(height: 24),
//
//                 _field('Full Name', nameController),
//                 const SizedBox(height: 16),
//                 _field('Email Address', emailController),
//                 const SizedBox(height: 16),
//                 _field('Password', passwordController, isPassword: true),
//                 const SizedBox(height: 16),
//                 _field('Confirm Password', confirmPasswordController, isPassword: true),
//                 const SizedBox(height: 24),
//
//                 SizedBox(width: double.infinity, height: 48,
//                   child: ElevatedButton(
//                     onPressed: loading ? null : registerUser,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFF2E6CF6),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     ),
//                     child: loading
//                         ? const CircularProgressIndicator(color: Colors.white)
//                         : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.black)),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Already have an account? Login', style: TextStyle(color: Color(0xFFA1A6B3))),
//                 ),
//               ]),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _field(String label, TextEditingController ctrl, {bool isPassword = false}) {
//     return TextField(
//       controller: ctrl,
//       obscureText: isPassword && obscure,
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Color(0xFFA1A6B3)),
//         filled: true, fillColor: const Color(0xFF0F1218),
//         suffixIcon: isPassword
//             ? IconButton(
//             icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFA1A6B3)),
//             onPressed: () => setState(() => obscure = !obscure))
//             : null,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//       ),
//     );
//   }
// }