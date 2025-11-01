import 'package:expanse_management/services/app_localizations.dart';

/// Helper extension để truy cập AppLocalizations dễ dàng hơn
extension L10nExtension on String {
  /// Dịch text theo key
  String get tr => AppLocalizations().translate(this);
  
  /// Dịch text với parameters
  String trWithParams(Map<String, String> params) {
    return AppLocalizations().translateWithParams(this, params);
  }
}

/// Global function để truy cập localization
final l10n = AppLocalizations();

