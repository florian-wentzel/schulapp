import 'package:flutter/services.dart';

class GetFileIntentManager {
  static const methodChannelID = "GET_FILE_INTENT_CHANNEL";

  static const platform = MethodChannel(methodChannelID);

  static Future<String?> getOpenFileUrl() async {
    const methodName = "getOpenFileUrl";
    String? url = await platform.invokeMethod(methodName);

    return url;
  }
}
