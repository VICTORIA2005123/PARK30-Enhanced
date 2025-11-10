import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await _authService.signInWithEmail(
        _emailController.text,
        _passwordController.text,
      );
      // Auth wrapper will handle navigation
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await _authService.signUpWithEmail(
        _emailController.text,
        _passwordController.text,
      );
      // Auth wrapper will handle navigation
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFE3F2FD)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Image.asset('assets/images/marwadi_logo.png', height: 120),
                    const SizedBox(height: 24),
                    const Text(
                      'MARWADI UNIVERSITY',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1565C0),
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Smart Parking System',
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF1976D2),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 48),
                    // --- Email field ---
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1976D2),
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.email,
                          color: Color(0xFF1976D2),
                        ),
                        labelStyle: const TextStyle(color: Color(0xFF1976D2)),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter an email' : null,
                    ),
                    const SizedBox(height: 16),
                    // --- Password field ---
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF1976D2),
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: Color(0xFF1976D2),
                        ),
                        labelStyle: const TextStyle(color: Color(0xFF1976D2)),
                      ),
                      obscureText: true,
                      validator: (value) => value!.length < 6
                          ? 'Password must be at least 6 characters'
                          : null,
                    ),
                    const SizedBox(height: 40),
                    // --- Buttons / Loader ---
                    if (_isLoading)
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF1976D2),
                        ),
                      )
                    else
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: const Text(
                                'LOGIN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton(
                              onPressed: _signup,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF1976D2),
                                side: const BorderSide(
                                  color: Color(0xFF1976D2),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'SIGN UP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
