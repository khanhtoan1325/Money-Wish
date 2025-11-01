import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeManager {
  // ValueNotifier lưu trạng thái theme hiện tại
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);

  // Khởi tạo từ Hive box 'settings'
  static Future<void> init() async {
    if (!Hive.isBoxOpen('settings')) {
      await Hive.openBox('settings');
    }
    final box = Hive.box('settings');
    final isDark = box.get('isDark', defaultValue: false) as bool;
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  // Chuyển đổi theme
  static void toggle() {
    final isDark = themeMode.value == ThemeMode.dark;
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;
    themeMode.value = newMode;
    final box = Hive.box('settings');
    box.put('isDark', newMode == ThemeMode.dark);
  }

  // Đặt theme theo yêu cầu
  static void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    final box = Hive.box('settings');
    box.put('isDark', mode == ThemeMode.dark);
  }
}
