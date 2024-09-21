import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class PaulDessauDownloader {
  PaulDessauDownloader._privateConstructor();

  static const String proxyUrl =
      "https://iserv-zeuthen-downloader-proxy.netlify.app/.netlify/functions/get-vertretungsplan";
//http://localhost:8888

  static Future<Uint8List> getPdfAsBytes({
    required String username,
    required String password,
  }) async {
    final body = {
      "username": username,
      "password": password,
    };
    final response = await http.post(
      Uri.parse(proxyUrl),
      body: body,
    );
    if (response.headers["content-type"] != "application/pdf") {
      var body = jsonDecode(response.body);
      if (body["msg"] == "Not Found") {
        throw "Keine PDF im \"Pläne\" Modul hochgeladen:(";
      }
      if (body["msg"] == "Unauthorized") {
        throw "Benutzername oder Passwort falsch:(";
      }
      throw "Misst da ist was unerwartetes schiefgelaufen:(\n${body["msg"]}";
    }
    return response.bodyBytes;
  }
}
