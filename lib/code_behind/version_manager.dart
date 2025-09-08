import 'dart:math';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
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

    return version;
  }

  Future<String> getVersionWithBuildnumberString() async {
    final packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    String text = version;
    if (buildNumber.isNotEmpty) {
      text += "+$buildNumber";
    }

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
    "0.10.0": AppLocalizationsManager.localizations.version_0_10_0,
    "0.9.9": AppLocalizationsManager.localizations.version_0_9_9,
    "0.9.8": AppLocalizationsManager.localizations.version_0_9_8,
    "0.9.7": AppLocalizationsManager.localizations.version_0_9_7,
    "0.9.6": AppLocalizationsManager.localizations.version_0_9_6,
    "0.9.5": AppLocalizationsManager.localizations.version_0_9_5,
    "0.9.4": AppLocalizationsManager.localizations.version_0_9_4,
    "0.9.3": AppLocalizationsManager.localizations.version_0_9_3,
    "0.9.2": AppLocalizationsManager.localizations.version_0_9_2,
    "0.9.1": AppLocalizationsManager.localizations.version_0_9_1,
    "0.9.0": AppLocalizationsManager.localizations.version_0_9_0,
    "0.8.7": AppLocalizationsManager.localizations.version_0_8_7,
    "0.8.6": AppLocalizationsManager.localizations.version_0_8_6,
    "0.8.5": AppLocalizationsManager.localizations.version_0_8_5,
    "0.8.4": AppLocalizationsManager.localizations.version_0_8_4,
    "0.8.3": AppLocalizationsManager.localizations.version_0_8_3,
    "0.8.2": AppLocalizationsManager.localizations.version_0_8_2,
    "0.8.1": AppLocalizationsManager.localizations.version_0_8_1,
    "0.8.0": AppLocalizationsManager.localizations.version_0_8_0,
    "0.7.4": AppLocalizationsManager.localizations.version_0_7_4,
    "0.7.3": AppLocalizationsManager.localizations.version_0_7_3,
    "0.7.2": AppLocalizationsManager.localizations.version_0_7_2,
    "0.7.1": AppLocalizationsManager.localizations.version_0_7_1,
    "0.7.0": AppLocalizationsManager.localizations.version_0_7_0,
    "0.6.0": AppLocalizationsManager.localizations.version_0_6_0,
    "0.5.2": AppLocalizationsManager.localizations.version_0_5_2,
    "0.5.1": AppLocalizationsManager.localizations.version_0_5_1,
    "0.5.0": AppLocalizationsManager.localizations.version_0_5_0,
    "0.4.9": AppLocalizationsManager.localizations.version_0_4_9,
    "0.4.8": AppLocalizationsManager.localizations.version_0_4_8,
    "0.4.7": AppLocalizationsManager.localizations.version_0_4_7,
    "0.4.6": AppLocalizationsManager.localizations.version_0_4_6,
    "0.4.5": AppLocalizationsManager.localizations.version_0_4_5,
    "0.4.4": AppLocalizationsManager.localizations.version_0_4_4,
    "0.4.3": AppLocalizationsManager.localizations.version_0_4_3,
    "0.4.2": AppLocalizationsManager.localizations.version_0_4_2,
    "0.4.1": AppLocalizationsManager.localizations.version_0_4_1,
    "0.4.0": AppLocalizationsManager.localizations.version_0_4_0,
    "0.3.0": AppLocalizationsManager.localizations.version_0_3_0,
    "0.2.8": AppLocalizationsManager.localizations.version_0_2_8,
    "0.2.7": AppLocalizationsManager.localizations.version_0_2_7,
    "0.2.6": AppLocalizationsManager.localizations.version_0_2_6,
    "0.2.5": AppLocalizationsManager.localizations.version_0_2_5,
    "0.2.4": AppLocalizationsManager.localizations.version_0_2_4,
    "0.2.3": AppLocalizationsManager.localizations.version_0_2_3,
    "0.2.2": AppLocalizationsManager.localizations.version_0_2_2,
    "0.2.1": AppLocalizationsManager.localizations.version_0_2_1,
    "0.2.0": AppLocalizationsManager.localizations.version_0_2_0,
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
