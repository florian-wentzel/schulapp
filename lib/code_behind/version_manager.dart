import 'dart:math';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

class VersionManager {
  static final VersionManager _instance = VersionManager._privateConstructor();
  VersionManager._privateConstructor();

  factory VersionManager() {
    return _instance;
  }

  Future<String> getVersionString() async {
    final packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    // String buildNumber = packageInfo.buildNumber;

    String text = version;
    // if (buildNumber.isNotEmpty) {
    //   text += "+$buildNumber";
    // }

    return text;
  }

  bool isFirstTimeOpening() {
    String? lastUsedVersion = TimetableManager().settings.getVar(
          Settings.lastUsedVersionKey,
        );

    return lastUsedVersion == null;
  }

  Future<bool> isNewVersionInstalled() async {
    String? lastUsedVersion = TimetableManager().settings.getVar(
          Settings.lastUsedVersionKey,
        );

    if (lastUsedVersion == null) {
      return false;
    }

    final currVersion = await getVersionString();

    int compareedVersions = compareVersions(lastUsedVersion, currVersion);

    return compareedVersions == -1;
  }

  Future<void> updateLastUsedVersion() async {
    final currVersion = await getVersionString();

    TimetableManager().settings.setVar(
          Settings.lastUsedVersionKey,
          currVersion,
        );
  }

  static int compareVersions(String v1, String v2) {
    try {
      List<String> parts1 = v1.split('.');
      List<String> parts2 = v2.split('.');

      for (int i = 0; i < min(parts1.length, parts2.length); i++) {
        int part1 = int.parse(parts1[i]);
        int part2 = int.parse(parts2[i]);
        if (part1 < part2) {
          return -1;
        } else if (part1 > part2) {
          return 1;
        }
      }

      return 0;
    } catch (_) {
      return 0;
    }
  }
}

class VersionHolder {
  static bool isVersionSaved(String version) {
    final versionInfo = getVersionInfo(version);

    return versionInfo != null;
  }

  static String? getVersionInfo(String version) {
    return _versions[version];
  }

  static Map<String, String> get versions {
    return _versions;
  }

  static final Map<String, String> _versions = {
    "0.1.8": AppLocalizationsManager.localizations.version_0_1_8,
    "0.1.7": AppLocalizationsManager.localizations.version_0_1_7,
    "0.1.6": AppLocalizationsManager.localizations.version_0_1_6,
    "0.1.5": AppLocalizationsManager.localizations.version_0_1_5,
    "0.1.4": AppLocalizationsManager.localizations.version_0_1_4,
    "0.1.3": AppLocalizationsManager.localizations.version_0_1_3,
    "0.1.2": AppLocalizationsManager.localizations.version_0_1_2,
    "0.1.1": AppLocalizationsManager.localizations.version_0_1_1,
    "0.1.0": AppLocalizationsManager.localizations.version_0_1_0,
  };
}
