import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class GoFileIoManager {
  static final GoFileIoManager _instance = GoFileIoManager._internal();

  factory GoFileIoManager() {
    return _instance;
  }

  GoFileIoManager._internal();

  static const _safeAlphabet =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

  //convert a string to a string with chars out of the _safeAlphabet
  String stringToSafeCode(String input) {
    Uint8List bytes = utf8.encode(input);

    int resultInt = 0;
    for (int byte in bytes) {
      resultInt = resultInt * 256 + byte;
    }

    String saveCode = '';

    while (resultInt > 0) {
      int index = resultInt % _safeAlphabet.length;
      resultInt = resultInt ~/ _safeAlphabet.length;

      saveCode = _safeAlphabet[index] + saveCode;
    }

    return saveCode;
  }

  //convert a string with chars out of the _safeAlphabet to a normal string
  String stringFromSafeCode(String input) {
    final chars = input.split('');
    int resultInt = 0;

    for (String char in chars) {
      int index = _safeAlphabet.indexOf(char);
      if (index == -1) {
        throw "$char is not a valid character in the safe alphabet";
      }
      resultInt = resultInt * _safeAlphabet.length + index;
    }

    List<int> bytes = [];
    while (resultInt > 0) {
      bytes.add(resultInt % 256);
      resultInt = resultInt ~/ 256;
    }

    return utf8.decode(bytes.reversed.toList());
  }

  Future<String> uploadFiles(
    List<File> files, {
    bool returnSaveCode = false,
  }) async {
    for (var file in files) {
      if (!file.existsSync()) {
        throw AppLocalizationsManager.localizations.strSelectedFileDoesNotExist;
      }
    }

    String? folderID;
    String? token;
    String? code;

    for (var file in files) {
      final tuple = await _uploadFile(
        file,
        folderID: folderID,
        returnSaveCode: returnSaveCode,
        token: token,
      );
      code = tuple.$1;
      folderID = tuple.$2;
      token = tuple.$3;
    }

    if (code == null) {
      throw AppLocalizationsManager.localizations.strThereWasAnError;
    }

    return code;
  }

  Future<(String code, String folderID, String token)> _uploadFile(
    File file, {
    String? folderID,
    String? token,
    bool returnSaveCode = false,
  }) async {
    //neue url wählt automatisch den nächstliegenden Server aus
    // var url = Uri.parse('https://store1.gofile.io/uploadFile');
    var url = Uri.parse('https://upload.gofile.io/uploadfile');
    var request = http.MultipartRequest('POST', url);

    if (folderID != null) {
      request.fields["folderId"] = folderID;
    }
    if (token != null) {
      request.fields["token"] = token;
    }

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();

      Map<String, dynamic>? json = jsonDecode(responseBody);

      String? downlaodLink = json?["data"]["parentFolderCode"];
      String? token = json?["data"]["guestToken"];
      String? folderID = json?["data"]["parentFolder"];

      if (downlaodLink != null && token != null && folderID != null) {
        if (returnSaveCode) {
          return (stringToSafeCode(downlaodLink), folderID, token);
        }
        return (downlaodLink, folderID, token);
      }
    }
    throw AppLocalizationsManager.localizations.strFailedToUploadFile(
      response.statusCode.toString(),
      await response.stream.bytesToString(),
    );
  }

  Future<bool> doesFileExists(
    String id, {
    bool isSaveCode = false,
  }) async {
    try {
      if (isSaveCode) {
        id = stringFromSafeCode(id);
      }

      String accToken = await _getAccToken();

      await getFileLinksAndNames(id, accToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<String>> downloadFiles(
    String id, {
    bool isSaveCode = false,
  }) async {
    if (isSaveCode) {
      id = stringFromSafeCode(id);
    }

    String accToken = await _getAccToken();

    List<(String link, String name)> fileLinksAndNames =
        await getFileLinksAndNames(
      id,
      accToken,
    );

    List<String> paths = [];

    for (var fileLinkAndName in fileLinksAndNames) {
      var client = http.Client();

      String link = fileLinkAndName.$1;
      String fileName = fileLinkAndName.$2;

      var apiUrl = Uri.parse(link);
      var request = http.Request('GET', apiUrl);

      request.headers.addAll({
        'Cookie': 'accountToken=$accToken',
        'Accept': '*/*',
      });

      var streamedResponse = await client.send(request);

      if (streamedResponse.statusCode == 200) {
        Directory appDocDir = SaveManager().getTempDir();
        String filePath = join(appDocDir.path, fileName);

        File file = File(filePath);
        var fileSink = file.openWrite();

        await streamedResponse.stream.pipe(fileSink);
        await fileSink.close();

        client.close();

        paths.add(filePath);
      } else {
        client.close();

        throw AppLocalizationsManager.localizations.strDownloadFailed(
          streamedResponse.statusCode.toString(),
          await streamedResponse.stream.bytesToString(),
        );
      }
    }

    return paths;
  }

  Future<String> _getAccToken() async {
    const getAccountTokenUrl = "https://api.gofile.io/accounts";

    var response = await http.post(Uri.parse(getAccountTokenUrl));

    if (response.statusCode == 200) {
      String responseBody = response.body;
      Map<String, dynamic>? json = jsonDecode(responseBody);
      String? accToken = json?["data"]["token"];
      if (accToken != null) {
        return accToken;
      }
    }
    throw AppLocalizationsManager.localizations.strFailedToRetrieveAccountToken(
      response.statusCode.toString(),
      response.body,
    );
  }

  Future<List<(String link, String name)>> getFileLinksAndNames(
    String id,
    String accToken,
  ) async {
    final getContentUrl = "https://api.gofile.io/contents/$id";

    final client = http.Client();

    var request = http.Request('GET', Uri.parse(getContentUrl));
    request.headers.addAll({
      'Authorization': 'Bearer $accToken',
      //where does 'X-Website-Token come from? (its like ?wt=... before in the old api)
      //https://gofile.io/dist/js/config.js at line 24 (like appdata.wt = "...")
      'X-Website-Token': "4fd6sg89d7s6",
    });

    var streamedResponse = await client.send(request);

    if (streamedResponse.statusCode == 200) {
      String responseBody = await streamedResponse.stream.bytesToString();
      Map<String, dynamic>? json = jsonDecode(responseBody);
      var children = json?['data']['children'] as Map<String, dynamic>?;

      if (children == null || children.isEmpty) {
        throw AppLocalizationsManager
            .localizations.strNoDataAvailablePleaseCheckCode;
      }

      List<(String link, String name)> list = [];

      for (var item in children.values) {
        String? link = item['link'];
        String? name = item['name'];
        if (link != null && name != null) {
          list.add((link, name));
        }
      }

      if (list.isEmpty) {
        throw AppLocalizationsManager.localizations.strSelectedFileDoesNotExist;
      }

      return list;
    }

    throw AppLocalizationsManager.localizations.strCouldNotGetFileLink(
      streamedResponse.statusCode.toString(),
      await streamedResponse.stream.bytesToString(),
    );
  }

  Future<bool> showTermsOfServicesEnabledDialog(BuildContext context) async {
    bool allowed = TimetableManager()
        .settings
        .getVar<bool>(Settings.termsOfServiceGoFileIoAllowed);

    if (!allowed) {
      allowed = await Utils.showBoolInputDialog(
        context,
        question: AppLocalizationsManager
            .localizations.strDoYouAgreeToTermsAndServiceOfGoFileIo,
        description: AppLocalizationsManager
            .localizations.strFeatureUsesGoFileIoToStoreDataOnline,
        showYesAndNoInsteadOfOK: true,
        extraButtonBuilder: (context) => TextButton(
          onPressed: () {
            launchUrl(Uri.parse('https://gofile.io/terms'));
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
          .setVar<bool>(Settings.termsOfServiceGoFileIoAllowed, true);
    }
    return true;
  }

  Future<bool> showImportTodoEventWarningDialog(BuildContext context) async {
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
