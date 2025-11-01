import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LocaleService {
  static final LocaleService _instance = LocaleService._internal();
  factory LocaleService() => _instance;
  LocaleService._internal();

  static const String _languageKey = 'selected_language';
  static const String _currencyKey = 'selected_currency';

  final ValueNotifier<String> languageNotifier = ValueNotifier<String>('vi');
  final ValueNotifier<String> currencyNotifier = ValueNotifier<String>('VND');

  /// Khởi tạo service - load preferences
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    languageNotifier.value = prefs.getString(_languageKey) ?? 'vi';
    currencyNotifier.value = prefs.getString(_currencyKey) ?? 'VND';
  }

  /// Lấy ngôn ngữ hiện tại
  String getCurrentLanguage() => languageNotifier.value;

  /// Lấy tiền tệ hiện tại
  String getCurrentCurrency() => currencyNotifier.value;

  /// Đặt ngôn ngữ mới
  Future<void> setLanguage(String languageCode) async {
    languageNotifier.value = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    
    // Notify AppLocalizations về thay đổi ngôn ngữ
    // AppLocalizations sẽ tự động listen thông qua initialize()
  }

  /// Đặt tiền tệ mới
  Future<void> setCurrency(String currencyCode) async {
    currencyNotifier.value = currencyCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currencyCode);
  }

  /// Danh sách ngôn ngữ hỗ trợ
  static final Map<String, String> supportedLanguages = {
    'vi': 'Tiếng Việt',
    'en': 'English',
    // Có thể thêm nhiều ngôn ngữ khác
  };

  /// Danh sách tiền tệ hỗ trợ
  static final Map<String, CurrencyInfo> supportedCurrencies = {
    'VND': CurrencyInfo(code: 'VND', symbol: '₫', name: 'Việt Nam Đồng', locale: 'vi_VN'),
    'USD': CurrencyInfo(code: 'USD', symbol: '\$', name: 'US Dollar', locale: 'en_US'),
    'EUR': CurrencyInfo(code: 'EUR', symbol: '€', name: 'Euro', locale: 'en_US'),
    'JPY': CurrencyInfo(code: 'JPY', symbol: '¥', name: 'Japanese Yen', locale: 'ja_JP'),
    'CNY': CurrencyInfo(code: 'CNY', symbol: '¥', name: 'Chinese Yuan', locale: 'zh_CN'),
    'KRW': CurrencyInfo(code: 'KRW', symbol: '₩', name: 'South Korean Won', locale: 'ko_KR'),
    'SGD': CurrencyInfo(code: 'SGD', symbol: 'S\$', name: 'Singapore Dollar', locale: 'en_SG'),
    'THB': CurrencyInfo(code: 'THB', symbol: '฿', name: 'Thai Baht', locale: 'th_TH'),
  };
}

class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  final String locale;

  CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    required this.locale,
  });
}

