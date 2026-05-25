import "dart:io";
import "dart:typed_data";

import "package:archive/archive.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:path/path.dart";
import "package:schulapp/code_behind/save_manager.dart";
import "package:schulapp/code_behind/settings.dart";
import "package:schulapp/code_behind/timetable_manager.dart";
import "package:schulapp/code_behind/utils.dart";
import "package:schulapp/l10n/app_localizations_manager.dart";
import "package:url_launcher/url_launcher.dart";

class OnlineShareManager {
  static Future<String> uploadToLitterbox(
    List<File> files, {
    String time = '72h',
  }) async {
    if (files.isEmpty) {
      throw ArgumentError('filePaths must not be empty');
    }

    final archive = Archive();
    for (final file in files) {
      if (!file.existsSync()) {
        throw FileSystemException('File does not exist', file.path);
      }

      final bytes = await file.readAsBytes();
      archive.addFile(
        ArchiveFile(
          file.path.split(Platform.pathSeparator).last,
          bytes.length,
          bytes,
        ),
      );
    }

    final encodedZip = ZipEncoder().encode(archive);

    final zipBytes = Uint8List.fromList(encodedZip);
    final uri =
        Uri.parse('https://litterbox.catbox.moe/resources/internals/api.php');

    final request = http.MultipartRequest('POST', uri)
      ..fields['reqtype'] = 'fileupload'
      ..fields['time'] = time
      ..files.add(http.MultipartFile.fromBytes(
        'fileToUpload',
        zipBytes,
        filename: 'files.zip',
      ));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final url = response.body.trim();
      return basenameWithoutExtension(Uri.parse(url).pathSegments.last);
    } else {
      throw HttpException(
          'Upload failed [${response.statusCode}]: ${response.body}');
    }
  }

  static Future<List<File>> downloadFromLitterbox(String code) async {
    final url = "https://litter.catbox.moe/$code.zip";
    final uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final archive = ZipDecoder().decodeBytes(response.bodyBytes);
      final tempDir = SaveManager().getTempDir();

      final files = <File>[];

      for (final entry in archive) {
        if (!entry.isFile) continue;
        String filePath = join(tempDir.path, entry.name);

        final file = File(filePath);
        await file.parent.create(recursive: true);
        await file.writeAsBytes(entry.content);
        files.add(file);
      }

      return files;
    } else {
      throw HttpException(
          'Download failed [${response.statusCode}]: ${response.body}');
    }
  }

  static Future<bool> fileExistsOnLitterbox(String code) async {
    try {
      final url = "https://litter.catbox.moe/$code.zip";
      final uri = Uri.parse(url);
      final response = await http.get(uri);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> showTermsOfServicesEnabledDialog(
      BuildContext context) async {
    bool allowed = TimetableManager()
        .settings
        .getVar<bool>(Settings.termsOfServiceLitterboxAllowedKey);

    if (!allowed) {
      allowed = await Utils.showBoolInputDialog(
        context,
        question: AppLocalizationsManager
            .localizations.strDoYouAgreeToTermsAndServiceOfLitterbox,
        description: AppLocalizationsManager
            .localizations.strFeatureUsesLitterboxToStoreDataOnline,
        showYesAndNoInsteadOfOK: true,
        extraButtonBuilder: (context) => TextButton(
          onPressed: () {
            launchUrl(Uri.parse('https://catbox.moe/legal.php'));
          },
          child: Text(AppLocalizationsManager.localizations.strTermsOfService),
        ),
      );

      if (!allowed) {
        if (context.mounted) {
          Utils.showInfo(
            context,
            msg: AppLocalizationsManager.localizations
                .strYouMustAgreeToTheTermsOfServiceToUseThisFeature,
            type: InfoType.error,
          );
        }
        return false;
      }
      TimetableManager()
          .settings
          .setVar<bool>(Settings.termsOfServiceLitterboxAllowedKey, true);
    }
    return true;
  }

  static Future<bool> showImportTodoEventWarningDialog(
      BuildContext context) async {
    bool show = TimetableManager()
        .settings
        .getVar<bool>(Settings.showImportTodoEventsWarnigKey);

    if (show) {
      final userKnows = await Utils.showBoolInputDialog(
        context,
        question:
            AppLocalizationsManager.localizations.strShareTodoEventWarning,
        description: AppLocalizationsManager
            .localizations.strShareTodoEventWarningDescription,
        extraButtonBuilder: (context) => TextButton(
          onPressed: () {
            show = false;
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizationsManager.localizations.strDoNotShowAgain),
        ),
      );

      if (!show) {
        TimetableManager()
            .settings
            .setVar<bool>(Settings.showImportTodoEventsWarnigKey, false);
        return true;
      }
      if (userKnows) {
        return true;
      }
      return false;
    }
    return true;
  }
}
