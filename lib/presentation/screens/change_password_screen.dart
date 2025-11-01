import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:expanse_management/Constants/color.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 30),
              const Icon(Icons.lock_outline,
                  size: 80, color: primaryColor),
              const SizedBox(height: 15),
              Text(
                "Cập nhật mật khẩu của bạn",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 30),

              // Mật khẩu cũ
              _buildPasswordField(
                context: context,
                controller: _oldPasswordController,
                label: "Mật khẩu hiện tại",
                obscureText: _obscureOld,
                toggleVisibility: () =>
                    setState(() => _obscureOld = !_obscureOld),
              ),
              const SizedBox(height: 20),

              // Mật khẩu mới
              _buildPasswordField(
                context: context,
                controller: _newPasswordController,
                label: "Mật khẩu mới",
                obscureText: _obscureNew,
                toggleVisibility: () =>
                    setState(() => _obscureNew = !_obscureNew),
              ),
              const SizedBox(height: 20),

              // Xác nhận mật khẩu mới
              _buildPasswordField(
                context: context,
                controller: _confirmPasswordController,
                label: "Xác nhận mật khẩu mới",
                obscureText: _obscureConfirm,
                toggleVisibility: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Xác nhận thay đổi",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback toggleVisibility,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập $label';
        }
        if (label == "Xác nhận mật khẩu mới" &&
            value != _newPasswordController.text) {
          return 'Mật khẩu xác nhận không khớp';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.grey.shade300, 
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: isDark ? Colors.white54 : Colors.grey,
          ),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }

  void _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;

    try {
      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Re-authenticate với mật khẩu cũ
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pop(context); // Đóng loading
        _showErrorDialog('Lỗi', 'Không tìm thấy người dùng đăng nhập');
        return;
      }

      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      
      await user.reauthenticateWithCredential(credential);

      // Đổi mật khẩu
      await user.updatePassword(newPassword);
      await user.reload();

      // Đóng loading
      if (!mounted) return;
      Navigator.pop(context);

      // Hiển thị thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Đổi mật khẩu thành công!"),
          backgroundColor: primaryColor,
        ),
      );

      // Quay lại màn hình trước
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Đóng loading
      if (mounted) Navigator.pop(context);

      String message = 'Lỗi không xác định';
      switch (e.code) {
        case 'wrong-password':
          message = 'Mật khẩu hiện tại không đúng';
          break;
        case 'weak-password':
          message = 'Mật khẩu mới quá yếu. Vui lòng chọn mật khẩu mạnh hơn';
          break;
        case 'requires-recent-login':
          message = 'Vui lòng đăng nhập lại để thực hiện thao tác này';
          break;
        default:
          message = 'Đổi mật khẩu thất bại: ${e.message ?? e.code}';
      }

      _showErrorDialog('Lỗi đổi mật khẩu', message);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      _showErrorDialog('Lỗi', 'Có lỗi xảy ra: $e');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
