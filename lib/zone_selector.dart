import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_model.dart';
import 'login.dart';
import 'app_theme.dart';

class ZoneSelectorPage extends StatefulWidget {
  const ZoneSelectorPage({super.key});

  @override
  State<ZoneSelectorPage> createState() => _ZoneSelectorPageState();
}

class _ZoneSelectorPageState extends State<ZoneSelectorPage> {
  bool _isLoading = false;

  Future<void> _selectZone(UserZone zone) async {
    print('🔵 Zone selected: ${zone.name}');

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_zone', zone.name);
      print('✅ Zone saved locally: ${zone.name}');

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('🔵 User logged in, saving to Firestore...');
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'zone': zone.name});
        print('✅ Zone saved to Firestore!');
      }

      if (!mounted) return;

      print('🔵 Navigating to login page...');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      print('❌ Error selecting zone: $e');
      setState(() => _isLoading = false);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: Colors.white))
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          'Select Your Zone',
                          style: AppTheme.heading1.copyWith(
                            color: Colors.white,
                            fontSize: 32,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.2),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Choose your experience',
                          style: AppTheme.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 60),

                        // Kids Zone Card
                        _buildZoneCard(
                          context: context,
                          emoji: '🎨',
                          label: 'Kids Zone',
                          gradient: [AppTheme.softTeal, AppTheme.accentTeal],
                          onTap: () => _selectZone(UserZone.kids),
                        ),

                        const SizedBox(height: 40),

                        // Adult Zone Card
                        _buildZoneCard(
                          context: context,
                          emoji: '💼',
                          label: 'Adult Zone',
                          gradient: [
                            AppTheme.primaryDeepTeal,
                            AppTheme.darkTeal,
                          ],
                          onTap: () => _selectZone(UserZone.adult),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildZoneCard({
    required BuildContext context,
    required String emoji,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.4),
              Colors.white.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Text(emoji, style: const TextStyle(fontSize: 60)),
            ),
            const SizedBox(height: 16),
            Text(
              label,
              style: AppTheme.heading3.copyWith(
                fontSize: 20,
                color: AppTheme.darkTeal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
