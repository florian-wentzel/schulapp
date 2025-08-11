import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/theme/theme_manager.dart';
import 'package:schulapp/theme/themes.dart';
import 'package:schulapp/widgets/custom_pop_up.dart';
import 'package:image/image.dart' as img;

class Utils {
  static const hourKey = "hour";
  static const minuteKey = "minute";

  static const aKey = "a";
  static const rKey = "r";
  static const gKey = "g";
  static const bKey = "b";

  static final List<Color> _gradeColors = [
    // const Color.fromARGB(255, 127, 127, 127),
    const Color.fromARGB(0, 127, 127, 127),
    const Color.fromARGB(255, 237, 84, 71),
    const Color.fromARGB(255, 237, 84, 71),
    const Color.fromARGB(255, 247, 144, 49),
    const Color.fromARGB(255, 250, 166, 53),
    const Color.fromARGB(255, 248, 181, 63),
    const Color.fromARGB(255, 248, 196, 76),
    const Color.fromARGB(255, 215, 185, 61),
    const Color.fromARGB(255, 181, 176, 50),
    const Color.fromARGB(255, 159, 171, 45),
    const Color.fromARGB(255, 145, 171, 44),
    const Color.fromARGB(255, 131, 171, 43),
    const Color.fromARGB(255, 116, 171, 43),
    const Color.fromARGB(255, 101, 171, 42),
    const Color.fromARGB(255, 83, 170, 42),
    const Color.fromARGB(255, 53, 170, 41),
    const Color.fromARGB(255, 53, 170, 41),
  ];

  ///from -1 to 15
  static Color getGradeColor(int grade) {
    return _gradeColors[grade + 1];
  }

  static bool get isMobile {
    return /*!kIsWeb && */ (Platform.isAndroid || Platform.isIOS);
  }

  static bool get isDesktop {
    return /*!kIsWeb && */
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
  }

  static void updateTimetableLessons(
    Timetable timetable,
    SchoolLessonPrefab prefab, {
    String? newName,
    String? newShortName,
    String? newTeacher,
    String? newRoom,
    Color? newColor,
  }) {
    for (var tt in timetable.weekTimetables) {
      updateTimetableLessons(
        tt,
        prefab,
        newName: newName,
        newShortName: newShortName,
        newTeacher: newTeacher,
        newRoom: newRoom,
        newColor: newColor,
      );
    }
    for (int schoolDayIndex = 0;
        schoolDayIndex < timetable.schoolDays.length;
        schoolDayIndex++) {
      for (int lessonIndex = 0;
          lessonIndex < timetable.maxLessonCount;
          lessonIndex++) {
        SchoolLesson lesson =
            timetable.schoolDays[schoolDayIndex].lessons[lessonIndex];

        if (lesson.name != prefab.name) {
          continue;
        }

        if (newName != null) {
          lesson.name = newName;
        }
        if (newShortName != null) {
          lesson.shortName = newShortName;
        }
        if (newTeacher != null) {
          lesson.teacher = newTeacher;
        }
        if (newRoom != null) {
          lesson.room = newRoom;
        }
        if (newColor != null) {
          lesson.color = newColor;
        }
      }
    }
  }

  static bool isScreenOnTop(BuildContext context) {
    return ModalRoute.of(context)?.isCurrent ?? false;
  }

  ///returns 1 for question1 and 2 for question2 -1 for none
  static Future<int> show2OptionDialog(
    BuildContext context, {
    required String question,
    required String option1,
    required String option2,
    bool disableOption1 = false,
    bool disableOption2 = false,
    String? description,
  }) async {
    return await showDialog<int>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(question),
              content: description == null ? null : Text(description),
              actions: <Widget>[
                TextButton(
                  onPressed: disableOption1
                      ? null
                      : () {
                          Navigator.pop(context, 1);
                        },
                  child: Text(option1),
                ),
                TextButton(
                  onPressed: disableOption2
                      ? null
                      : () {
                          Navigator.pop(context, 2);
                        },
                  child: Text(
                    option2,
                  ),
                ),
              ],
            );
          },
        ) ??
        -1;
  }

  static Future<bool> showBoolInputDialog(
    BuildContext context, {
    required String question,
    String? description,
    TextButton Function(BuildContext context)? extraButtonBuilder,
    bool autofocus = false,
    bool showYesAndNoInsteadOfOK = false,
    bool markTrueAsRed = false,
    bool markFalseAsRed = false,
    bool hideFalse = false,
  }) async {
    bool? value = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(question),
          content: description == null ? null : Text(description),
          actions: <Widget>[
            if (extraButtonBuilder != null) extraButtonBuilder.call(context),
            TextButton(
              style: markTrueAsRed
                  ? TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    )
                  : null,
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(showYesAndNoInsteadOfOK
                  ? AppLocalizationsManager.localizations.strYes
                  : AppLocalizationsManager.localizations.strOK),
            ),
            if (!hideFalse)
              TextButton(
                style: markFalseAsRed
                    ? TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      )
                    : null,
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text(
                  showYesAndNoInsteadOfOK
                      ? AppLocalizationsManager.localizations.strNo
                      : AppLocalizationsManager.localizations.strCancel,
                ),
              ),
          ],
        );
      },
    );

    return value ?? false;
  }

  static Future<double?> showRangeInputDialog(
    BuildContext context, {
    required double minValue,
    required double maxValue,
    required double startValue,
    String textAfterValue = "",
    double distToSnapToPoint = 2,
    int precision = 0,
    bool onlyIntegers = false,
    bool showDeleteButton = false,
    String? title,
    List<double>? snapPoints,
  }) async {
    double currValue = startValue;
    snapPoints ??= [];

    bool deletePressed = false;

    final value = await showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title == null ? null : Text(title),
          content: StatefulBuilder(
            builder: (context, snapshot) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    child: Slider.adaptive(
                      value: currValue,
                      min: minValue,
                      max: maxValue,
                      onChanged: (value) {
                        for (double snapPoint in snapPoints ?? []) {
                          double dist = (snapPoint - value).abs();
                          if (dist < distToSnapToPoint) {
                            value = snapPoint;
                          }
                        }

                        if (onlyIntegers) {
                          value = value.round().toDouble();
                        }

                        snapshot.call(
                          () {
                            currValue = value;
                          },
                        );
                      },
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      int? length = await Utils.showIntInputDialog(
                        context,
                        hintText: title ?? "",
                        autofocus: true,
                      );

                      if (length == null) return;

                      snapshot.call(() {
                        currValue = length.toDouble().clamp(minValue, maxValue);
                      });
                    },
                    child: Text(
                      "${currValue.toStringAsFixed(precision)} $textAfterValue",
                    ),
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, currValue);
              },
              child: Text(AppLocalizationsManager.localizations.strOK),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizationsManager.localizations.strCancel),
            ),
            if (showDeleteButton)
              TextButton(
                onPressed: () {
                  deletePressed = true;
                  Navigator.pop(context);
                },
                child: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
          ],
        );
      },
    );
    if (showDeleteButton) {
      if (deletePressed) {
        return null;
      }

      if (value == null) {
        return startValue;
      }

      return value;
    }

    return value;
  }

  static Future<String?> showStringInputDialog(
    BuildContext context, {
    required String hintText,
    bool autofocus = true,
    String? title,
    String? initText,
    int maxInputLength = 20,
  }) async {
    TextEditingController textController = TextEditingController();
    textController.text = initText ?? "";

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title == null ? null : Text(title),
          content: TextField(
            maxLength: maxInputLength,
            autofocus: autofocus,
            controller: textController,
            decoration: InputDecoration(
              hintText: hintText,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, textController.text);
              },
              child: Text(AppLocalizationsManager.localizations.strOK),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizationsManager.localizations.strCancel),
            ),
          ],
        );
      },
    );
  }

  static Future<int?> showIntInputDialog(
    BuildContext context, {
    required String hintText,
    bool autofocus = true,
    String? title,
    String? initText,
    int maxInputLength = 20,
  }) async {
    TextEditingController textController = TextEditingController();
    textController.text = initText ?? "";

    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title == null ? null : Text(title),
          content: TextField(
            maxLength: maxInputLength,
            autofocus: autofocus,
            controller: textController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: InputDecoration(
              hintText: hintText,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, int.tryParse(textController.text));
              },
              child: Text(AppLocalizationsManager.localizations.strOK),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizationsManager.localizations.strCancel),
            ),
          ],
        );
      },
    );
  }

  static Future<Color?> showColorInputDialog(
    BuildContext context, {
    String? hintText,
    String? title,
    Color? pickerColor,
  }) {
    Color selectedColor = pickerColor ?? Colors.blue;

    return showDialog<Color?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: title == null ? null : Text(title),
          content: MaterialPicker(
            pickerColor: selectedColor,
            onColorChanged: (value) {
              selectedColor = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, selectedColor);
              },
              child: Text(AppLocalizationsManager.localizations.strOK),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizationsManager.localizations.strCancel),
            ),
          ],
        );
      },
    );
  }

  static Map<String, dynamic> timeToJson(TimeOfDay time) {
    return {
      hourKey: time.hour,
      minuteKey: time.minute,
    };
  }

  static TimeOfDay jsonToTime(Map<String, dynamic> json) {
    int hour = json[hourKey];
    int minute = json[minuteKey];
    return TimeOfDay(hour: hour, minute: minute);
  }

  static void showInfo(
    BuildContext context, {
    required String msg,
    InfoType type = InfoType.normal,
    Duration? duration,
    SnackBarAction? actionWidget,
  }) {
    duration ??= const Duration(seconds: 4);
    Color textColor =
        Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;
    Color backgroundColor;

    switch (type) {
      case InfoType.normal:
        backgroundColor = Colors.white;
        textColor = Colors.black;
        break;
      case InfoType.info:
        backgroundColor = Theme.of(context).cardColor.withAlpha(255);
        break;
      case InfoType.success:
        backgroundColor = Colors.green;
        break;
      case InfoType.warning:
        backgroundColor = Colors.yellow;
        textColor = Colors.black;
        break;
      case InfoType.error:
        backgroundColor = Colors.red;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        action: actionWidget,
        backgroundColor: backgroundColor,
        duration: duration,
        content: Text(
          msg,
          style: TextStyle(
            color: textColor,
          ),
        ),
      ),
    );
  }

  static void hideCurrInfo(
    BuildContext context, {
    SnackBarClosedReason closedReason = SnackBarClosedReason.hide,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(
      reason: closedReason,
    );
  }

  static SchoolSemester? getMainSemester() {
    if (TimetableManager().semesters.isEmpty) {
      return null;
    }

    try {
      String? mainTimetableName =
          TimetableManager().settings.getVar(Settings.mainSemesterNameKey);

      if (mainTimetableName != null) {
        return TimetableManager().semesters.firstWhere(
              (element) => element.name == mainTimetableName,
            );
      }
    } catch (_) {}

    // return TimetableManager().semesters.first;
    return null;
  }

  static Future<Timetable?> showSelectTimetableSheet(BuildContext context,
      {required String title}) async {
    Timetable? timetable;

    await Utils.showListSelectionBottomSheet(
      context,
      title: title,
      items: TimetableManager().timetables,
      itemBuilder: (context, index) {
        final tt = TimetableManager().timetables[index];

        return ListTile(
          onTap: () {
            timetable = tt;
            Navigator.of(context).pop();
          },
          title: Text(tt.name),
        );
      },
    );

    return timetable;
  }

  static Timetable? getHomescreenTimetable() {
    if (TimetableManager().timetables.isEmpty) {
      return null;
    }

    try {
      String? mainTimetableName =
          TimetableManager().settings.getVar(Settings.mainTimetableNameKey);

      if (mainTimetableName != null) {
        return TimetableManager().timetables.firstWhere(
              (element) => element.name == mainTimetableName,
            );
      }
    } catch (_) {}

    return TimetableManager().timetables.first;
  }

  static double getMobileRatio() => 9 / 16;

  static double getAspectRatio(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return width / height;
  }

  static String dateToString(DateTime date, {bool showYear = true}) {
    if (!showYear) {
      return "${date.day}.${date.month}";
    }
    return "${date.day}.${date.month}.${date.year}";
  }

  static String timeToString(DateTime date) {
    // return TimeOfDay.fromDateTime(date).format(context);
    String hour = date.hour.toString();
    if (date.hour < 10) {
      hour = "0${date.hour}";
    }
    String minute = date.minute.toString();
    if (date.minute < 10) {
      minute = "0${date.minute}";
    }

    return "$hour : $minute";
  }

  static Future<T?> showCustomPopUp<T>({
    required BuildContext context,
    required Object heroObject,
    required Widget body,
    int alpha = 220,
    Widget Function(BuildContext, Animation<double>, HeroFlightDirection,
            BuildContext, BuildContext)?
        flightShuttleBuilder,
    Color? color,
  }) async {
    color ??= Theme.of(context).cardColor.withAlpha(alpha);

    return await Navigator.push<T>(
      context,
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) => CustomPopUp(
          heroObject: heroObject,
          color: color!,
          body: body,
          flightShuttleBuilder: flightShuttleBuilder,
        ),
        barrierDismissible: true,
        fullscreenDialog: true,
      ),
    );
  }

  static int nowInSeconds() {
    final DateTime now = DateTime.now();

    return now.hour * 3600 + now.minute * 60 + now.second;
  }

  static int getCurrentWeekDayIndex() {
    int dayIndex = DateTime.now().weekday - 1;

    if (dayIndex == 5) return 4; //wenn samstag zeig Freitag
    if (dayIndex == 6) return 0; //wenn sonntag zeig Montag

    return dayIndex % 5;
  }

  static DateTime getWeekDay(DateTime dateTime, int targetDay) {
    int diff = dateTime.weekday - targetDay;

    if (diff < 0) {
      diff += 7;
    }

    DateTime dayOfCurrentWeek = dateTime.subtract(Duration(days: diff));

    return dayOfCurrentWeek;
  }

  static bool isMobileRatio(BuildContext context) {
    final aspectRatio = Utils.getAspectRatio(context);

    return (aspectRatio <= Utils.getMobileRatio());
  }

  static bool sameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static Future<SchoolLessonPrefab?> showSelectLessonPrefabList(
    BuildContext context, {
    required List<SchoolLessonPrefab> prefabs,
  }) async {
    SchoolLessonPrefab? selectedPrefab;

    await showStringAcionListBottomSheet(
      context,
      items: prefabs.map((e) {
        return (
          e.name,
          () async {
            selectedPrefab = e;
          },
        );
      }).toList(),
    );

    return selectedPrefab;
  }

  ///returns true if the action was executed
  ///returns false if the action was not executed
  ///returns null if the delete button was pressed
  static Future<bool?> showStringAcionListBottomSheet(
    BuildContext context, {
    String? title,
    bool runActionAfterPop = false,
    bool autoRunOnlyPossibleOption = false,
    bool showDeleteButton = false,
    required List<(String text, Future<void> Function()? action)> items,
  }) async {
    title ??= AppLocalizationsManager.localizations.strActions;

    Future<void> Function()? selectedAction;

    bool? result = false;

    if (autoRunOnlyPossibleOption && items.length == 1) {
      await items.first.$2?.call();
      return true;
    }

    await Utils.showListSelectionBottomSheet(
      context,
      title: title,
      items: items,
      itemBuilder: (context, index) {
        final label = items[index].$1;
        final cb = items[index].$2;
        return ListTile(
          title: Text(
            label,
          ),
          enabled: cb != null,
          onTap: () async {
            if (runActionAfterPop) {
              selectedAction = cb;
            } else {
              await cb?.call();
            }
            result = true;
            if (!context.mounted) return;
            Navigator.of(context).pop();
          },
        );
      },
      bottomActions: [
        ElevatedButton(
          onPressed: () {
            result = false;
            Navigator.of(context).pop();
          },
          child: Text(AppLocalizationsManager.localizations.strCancel),
        ),
        if (showDeleteButton)
          ElevatedButton(
            onPressed: () {
              result = null;
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
      ],
    );

    if (runActionAfterPop) {
      await selectedAction?.call();
    }

    return result;
  }

  static Future<T?> showListSelectionBottomSheet<T>(
    BuildContext context, {
    required String? title,
    required List<T> items,
    required Widget? Function(BuildContext context, int index) itemBuilder,
    String? underTitle,
    List<Widget>? bottomActions,
    bool boldTitle = true,
    double scrollControlDisabledMaxHeightRatio = 0.6,
  }) async {
    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      scrollControlDisabledMaxHeightRatio: scrollControlDisabledMaxHeightRatio,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (title != null)
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: boldTitle ? FontWeight.bold : null,
                      ),
                  textAlign: TextAlign.center,
                ),
              underTitle == null
                  ? Container()
                  : Column(
                      children: [
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          underTitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: itemBuilder,
                  ),
                ),
              ),
              if (bottomActions != null) ...bottomActions,
            ],
          ),
        );
      },
    );
    return null;
  }

  static bool isCustomTask({
    required String linkedSubjectName,
  }) {
    Timetable? selectedTimetable = Utils.getHomescreenTimetable();
    if (selectedTimetable == null) return false;

    Map<String, SchoolLessonPrefab> prefabs = {};

    for (var p in selectedTimetable.lessonPrefabs) {
      prefabs[p.name] = p;
    }

    for (var tt in selectedTimetable.weekTimetables) {
      for (var p in tt.lessonPrefabs) {
        prefabs[p.name] = p;
      }
    }

    List<SchoolLessonPrefab> selectedTimetablePrefabs = prefabs.values.toList();

    final isCustomTask = !selectedTimetablePrefabs.any(
      (element) => element.name == linkedSubjectName,
    );

    return isCustomTask;
  }

  static int getWeekIndex(DateTime date) {
    DateTime firstDayOfYear = DateTime(date.year, 1, 1);

    int daysDifference = date.difference(firstDayOfYear).inDays;

    int weekIndex = daysDifference ~/ 7 + 1;

    return weekIndex;
  }

  static Future<Uint8List?> createImageFromWidget(
    BuildContext context,
    Widget widget, {
    Duration? wait,
    Size? logicalSize,
    Size? imageSize,
    bool addBorder = false,
  }) async {
    final repaintBoundary = RenderRepaintBoundary();

    logicalSize ??=
        View.of(context).physicalSize / View.of(context).devicePixelRatio;
    imageSize ??= View.of(context).physicalSize;

    final canvasColor = Theme.of(context).canvasColor;

    final renderView = RenderView(
      child: RenderPositionedBox(
        alignment: Alignment.center,
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints(
          minWidth: 0.0,
          maxWidth: logicalSize.width,
          minHeight: 0.0,
          maxHeight: logicalSize.height,
        ),
        devicePixelRatio: 3,
      ),
      view: View.of(context),
    );

    final pipelineOwner = PipelineOwner();
    final buildOwner = BuildOwner(focusManager: FocusManager());

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(),
        child: Directionality(
          textDirection: ui.TextDirection.ltr,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: ThemeManager().themeMode,
            home: Scaffold(
              body: widget,
            ),
          ),
        ),
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);

    if (wait != null) {
      await Future.delayed(wait);
    }

    buildOwner
      ..buildScope(rootElement)
      ..finalizeTree();

    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

    final image = await repaintBoundary.toImage(
        pixelRatio: imageSize.width / logicalSize.width);

    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    final bytes = byteData?.buffer.asUint8List();

    if (addBorder) {
      const borderWidth = 32;
      return addBorderToImage(
        bytes!,
        borderWidth: borderWidth,
        // borderRadius: borderWidth * 2,
        borderColor: img.ColorFloat32.rgba(
          canvasColor.r,
          canvasColor.g,
          canvasColor.b,
          canvasColor.a,
        ),
      );
    }

    return bytes;
  }

  static Uint8List addBorderToImage(
    Uint8List pngBytes, {
    required int borderWidth,
    // required int borderRadius,
    required img.Color borderColor,
  }) {
    // Decode the PNG into an Image object
    img.Image? image = img.decodeImage(pngBytes);
    if (image == null) return pngBytes;

    // Calculate new dimensions
    int newWidth = image.width + 2 * borderWidth;
    int newHeight = image.height + 2 * borderWidth;

    // Create a new image with a black background
    img.Image borderedImage = img.Image(
      width: newWidth,
      height: newHeight,
    );

    img.fill(borderedImage, color: borderColor); // Fill with black

    // Copy the original image into the center
    borderedImage = img.compositeImage(
      borderedImage,
      image,
      dstX: borderWidth,
      dstY: borderWidth,
    );

    // // Create a mask with rounded corners
    // img.Image mask = img.Image(
    //   width: newWidth,
    //   height: newHeight,
    // );

    // img.fill(
    //   mask,
    //   color: img.ColorFloat32.rgba(0, 0, 0, 0),
    // ); // Fully transparent

    // // Draw a rounded rectangle (opaque white) as the visible area
    // img.drawRect(
    //   mask,
    //   x1: 0,
    //   y1: 0,
    //   x2: newWidth,
    //   y2: newHeight,
    //   // radius: borderRadius,
    //   color: img.ColorFloat32.rgba(255, 255, 255, 255),
    // );

    // // Apply the mask to make the corners transparent
    // img.Image finalImage =
    //     img.copyResize(borderedImage, width: newWidth, height: newHeight);
    // img.compositeImage(
    //   finalImage,
    //   mask,
    //   blend: img.BlendMode.difference,
    // );

    // Encode back to PNG
    return Uint8List.fromList(
      img.encodePng(borderedImage),
    );
  }
}

enum InfoType {
  normal,
  info,
  success,
  warning,
  error,
}
