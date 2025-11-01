import 'package:flutter/material.dart';
import 'package:expanse_management/Constants/color.dart';
import 'package:expanse_management/services/app_localizations.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appLocalizations = AppLocalizations();
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xfff5f5f5),
      appBar: AppBar(
        title: ValueListenableBuilder<String>(
          valueListenable: appLocalizations.languageNotifier,
          builder: (context, lang, _) => Text(appLocalizations.get('app_info_title')),
        ),
        centerTitle: true,
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            // 🌿 Logo ứng dụng
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [gradientStart, gradientMiddle, gradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.5, 1.0],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(Icons.account_balance_wallet,
                  color: Colors.white, size: 65),
            ),

            const SizedBox(height: 25),

            // 🌿 Tên ứng dụng
            Text(
              "MoneyWise",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: primaryColor,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<String>(
              valueListenable: appLocalizations.languageNotifier,
              builder: (context, lang, _) => Text(
                appLocalizations.get('app_subtitle'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white70 : textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 10),

            // 🌿 Mô tả
            Text(
              "Ứng dụng giúp bạn theo dõi, quản lý thu chi và ví cá nhân một cách thông minh, trực quan và an toàn.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white70 : Colors.black54,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 30),

            // 🌿 Thông tin ứng dụng
            ValueListenableBuilder<String>(
              valueListenable: appLocalizations.languageNotifier,
              builder: (context, lang, _) => _buildSectionCard(
                context: context,
                title: appLocalizations.get('detail_info'),
                children: [
                  _buildInfoRow(context, appLocalizations.get('version'), "1.0.0"),
                  _buildInfoRow(context, appLocalizations.get('developer'), "Nguyễn Khánh Toàn"),
                  _buildInfoRow(context, appLocalizations.get('developer'), "Nguyễn Công Thịnh"),
                  _buildInfoRow(context, appLocalizations.get('developer'), "Nguyễn Nhật Trình"),
                  _buildInfoRow(context, appLocalizations.get('support_email'), "nguyenkhanhtoan1325@gmail.com"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // 🌿 Giấy phép hoặc liên hệ
            ValueListenableBuilder<String>(
              valueListenable: appLocalizations.languageNotifier,
              builder: (context, lang, _) => _buildSectionCard(
                context: context,
                title: appLocalizations.get('contact_copyright'),
                children: [
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return ListTile(
                        leading: const Icon(Icons.mail_outline, color: primaryColor),
                        title: Text(
                          appLocalizations.get('support_email'),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          "nguyenkhanhtoan1325@gmail.com",
                          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                        ),
                      );
                    },
                  ),
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return Divider(color: isDark ? Colors.white24 : Colors.grey.shade300);
                    },
                  ),
                  Builder(
                    builder: (context) {
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      return ListTile(
                        leading: const Icon(Icons.copyright, color: primaryColor),
                        title: Text(
                          appLocalizations.get('copyright'),
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          "All rights reserved.",
                          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🌿 Thẻ chứa từng nhóm thông tin
  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  // 🌿 Dòng thông tin đơn giản
  Widget _buildInfoRow(BuildContext context, String title, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.w500)),
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  color: primaryColor,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
