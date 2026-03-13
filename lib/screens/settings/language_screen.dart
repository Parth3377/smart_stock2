import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen>
    with SingleTickerProviderStateMixin {

  String selectedLanguage = "English";

  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fade = Tween<double>(begin: 0, end: 1).animate(_controller);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFF0F1218),

      appBar: AppBar(
        title: const Text("Language"),
        backgroundColor: const Color(0xFF161A22),
        elevation: 0,
      ),

      body: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,

          child: ListView(
            padding: const EdgeInsets.all(16),

            children: [

              /// ================= HEADER =================

              Container(
                padding: const EdgeInsets.all(22),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E6CF6), Color(0xFF4B8BFF)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),

                child: const Row(
                  children: [

                    Icon(Icons.language,
                        size: 40,
                        color: Colors.white),

                    SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Select Language",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "Choose your preferred language for the SmartStock interface.",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 28),

              /// ================= LANGUAGE OPTIONS =================

              _languageCard("English", "Global language", Icons.language),

              _languageCard("Hindi", "भारत की भाषा", Icons.translate),

              _languageCard("Gujarati", "ગુજરાતી ભાષા", Icons.translate),

              _languageCard("Spanish", "Idioma Español", Icons.translate),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= LANGUAGE CARD =================

  Widget _languageCard(String title, String subtitle, IconData icon) {

    final selected = selectedLanguage == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLanguage = title;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: const Color(0xFF161A22),
          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: selected
                ? const Color(0xFF2E6CF6)
                : Colors.transparent,
            width: 2,
          ),
        ),

        child: Row(
          children: [

            Icon(icon, color: const Color(0xFF2E6CF6)),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFFA1A6B3),
                    ),
                  ),
                ],
              ),
            ),

            Radio(
              value: title,
              groupValue: selectedLanguage,
              activeColor: const Color(0xFF2E6CF6),
              onChanged: (value) {
                setState(() {
                  selectedLanguage = value.toString();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}