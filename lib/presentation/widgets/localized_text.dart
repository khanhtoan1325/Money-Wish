import 'package:flutter/material.dart';
import 'package:expanse_management/services/app_localizations.dart';

/// Widget Text tự động dịch thuật và tự động cập nhật khi ngôn ngữ thay đổi
class LocalizedText extends StatelessWidget {
  final String translationKey;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Map<String, String>? params;

  const LocalizedText(
    this.translationKey, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.params,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations();
    
    return ValueListenableBuilder<String>(
      valueListenable: appLocalizations.languageNotifier,
      builder: (context, lang, _) {
        final text = params != null
            ? appLocalizations.translateWithParams(translationKey, params!)
            : appLocalizations.translate(translationKey);
        
        return Text(
          text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

/// Helper để dễ dàng truy cập localization
final l10n = AppLocalizations();

