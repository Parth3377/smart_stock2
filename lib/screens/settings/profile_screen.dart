import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'edit_profile_screen.dart';
import 'security_screen.dart';
import 'notifications_screen.dart';
import 'language_screen.dart';
import 'help_screen.dart';
import 'privacy_screen.dart';
import 'about_screen.dart';

import '../dashboard/dashboard_screen.dart';
import '../products/products_screen.dart';
import '../order_draft/order_draft_screen.dart';
import '../../widgets/glass_bottom_navbar.dart';
import '../../core/theme_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {

    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),

      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// PROFILE HEADER
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E6CF6), Color(0xFF4B8BFF)],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [

                const CircleAvatar(
                  radius: 34,
                  backgroundImage: AssetImage("assets/images/profile.png"),
                ),

                const SizedBox(width: 16),

                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Parth Chauhan",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "chauhanparth2278@gmail.com",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// ACCOUNT SECTION
          _sectionTitle("Account"),

          _tile(Icons.person, "Edit Profile", () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()));
          }),

          _tile(Icons.lock, "Security", () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SecurityScreen()));
          }),

          _tile(Icons.notifications, "Notifications", () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()));
          }),

          const SizedBox(height: 24),

          /// APP SETTINGS
          _sectionTitle("App Preferences"),

          SwitchListTile(
            title: const Text("Dark Mode"),
            value: themeManager.isDark,
            onChanged: (v) {
              themeManager.toggleTheme(v);
            },
          ),

          _tile(Icons.language, "Language", () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const LanguageScreen()));
          }),

          const SizedBox(height: 24),

          /// SUPPORT
          _sectionTitle("Support"),

          _tile(Icons.help_outline, "Help & Support", () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HelpScreen()));
          }),

          _tile(Icons.privacy_tip, "Privacy Policy", () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PrivacyScreen()));
          }),

          _tile(Icons.info_outline, "About App", () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AboutScreen()));
          }),

          const SizedBox(height: 30),

          /// LOGOUT BUTTON
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.logout , color: Colors.indigoAccent,),
            label: const Text("Log Out" , style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900 , color: Colors.white)),
            onPressed: () {
              _logoutDialog(context);
            },
          )
        ],
      ),

      /// BOTTOM NAV
      bottomNavigationBar: GlassBottomNavbar(

        currentIndex: 3,

        onTap: (index) {

          if (index == 3) return;

          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const DashboardScreen(),
              ),
            );
          }

          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const ProductsScreen(),
              ),
            );
          }

          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const OrderDraftScreen(),
              ),
            );
          }

        },

      ),
    );
  }

  /// SECTION TITLE
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  /// SETTINGS TILE
  Widget _tile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161A22),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2E6CF6)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
        onTap: onTap,
      ),
    );
  }

  /// LOGOUT DIALOG
  void _logoutDialog(BuildContext context) {

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF161A22),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [

          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Logout"),
          )
        ],
      ),
    );
  }
}