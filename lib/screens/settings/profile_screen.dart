import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'edit_profile_screen.dart';
import 'security_screen.dart';
import 'notifications_screen.dart';
import 'language_screen.dart';
import 'help_screen.dart';
import 'privacy_screen.dart';
import 'about_screen.dart';
import '../auth/login_screen.dart';
import '../../core/theme_manager.dart';
import '../../widgets/glass_bottom_navbar.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  // Get initials: "Parth Chauhan" → "PC"
  String _initials(String? name) {
    if (name == null || name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final user         = FirebaseAuth.instance.currentUser;
    final displayName  = user?.displayName ?? 'User';
    final email        = user?.email ?? '';
    final initials     = _initials(displayName);
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
      ),

      bottomNavigationBar: GlassBottomNavbar(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          if (index == 1) Navigator.pushReplacementNamed(context, AppRoutes.products);
          if (index == 2) Navigator.pushReplacementNamed(context, AppRoutes.orderDraft);
        },
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── PROFILE HEADER with initials avatar ───────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF2E6CF6), Color(0xFF4B8BFF)]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(children: [

              // Initials avatar
              Container(
                width: 68, height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white38, width: 2),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: TextStyle(
                        color: Colors.white, fontSize: 18,
                        fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(email, style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          // ── ACCOUNT ───────────────────────────────────────────────
          _sectionTitle('Account'),
          _tile(Icons.person_outline,  'Edit Profile',    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
          _tile(Icons.lock_outline,    'Security',        () => Navigator.push(context, MaterialPageRoute(builder: (_) => SecurityScreen()))),
          _tile(Icons.notifications_outlined, 'Notifications',
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsScreen()))),

          const SizedBox(height: 20),

          // ── APP PREFERENCES ────────────────────────────────────────
          _sectionTitle('App Preferences'),
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              leading: Icon(Icons.dark_mode_outlined, color: Color(0xFF2E6CF6)),
              title: Text('Dark Mode', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
              trailing: Switch(
                value: themeManager.isDark,
                onChanged: (v) => themeManager.toggleTheme(v),
                activeColor: const Color(0xFF2E6CF6),
              ),
            ),
          ),
          // _tile(Icons.language_outlined, 'Language',
          //         () => Navigator.push(context, MaterialPageRoute(builder: (_) => LanguageScreen()))),
          //
          // const SizedBox(height: 20),

          // ── SUPPORT ───────────────────────────────────────────────
          _sectionTitle('Support'),
          _tile(Icons.help_outline,    'Help & Support',  () => Navigator.push(context, MaterialPageRoute(builder: (_) => HelpScreen()))),
          _tile(Icons.privacy_tip_outlined, 'Privacy Policy', () => Navigator.push(context, MaterialPageRoute(builder: (_) => PrivacyScreen()))),
          _tile(Icons.info_outline,    'About',           () => Navigator.push(context, MaterialPageRoute(builder: (_) => AboutScreen()))),

          const SizedBox(height: 20),

          // ── LOGOUT ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton.icon(
              onPressed: () => _logoutDialog(context),
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('Logout', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(title, style: TextStyle(
        fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
  );

  Widget _tile(IconData icon, String title, VoidCallback onTap) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(14),
    ),
    child: ListTile(
      leading: Icon(icon, color: Color(0xFF2E6CF6)),
      title: Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).textTheme.bodySmall?.color),
      onTap: onTap,
    ),
  );

  void _logoutDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Text('Logout', style: TextStyle(color: Colors.red)),
      content: Text('Are you sure you want to logout?',
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color))),
        ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                  context, AppRoutes.login, (r) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white))),
      ],
    ));
  }
}



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// import 'edit_profile_screen.dart';
// import 'security_screen.dart';
// import 'notifications_screen.dart';
// import 'language_screen.dart';
// import 'help_screen.dart';
// import 'privacy_screen.dart';
// import 'about_screen.dart';
// import '../auth/login_screen.dart';
// import '../../core/theme_manager.dart';
// import '../../widgets/glass_bottom_navbar.dart';
// import '../../routes/app_routes.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//
//   // Get initials: "Parth Chauhan" → "PC"
//   String _initials(String? name) {
//     if (name == null || name.isEmpty) return '?';
//     final parts = name.trim().split(' ');
//     if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
//     return parts[0][0].toUpperCase();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user         = FirebaseAuth.instance.currentUser;
//     final displayName  = user?.displayName ?? 'User';
//     final email        = user?.email ?? '';
//     final initials     = _initials(displayName);
//     final themeManager = Provider.of<ThemeManager>(context);
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F1218),
//
//       appBar: AppBar(
//         title: const Text('Profile'),
//         backgroundColor: const Color(0xFF161A22),
//         elevation: 0,
//       ),
//
//       bottomNavigationBar: GlassBottomNavbar(
//         currentIndex: 3,
//         onTap: (index) {
//           if (index == 0) Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
//           if (index == 1) Navigator.pushReplacementNamed(context, AppRoutes.products);
//           if (index == 2) Navigator.pushReplacementNamed(context, AppRoutes.orderDraft);
//         },
//       ),
//
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//
//           // ── PROFILE HEADER with initials avatar ───────────────────
//           Container(
//             padding: const EdgeInsets.all(18),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                   colors: [Color(0xFF2E6CF6), Color(0xFF4B8BFF)]),
//               borderRadius: BorderRadius.circular(22),
//             ),
//             child: Row(children: [
//
//               // Initials avatar
//               Container(
//                 width: 68, height: 68,
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white38, width: 2),
//                 ),
//                 child: Center(
//                   child: Text(
//                     initials,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//
//               const SizedBox(width: 16),
//
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(displayName, style: const TextStyle(
//                         color: Colors.white, fontSize: 18,
//                         fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 4),
//                     Text(email, style: const TextStyle(
//                         color: Colors.white70, fontSize: 13),
//                         overflow: TextOverflow.ellipsis),
//                   ],
//                 ),
//               ),
//             ]),
//           ),
//
//           const SizedBox(height: 24),
//
//           // ── ACCOUNT ───────────────────────────────────────────────
//           _sectionTitle('Account'),
//           _tile(Icons.person_outline,  'Edit Profile',    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
//           _tile(Icons.lock_outline,    'Security',        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SecurityScreen()))),
//           _tile(Icons.notifications_outlined, 'Notifications',
//                   () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
//
//           const SizedBox(height: 20),
//
//           // ── APP PREFERENCES ────────────────────────────────────────
//           _sectionTitle('App Preferences'),
//           Container(
//             margin: const EdgeInsets.only(bottom: 8),
//             decoration: BoxDecoration(
//               color: const Color(0xFF161A22),
//               borderRadius: BorderRadius.circular(14),
//             ),
//             child: ListTile(
//               leading: const Icon(Icons.dark_mode_outlined, color: Color(0xFF2E6CF6)),
//               title: const Text('Dark Mode', style: TextStyle(color: Colors.white)),
//               trailing: Switch(
//                 value: themeManager.isDark,
//                 onChanged: (v) => themeManager.toggleTheme(v),
//                 activeColor: const Color(0xFF2E6CF6),
//               ),
//             ),
//           ),
//           _tile(Icons.language_outlined, 'Language',
//                   () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageScreen()))),
//
//           const SizedBox(height: 20),
//
//           // ── SUPPORT ───────────────────────────────────────────────
//           _sectionTitle('Support'),
//           _tile(Icons.help_outline,    'Help & Support',  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen()))),
//           _tile(Icons.privacy_tip_outlined, 'Privacy Policy', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyScreen()))),
//           _tile(Icons.info_outline,    'About',           () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()))),
//
//           const SizedBox(height: 20),
//
//           // ── LOGOUT ────────────────────────────────────────────────
//           Container(
//             width: double.infinity,
//             margin: const EdgeInsets.only(bottom: 8),
//             child: OutlinedButton.icon(
//               onPressed: () => _logoutDialog(context),
//               icon: const Icon(Icons.logout, color: Colors.red),
//               label: const Text('Logout', style: TextStyle(color: Colors.blueAccent , fontWeight: FontWeight.w900 , fontSize: 18)),
//               style: OutlinedButton.styleFrom(
//                 side: const BorderSide(color: Colors.red),
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14)),
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
//
//   Widget _sectionTitle(String title) => Padding(
//     padding: const EdgeInsets.only(bottom: 10),
//     child: Text(title, style: const TextStyle(
//         fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
//   );
//
//   Widget _tile(IconData icon, String title, VoidCallback onTap) => Container(
//     margin: const EdgeInsets.only(bottom: 8),
//     decoration: BoxDecoration(
//       color: const Color(0xFF161A22),
//       borderRadius: BorderRadius.circular(14),
//     ),
//     child: ListTile(
//       leading: Icon(icon, color: const Color(0xFF2E6CF6)),
//       title: Text(title, style: const TextStyle(color: Colors.white)),
//       trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
//       onTap: onTap,
//     ),
//   );
//
//   void _logoutDialog(BuildContext context) {
//     showDialog(context: context, builder: (_) => AlertDialog(
//       backgroundColor: const Color(0xFF161A22),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       title: const Text('Logout', style: TextStyle(color: Colors.white)),
//       content: const Text('Are you sure you want to logout?',
//           style: TextStyle(color: Colors.white70)),
//       actions: [
//         TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
//         ElevatedButton(
//             onPressed: () async {
//               Navigator.pop(context);
//               await FirebaseAuth.instance.signOut();
//               if (!mounted) return;
//               Navigator.pushNamedAndRemoveUntil(
//                   context, AppRoutes.login, (r) => false);
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Logout', style: TextStyle(color: Colors.white))),
//       ],
//     ));
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import 'edit_profile_screen.dart';
// import 'security_screen.dart';
// import 'notifications_screen.dart';
// import 'language_screen.dart';
// import 'help_screen.dart';
// import 'privacy_screen.dart';
// import 'about_screen.dart';
//
// import '../dashboard/dashboard_screen.dart';
// import '../products/products_screen.dart';
// import '../order_draft/order_draft_screen.dart';
// import '../../widgets/glass_bottom_navbar.dart';
// import '../../core/theme_manager.dart';
// import '../auth/login_screen.dart';
//
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//
//   @override
//   Widget build(BuildContext context) {
//
//     final themeManager = Provider.of<ThemeManager>(context);
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F1218),
//
//       appBar: AppBar(
//         title: const Text("Profile"),
//         backgroundColor: const Color(0xFF161A22),
//         elevation: 0,
//       ),
//
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//
//           /// PROFILE HEADER
//           Container(
//             padding: const EdgeInsets.all(18),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF2E6CF6), Color(0xFF4B8BFF)],
//               ),
//               borderRadius: BorderRadius.circular(22),
//             ),
//             child: Row(
//               children: [
//
//                 const CircleAvatar(
//                   radius: 34,
//                   backgroundImage: AssetImage("assets/images/profile.png"),
//                 ),
//
//                 const SizedBox(width: 16),
//
//                 const Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Parth Chauhan",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     Text(
//                       "chauhanparth2278@gmail.com",
//                       style: TextStyle(color: Colors.white70),
//                     ),
//                   ],
//                 )
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 24),
//
//           /// ACCOUNT SECTION
//           _sectionTitle("Account"),
//
//           _tile(Icons.person, "Edit Profile", () {
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => const EditProfileScreen()));
//           }),
//
//           _tile(Icons.lock, "Security", () {
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => const SecurityScreen()));
//           }),
//
//           _tile(Icons.notifications, "Notifications", () {
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => const NotificationsScreen()));
//           }),
//
//           const SizedBox(height: 24),
//
//           /// APP SETTINGS
//           _sectionTitle("App Preferences"),
//
//           SwitchListTile(
//             title: const Text("Dark Mode"),
//             value: themeManager.isDark,
//             onChanged: (v) {
//               themeManager.toggleTheme(v);
//             },
//           ),
//
//           _tile(Icons.language, "Language", () {
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => const LanguageScreen()));
//           }),
//
//           const SizedBox(height: 24),
//
//           /// SUPPORT
//           _sectionTitle("Support"),
//
//           _tile(Icons.help_outline, "Help & Support", () {
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => const HelpScreen()));
//           }),
//
//           _tile(Icons.privacy_tip, "Privacy Policy", () {
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => const PrivacyScreen()));
//           }),
//
//           _tile(Icons.info_outline, "About App", () {
//             Navigator.push(context,
//                 MaterialPageRoute(builder: (_) => const AboutScreen()));
//           }),
//
//           const SizedBox(height: 30),
//
//           /// LOGOUT BUTTON
//           ElevatedButton.icon(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.orange,
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(14),
//               ),
//             ),
//             icon: const Icon(Icons.logout , color: Colors.indigoAccent,),
//             label: const Text("Log Out" , style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900 , color: Colors.white)),
//
//             onPressed: () {
//               Navigator.pop(context);
//
//               /// navigate to login screen and remove all previous pages
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const LoginScreen(),
//                 ),
//                     (route) => false,
//               );
//
//             },
//           )
//         ],
//       ),
//
//       /// BOTTOM NAV
//       bottomNavigationBar: GlassBottomNavbar(
//
//         currentIndex: 3,
//
//         onTap: (index) {
//
//           if (index == 3) return;
//
//           if (index == 0) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const DashboardScreen(),
//               ),
//             );
//           }
//
//           if (index == 1) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const ProductsScreen(),
//               ),
//             );
//           }
//
//           if (index == 2) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => const OrderDraftScreen(),
//               ),
//             );
//           }
//
//         },
//
//       ),
//     );
//   }
//
//   /// SECTION TITLE
//   Widget _sectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
//
//   /// SETTINGS TILE
//   Widget _tile(IconData icon, String title, VoidCallback onTap) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       decoration: BoxDecoration(
//         color: const Color(0xFF161A22),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: ListTile(
//         leading: Icon(icon, color: const Color(0xFF2E6CF6)),
//         title: Text(title, style: const TextStyle(color: Colors.white)),
//         trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
//         onTap: onTap,
//       ),
//     );
//   }
//
//   /// LOGOUT DIALOG
//   void _logoutDialog(BuildContext context) {
//
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         backgroundColor: const Color(0xFF161A22),
//         title: const Text("Logout"),
//         content: const Text("Are you sure you want to logout?"),
//         actions: [
//
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text("Logout"),
//           )
//         ],
//       ),
//     );
//   }
// }