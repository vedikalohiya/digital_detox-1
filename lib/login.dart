import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup.dart';
import 'database_helper.dart';
import 'forgot_password_page.dart';
import 'mode_selector.dart';
import 'app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final pass = TextEditingController();

  String? emailError;
  String? passError;
  bool _isPasswordVisible = false; // 👁️ Track password visibility

  bool isValidEmail(String e) =>
      RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(e.trim());

  bool isValidPass(String p) => RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_])(?!.*\s).{8,}$',
  ).hasMatch(p);

  void validate() {
    setState(() {
      emailError = email.text.trim().isEmpty
          ? 'Email is required'
          : (!isValidEmail(email.text)
                ? 'Enter a valid email (e.g. abc@gmail.com)'
                : null);

      passError = pass.text.isEmpty
          ? 'Password is required'
          : (!isValidPass(pass.text)
                ? 'Min 8 chars, 1 upper, 1 lower, 1 digit, 1 special, no spaces'
                : null);
    });
  }

  Future<void> handleLogin() async {
    validate();
    if (emailError == null && passError == null) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        final dbHelper = DatabaseHelper();
        bool loginSuccessful = false;
        String? userId;

        try {
          UserCredential userCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                email: email.text.trim(),
                password: pass.text,
              );
          loginSuccessful = true;
          userId = userCredential.user?.uid;

          // Update lastLogin timestamp in Firestore
          if (userId != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .update({'lastLogin': FieldValue.serverTimestamp()});
            print('✅ Login timestamp updated for user: $userId');
          }
        } catch (_) {
          Map<String, dynamic>? user = await dbHelper.loginUser(
            email: email.text.trim(),
            password: pass.text,
          );
          if (user != null) loginSuccessful = true;
        }

        if (mounted) Navigator.of(context).pop();

        if (loginSuccessful) {
          if (mounted) {
            // Always show mode selector after login
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ModeSelector()),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid email or password'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) Navigator.of(context).pop();
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email.';
            break;
          case 'wrong-password':
            errorMessage = 'Wrong password provided.';
            break;
          default:
            errorMessage = 'An error occurred. Please try again.';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    email.addListener(() {
      if (emailError != null) validate();
    });
    pass.addListener(() {
      if (passError != null) validate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Title
                Text(
                  'Digital Detox',
                  style: AppTheme.heading1.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
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
                const SizedBox(height: 8),
                Text(
                  'Welcome Back!',
                  style: AppTheme.heading3.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Login Form Container
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
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        style: AppTheme.bodyLarge,
                        decoration: AppTheme.inputDecoration(
                          labelText: 'Email',
                          errorText: emailError,
                          prefixIcon: Icons.email,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: pass,
                        obscureText: !_isPasswordVisible,
                        style: AppTheme.bodyLarge,
                        decoration:
                            AppTheme.inputDecoration(
                              labelText: 'Password',
                              errorText: passError,
                              prefixIcon: Icons.lock,
                            ).copyWith(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: AppTheme.primaryDeepTeal,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Forgot Password?',
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.darkTeal,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: handleLogin,
                        style: AppTheme.primaryButtonStyle,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignupPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.darkTeal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
