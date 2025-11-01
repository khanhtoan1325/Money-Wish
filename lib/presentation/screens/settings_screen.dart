import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:expanse_management/presentation/screens/login_screen.dart';
import 'package:expanse_management/theme/theme_manager.dart';
import '../screens/app_info_screen.dart';
import '../screens/security_screen.dart';
import 'package:expanse_management/presentation/screens/wallet_screen.dart';
import 'package:expanse_management/presentation/screens/category_screen.dart';
import 'package:expanse_management/presentation/screens/profile_screen.dart';
import 'package:expanse_management/services/notification_service.dart';
import 'package:expanse_management/services/locale_service.dart';
import 'package:expanse_management/services/app_localizations.dart';
import 'package:expanse_management/Constants/color.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notifications = true;
  bool _isLoggingOut = false;
  final NotificationService _notificationService = NotificationService();
  final LocaleService _localeService = LocaleService();
  final AppLocalizations _appLocalizations = AppLocalizations();
  String _currentLanguage = 'vi';
  String _currentCurrency = 'VND';
  
  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
    _loadLocaleSettings();
  }
  
  Future<void> _loadNotificationSettings() async {
    final enabled = await _notificationService.isNotificationEnabled();
    setState(() {
      notifications = enabled;
    });
  }

  Future<void> _loadLocaleSettings() async {
    await _localeService.initialize();
    setState(() {
      _currentLanguage = _localeService.getCurrentLanguage();
      _currentCurrency = _localeService.getCurrentCurrency();
    });
  }

  // ✅ Logout method đúng cách
  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
              title: ValueListenableBuilder<String>(
                valueListenable: _appLocalizations.languageNotifier,
                builder: (context, lang, _) => Text(_appLocalizations.get('logout')),
              ),
              content: ValueListenableBuilder<String>(
                valueListenable: _appLocalizations.languageNotifier,
                builder: (context, lang, _) => Text(_appLocalizations.get('logout_confirm')),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: ValueListenableBuilder<String>(
              valueListenable: _appLocalizations.languageNotifier,
              builder: (context, lang, _) => Text(_appLocalizations.get('cancel')),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: ValueListenableBuilder<String>(
              valueListenable: _appLocalizations.languageNotifier,
              builder: (context, lang, _) => Text(
                _appLocalizations.get('logout'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoggingOut = true);

    try {
      // Sign out từ Google (nếu đã login bằng Google)
      try {
        await GoogleSignIn().signOut();
      } catch (e) {
        // Ignore Google sign out error
        debugPrint('Google sign out error: $e');
      }

      // Sign out từ Firebase
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      // Navigate to login screen
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );

      // Show success message (sau khi navigate)
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(
      //     content: Text('✅ Đăng xuất thành công'),
      //     backgroundColor: Colors.green,
      //   ),
      // );
    } catch (e) {
      setState(() => _isLoggingOut = false);
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: ValueListenableBuilder<String>(
            valueListenable: _appLocalizations.languageNotifier,
            builder: (context, lang, _) => Text(_appLocalizations.get('error')),
          ),
          content: ValueListenableBuilder<String>(
            valueListenable: _appLocalizations.languageNotifier,
            builder: (context, lang, _) => Text('${_appLocalizations.get('error')}: $e'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: ValueListenableBuilder<String>(
                valueListenable: _appLocalizations.languageNotifier,
                builder: (context, lang, _) => Text(_appLocalizations.get('ok')),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xfff5f5f5),
      body: Column(
        children: [
          // 🔹 Header có nút quay lại
          Container(
            width: double.infinity,
            height: 160,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [gradientStart, gradientEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.only(top: 50, left: 10, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 24,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 10),
                ValueListenableBuilder<String>(
                  valueListenable: _appLocalizations.languageNotifier,
                  builder: (context, lang, _) => Text(
                    _appLocalizations.get('settings'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // 👤 Hồ sơ
                _buildSettingCard(
                  icon: Icons.person,
                  title: 'profile',
                  subtitle: 'view_account_info',
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),

                // 🌙 Chế độ tối
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: ThemeManager.themeMode,
                  builder: (context, mode, _) {
                    final isDarkMode = mode == ThemeMode.dark;
                    return _buildSettingCard(
                      icon: Icons.dark_mode,
                      title: 'dark_mode',
                      subtitle: isDarkMode ? 'dark_mode_enabled' : 'dark_mode_disabled',
                      trailing: Switch(
                        value: isDarkMode,
                        onChanged: (value) {
                          ThemeManager.setThemeMode(
                            value ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                        activeTrackColor: primaryColor.withValues(alpha: 0.5),
                        activeThumbColor: primaryColor,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),

                // 🔔 Thông báo
                _buildSettingCard(
                  icon: Icons.notifications,
                  title: 'notifications',
                  subtitle: 'notifications_subtitle',
                  trailing: Switch(
                    value: notifications,
                    onChanged: (value) async {
                      setState(() => notifications = value);
                      await _notificationService.setNotificationEnabled(value);
                      
                      // Nếu tắt, hủy tất cả scheduled notifications
                      if (!value) {
                        await _notificationService.clearAllScheduledNotifications();
                        if (!mounted) return;
                        final appLocalizations = AppLocalizations();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: ValueListenableBuilder<String>(
                              valueListenable: appLocalizations.languageNotifier,
                              builder: (context, lang, _) => Text(
                                appLocalizations.get('notifications_disabled'),
                              ),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    activeTrackColor: primaryColor.withValues(alpha: 0.5),
                    activeThumbColor: primaryColor,
                  ),
                ),
                const SizedBox(height: 15),

                // 🌍 Ngôn ngữ
                _buildSettingCard(
                  icon: Icons.language,
                  title: 'language',
                  subtitle: LocaleService.supportedLanguages[_currentLanguage] ?? 'Tiếng Việt',
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 18,
                  ),
                  onTap: () => _showLanguageDialog(),
                ),
                const SizedBox(height: 15),

                // 💰 Tiền tệ
                _buildSettingCard(
                  icon: Icons.attach_money,
                  title: 'currency',
                  subtitle: LocaleService.supportedCurrencies[_currentCurrency]?.name ?? 'Việt Nam Đồng',
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 18,
                  ),
                  onTap: () => _showCurrencyDialog(),
                ),
                const SizedBox(height: 15),

                // 🔐 Bảo mật
                _buildSettingCard(
                  icon: Icons.security,
                  title: 'security',
                  subtitle: 'security_subtitle',
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SecurityScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),

                // ℹ️ Giới thiệu ứng dụng
                _buildSettingCard(
                  icon: Icons.info_outline,
                  title: 'app_info',
                  subtitle: 'app_info_subtitle',
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 18,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AppInfoScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 25),

                // 💼 Quản lý ví
                _buildSettingCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'wallet_management',
                  subtitle: 'wallet_management_subtitle',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const WalletScreen()),
                    );
                  },
                ),
                const SizedBox(height: 15),

                // 🗂 Quản lý danh mục
                _buildSettingCard(
                  icon: Icons.category_outlined,
                  title: 'category_management',
                  subtitle: 'category_management_subtitle',
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CategoryScreen()),
                    );
                  },
                ),
                const SizedBox(height: 25),

                // 🚪 Đăng xuất - ✅ SỬA LẠI
                ElevatedButton.icon(
                  onPressed: _isLoggingOut ? null : _handleLogout,
                  icon: _isLoggingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.logout, color: Colors.white),
                  label: ValueListenableBuilder<String>(
                    valueListenable: _appLocalizations.languageNotifier,
                    builder: (context, lang, _) => Text(
                      _isLoggingOut ? _appLocalizations.get('logging_out') : _appLocalizations.get('logout'),
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🌿 Widget tái sử dụng
  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appLocalizations = AppLocalizations();
    
    // Check if title/subtitle is a translation key or plain text
    final bool titleIsKey = appLocalizations.translate(title) != title;
    final bool subtitleIsKey = appLocalizations.translate(subtitle) != subtitle;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      splashColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xffe6f5f3),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xffe6f5f3),
              child: Icon(icon, color: primaryColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ValueListenableBuilder<String>(
                    valueListenable: appLocalizations.languageNotifier,
                    builder: (context, lang, _) => Text(
                      titleIsKey ? appLocalizations.translate(title) : title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 3),
                  ValueListenableBuilder<String>(
                    valueListenable: appLocalizations.languageNotifier,
                    builder: (context, lang, _) => Text(
                      subtitleIsKey ? appLocalizations.translate(subtitle) : subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white70 : Colors.grey,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  // Dialog chọn ngôn ngữ
  Future<void> _showLanguageDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: ValueListenableBuilder<String>(
            valueListenable: _appLocalizations.languageNotifier,
            builder: (context, lang, _) => Text(_appLocalizations.get('language')),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: LocaleService.supportedLanguages.entries.map((entry) {
                return RadioListTile<String>(
                  title: Text(entry.value),
                  value: entry.key,
                  groupValue: _currentLanguage,
                  onChanged: (value) {
                    Navigator.pop(context, value);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selected != null && selected != _currentLanguage) {
      await _localeService.setLanguage(selected);
      setState(() {
        _currentLanguage = selected;
      });
      if (mounted) {
        final appLocalizations = AppLocalizations();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLocalizations.translateWithParams(
              'language_changed',
              {'language': LocaleService.supportedLanguages[selected] ?? selected},
            )),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // Dialog chọn tiền tệ
  Future<void> _showCurrencyDialog() async {
    final selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: ValueListenableBuilder<String>(
            valueListenable: _appLocalizations.languageNotifier,
            builder: (context, lang, _) => Text(_appLocalizations.get('currency')),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: LocaleService.supportedCurrencies.entries.map((entry) {
                final currency = entry.value;
                return RadioListTile<String>(
                  title: Text('${currency.name} (${currency.symbol})'),
                  subtitle: Text(currency.code),
                  value: entry.key,
                  groupValue: _currentCurrency,
                  onChanged: (value) {
                    Navigator.pop(context, value);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selected != null && selected != _currentCurrency) {
      await _localeService.setCurrency(selected);
      setState(() {
        _currentCurrency = selected;
      });
      if (mounted) {
        final currencyName = LocaleService.supportedCurrencies[selected]?.name ?? selected;
        final appLocalizations = AppLocalizations();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(appLocalizations.translateWithParams(
              'currency_changed',
              {'currency': currencyName},
            )),
            duration: const Duration(seconds: 2),
          ),
        );
        // Có thể cần reload UI để cập nhật currency format
        // Tùy thuộc vào cách bạn implement, có thể cần notifyListeners
      }
    }
  }
}