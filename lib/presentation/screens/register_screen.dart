import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_database/firebase_database.dart' as fb_db;
import 'package:expanse_management/Constants/color.dart';
import 'package:expanse_management/services/app_localizations.dart';
import 'package:expanse_management/presentation/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AppLocalizations _appLocalizations = AppLocalizations();
  final TextEditingController _emailC = TextEditingController();
  final TextEditingController _passC = TextEditingController();
  final TextEditingController _confirmC = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final email = _emailC.text.trim();
    final password = _passC.text;

    try {
      final cred = await fb_auth.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final uid = cred.user?.uid;
      if (uid != null) {
        // Save minimal profile to Realtime Database under users/{uid}
        final ref = fb_db.FirebaseDatabase.instance.ref().child('users').child(uid);
        await ref.set({
          'email': email,
          'createdAt': DateTime.now().toIso8601String(),
        });
      }

      setState(() => _isLoading = false);
      if (!mounted) return;
      Navigator.of(context).pop();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ValueListenableBuilder<String>(
            valueListenable: _appLocalizations.languageNotifier,
            builder: (context, lang, _) => Text(_appLocalizations.get('register_success')),
          ),
        ),
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String message = _appLocalizations.get('register_failed');
      if (e.code == 'email-already-in-use') {
        message = _appLocalizations.get('email_already_in_use');
      } else if (e.code == 'weak-password') {
        message = _appLocalizations.get('weak_password');
      }
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => ValueListenableBuilder<String>(
          valueListenable: _appLocalizations.languageNotifier,
          builder: (context, lang, _) => AlertDialog(
            title: Text(_appLocalizations.get('error')),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(_appLocalizations.get('ok')),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => ValueListenableBuilder<String>(
          valueListenable: _appLocalizations.languageNotifier,
          builder: (context, lang, _) => AlertDialog(
            title: Text(_appLocalizations.get('error')),
            content: Text(_appLocalizations.get('something_went_wrong')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(_appLocalizations.get('ok')),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    _confirmC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18.0);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [gradientStart, gradientMiddle, gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.5, 1.0],
            ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo và tiêu đề
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Colors.white,
                          Color(0xFFE8F5E9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 65,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "MoneyWise",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<String>(
                    valueListenable: _appLocalizations.languageNotifier,
                    builder: (context, lang, _) => Text(
                      _appLocalizations.get('register_subtitle'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Form đăng ký
                  Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(borderRadius: radius),
                    shadowColor: Colors.black26,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailC,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: _appLocalizations.get('email_label'),
                                prefixIcon: const Icon(Icons.email_outlined),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return _appLocalizations.get('enter_email');
                                final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                                if (!regex.hasMatch(v.trim())) return _appLocalizations.get('invalid_email');
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passC,
                              obscureText: _obscure,
                              decoration: InputDecoration(
                                labelText: _appLocalizations.get('password'),
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return _appLocalizations.get('enter_password');
                                if (v.length < 4) return _appLocalizations.get('password_too_short');
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _confirmC,
                              obscureText: _obscureConfirm,
                              decoration: InputDecoration(
                                labelText: _appLocalizations.get('confirm_password'),
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(_obscureConfirm
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () =>
                                      setState(() => _obscureConfirm = !_obscureConfirm),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return _appLocalizations.get('enter_password_again');
                                if (v != _passC.text) return _appLocalizations.get('passwords_not_match');
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: _isLoading ? null : _register,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : ValueListenableBuilder<String>(
                                        valueListenable: _appLocalizations.languageNotifier,
                                        builder: (context, lang, _) => Text(
                                          _appLocalizations.get('register'),
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                            builder: (_) => const LoginScreen()),
                                      );
                                    },
                              child: ValueListenableBuilder<String>(
                                valueListenable: _appLocalizations.languageNotifier,
                                builder: (context, lang, _) => Text(
                                  _appLocalizations.get('back_to_login'),
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
