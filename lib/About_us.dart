import 'package:flutter/material.dart';
import 'app_theme.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        'About Us',
                        style: AppTheme.heading2.copyWith(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 20),

                // Hero Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.35),
                        Colors.white.withOpacity(0.25),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.phone_android,
                        size: 80,
                        color: AppTheme.darkTeal,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "Digital Detox",
                        style: AppTheme.heading1.copyWith(
                          fontSize: 28,
                          color: AppTheme.darkTeal,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Balance your digital life and real life",
                        textAlign: TextAlign.center,
                        style: AppTheme.bodyLarge.copyWith(
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                _buildSectionTitle("About the App"),
                Text(
                  "Our Digital Detox app helps you balance technology and real life. "
                  "We aim to reduce screen addiction, improve mental health, "
                  "and promote mindful usage of devices.",
                  style: AppTheme.bodyLarge.copyWith(
                    fontSize: 16,
                    height: 1.5,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 25),

                _buildSectionTitle("Key Features"),
                const SizedBox(height: 10),
                const FeatureTile(
                  icon: Icons.timer,
                  text: "Track and limit your screen time",
                ),
                const FeatureTile(
                  icon: Icons.schedule,
                  text: "Set focus/break intervals",
                ),
                const FeatureTile(
                  icon: Icons.self_improvement,
                  text: "Mindfulness reminders",
                ),
                const FeatureTile(
                  icon: Icons.show_chart,
                  text: "Personal progress insights",
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: AppTheme.heading3.copyWith(
            fontSize: 22,
            color: AppTheme.darkTeal,
          ),
        ),
        Container(
          height: 2,
          width: 100,
          margin: const EdgeInsets.only(top: 8, bottom: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.darkTeal, Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String text;
  const FeatureTile({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.4),
            Colors.white.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.darkTeal, size: 28),
        title: Text(
          text,
          style: AppTheme.bodyLarge.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
