import 'package:expanse_management/Constants/color.dart';
import 'package:expanse_management/presentation/widgets/bottom_navbar.dart';
import 'package:expanse_management/presentation/screens/register_screen.dart';
import 'package:expanse_management/services/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AppLocalizations _appLocalizations = AppLocalizations();
  final TextEditingController _emailC = TextEditingController();
  final TextEditingController _passC = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;

  // Đăng nhập bằng Email/Password
  void _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final email = _emailC.text.trim();
    final password = _passC.text;

    try {
      await fb_auth.FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      setState(() => _isLoading = false);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Bottom()),
      );
    } on fb_auth.FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = _appLocalizations.get('user_not_found');
          break;
        case 'wrong-password':
          message = _appLocalizations.get('wrong_password');
          break;
        case 'invalid-email':
          message = _appLocalizations.get('invalid_email');
          break;
        case 'user-disabled':
          message = _appLocalizations.get('user_disabled');
          break;
        case 'too-many-requests':
          message = _appLocalizations.get('too_many_requests');
          break;
        case 'invalid-credential':
          message = _appLocalizations.get('invalid_credential');
          break;
        default:
          message = '${_appLocalizations.get('login_failed')}: ${e.message ?? e.code}';
      }
      _showErrorDialog(_appLocalizations.get('login_error'), message);
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _showErrorDialog(
        _appLocalizations.get('error'),
        '${_appLocalizations.get('something_went_wrong')}\n\n${_appLocalizations.get('error')}: $e',
      );
    }
  }

  // ✅ Google Sign-In (đã đơn giản hóa - chỉ cần Firebase)
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      // Gọi trực tiếp signIn
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Lấy authentication
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Tạo credential
      final fb_auth.OAuthCredential credential = fb_auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken ?? googleAuth.idToken,
      );

      // Đăng nhập Firebase
      await fb_auth.FirebaseAuth.instance.signInWithCredential(credential);

      // ✅ Chuyển sang trang chính (Firebase sẽ tự động load data theo userId)
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const Bottom()),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      
      print('Google Sign-In Error: $e');
      
      _showErrorDialog(
        _appLocalizations.get('login_error'),
        '${_appLocalizations.get('error')}: $e\n\n${_appLocalizations.get('something_went_wrong')}',
      );
    }
  }

  // Helper method để hiển thị dialog lỗi
  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => ValueListenableBuilder<String>(
        valueListenable: _appLocalizations.languageNotifier,
        builder: (context, lang, _) => AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(message),
          ),
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

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18.0);

    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
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
                      Icons.account_balance_wallet_rounded,
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
                      _appLocalizations.get('app_subtitle'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Form đăng nhập
                  Card(
                    elevation: 12,
                    shape: RoundedRectangleBorder(borderRadius: radius),
                    shadowColor: Colors.black26,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Email field
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
                                if (v == null || v.trim().isEmpty) {
                                  return _appLocalizations.get('enter_email');
                                }
                                final emailRegex =
                                    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                                if (!emailRegex.hasMatch(v.trim())) {
                                  return _appLocalizations.get('invalid_email');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password field
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
                                  onPressed: () =>
                                      setState(() => _obscure = !_obscure),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return _appLocalizations.get('enter_password');
                                }
                                if (v.length < 4) {
                                  return _appLocalizations.get('password_too_short');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 28),

                            // Nút đăng nhập Email/Password
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: _isLoading ? null : _onLogin,
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
                                          _appLocalizations.get('login'),
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

                            // Nút đăng nhập bằng Google
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                icon: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: SvgPicture.network(
                                    'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                                    placeholderBuilder: (context) =>
                                        const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 1.5,
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                                label: ValueListenableBuilder<String>(
                                  valueListenable: _appLocalizations.languageNotifier,
                                  builder: (context, lang, _) => Text(_appLocalizations.get('login_with_google')),
                                ),
                                onPressed: _isLoading ? null : _signInWithGoogle,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black87,
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Nút tạo tài khoản mới
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const RegisterScreen(),
                                        ),
                                      );
                                    },
                              child: ValueListenableBuilder<String>(
                                valueListenable: _appLocalizations.languageNotifier,
                                builder: (context, lang, _) => Text(
                                  _appLocalizations.get('dont_have_account'),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),

                            // Nút quên mật khẩu
                            TextButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const ForgotPasswordScreen(),
                                        ),
                                      );
                                    },
                              child: ValueListenableBuilder<String>(
                                valueListenable: _appLocalizations.languageNotifier,
                                builder: (context, lang, _) => Text(_appLocalizations.get('forgot_password')),
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
    ));
  }
}