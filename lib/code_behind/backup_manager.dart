import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/version_manager.dart';
import 'package:schulapp/code_behind/zip_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

class BackupManager {
  static const String backupExportExtension = ".schulbackup";
  static const String secureBackupFileName = "secure-backup.json";
  static const String countKey = "file-count";
  static const String versionKey = "version";

  static Future<File?> createBackupAt({
    required String path,
    void Function(double)? onProgress,
  }) async {
    try {
      final mainDir = SaveManager().getMainSaveDir();

      if (!mainDir.existsSync()) {
        return null;
      }

      final tempDir = SaveManager().getTempDir();

      copyDirectorySync(
        source: mainDir,
        destination: tempDir,
        skipDirWithName: basename(tempDir.path),
      );

      await createSecureBackupFile(tempDir);

      final now = DateTime.now();
      final exportName =
          "Backup-${now.day}.${now.month}.${now.year}$backupExportExtension";

      final exportFile = File(join(path, exportName));

      final zipFile = await ZipManager.folderToZip(
        tempDir,
        exportFile,
        onProgress: onProgress,
      );

      SaveManager().deleteTempDir();

      return zipFile;
    } catch (e) {
      debugPrint(e.toString());
      try {
        SaveManager().deleteTempDir();
      } catch (e) {
        debugPrint(e.toString());
        return null;
      }
      return null;
    }
  }

  static Future<bool> restoreBackupFrom({
    required String path,
    required Future<bool> Function(String error) onErrorCB,
  }) async {
    final restoreFile = File(path);

    if (!restoreFile.existsSync()) {
      return false;
    }

    try {
      final tempDir = SaveManager().getTempDir();

      final unzipedFile = ZipManager.zipToFolder(restoreFile, tempDir);

      //test if the versions and the filecount match
      final secureZipErrorMsg = await checkSecureBackupFileFromDir(tempDir);

      if (secureZipErrorMsg != null) {
        final continueRestore = await onErrorCB.call(secureZipErrorMsg);
        if (!continueRestore) {
          SaveManager().deleteTempDir();
          return false;
        }
      }

      //delete All files
      SaveManager().deleteMainSaveDirExceptTemp();

      final mainDir = SaveManager().getMainSaveDir();

      copyDirectorySync(
        source: unzipedFile,
        destination: mainDir,
      );

      SaveManager().deleteTempDir();

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  //from: https://stackoverflow.com/a/76166248
  static void copyDirectorySync({
    required Directory source,
    required Directory destination,
    String? skipDirWithName,
  }) {
    if (!destination.existsSync()) {
      destination.createSync(recursive: true);
    }

    /// get all files from source (recursive: false is important here)
    source.listSync(recursive: false).forEach(
      (entity) {
        final newPath = join(destination.path, basename(entity.path));
        if (entity is File) {
          entity.copySync(newPath);
        } else if (entity is Directory) {
          if (skipDirWithName != null &&
              basename(entity.path) == skipDirWithName) {
            return;
          }
          copyDirectorySync(
            source: entity,
            destination: Directory(newPath),
            skipDirWithName: skipDirWithName,
          );
        }
      },
    );
  }

  ///returns null if every thing is working otherwise the error msg
  static Future<String?> checkSecureBackupFileFromDir(Directory dir) async {
    final secureBackupFile = File(join(dir.path, secureBackupFileName));

    if (!secureBackupFile.existsSync()) {
      return AppLocalizationsManager.localizations.strSecureBackupFileDoesNot;
    }

    final jsonString = secureBackupFile.readAsStringSync();

    Map<String, dynamic> json = jsonDecode(jsonString);

    String currVersion = await VersionManager().getVersionString();

    final count = dir
        .listSync(
          recursive: true,
          followLinks: false,
        )
        .length;

    String? error;

    if (json[countKey] != count) {
      error = AppLocalizationsManager
          .localizations.strFilesHaveBeenDeleteOrAddedBackup;
    }

    if (VersionManager.compareVersions(currVersion, json[versionKey]) != 0) {
      if (error == null) {
        error = AppLocalizationsManager
            .localizations.strVersionOfAppDoesNotMatchWithBackup;
      } else {
        error +=
            "\n${AppLocalizationsManager.localizations.strVersionOfAppDoesNotMatchWithBackup}";
      }
    }

    return error;
  }

  static Future<void> createSecureBackupFile(Directory dir) async {
    final secureBackupFile = File(join(dir.path, secureBackupFileName));

    if (!secureBackupFile.existsSync()) {
      secureBackupFile.createSync();
    }

    final list = dir.listSync(
      recursive: true,
      followLinks: false,
    );

    int count = list.length;

    Map<String, dynamic> json = {
      countKey: count,
      versionKey: await VersionManager().getVersionString(),
    };

    String jsonString = jsonEncode(json);

    secureBackupFile.writeAsStringSync(jsonString);
  }
}
