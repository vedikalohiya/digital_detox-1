import 'package:flutter/material.dart';
import 'app_theme.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();

  bool _isSending = false;

  Future<void> sendEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSending = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Message sent successfully!'),
          backgroundColor: AppTheme.primaryDeepTeal,
        ),
      );
      nameController.clear();
      emailController.clear();
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
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
                        'Contact Us',
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
                  padding: const EdgeInsets.all(24),
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
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.contact_mail,
                          color: AppTheme.darkTeal,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Get in Touch",
                        style: AppTheme.heading2.copyWith(
                          fontSize: 24,
                          color: AppTheme.darkTeal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "We'd love to hear from you!",
                        style: AppTheme.bodyLarge.copyWith(
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.4),
                        Colors.white.withOpacity(0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nameController,
                          style: AppTheme.bodyLarge,
                          decoration: AppTheme.inputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icons.person,
                          ),
                          validator: (value) => value?.isEmpty == true
                              ? 'Please enter your name'
                              : null,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: emailController,
                          style: AppTheme.bodyLarge,
                          decoration: AppTheme.inputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icons.email,
                          ),
                          validator: (value) {
                            if (value?.isEmpty == true) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(value!)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: messageController,
                          style: AppTheme.bodyLarge,
                          decoration: AppTheme.inputDecoration(
                            labelText: 'Message',
                            prefixIcon: Icons.message,
                          ),
                          maxLines: 4,
                          validator: (value) => value?.isEmpty == true
                              ? 'Please enter a message'
                              : null,
                        ),
                        const SizedBox(height: 24),

                        _isSending
                            ? CircularProgressIndicator(
                                color: AppTheme.primaryDeepTeal,
                              )
                            : SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.send,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Send Message',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: AppTheme.primaryButtonStyle,
                                  onPressed: _isSending ? null : sendEmail,
                                ),
                              ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Text(
                  "© 2025 Digital Detox App",
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
