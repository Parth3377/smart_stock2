import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'register_screen.dart';
import '../../routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_providers.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {

  final emailController    = TextEditingController();
  final passwordController = TextEditingController();

  late AnimationController _controller;
  late Animation<double>   _scale;

  bool loginLoading  = false; // for email login button
  bool googleLoading = false; // for google button — separate!
  bool obscure       = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════
  //  EMAIL LOGIN
  // ══════════════════════════════════════════════════════════════
  Future<void> _loginWithEmail() async {
    final email    = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _snack('Please enter your email and password.');
      return;
    }

    setState(() => loginLoading = true);

    final result = await context.read<FirebaseAuthProvider>()
        .login(email, password);

    if (!mounted) return;
    setState(() => loginLoading = false);

    if (result.success) {
      _navigateTo(result.isAdmin);
    } else {
      _snack(result.errorMessage ?? 'Login failed.');
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  GOOGLE LOGIN
  // ══════════════════════════════════════════════════════════════
  Future<void> _loginWithGoogle() async {
    setState(() => googleLoading = true);

    final result = await context.read<FirebaseAuthProvider>()
        .signInWithGoogle();

    if (!mounted) return;
    setState(() => googleLoading = false);

    if (result.success) {
      _navigateTo(result.isAdmin);
    } else {
      // 'cancelled' means user closed popup — don't show error
      if (result.errorMessage != null &&
          result.errorMessage != 'cancelled') {
        _snack(result.errorMessage!);
      }
    }
  }

  // ══════════════════════════════════════════════════════════════
  //  NAVIGATE — using named routes (keeps MultiProvider intact)
  // ══════════════════════════════════════════════════════════════
  void _navigateTo(bool isAdmin) {
    if (isAdmin) {
      final user = context.read<FirebaseAuthProvider>().currentUser;
      context.read<AdminAuthProvider>().loginAsAdmin(
        user?.email ?? '',
        name: user?.displayName ?? 'Admin',
      );
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.adminDashboard, (r) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.dashboard, (r) => false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    ));
  }

  // ══════════════════════════════════════════════════════════════
  //  UI
  // ══════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B0E14),
              Color(0xFF101626),
              Color(0xFF0B0E14),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(children: [

              // LOGO
              Image.asset('assets/logo.png', height: 190),
              const SizedBox(height: 10),

              // CARD
              Container(
                width: size.width > 600 ? 420 : size.width * 0.92,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 32),
                decoration: BoxDecoration(
                  color: const Color(0xFF161A22),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 35,
                      offset: const Offset(0, 25),
                    ),
                  ],
                ),
                child: Column(children: [

                  const Text('Welcome Back',
                      style: TextStyle(fontSize: 22,
                          fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 6),
                  const Text('Login to manage your orders & inventory',
                      style: TextStyle(color: Color(0xFFA1A6B3), fontSize: 13)),
                  const SizedBox(height: 24),

                  // Email field
                  _field('Email Address', emailController),
                  const SizedBox(height: 16),

                  // Password field
                  _field('Password', passwordController, isPassword: true),
                  const SizedBox(height: 24),

                  // ── LOGIN BUTTON ───────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: loginLoading ? null : _loginWithEmail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E6CF6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: loginLoading
                          ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white70, strokeWidth: 2))
                          : const Text('Login',
                          style: TextStyle(fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.black)),
                    ),
                  ),

                  const SizedBox(height: 22),
                  Row(children: const [
                    Expanded(child: Divider(color: Color(0xFF2A2F3A))),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('OR',
                            style: TextStyle(color: Color(0xFFA1A6B3)))),
                    Expanded(child: Divider(color: Color(0xFF2A2F3A))),
                  ]),
                  const SizedBox(height: 18),

                  // ── GOOGLE BUTTON ──────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: googleLoading ? null : _loginWithGoogle,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2A2F3A)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: googleLoading
                          ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.blue, strokeWidth: 2))
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20, height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: const Center(
                              child: Text('G',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4285F4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text('Continue with Google',
                              style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // REGISTER LINK
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.register),
                    child: const Text('New here? Create an account',
                        style: TextStyle(color: Color(0xFFA1A6B3))),
                  ),

                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {bool isPassword = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPassword && obscure,
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
// import 'package:provider/provider.dart';
// import 'register_screen.dart';
// import '../../routes/app_routes.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/admin_providers.dart';
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen>
//     with SingleTickerProviderStateMixin {
//
//   final emailController = TextEditingController();
//   final passwordController = TextEditingController();
//
//   late AnimationController _controller;
//   late Animation<double> _scale;
//   late Animation<double> _fade;
//
//   bool loading = false;
//   bool googleLoading = false;
//   bool obscure = true;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     );
//
//     _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: Curves.easeOutBack,
//       ),
//     );
//
//     _fade = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeIn,
//     );
//
//     _controller.forward();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   /// 🔐 FIREBASE LOGIN using FirebaseAuthProvider
//   Future<void> loginUser() async {
//     final email    = emailController.text.trim();
//     final password = passwordController.text.trim();
//
//     if (email.isEmpty || password.isEmpty) {
//       _showSnack('Please enter your email and password.');
//       return;
//     }
//
//     setState(() => loading = true);
//
//     final authProvider = context.read<FirebaseAuthProvider>();
//     final result = await authProvider.login(email, password);
//
//     setState(() => loading = false);
//     if (!mounted) return;
//
//     if (result.success) {
//       if (result.isAdmin) {
//         context.read<AdminAuthProvider>().loginAsAdmin(
//             email, name: authProvider.currentUser?.displayName ?? 'Admin');
//         Navigator.pushNamedAndRemoveUntil(
//             context, AppRoutes.adminDashboard, (r) => false);
//       } else {
//         Navigator.pushNamedAndRemoveUntil(
//             context, AppRoutes.dashboard, (r) => false);
//       }
//     } else {
//       _showSnack(authProvider.errorMessage ?? 'Login failed.');
//     }
//   }
//
//   /// 🔐 GOOGLE SIGN-IN using FirebaseAuthProvider
//   Future<void> googleLogin() async {
//     setState(() => googleLoading = true);
//
//     final authProvider = context.read<FirebaseAuthProvider>();
//     final result = await authProvider.signInWithGoogle();
//
//     setState(() => googleLoading = false);
//     if (!mounted) return;
//
//     if (result.success) {
//       if (result.isAdmin) {
//         context.read<AdminAuthProvider>().loginAsAdmin(
//             authProvider.currentUser?.email ?? '',
//             name: authProvider.currentUser?.displayName ?? 'Admin');
//         Navigator.pushNamedAndRemoveUntil(
//             context, AppRoutes.adminDashboard, (r) => false);
//       } else {
//         Navigator.pushNamedAndRemoveUntil(
//             context, AppRoutes.dashboard, (r) => false);
//       }
//     } else {
//       if (result.errorMessage != null &&
//           !result.errorMessage!.contains('cancelled')) {
//         _showSnack(authProvider.errorMessage ?? 'Google sign-in failed.');
//       }
//     }
//   }
//
//   void _showSnack(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text(msg),
//       backgroundColor: Colors.redAccent,
//       behavior: SnackBarBehavior.floating,
//       duration: const Duration(seconds: 4),
//     ));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//
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
//
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//
//             child: Column(
//               children: [
//
//                 /// LOGO
//                 Image.asset(
//                   "assets/logo.png",
//                   height: 190,
//                 ),
//
//                 const SizedBox(height: 10),
//
//                 /// LOGIN CARD
//                 Container(
//                   width: size.width > 600 ? 420 : size.width * 0.92,
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 28,
//                       vertical: 32),
//
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF161A22),
//                     borderRadius: BorderRadius.circular(18),
//
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.5),
//                         blurRadius: 35,
//                         offset: const Offset(0, 25),
//                       ),
//                     ],
//                   ),
//
//                   child: Column(
//                     children: [
//
//                       const Text(
//                         "Welcome Back",
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//
//                       const SizedBox(height: 6),
//
//                       const Text(
//                         "Login to manage your orders & inventory",
//                         style: TextStyle(
//                           color: Color(0xFFA1A6B3),
//                           fontSize: 13,
//                         ),
//                       ),
//
//                       const SizedBox(height: 24),
//
//                       _inputField(
//                         "Email Address",
//                         emailController,
//                       ),
//
//                       const SizedBox(height: 16),
//
//                       _inputField(
//                         "Password",
//                         passwordController,
//                         isPassword: true,
//                       ),
//
//                       const SizedBox(height: 24),
//
//                       /// LOGIN BUTTON
//                       SizedBox(
//                         width: double.infinity,
//                         height: 48,
//
//                         child: ElevatedButton(
//                           onPressed: loading ? null : loginUser,
//
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF2E6CF6),
//
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//
//                           child: loading
//                               ? const CircularProgressIndicator(
//                             color: Colors.white70,
//                           )
//                               : const Text(
//                             "Login",
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w900,
//                               color: Colors.black,
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 22),
//
//                       Row(
//                         children: const [
//                           Expanded(
//                             child: Divider(color: Color(0xFF2A2F3A)),
//                           ),
//
//                           Padding(
//                             padding:
//                             EdgeInsets.symmetric(horizontal: 10),
//
//                             child: Text(
//                               "OR",
//                               style: TextStyle(
//                                 color: Color(0xFFA1A6B3),
//                               ),
//                             ),
//                           ),
//
//                           Expanded(
//                             child: Divider(color: Color(0xFF2A2F3A)),
//                           ),
//                         ],
//                       ),
//
//                       const SizedBox(height: 18),
//
//                       /// GOOGLE BUTTON
//                       GestureDetector(
//                         onTap: googleLoading ? null : googleLogin,
//                         child: Container(
//                           height: 48,
//                           decoration: BoxDecoration(
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: const Color(0xFF2A2F3A),
//                             ),
//                           ),
//                           child: Center(
//                             child: googleLoading
//                                 ? const SizedBox(
//                               width: 22,
//                               height: 22,
//                               child: CircularProgressIndicator(
//                                 color: Colors.blue,
//                                 strokeWidth: 2,
//                               ),
//                             )
//                                 : Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Container(
//                                   width: 20, height: 20,
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(3),
//                                   ),
//                                   child: const Center(
//                                     child: Text('G',
//                                       style: TextStyle(
//                                         fontSize: 13,
//                                         fontWeight: FontWeight.bold,
//                                         color: Color(0xFF4285F4),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 10),
//                                 const Text(
//                                   "Continue with Google",
//                                   style: TextStyle(color: Colors.blue),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       const SizedBox(height: 18),
//
//                       /// REGISTER
//                       TextButton(
//                         onPressed: () {
//                           Navigator.pushNamed(context, AppRoutes.register);
//                         },
//                         child: const Text(
//                           "New here? Create an account",
//                           style: TextStyle(
//                             color: Color(0xFFA1A6B3),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _inputField(
//       String label,
//       TextEditingController controller,
//       {bool isPassword = false}
//       ) {
//
//     return TextField(
//       controller: controller,
//       obscureText: isPassword && obscure,
//
//       style: const TextStyle(color: Colors.white),
//
//       decoration: InputDecoration(
//         labelText: label,
//
//         labelStyle: const TextStyle(
//           color: Color(0xFFA1A6B3),
//         ),
//
//         filled: true,
//         fillColor: const Color(0xFF0F1218),
//
//         suffixIcon: isPassword
//             ? IconButton(
//           icon: Icon(
//             obscure
//                 ? Icons.visibility_off
//                 : Icons.visibility,
//
//             color: const Color(0xFFA1A6B3),
//           ),
//
//           onPressed: () {
//             setState(() {
//               obscure = !obscure;
//             });
//           },
//         )
//             : null,
//
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
// }
//
//
//
// // import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'register_screen.dart';
// // import '../../routes/app_routes.dart';
// // import '../../providers/auth_provider.dart';
// // import '../../providers/admin_providers.dart';
// //
// // class LoginScreen extends StatefulWidget {
// //   const LoginScreen({super.key});
// //
// //   @override
// //   State<LoginScreen> createState() => _LoginScreenState();
// // }
// //
// // class _LoginScreenState extends State<LoginScreen>
// //     with SingleTickerProviderStateMixin {
// //
// //   final emailController = TextEditingController();
// //   final passwordController = TextEditingController();
// //
// //   late AnimationController _controller;
// //   late Animation<double> _scale;
// //   late Animation<double> _fade;
// //
// //   bool loading = false;
// //   bool obscure = true;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     _controller = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 900),
// //     );
// //
// //     _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
// //       CurvedAnimation(
// //         parent: _controller,
// //         curve: Curves.easeOutBack,
// //       ),
// //     );
// //
// //     _fade = CurvedAnimation(
// //       parent: _controller,
// //       curve: Curves.easeIn,
// //     );
// //
// //     _controller.forward();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _controller.dispose();
// //     super.dispose();
// //   }
// //
// //   /// 🔐 FIREBASE LOGIN using FirebaseAuthProvider
// //   Future<void> loginUser() async {
// //     final email    = emailController.text.trim();
// //     final password = passwordController.text.trim();
// //
// //     if (email.isEmpty || password.isEmpty) {
// //       _showSnack('Please enter your email and password.');
// //       return;
// //     }
// //
// //     setState(() => loading = true);
// //
// //     final authProvider = context.read<FirebaseAuthProvider>();
// //     final result = await authProvider.login(email, password);
// //
// //     setState(() => loading = false);
// //     if (!mounted) return;
// //
// //     if (result.success) {
// //       if (result.isAdmin) {
// //         context.read<AdminAuthProvider>().loginAsAdmin(
// //             email, name: authProvider.currentUser?.displayName ?? 'Admin');
// //         Navigator.pushNamedAndRemoveUntil(
// //             context, AppRoutes.adminDashboard, (r) => false);
// //       } else {
// //         Navigator.pushNamedAndRemoveUntil(
// //             context, AppRoutes.dashboard, (r) => false);
// //       }
// //     } else {
// //       _showSnack(authProvider.errorMessage ?? 'Login failed.');
// //     }
// //   }
// //
// //   /// 🔐 GOOGLE SIGN-IN using FirebaseAuthProvider
// //   Future<void> googleLogin() async {
// //     setState(() => loading = true);
// //
// //     final authProvider = context.read<FirebaseAuthProvider>();
// //     final result = await authProvider.signInWithGoogle();
// //
// //     setState(() => loading = false);
// //     if (!mounted) return;
// //
// //     if (result.success) {
// //       if (result.isAdmin) {
// //         context.read<AdminAuthProvider>().loginAsAdmin(
// //             authProvider.currentUser?.email ?? '',
// //             name: authProvider.currentUser?.displayName ?? 'Admin');
// //         Navigator.pushNamedAndRemoveUntil(
// //             context, AppRoutes.adminDashboard, (r) => false);
// //       } else {
// //         Navigator.pushNamedAndRemoveUntil(
// //             context, AppRoutes.dashboard, (r) => false);
// //       }
// //     } else {
// //       if (result.errorMessage != null &&
// //           !result.errorMessage!.contains('cancelled')) {
// //         _showSnack(authProvider.errorMessage ?? 'Google sign-in failed.');
// //       }
// //     }
// //   }
// //
// //   void _showSnack(String msg) {
// //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
// //       content: Text(msg),
// //       backgroundColor: Colors.redAccent,
// //       behavior: SnackBarBehavior.floating,
// //       duration: const Duration(seconds: 4),
// //     ));
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //
// //     final size = MediaQuery.of(context).size;
// //
// //     return Scaffold(
// //       body: Container(
// //         width: double.infinity,
// //         height: double.infinity,
// //
// //         decoration: const BoxDecoration(
// //           gradient: LinearGradient(
// //             begin: Alignment.topLeft,
// //             end: Alignment.bottomRight,
// //             colors: [
// //               Color(0xFF0B0E14),
// //               Color(0xFF101626),
// //               Color(0xFF0B0E14),
// //             ],
// //           ),
// //         ),
// //
// //         child: Center(
// //           child: SingleChildScrollView(
// //             padding: const EdgeInsets.all(24),
// //
// //             child: Column(
// //               children: [
// //
// //                 /// LOGO
// //                 Image.asset(
// //                   "assets/logo.png",
// //                   height: 190,
// //                 ),
// //
// //                 const SizedBox(height: 10),
// //
// //                 /// LOGIN CARD
// //                 Container(
// //                   width: size.width > 600 ? 420 : size.width * 0.92,
// //                   padding: const EdgeInsets.symmetric(
// //                       horizontal: 28,
// //                       vertical: 32),
// //
// //                   decoration: BoxDecoration(
// //                     color: const Color(0xFF161A22),
// //                     borderRadius: BorderRadius.circular(18),
// //
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.black.withOpacity(0.5),
// //                         blurRadius: 35,
// //                         offset: const Offset(0, 25),
// //                       ),
// //                     ],
// //                   ),
// //
// //                   child: Column(
// //                     children: [
// //
// //                       const Text(
// //                         "Welcome Back",
// //                         style: TextStyle(
// //                           fontSize: 22,
// //                           fontWeight: FontWeight.w600,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //
// //                       const SizedBox(height: 6),
// //
// //                       const Text(
// //                         "Login to manage your orders & inventory",
// //                         style: TextStyle(
// //                           color: Color(0xFFA1A6B3),
// //                           fontSize: 13,
// //                         ),
// //                       ),
// //
// //                       const SizedBox(height: 24),
// //
// //                       _inputField(
// //                         "Email Address",
// //                         emailController,
// //                       ),
// //
// //                       const SizedBox(height: 16),
// //
// //                       _inputField(
// //                         "Password",
// //                         passwordController,
// //                         isPassword: true,
// //                       ),
// //
// //                       const SizedBox(height: 24),
// //
// //                       /// LOGIN BUTTON
// //                       SizedBox(
// //                         width: double.infinity,
// //                         height: 48,
// //
// //                         child: ElevatedButton(
// //                           onPressed: loading ? null : loginUser,
// //
// //                           style: ElevatedButton.styleFrom(
// //                             backgroundColor: const Color(0xFF2E6CF6),
// //
// //                             shape: RoundedRectangleBorder(
// //                               borderRadius: BorderRadius.circular(12),
// //                             ),
// //                           ),
// //
// //                           child: loading
// //                               ? const CircularProgressIndicator(
// //                             color: Colors.white70,
// //                           )
// //                               : const Text(
// //                             "Login",
// //                             style: TextStyle(
// //                               fontSize: 16,
// //                               fontWeight: FontWeight.w900,
// //                               color: Colors.black,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //
// //                       const SizedBox(height: 22),
// //
// //                       Row(
// //                         children: const [
// //                           Expanded(
// //                             child: Divider(color: Color(0xFF2A2F3A)),
// //                           ),
// //
// //                           Padding(
// //                             padding:
// //                             EdgeInsets.symmetric(horizontal: 10),
// //
// //                             child: Text(
// //                               "OR",
// //                               style: TextStyle(
// //                                 color: Color(0xFFA1A6B3),
// //                               ),
// //                             ),
// //                           ),
// //
// //                           Expanded(
// //                             child: Divider(color: Color(0xFF2A2F3A)),
// //                           ),
// //                         ],
// //                       ),
// //
// //                       const SizedBox(height: 18),
// //
// //                       /// GOOGLE BUTTON
// //                       GestureDetector(
// //                         onTap: googleLogin,
// //
// //                         child: Container(
// //                           height: 48,
// //
// //                           decoration: BoxDecoration(
// //                             borderRadius: BorderRadius.circular(12),
// //
// //                             border: Border.all(
// //                               color: const Color(0xFF2A2F3A),
// //                             ),
// //                           ),
// //
// //                           child: const Center(
// //                             child: Text(
// //                               "Continue with Google",
// //                               style: TextStyle(
// //                                 color: Colors.blue,
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //
// //                       const SizedBox(height: 18),
// //
// //                       /// REGISTER
// //                       TextButton(
// //                         onPressed: () {
// //                           Navigator.pushNamed(context, AppRoutes.register);
// //                         },
// //                         child: const Text(
// //                           "New here? Create an account",
// //                           style: TextStyle(
// //                             color: Color(0xFFA1A6B3),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _inputField(
// //       String label,
// //       TextEditingController controller,
// //       {bool isPassword = false}
// //       ) {
// //
// //     return TextField(
// //       controller: controller,
// //       obscureText: isPassword && obscure,
// //
// //       style: const TextStyle(color: Colors.white),
// //
// //       decoration: InputDecoration(
// //         labelText: label,
// //
// //         labelStyle: const TextStyle(
// //           color: Color(0xFFA1A6B3),
// //         ),
// //
// //         filled: true,
// //         fillColor: const Color(0xFF0F1218),
// //
// //         suffixIcon: isPassword
// //             ? IconButton(
// //           icon: Icon(
// //             obscure
// //                 ? Icons.visibility_off
// //                 : Icons.visibility,
// //
// //             color: const Color(0xFFA1A6B3),
// //           ),
// //
// //           onPressed: () {
// //             setState(() {
// //               obscure = !obscure;
// //             });
// //           },
// //         )
// //             : null,
// //
// //         border: OutlineInputBorder(
// //           borderRadius: BorderRadius.circular(12),
// //           borderSide: BorderSide.none,
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// //
// // // import 'package:flutter/material.dart';
// // // import 'package:provider/provider.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'register_screen.dart';
// // // import '../../routes/app_routes.dart';
// // // import '../../providers/admin_providers.dart';
// // //
// // // class LoginScreen extends StatefulWidget {
// // //   const LoginScreen({super.key});
// // //
// // //   @override
// // //   State<LoginScreen> createState() => _LoginScreenState();
// // // }
// // //
// // // class _LoginScreenState extends State<LoginScreen>
// // //     with SingleTickerProviderStateMixin {
// // //
// // //   final emailController = TextEditingController();
// // //   final passwordController = TextEditingController();
// // //
// // //   late AnimationController _controller;
// // //   late Animation<double> _scale;
// // //   late Animation<double> _fade;
// // //
// // //   bool loading = false;
// // //   bool obscure = true;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //
// // //     _controller = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 900),
// // //     );
// // //
// // //     _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
// // //       CurvedAnimation(
// // //         parent: _controller,
// // //         curve: Curves.easeOutBack,
// // //       ),
// // //     );
// // //
// // //     _fade = CurvedAnimation(
// // //       parent: _controller,
// // //       curve: Curves.easeIn,
// // //     );
// // //
// // //     _controller.forward();
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _controller.dispose();
// // //     super.dispose();
// // //   }
// // //
// // //   static const List<String> _adminEmails = ['admin@smartstock.com'];
// // //   bool _isAdmin(String email) =>
// // //       _adminEmails.contains(email.toLowerCase().trim());
// // //
// // //   /// 🔐 FIREBASE LOGIN
// // //   Future<void> loginUser() async {
// // //     final email    = emailController.text.trim();
// // //     final password = passwordController.text.trim();
// // //
// // //     if (email.isEmpty || password.isEmpty) {
// // //       _showSnack('Please enter your email and password.');
// // //       return;
// // //     }
// // //
// // //     setState(() => loading = true);
// // //
// // //     try {
// // //       final cred = await FirebaseAuth.instance
// // //           .signInWithEmailAndPassword(email: email, password: password);
// // //
// // //       setState(() => loading = false);
// // //       if (!mounted) return;
// // //
// // //       _navigateAfterLogin(cred.user!);
// // //       _syncFirestore(cred.user!);
// // //
// // //     } on FirebaseAuthException catch (e) {
// // //       setState(() => loading = false);
// // //       _showSnack(_authError(e.code));
// // //     } catch (e) {
// // //       setState(() => loading = false);
// // //       _showSnack('Login failed. Please try again.');
// // //     }
// // //   }
// // //
// // //   Future<void> googleLogin() async {
// // //     setState(() => loading = true);
// // //     try {
// // //       final provider = GoogleAuthProvider()
// // //         ..addScope('email')..addScope('profile');
// // //       final cred = await FirebaseAuth.instance.signInWithPopup(provider);
// // //       setState(() => loading = false);
// // //       if (!mounted) return;
// // //       _navigateAfterLogin(cred.user!);
// // //       _syncFirestore(cred.user!);
// // //     } on FirebaseAuthException catch (e) {
// // //       setState(() => loading = false);
// // //       if (e.code == 'popup-closed-by-user' ||
// // //           e.code == 'cancelled-popup-request') return;
// // //       _showSnack('Google sign-in failed: ${e.message ?? e.code}');
// // //     } catch (e) {
// // //       setState(() => loading = false);
// // //       _showSnack('Google sign-in failed. Try again.');
// // //     }
// // //   }
// // //
// // //   // ── Navigate using named routes (CRITICAL: keeps MultiProvider intact) ──
// // //   void _navigateAfterLogin(User user) {
// // //     if (_isAdmin(user.email ?? '')) {
// // //       context.read<AdminAuthProvider>().loginAsAdmin(
// // //           user.email ?? '', name: user.displayName ?? 'Admin');
// // //       Navigator.pushNamedAndRemoveUntil(
// // //           context, AppRoutes.adminDashboard, (r) => false);
// // //     } else {
// // //       Navigator.pushNamedAndRemoveUntil(
// // //           context, AppRoutes.dashboard, (r) => false);
// // //     }
// // //   }
// // //
// // //   Future<void> _syncFirestore(User user) async {
// // //     try {
// // //       final isAdmin = _isAdmin(user.email ?? '');
// // //       await FirebaseFirestore.instance
// // //           .collection(isAdmin ? 'admins' : 'users')
// // //           .doc(user.uid)
// // //           .set({
// // //         'uid': user.uid, 'name': user.displayName ?? '',
// // //         'email': user.email ?? '', 'photoUrl': user.photoURL ?? '',
// // //         'role': isAdmin ? 'Super Admin' : 'client',
// // //         'updatedAt': FieldValue.serverTimestamp(),
// // //       }, SetOptions(merge: true));
// // //     } catch (_) {}
// // //   }
// // //
// // //   String _authError(String code) {
// // //     switch (code) {
// // //       case 'user-not-found':         return 'No account found. Please register first.';
// // //       case 'wrong-password':         return 'Wrong password. Please try again.';
// // //       case 'invalid-credential':     return 'Wrong email or password.';
// // //       case 'invalid-email':          return 'Please enter a valid email.';
// // //       case 'user-disabled':          return 'This account is disabled.';
// // //       case 'too-many-requests':      return 'Too many attempts. Please wait.';
// // //       case 'network-request-failed': return 'No internet connection.';
// // //       default:                       return 'Login failed (${code}).';
// // //     }
// // //   }
// // //
// // //   void _showSnack(String msg) {
// // //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
// // //       content: Text(msg), backgroundColor: Colors.redAccent,
// // //       behavior: SnackBarBehavior.floating,
// // //       duration: const Duration(seconds: 4),
// // //     ));
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //
// // //     final size = MediaQuery.of(context).size;
// // //
// // //     return Scaffold(
// // //       body: Container(
// // //         width: double.infinity,
// // //         height: double.infinity,
// // //
// // //         decoration: const BoxDecoration(
// // //           gradient: LinearGradient(
// // //             begin: Alignment.topLeft,
// // //             end: Alignment.bottomRight,
// // //             colors: [
// // //               Color(0xFF0B0E14),
// // //               Color(0xFF101626),
// // //               Color(0xFF0B0E14),
// // //             ],
// // //           ),
// // //         ),
// // //
// // //         child: Center(
// // //           child: SingleChildScrollView(
// // //             padding: const EdgeInsets.all(24),
// // //
// // //             child: Column(
// // //               children: [
// // //
// // //                 /// LOGO
// // //                 Image.asset(
// // //                   "assets/logo.png",
// // //                   height: 190,
// // //                 ),
// // //
// // //                 const SizedBox(height: 10),
// // //
// // //                 /// LOGIN CARD
// // //                 Container(
// // //                   width: size.width > 600 ? 420 : size.width * 0.92,
// // //                   padding: const EdgeInsets.symmetric(
// // //                       horizontal: 28,
// // //                       vertical: 32),
// // //
// // //                   decoration: BoxDecoration(
// // //                     color: const Color(0xFF161A22),
// // //                     borderRadius: BorderRadius.circular(18),
// // //
// // //                     boxShadow: [
// // //                       BoxShadow(
// // //                         color: Colors.black.withOpacity(0.5),
// // //                         blurRadius: 35,
// // //                         offset: const Offset(0, 25),
// // //                       ),
// // //                     ],
// // //                   ),
// // //
// // //                   child: Column(
// // //                     children: [
// // //
// // //                       const Text(
// // //                         "Welcome Back",
// // //                         style: TextStyle(
// // //                           fontSize: 22,
// // //                           fontWeight: FontWeight.w600,
// // //                           color: Colors.white,
// // //                         ),
// // //                       ),
// // //
// // //                       const SizedBox(height: 6),
// // //
// // //                       const Text(
// // //                         "Login to manage your orders & inventory",
// // //                         style: TextStyle(
// // //                           color: Color(0xFFA1A6B3),
// // //                           fontSize: 13,
// // //                         ),
// // //                       ),
// // //
// // //                       const SizedBox(height: 24),
// // //
// // //                       _inputField(
// // //                         "Email Address",
// // //                         emailController,
// // //                       ),
// // //
// // //                       const SizedBox(height: 16),
// // //
// // //                       _inputField(
// // //                         "Password",
// // //                         passwordController,
// // //                         isPassword: true,
// // //                       ),
// // //
// // //                       const SizedBox(height: 24),
// // //
// // //                       /// LOGIN BUTTON
// // //                       SizedBox(
// // //                         width: double.infinity,
// // //                         height: 48,
// // //
// // //                         child: ElevatedButton(
// // //                           onPressed: loading ? null : loginUser,
// // //
// // //                           style: ElevatedButton.styleFrom(
// // //                             backgroundColor: const Color(0xFF2E6CF6),
// // //
// // //                             shape: RoundedRectangleBorder(
// // //                               borderRadius: BorderRadius.circular(12),
// // //                             ),
// // //                           ),
// // //
// // //                           child: loading
// // //                               ? const CircularProgressIndicator(
// // //                             color: Colors.white70,
// // //                           )
// // //                               : const Text(
// // //                             "Login",
// // //                             style: TextStyle(
// // //                               fontSize: 16,
// // //                               fontWeight: FontWeight.w900,
// // //                               color: Colors.black,
// // //                             ),
// // //                           ),
// // //                         ),
// // //                       ),
// // //
// // //                       const SizedBox(height: 22),
// // //
// // //                       Row(
// // //                         children: const [
// // //                           Expanded(
// // //                             child: Divider(color: Color(0xFF2A2F3A)),
// // //                           ),
// // //
// // //                           Padding(
// // //                             padding:
// // //                             EdgeInsets.symmetric(horizontal: 10),
// // //
// // //                             child: Text(
// // //                               "OR",
// // //                               style: TextStyle(
// // //                                 color: Color(0xFFA1A6B3),
// // //                               ),
// // //                             ),
// // //                           ),
// // //
// // //                           Expanded(
// // //                             child: Divider(color: Color(0xFF2A2F3A)),
// // //                           ),
// // //                         ],
// // //                       ),
// // //
// // //                       const SizedBox(height: 18),
// // //
// // //                       /// GOOGLE BUTTON
// // //                       GestureDetector(
// // //                         onTap: googleLogin,
// // //
// // //                         child: Container(
// // //                           height: 48,
// // //
// // //                           decoration: BoxDecoration(
// // //                             borderRadius: BorderRadius.circular(12),
// // //
// // //                             border: Border.all(
// // //                               color: const Color(0xFF2A2F3A),
// // //                             ),
// // //                           ),
// // //
// // //                           child: const Center(
// // //                             child: Text(
// // //                               "Continue with Google",
// // //                               style: TextStyle(
// // //                                 color: Colors.blue,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ),
// // //                       ),
// // //
// // //                       const SizedBox(height: 18),
// // //
// // //                       /// REGISTER
// // //                       TextButton(
// // //                         onPressed: () {
// // //                           Navigator.pushNamed(context, AppRoutes.register);
// // //                         },
// // //
// // //                         child: const Text(
// // //                           "New here? Create an account",
// // //                           style: TextStyle(
// // //                             color: Color(0xFFA1A6B3),
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _inputField(
// // //       String label,
// // //       TextEditingController controller,
// // //       {bool isPassword = false}
// // //       ) {
// // //
// // //     return TextField(
// // //       controller: controller,
// // //       obscureText: isPassword && obscure,
// // //
// // //       style: const TextStyle(color: Colors.white),
// // //
// // //       decoration: InputDecoration(
// // //         labelText: label,
// // //
// // //         labelStyle: const TextStyle(
// // //           color: Color(0xFFA1A6B3),
// // //         ),
// // //
// // //         filled: true,
// // //         fillColor: const Color(0xFF0F1218),
// // //
// // //         suffixIcon: isPassword
// // //             ? IconButton(
// // //           icon: Icon(
// // //             obscure
// // //                 ? Icons.visibility_off
// // //                 : Icons.visibility,
// // //
// // //             color: const Color(0xFFA1A6B3),
// // //           ),
// // //
// // //           onPressed: () {
// // //             setState(() {
// // //               obscure = !obscure;
// // //             });
// // //           },
// // //         )
// // //             : null,
// // //
// // //         border: OutlineInputBorder(
// // //           borderRadius: BorderRadius.circular(12),
// // //           borderSide: BorderSide.none,
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// //
// //
// // // import 'package:flutter/material.dart';
// // // import 'package:provider/provider.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'register_screen.dart';
// // // import '../../routes/app_routes.dart';
// // // import '../../providers/admin_providers.dart';
// // //
// // // class LoginScreen extends StatefulWidget {
// // //   const LoginScreen({super.key});
// // //
// // //   @override
// // //   State<LoginScreen> createState() => _LoginScreenState();
// // // }
// // //
// // // class _LoginScreenState extends State<LoginScreen>
// // //     with SingleTickerProviderStateMixin {
// // //
// // //   final emailController = TextEditingController();
// // //   final passwordController = TextEditingController();
// // //
// // //   late AnimationController _controller;
// // //   late Animation<double> _scale;
// // //   late Animation<double> _fade;
// // //
// // //   bool loading = false;
// // //   bool obscure = true;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //
// // //     _controller = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 900),
// // //     );
// // //
// // //     _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
// // //       CurvedAnimation(
// // //         parent: _controller,
// // //         curve: Curves.easeOutBack,
// // //       ),
// // //     );
// // //
// // //     _fade = CurvedAnimation(
// // //       parent: _controller,
// // //       curve: Curves.easeIn,
// // //     );
// // //
// // //     _controller.forward();
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _controller.dispose();
// // //     super.dispose();
// // //   }
// // //
// // //   // Admin emails — add more here if needed
// // //   static const List<String> _adminEmails = ['admin@smartstock.com'];
// // //   bool _isAdmin(String email) => _adminEmails.contains(email.toLowerCase().trim());
// // //
// // //   /// 🔐 FIREBASE LOGIN
// // //   Future<void> loginUser() async {
// // //     final email    = emailController.text.trim();
// // //     final password = passwordController.text.trim();
// // //
// // //     if (email.isEmpty || password.isEmpty) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text('Please enter your email and password.')),
// // //       );
// // //       return;
// // //     }
// // //
// // //     setState(() => loading = true);
// // //
// // //     try {
// // //       final cred = await FirebaseAuth.instance
// // //           .signInWithEmailAndPassword(email: email, password: password);
// // //
// // //       setState(() => loading = false);
// // //       if (!mounted) return;
// // //
// // //       // Navigate using NAMED ROUTES — stays inside MultiProvider tree
// // //       if (_isAdmin(cred.user?.email ?? '')) {
// // //         context.read<AdminAuthProvider>().loginAsAdmin(
// // //             email, name: cred.user?.displayName ?? 'Admin');
// // //         Navigator.pushNamedAndRemoveUntil(
// // //             context, AppRoutes.adminDashboard, (r) => false);
// // //       } else {
// // //         Navigator.pushNamedAndRemoveUntil(
// // //             context, AppRoutes.dashboard, (r) => false);
// // //       }
// // //
// // //       // Sync to Firestore in background (non-blocking)
// // //       _syncToFirestore(cred.user!);
// // //
// // //     } on FirebaseAuthException catch (e) {
// // //       setState(() => loading = false);
// // //       String msg;
// // //       switch (e.code) {
// // //         case 'user-not-found':     msg = 'No account found. Please register first.'; break;
// // //         case 'wrong-password':     msg = 'Wrong password. Please try again.'; break;
// // //         case 'invalid-credential': msg = 'Wrong email or password.'; break;
// // //         case 'invalid-email':      msg = 'Please enter a valid email.'; break;
// // //         case 'too-many-requests':  msg = 'Too many attempts. Please wait.'; break;
// // //         default:                   msg = 'Login failed (${e.code}).';
// // //       }
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(content: Text(msg), backgroundColor: Colors.redAccent,
// // //             behavior: SnackBarBehavior.floating),
// // //       );
// // //     } catch (e) {
// // //       setState(() => loading = false);
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(content: Text('Login failed: ${e.toString()}'),
// // //             backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
// // //       );
// // //     }
// // //   }
// // //
// // //   Future<void> googleLogin() async {
// // //     setState(() => loading = true);
// // //     try {
// // //       final googleProvider = GoogleAuthProvider()
// // //         ..addScope('email')
// // //         ..addScope('profile');
// // //       final cred = await FirebaseAuth.instance.signInWithPopup(googleProvider);
// // //       setState(() => loading = false);
// // //       if (!mounted) return;
// // //       if (_isAdmin(cred.user?.email ?? '')) {
// // //         context.read<AdminAuthProvider>().loginAsAdmin(
// // //             cred.user?.email ?? '', name: cred.user?.displayName ?? 'Admin');
// // //         Navigator.pushNamedAndRemoveUntil(
// // //             context, AppRoutes.adminDashboard, (r) => false);
// // //       } else {
// // //         Navigator.pushNamedAndRemoveUntil(
// // //             context, AppRoutes.dashboard, (r) => false);
// // //       }
// // //       _syncToFirestore(cred.user!);
// // //     } on FirebaseAuthException catch (e) {
// // //       setState(() => loading = false);
// // //       if (e.code == 'popup-closed-by-user' || e.code == 'cancelled-popup-request') return;
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         SnackBar(content: Text('Google sign-in failed: ${e.message ?? e.code}'),
// // //             backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
// // //       );
// // //     } catch (e) {
// // //       setState(() => loading = false);
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text('Google sign-in failed. Please try again.'),
// // //             backgroundColor: Colors.redAccent, behavior: SnackBarBehavior.floating),
// // //       );
// // //     }
// // //   }
// // //
// // //   Future<void> _syncToFirestore(User user) async {
// // //     try {
// // //       final isAdmin = _isAdmin(user.email ?? '');
// // //       await FirebaseFirestore.instance
// // //           .collection(isAdmin ? 'admins' : 'users')
// // //           .doc(user.uid)
// // //           .set({
// // //         'uid': user.uid, 'name': user.displayName ?? '',
// // //         'email': user.email ?? '', 'photoUrl': user.photoURL ?? '',
// // //         'role': isAdmin ? 'Super Admin' : 'client',
// // //         'updatedAt': FieldValue.serverTimestamp(),
// // //       }, SetOptions(merge: true));
// // //     } catch (_) {} // silent
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //
// // //     final size = MediaQuery.of(context).size;
// // //
// // //     return Scaffold(
// // //       body: Container(
// // //         width: double.infinity,
// // //         height: double.infinity,
// // //
// // //         decoration: const BoxDecoration(
// // //           gradient: LinearGradient(
// // //             begin: Alignment.topLeft,
// // //             end: Alignment.bottomRight,
// // //             colors: [
// // //               Color(0xFF0B0E14),
// // //               Color(0xFF101626),
// // //               Color(0xFF0B0E14),
// // //             ],
// // //           ),
// // //         ),
// // //
// // //         child: Center(
// // //           child: SingleChildScrollView(
// // //             padding: const EdgeInsets.all(24),
// // //
// // //             child: Column(
// // //               children: [
// // //
// // //                 /// LOGO
// // //                 Image.asset(
// // //                   "assets/logo.png",
// // //                   height: 190,
// // //                 ),
// // //
// // //                 const SizedBox(height: 10),
// // //
// // //                 /// LOGIN CARD
// // //                 Container(
// // //                   width: size.width > 600 ? 420 : size.width * 0.92,
// // //                   padding: const EdgeInsets.symmetric(
// // //                       horizontal: 28,
// // //                       vertical: 32),
// // //
// // //                   decoration: BoxDecoration(
// // //                     color: const Color(0xFF161A22),
// // //                     borderRadius: BorderRadius.circular(18),
// // //
// // //                     boxShadow: [
// // //                       BoxShadow(
// // //                         color: Colors.black.withOpacity(0.5),
// // //                         blurRadius: 35,
// // //                         offset: const Offset(0, 25),
// // //                       ),
// // //                     ],
// // //                   ),
// // //
// // //                   child: Column(
// // //                     children: [
// // //
// // //                       const Text(
// // //                         "Welcome Back",
// // //                         style: TextStyle(
// // //                           fontSize: 22,
// // //                           fontWeight: FontWeight.w600,
// // //                           color: Colors.white,
// // //                         ),
// // //                       ),
// // //
// // //                       const SizedBox(height: 6),
// // //
// // //                       const Text(
// // //                         "Login to manage your orders & inventory",
// // //                         style: TextStyle(
// // //                           color: Color(0xFFA1A6B3),
// // //                           fontSize: 13,
// // //                         ),
// // //                       ),
// // //
// // //                       const SizedBox(height: 24),
// // //
// // //                       _inputField(
// // //                         "Email Address",
// // //                         emailController,
// // //                       ),
// // //
// // //                       const SizedBox(height: 16),
// // //
// // //                       _inputField(
// // //                         "Password",
// // //                         passwordController,
// // //                         isPassword: true,
// // //                       ),
// // //
// // //                       const SizedBox(height: 24),
// // //
// // //                       /// LOGIN BUTTON
// // //                       SizedBox(
// // //                         width: double.infinity,
// // //                         height: 48,
// // //
// // //                         child: ElevatedButton(
// // //                           onPressed: loading ? null : loginUser,
// // //
// // //                           style: ElevatedButton.styleFrom(
// // //                             backgroundColor: const Color(0xFF2E6CF6),
// // //
// // //                             shape: RoundedRectangleBorder(
// // //                               borderRadius: BorderRadius.circular(12),
// // //                             ),
// // //                           ),
// // //
// // //                           child: loading
// // //                               ? const CircularProgressIndicator(
// // //                             color: Colors.white70,
// // //                           )
// // //                               : const Text(
// // //                             "Login",
// // //                             style: TextStyle(
// // //                               fontSize: 16,
// // //                               fontWeight: FontWeight.w900,
// // //                               color: Colors.black,
// // //                             ),
// // //                           ),
// // //                         ),
// // //                       ),
// // //
// // //                       const SizedBox(height: 22),
// // //
// // //                       Row(
// // //                         children: const [
// // //                           Expanded(
// // //                             child: Divider(color: Color(0xFF2A2F3A)),
// // //                           ),
// // //
// // //                           Padding(
// // //                             padding:
// // //                             EdgeInsets.symmetric(horizontal: 10),
// // //
// // //                             child: Text(
// // //                               "OR",
// // //                               style: TextStyle(
// // //                                 color: Color(0xFFA1A6B3),
// // //                               ),
// // //                             ),
// // //                           ),
// // //
// // //                           Expanded(
// // //                             child: Divider(color: Color(0xFF2A2F3A)),
// // //                           ),
// // //                         ],
// // //                       ),
// // //
// // //                       const SizedBox(height: 18),
// // //
// // //                       /// GOOGLE BUTTON
// // //                       GestureDetector(
// // //                         onTap: googleLogin,
// // //
// // //                         child: Container(
// // //                           height: 48,
// // //
// // //                           decoration: BoxDecoration(
// // //                             borderRadius: BorderRadius.circular(12),
// // //
// // //                             border: Border.all(
// // //                               color: const Color(0xFF2A2F3A),
// // //                             ),
// // //                           ),
// // //
// // //                           child: const Center(
// // //                             child: Text(
// // //                               "Continue with Google",
// // //                               style: TextStyle(
// // //                                 color: Colors.blue,
// // //                               ),
// // //                             ),
// // //                           ),
// // //                         ),
// // //                       ),
// // //
// // //                       const SizedBox(height: 18),
// // //
// // //                       /// REGISTER
// // //                       TextButton(
// // //                         onPressed: () {
// // //                           Navigator.pushNamed(context, AppRoutes.register);
// // //                         },
// // //                         child: const Text(
// // //                           "New here? Create an account",
// // //                           style: TextStyle(
// // //                             color: Color(0xFFA1A6B3),
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _inputField(
// // //       String label,
// // //       TextEditingController controller,
// // //       {bool isPassword = false}
// // //       ) {
// // //
// // //     return TextField(
// // //       controller: controller,
// // //       obscureText: isPassword && obscure,
// // //
// // //       style: const TextStyle(color: Colors.white),
// // //
// // //       decoration: InputDecoration(
// // //         labelText: label,
// // //
// // //         labelStyle: const TextStyle(
// // //           color: Color(0xFFA1A6B3),
// // //         ),
// // //
// // //         filled: true,
// // //         fillColor: const Color(0xFF0F1218),
// // //
// // //         suffixIcon: isPassword
// // //             ? IconButton(
// // //           icon: Icon(
// // //             obscure
// // //                 ? Icons.visibility_off
// // //                 : Icons.visibility,
// // //
// // //             color: const Color(0xFFA1A6B3),
// // //           ),
// // //
// // //           onPressed: () {
// // //             setState(() {
// // //               obscure = !obscure;
// // //             });
// // //           },
// // //         )
// // //             : null,
// // //
// // //         border: OutlineInputBorder(
// // //           borderRadius: BorderRadius.circular(12),
// // //           borderSide: BorderSide.none,
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }