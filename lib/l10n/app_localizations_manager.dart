import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations_en.dart';

class AppLocalizationsManager {
  //return default to English
  static AppLocalizations get localizations {
    return _localizations ?? AppLocalizationsEn();
  }

  static AppLocalizations? _localizations;

  static void setLocalizations(AppLocalizations value) {
    _localizations = value;
  }
}
