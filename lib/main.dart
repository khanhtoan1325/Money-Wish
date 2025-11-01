import 'package:expanse_management/presentation/screens/login_screen.dart';
import 'package:expanse_management/theme/theme_manager.dart';
import 'package:expanse_management/domain/models/category_model.dart';
import 'package:expanse_management/domain/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:expanse_management/presentation/screens/add_budget_screen.dart';
import 'package:expanse_management/presentation/screens/budget_list_screen.dart';
import 'package:expanse_management/presentation/screens/budget_detail_screen.dart';
import 'package:expanse_management/services/notification_service.dart';
import 'package:expanse_management/services/locale_service.dart';
import 'package:expanse_management/services/app_localizations.dart';
import 'package:expanse_management/Constants/color.dart';

// Future<void> clearData() async {
//   final appDocumentDirectory =
//       await path_provider.getApplicationDocumentsDirectory();
//   Hive.init(appDocumentDirectory.path);
//   await Hive.deleteFromDisk();
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // WidgetsFlutterBinding.ensureInitialized();
  // await clearData();
  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(CategoryModelAdapter());
  
  // Mở box với xử lý lỗi: xóa và tạo lại nếu có lỗi type cast
  try {
    await Hive.openBox<Transaction>('transactions');
  } catch (e) {
    // Xóa box cũ nếu có lỗi
    await Hive.deleteBoxFromDisk('transactions');
    await Hive.openBox<Transaction>('transactions');
  }
  
  try {
    await Hive.openBox<CategoryModel>('categories');
  } catch (e) {
    // Xóa box cũ nếu có lỗi
    await Hive.deleteBoxFromDisk('categories');
    await Hive.openBox<CategoryModel>('categories');
  }
  // Note: no local demo users are created. Authentication uses Firebase Auth.

  // 🔹 Khởi tạo theme từ Hive
  await ThemeManager.init();
  
  // 🔔 Khởi tạo Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // 🌍 Khởi tạo Locale Service
  final localeService = LocaleService();
  await localeService.initialize();
  
  // 🌍 Khởi tạo App Localizations
  final appLocalizations = AppLocalizations();
  await appLocalizations.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Ensure theme manager is initialized before building
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: primaryColor,
            useMaterial3: true,
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              secondary: secondaryColor,
              surface: backgroundCard,
              background: backgroundLight,
              error: errorColor,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: textPrimary,
              onBackground: textPrimary,
              onError: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: primaryColor,
            useMaterial3: true,
            scaffoldBackgroundColor: backgroundDark,
            colorScheme: ColorScheme.dark(
              primary: primaryLight,
              secondary: secondaryLight,
              surface: backgroundCardDark,
              background: backgroundDark,
              error: errorColor,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Colors.white,
              onBackground: Colors.white,
              onError: Colors.white,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E),
              elevation: 0,
              foregroundColor: Colors.white,
            ),
            cardTheme: const CardThemeData(
              color: Color(0xFF1E1E1E),
            ),
            // Đảm bảo Text widget có màu sáng trong dark mode
            textTheme: const TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white70),
              bodySmall: TextStyle(color: Colors.white60),
              headlineLarge: TextStyle(color: Colors.white),
              headlineMedium: TextStyle(color: Colors.white),
              headlineSmall: TextStyle(color: Colors.white),
              titleLarge: TextStyle(color: Colors.white),
              titleMedium: TextStyle(color: Colors.white),
              titleSmall: TextStyle(color: Colors.white70),
              labelLarge: TextStyle(color: Colors.white70),
              labelMedium: TextStyle(color: Colors.white60),
              labelSmall: TextStyle(color: Colors.white54),
            ),
            // Icon theme cho dark mode
            iconTheme: const IconThemeData(color: Colors.white70),
            // Input decoration theme
            inputDecorationTheme: const InputDecorationTheme(
              labelStyle: TextStyle(color: Colors.white70),
              hintStyle: TextStyle(color: Colors.white38),
              border: OutlineInputBorder(),
            ),
            // ListTile theme
            listTileTheme: const ListTileThemeData(
              textColor: Colors.white70,
              iconColor: Colors.white70,
            ),
            // Divider theme
            dividerTheme: const DividerThemeData(
              color: Colors.white24,
            ),
          ),
          home: const LoginScreen(),

          // ✅ Thêm routes ở đây
          routes: {
            '/budgets': (context) => const BudgetListScreen(),
            '/add-budget': (context) => const AddBudgetScreen(),
            // '/budget-detail' sẽ dùng Navigator.push với arguments
          },
        );
      },
    );
  }
}
