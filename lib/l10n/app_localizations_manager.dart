import 'dart:ui';

import 'package:schulapp/l10n/generated/app_localizations.dart';
import 'package:schulapp/l10n/generated/app_localizations_en.dart';

class AppLocalizationsManager {
  //return default to English
  static AppLocalizations get localizations {
    return _localizations ?? AppLocalizationsEn();
  }

  static String get languageCode {
    return _locale?.languageCode ?? "en";
  }

  static AppLocalizations? _localizations;
  static Locale? _locale;

  static void setLocalizations(AppLocalizations value, Locale locale) {
    _localizations = value;
    _locale = locale;
  }
}
