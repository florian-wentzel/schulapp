import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class VersionManager {
  static Future<void> checkForUpdateAndErrors() async {
    const waitHours = 4;

    final lastFetch = TimetableManager().settings.getVar<DateTime?>(
          Settings.lastAppInfoJsonFetchKey,
        );

    if (lastFetch != null &&
        lastFetch
            .add(Duration(hours: waitHours))
            .isAfter(DateTime.now().toUtc())) {
      return;
    }

    TimetableManager().settings.setVar<DateTime?>(
          Settings.lastAppInfoJsonFetchKey,
          DateTime.now().toUtc(),
        );

    await Future.delayed(const Duration(seconds: 1));

    final appInfoJsonMap = await _getAppInfoJsonMap();

    final updateVersion = await checkForUpdates(appInfoJsonMap);
    if (updateVersion != null) {
      Utils.showInfo(
        null,
        type: InfoType.info,
        msg: AppLocalizationsManager.localizations.strNewVersionAvailable,
        actionWidget: SnackBarAction(
          label: AppLocalizationsManager.localizations.strUpdate,
          onPressed: _launchStorePage,
        ),
      );
    }

    final errors = await checkForKnownErrors(appInfoJsonMap);
    if (errors != null) {
      for (final error in errors) {
        Utils.showInfo(
          null,
          msg: error.$1,
          type: error.$2,
          duration: Duration(seconds: 7),
          actionWidget: error.$3
              ? SnackBarAction(
                  label: AppLocalizationsManager.localizations.strUpdate,
                  onPressed: _launchStorePage,
                )
              : null,
        );
      }
    }
  }

  static Future<void> _launchStorePage() async {
    Utils.hideCurrInfo(null);
    if (Platform.isAndroid) {
      try {
        await launchUrl(
          Uri.parse(
            "market://details?id=com.flologames.schulapp",
          ),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        await launchUrl(
          Uri.parse(
            "https://play.google.com/store/apps/details?id=com.flologames.schulapp",
          ),
          mode: LaunchMode.externalApplication,
        );
      }
    } else if (Platform.isIOS) {
      await launchUrl(
        Uri.parse(
          'https://apps.apple.com/us/app/schulapp-dein-schulbegleiter/id6743677720',
        ),
        mode: LaunchMode.externalApplication,
      );
    } else {
      await launchUrl(
        Uri.parse(
          'https://github.com/florian-wentzel/schulapp/',
        ),
      );
    }
  }

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

  static List<(String, InfoType, bool)>? parseAppInfoJsonWarnings(
    String currVersion,
    Map<String, dynamic> appInfoJsonMap,
  ) {
    final warnings = appInfoJsonMap["warnings"] as Map<String, dynamic>?;

    if (warnings == null) {
      return null;
    }

    List<(String, InfoType, bool)> errors = [];

    for (final error in warnings.entries) {
      final key = error.key.trim();
      final map = error.value as Map<String, dynamic>?;
      if (map == null) continue;

      String? msg = map[AppLocalizationsManager.languageCode] as String?;
      msg ??= map["en"] as String?;
      if (msg == null) continue;

      final importance = map["importance"] as int?;
      if (importance == null) continue;

      final infoType = _getInfoType(importance);

      final updateAvailable = (map["updateAvailable"] as bool?) ?? false;

      if (key.startsWith("<>")) {
        final versions = key.substring(2).trim().split(' ');
        if (versions.length != 2) continue;

        final version1 = versions[0];
        final version2 = versions[1];

        if (compareVersions(currVersion, version1) < 0 ||
            compareVersions(currVersion, version2) > 0) {
          continue;
        }

        errors.add((msg, infoType, updateAvailable));
        continue;
      }
      if (key.startsWith("<")) {
        final version = key.substring(1).trim();

        if (compareVersions(currVersion, version) != -1) {
          continue;
        }

        errors.add((msg, infoType, updateAvailable));
        continue;
      }
      if (key.startsWith(">")) {
        final version = key.substring(1).trim();

        if (compareVersions(currVersion, version) != 1) {
          continue;
        }

        errors.add((msg, infoType, updateAvailable));
        continue;
      }
      if (key.startsWith("=")) {
        final version = key.substring(1).trim();

        if (compareVersions(currVersion, version) != 0) {
          continue;
        }

        errors.add((msg, infoType, updateAvailable));
        continue;
      }
    }

    return errors;
  }

  /// returns null if no update is available, otherwise the latest version
  static Future<String?> checkForUpdates(
    Map<String, dynamic> appInfoJsonMap,
  ) async {
    final currVersion = await VersionManager().getVersionString();

    final latestVersion = appInfoJsonMap["latest_version"] as String?;

    if (latestVersion == null) return null;

    if (VersionManager.compareVersions(currVersion, latestVersion) != -1) {
      return null;
    }

    return latestVersion;
  }

  static Future<List<(String, InfoType, bool)>?> checkForKnownErrors(
    Map<String, dynamic> appInfoJsonMap,
  ) async {
    final currVersion = await VersionManager().getVersionString();

    return parseAppInfoJsonWarnings(currVersion, appInfoJsonMap);
  }

  static Future<Map<String, dynamic>> _getAppInfoJsonMap() async {
    final appInfoUrl =
        "https://raw.githubusercontent.com/florian-wentzel/schulapp/refs/heads/main/api/app_info.json";
    final response = await http.get(Uri.parse(appInfoUrl));
    return json.decode(response.body);
  }

  static InfoType _getInfoType(int importance) {
    switch (importance) {
      case 0:
        return InfoType.info;
      case 1:
        return InfoType.warning;
      case 2:
        return InfoType.error;
      default:
        return InfoType.info;
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
    "0.10.5": AppLocalizationsManager.localizations.version_0_10_5,
    "0.10.4": AppLocalizationsManager.localizations.version_0_10_4,
    "0.10.3": AppLocalizationsManager.localizations.version_0_10_3,
    "0.10.2": AppLocalizationsManager.localizations.version_0_10_2,
    "0.10.1": AppLocalizationsManager.localizations.version_0_10_1,
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
