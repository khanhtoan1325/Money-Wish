import 'package:flutter/material.dart';
import '../screens/change_password_screen.dart';
import 'package:expanse_management/Constants/color.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool biometricLock = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text('Bảo mật & Quyền riêng tư'),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // 🌿 Phần thông tin mở đầu
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [gradientStart, gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  Icon(Icons.security_rounded, size: 40, color: Colors.white),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      "Tăng cường bảo mật cho tài khoản của bạn và bảo vệ quyền riêng tư cá nhân.",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 🌿 Tùy chọn bảo mật
            _buildSettingCard(
              context: context,
              icon: Icons.fingerprint,
              title: 'Khóa vân tay / Face ID',
              subtitle: 'Bảo vệ ứng dụng bằng sinh trắc học',
              trailing: Switch(
                value: biometricLock,
                onChanged: (value) {
                  setState(() => biometricLock = value);
                },
                activeColor: primaryColor,
              ),
            ),
            const SizedBox(height: 15),

            // ✅ Đổi mật khẩu
            _buildSettingCard(
              context: context,
              icon: Icons.lock_reset,
              title: 'Đổi mật khẩu',
              subtitle: 'Cập nhật mật khẩu đăng nhập mới',
              trailing: IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChangePasswordScreen(),
                    ),
                  );
                },
                icon: Icon(Icons.arrow_forward_ios, size: 18, color: isDark ? Colors.white54 : Colors.grey),
              ),
            ),
            const SizedBox(height: 15),

            _buildSettingCard(
              context: context,
              icon: Icons.privacy_tip_outlined,
              title: 'Chính sách quyền riêng tư',
              subtitle: 'Xem chi tiết chính sách bảo mật dữ liệu',
              trailing: IconButton(
                onPressed: () {
                  _showPrivacyDialog(context);
                },
                icon: Icon(Icons.arrow_forward_ios, color: isDark ? Colors.white54 : Colors.grey, size: 18),
              ),
            ),

            const SizedBox(height: 25),

            // 🌿 Ghi chú nhỏ
            Text(
              "Ứng dụng không thu thập dữ liệu cá nhân của bạn ngoài phạm vi cần thiết để vận hành.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "© 2025 MoneyWise",
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🌿 Widget card hiển thị tùy chọn
  Widget _buildSettingCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xffe6f5f3),
            child: Icon(icon, color: primaryColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 13, 
                        color: isDark ? Colors.white70 : Colors.grey, 
                        height: 1.3)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  // 🌿 Popup chính sách quyền riêng tư
  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Chính sách quyền riêng tư"),
        content: const Text(
          "Chúng tôi cam kết bảo vệ thông tin cá nhân của bạn. "
          "Dữ liệu chỉ được sử dụng để cải thiện trải nghiệm người dùng, "
          "và không chia sẻ với bên thứ ba.",
          style: TextStyle(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text("Đóng", style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }
}
