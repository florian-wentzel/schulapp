import 'package:schulapp/l10n/generated/app_localizations.dart';
import 'package:schulapp/l10n/generated/app_localizations_en.dart';

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
