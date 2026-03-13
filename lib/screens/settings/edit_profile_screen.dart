import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  final nameController = TextEditingController(text: "Parth Chauhan");
  final emailController = TextEditingController(text: "chauhanparth2278@gmail.com");
  final phoneController = TextEditingController(text: "9876543210");
  final addressController = TextEditingController(text: "Ahmedabad, Gujarat");

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),

      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// PROFILE IMAGE
            Stack(
              children: [

                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage("assets/images/profile.png"),
                ),

                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E6CF6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                )
              ],
            ),

            const SizedBox(height: 30),

            _inputField("Full Name", nameController),
            const SizedBox(height: 16),

            _inputField("Email", emailController),
            const SizedBox(height: 16),

            _inputField("Phone Number", phoneController),
            const SizedBox(height: 16),

            _inputField("Address", addressController),

            const SizedBox(height: 30),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E6CF6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Profile Updated Successfully" , selectionColor: Colors.orange,),
                    ),
                  );

                },
                child: const Text(
                  "Save Changes",
                  style: TextStyle(fontSize: 16 , color: Colors.black , fontWeight: FontWeight.w900),
                ),
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {

    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),

      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFA1A6B3)),
        filled: true,
        fillColor: const Color(0xFF161A22),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}