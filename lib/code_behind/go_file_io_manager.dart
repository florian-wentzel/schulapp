import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

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

  Future<String> uploadFile(
    File file, {
    bool returnSaveCode = false,
  }) async {
    if (!file.existsSync()) {
      throw AppLocalizationsManager.localizations.strSelectedFileDoesNotExist;
    }

    var url = Uri.parse('https://store1.gofile.io/uploadFile');
    var request = http.MultipartRequest('POST', url);

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var response = await request.send();

    if (response.statusCode == 200) {
      String responseBody = await response.stream.bytesToString();

      Map<String, dynamic>? json = jsonDecode(responseBody);

      String? downlaodLink = json?["data"]["parentFolderCode"];
      if (downlaodLink != null) {
        if (returnSaveCode) {
          return stringToSafeCode(downlaodLink);
        }
        return downlaodLink;
      }
    }
    throw AppLocalizationsManager.localizations.strFailedToUploadFile(
      response.statusCode.toString(),
      await response.stream.bytesToString(),
    );
  }

  Future<String> downloadFile(
    String id, {
    bool isSaveCode = false,
  }) async {
    if (isSaveCode) {
      id = stringFromSafeCode(id);
    }

    String accToken = await _getAccToken();

    (String link, String name) fileLinkAndName = await _getFileLinkAndName(
      id,
      accToken,
    );

    String link = fileLinkAndName.$1;
    String fileName = fileLinkAndName.$2;

    var client = http.Client();

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

      return filePath;
    } else {
      client.close();

      throw AppLocalizationsManager.localizations.strDownloadFailed(
        streamedResponse.statusCode.toString(),
        await streamedResponse.stream.bytesToString(),
      );
    }
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

  Future<(String link, String name)> _getFileLinkAndName(
    String id,
    String accToken,
  ) async {
    //where does wt=... come from?
    //https://gofile.io/dist/js/global.js at line 23 (appdata.wt = "4fd6sg89d7s6")
    final getContentUrl = "https://api.gofile.io/contents/$id?wt=4fd6sg89d7s6";

    final client = http.Client();

    var request = http.Request('GET', Uri.parse(getContentUrl));
    request.headers.addAll({
      'Authorization': 'Bearer $accToken',
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

      String? link = children.values.first['link'];
      String? name = children.values.first['name'];
      if (link != null && name != null) {
        return (link, name);
      }
    }

    throw AppLocalizationsManager.localizations.strCouldNotGetFileLink(
      streamedResponse.statusCode.toString(),
      await streamedResponse.stream.bytesToString(),
    );
  }
}
