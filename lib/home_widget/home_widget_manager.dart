import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

class HomeWidgetManager {
  static const groupID = "group.schulapp";
  static const androidWidgetName = "TimetableOneDay";
  static const filePathKey = "filepath";

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(groupID);
  }

  static Future<void> update(
      BuildContext context, Widget widget, Size logicalSize) async {
    try {
      await HomeWidget.renderFlutterWidget(
        widget,
        key: filePathKey,
        logicalSize: logicalSize,
        pixelRatio: 4,
      );
      // Uint8List bytes = await DavinciCapture.offStage(
      //   widget,
      //   context: context,
      //   returnImageUint8List: true,
      //   openFilePreview: true,
      //   wait: const Duration(seconds: 1),
      // );

      // final directory = await getApplicationSupportDirectory();

      // File tempFile = File(join(directory.path, "widget.png"));

      // tempFile.writeAsBytesSync(bytes);

      // await HomeWidget.saveWidgetData<String>(filePathKey, tempFile.path);
      await HomeWidget.updateWidget(
        androidName: androidWidgetName,
      );
    } catch (e) {
      print(e);
    }
  }
}
