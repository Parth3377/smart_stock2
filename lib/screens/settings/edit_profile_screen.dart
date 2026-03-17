// ════════════════════════════════════════════════════════════════════
//  lib/screens/settings/edit_profile_screen.dart
//
//  ✅ Loads real data from Firebase Auth
//  ✅ Saves to Firebase Auth (displayName) + Firestore (users collection)
//  ✅ Initials avatar: "Parth Chauhan" → "PC"
// ════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    nameController    = TextEditingController(text: user?.displayName ?? '');
    emailController   = TextEditingController(text: user?.email ?? '');
    phoneController   = TextEditingController();
    addressController = TextEditingController();
    _loadExtraFromFirestore();
  }

  Future<void> _loadExtraFromFirestore() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final doc = await FirebaseFirestore.instance
          .collection('users').doc(uid).get();
      if (doc.exists && mounted) {
        setState(() {
          phoneController.text   = doc.data()?['phone']   as String? ?? '';
          addressController.text = doc.data()?['city']    as String? ?? '';
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0][0].toUpperCase();
  }

  Future<void> _save() async {
    final name    = nameController.text.trim();
    final phone   = phoneController.text.trim();
    final address = addressController.text.trim();

    if (name.isEmpty) {
      _snack('Name cannot be empty.', isError: true); return;
    }

    setState(() => loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      // Update Firebase Auth display name
      await user.updateDisplayName(name);

      // Update Firestore users document
      await FirebaseFirestore.instance
          .collection('users').doc(user.uid).set({
        'uid':       user.uid,
        'name':      name,
        'email':     user.email ?? '',
        'phone':     phone,
        'city':      address,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      setState(() => loading = false);
      if (!mounted) return;

      _snack('Profile updated successfully! ✅');
      Navigator.pop(context);

    } on FirebaseAuthException catch (e) {
      setState(() => loading = false);
      _snack(e.message ?? 'Update failed.', isError: true);
    } catch (e) {
      setState(() => loading = false);
      _snack('Update failed. Please try again.', isError: true);
    }
  }

  void _snack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF2E6CF6),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final initials = _initials(nameController.text);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          const SizedBox(height: 8),

          // ── Initials Avatar ─────────────────────────────────────────
          Stack(children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E6CF6), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white, fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 2, right: 2,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E6CF6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF0F1218), width: 2),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 16),
              ),
            ),
          ]),

          const SizedBox(height: 30),

          _field('Full Name',    nameController),
          const SizedBox(height: 16),
          _field('Email',        emailController, readOnly: true),
          const SizedBox(height: 16),
          _field('Phone Number', phoneController,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 16),
          _field('Address / City', addressController),
          const SizedBox(height: 30),

          // ── Save Button ───────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: loading ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E6CF6),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: loading
                  ? const SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : const Text('Save Changes', style: TextStyle(
                  fontSize: 16, color: Colors.black,
                  fontWeight: FontWeight.w900)),
            ),
          ),

          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {bool readOnly = false,
        TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: TextStyle(color: readOnly ? Colors.white54 : Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFA1A6B3)),
        filled: true,
        fillColor: readOnly
            ? const Color(0xFF1A1F29)
            : const Color(0xFF161A22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        suffixIcon: readOnly
            ? const Icon(Icons.lock_outline,
            color: Colors.white30, size: 18)
            : null,
      ),
    );
  }
}



// import 'package:flutter/material.dart';
//
// class EditProfileScreen extends StatefulWidget {
//   const EditProfileScreen({super.key});
//
//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }
//
// class _EditProfileScreenState extends State<EditProfileScreen> {
//
//   final nameController = TextEditingController(text: "Parth Chauhan");
//   final emailController = TextEditingController(text: "chauhanparth2278@gmail.com");
//   final phoneController = TextEditingController(text: "9876543210");
//   final addressController = TextEditingController(text: "Ahmedabad, Gujarat");
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       backgroundColor: const Color(0xFF0F1218),
//
//       appBar: AppBar(
//         title: const Text("Edit Profile"),
//         backgroundColor: const Color(0xFF161A22),
//         elevation: 0,
//       ),
//
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//
//             /// PROFILE IMAGE
//             Stack(
//               children: [
//
//                 const CircleAvatar(
//                   radius: 50,
//                   backgroundImage: AssetImage("assets/images/profile.png"),
//                 ),
//
//                 Positioned(
//                   bottom: 0,
//                   right: 0,
//                   child: Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF2E6CF6),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Icon(Icons.edit, color: Colors.white, size: 18),
//                   ),
//                 )
//               ],
//             ),
//
//             const SizedBox(height: 30),
//
//             _inputField("Full Name", nameController),
//             const SizedBox(height: 16),
//
//             _inputField("Email", emailController),
//             const SizedBox(height: 16),
//
//             _inputField("Phone Number", phoneController),
//             const SizedBox(height: 16),
//
//             _inputField("Address", addressController),
//
//             const SizedBox(height: 30),
//
//             /// SAVE BUTTON
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF2E6CF6),
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//                 onPressed: () {
//
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text("Profile Updated Successfully" , selectionColor: Colors.orange,),
//                     ),
//                   );
//
//                 },
//                 child: const Text(
//                   "Save Changes",
//                   style: TextStyle(fontSize: 16 , color: Colors.black , fontWeight: FontWeight.w900),
//                 ),
//               ),
//             )
//
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _inputField(String label, TextEditingController controller) {
//
//     return TextField(
//       controller: controller,
//       style: const TextStyle(color: Colors.white),
//
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Color(0xFFA1A6B3)),
//         filled: true,
//         fillColor: const Color(0xFF161A22),
//
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(14),
//           borderSide: BorderSide.none,
//         ),
//       ),
//     );
//   }
// }