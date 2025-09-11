import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_clipboard/flutter_image_clipboard.dart';
import 'package:go_router/go_router.dart';
import 'package:schulapp/code_behind/go_file_io_manager.dart';
import 'package:schulapp/code_behind/multi_platform_manager.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/timetable_controller.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/home_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ExportTimetablePage extends StatefulWidget {
  final void Function() goToHomePage;

  const ExportTimetablePage({
    super.key,
    required this.goToHomePage,
  });

  @override
  State<ExportTimetablePage> createState() => EexportTimetablePageState();
}

class EexportTimetablePageState extends State<ExportTimetablePage> {
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          AppLocalizationsManager.localizations.strSelectTimetableToExport,
          style: Theme.of(context).textTheme.headlineLarge,
          textAlign: TextAlign.center,
        ),
        _timetableList(),
        ElevatedButton(
          onPressed: () {
            widget.goToHomePage();
          },
          child: Text(AppLocalizationsManager.localizations.strBack),
        ),
        const SizedBox(
          height: 16,
        ),
      ],
    );
  }

  Widget _timetableList() {
    return Flexible(
      fit: FlexFit.tight,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListView.builder(
          itemCount: TimetableManager().timetables.length,
          itemBuilder: _itemBuilder,
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    Timetable timetable = TimetableManager().timetables[index];

    return IgnorePointer(
      ignoring: _exporting,
      child: ListTile(
        title: Text(timetable.name),
        trailing: Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(
                      timetable: timetable,
                      title:
                          AppLocalizationsManager.localizations.strTimetableX(
                        timetable.name,
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.info),
            ),
          ],
        ),
        onTap: () => _onItemTap(index),
      ),
    );
  }

  Future<void> _exportTimetable(int index) async {
    Timetable timetable = TimetableManager().timetables[index];

    Utils.showInfo(
      context,
      msg: AppLocalizationsManager.localizations.strExporting,
    );

    try {
      SaveManager().cleanExports();
    } catch (e) {
      Utils.hideCurrInfo(context);
      Utils.showInfo(
        context,
        msg: e.toString(),
        type: InfoType.error,
      );
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory == null) {
      if (mounted) {
        Utils.showInfo(
          context,
          type: InfoType.warning,
          msg: AppLocalizationsManager.localizations.strNoFileSelected,
        );
      }
      return;
    }
    if (selectedDirectory == "/") {
      if (mounted) {
        Utils.showInfo(
          context,
          type: InfoType.error,
          msg: AppLocalizationsManager.localizations.strThereWasAnError,
        );
      }
      return;
    }

    File? exportFile;

    try {
      exportFile =
          await SaveManager().exportTimetable(timetable, selectedDirectory);
      if (mounted) {
        Utils.hideCurrInfo(context);
      }
    } catch (e) {
      exportFile = null;
      if (mounted) {
        Utils.hideCurrInfo(context);
        Utils.showInfo(
          context,
          msg: e.toString(),
          type: InfoType.error,
        );
      }
      return;
    }

    if (mounted) {
      if (Platform.isAndroid || Platform.isIOS) {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager
              .localizations.strFileSavedInDownloadsDirectory,
          type: InfoType.success,
        );
      } else {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager.localizations.strExportingSuccessful,
          type: InfoType.success,
        );
      }
    }

    await MultiPlatformManager.shareFile(exportFile);

    widget.goToHomePage();
  }

  Future<void> _onShareTimetable(Timetable timetable) async {
    final enabled =
        await GoFileIoManager().showTermsOfServicesEnabledDialog(context);

    if (!enabled) return;

    try {
      final code = SaveManager().shareTimetable(timetable);

      if (!mounted) return;

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) {
          return FutureBuilder(
            future: code,
            builder: (context, snapshot) {
              Widget child;
              if (!snapshot.hasData) {
                child = const Center(
                  key: ValueKey("CircularProgressIndicator"),
                  child: CircularProgressIndicator(),
                );
              } else {
                final headingText = snapshot.data;

                if (headingText == null) {
                  Utils.showInfo(
                    context,
                    msg: AppLocalizationsManager
                        .localizations.strThereWasAnError,
                    type: InfoType.error,
                  );
                  Navigator.of(context).pop();
                  return const SizedBox.shrink();
                }

                child = ShareGoFileIOBottomSheet(
                  key: const ValueKey("ShareTimetableBottomSheet"),
                  shareText: AppLocalizationsManager
                      .localizations.strShareYourTimetable,
                  code: headingText,
                );
              }

              return AnimatedSwitcher(
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SizeTransition(
                      sizeFactor: animation,
                      child: child,
                    ),
                  );
                },
                duration: const Duration(
                  milliseconds: 400,
                ),
                child: child,
              );
            },
          );
        },
      );
    } catch (e) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg: e.toString(),
          type: InfoType.error,
        );
      }
    }
  }

  void _onItemTap(int timetableIndex) async {
    Timetable timetable = TimetableManager().timetables[timetableIndex];

    final actionWidgets = <(String title, Future<void> Function()? onPressed)>[
      (
        AppLocalizationsManager.localizations.strExportAsFile(
          SaveManager.timetableExportExtension,
        ),
        () async {
          if (_exporting) return;
          _exporting = true;
          setState(() {});
          await _exportTimetable(timetableIndex);
          _exporting = false;
          setState(() {});
        }
      ),
      (
        AppLocalizationsManager.localizations.strShareViaOnlineCode,
        () async {
          if (_exporting) return;
          _exporting = true;
          setState(() {});
          await _onShareTimetable(timetable);
          _exporting = false;
          setState(() {});
        }
      ),
      (
        AppLocalizationsManager.localizations.strShareImage,
        () async {
          if (_exporting) return;
          _exporting = true;
          setState(() {});

          BuildContext? dialogContext;

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext dContext) {
              dialogContext = dContext;
              return const Dialog(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              );
            },
          );

          final size = TimetableWidget.getPrefferedSize(
            timetable,
          );

          final Uint8List? imageBytes = await Utils.createImageFromWidget(
            context,
            SizedBox(
              width: size.width,
              height: size.height,
              child: TimetableWidget(
                controller: TimetableController(),
                timetable: timetable,
                showTodoEvents: false,
                showPageView: false,
                showHolidaysAndDates: false,
                highlightCurrLessonAndDay: false,
                size: size,
              ),
            ),
            wait: const Duration(milliseconds: 100),
            logicalSize: size,
            imageSize: Size(
              size.width * 4,
              size.height * 4,
            ),
            addBorder: true,
          );

          if (dialogContext?.mounted ?? false) {
            dialogContext?.pop();
          }

          _exporting = false;
          setState(() {});

          if (imageBytes == null) {
            if (mounted) {
              Utils.showInfo(
                context,
                msg: AppLocalizationsManager.localizations.strThereWasAnError,
                type: InfoType.error,
              );
            }
            return;
          }

          if (!mounted) return;

          await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            builder: (context) {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 12,
                    children: [
                      Text(
                        AppLocalizationsManager
                            .localizations.strShareYourTimetable,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.memory(imageBytes, fit: BoxFit.cover),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () async {
                              File? file = SaveManager()
                                  .saveTempImage(imageBytes, "timetable.png");

                              if (file == null) {
                                Utils.showInfo(
                                  context,
                                  msg: AppLocalizationsManager
                                      .localizations.strThereWasAnError,
                                  type: InfoType.error,
                                );
                                return;
                              }

                              if (Platform.isWindows) {
                                await MultiPlatformManager.shareFile(file);
                                return;
                              }
                              final box =
                                  context.findRenderObject() as RenderBox?;

                              Share.shareXFiles(
                                [
                                  XFile.fromData(
                                    imageBytes,
                                    name: "timetable.png",
                                    mimeType: "image/png",
                                    lastModified: DateTime.now(),
                                  ),
                                ],
                                sharePositionOrigin:
                                    box!.localToGlobal(Offset.zero) & box.size,
                              );

                              SaveManager().deleteTempDir();
                            },
                            icon: const Icon(Icons.share),
                          ),
                          IconButton(
                            onPressed: () async {
                              File? file = SaveManager()
                                  .saveTempImage(imageBytes, "timetable.png");

                              if (file == null) {
                                Utils.showInfo(
                                  context,
                                  msg: AppLocalizationsManager
                                      .localizations.strThereWasAnError,
                                  type: InfoType.error,
                                );
                                return;
                              }
                              if (Platform.isWindows) {
                                await MultiPlatformManager.shareFile(file);
                                return;
                              }
                              if (Platform.isAndroid || Platform.isIOS) {
                                await FlutterImageClipboard()
                                    .copyImageToClipboard(
                                  file,
                                );
                                if (context.mounted) {
                                  Utils.showInfo(
                                    context,
                                    msg: AppLocalizationsManager
                                        .localizations.strCopiedToClipboard,
                                    type: InfoType.success,
                                  );
                                }
                              }

                              SaveManager().deleteTempDir();
                            },
                            icon: const Icon(Icons.copy),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          AppLocalizationsManager.localizations.strFinished,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      ),
    ];

    await Utils.showStringAcionListBottomSheet(
      context,
      items: actionWidgets,
    );
  }
}

class ShareGoFileIOBottomSheet extends StatefulWidget {
  const ShareGoFileIOBottomSheet({
    super.key,
    required this.code,
    required this.shareText,
  });

  final String code;
  final String shareText;

  @override
  State<ShareGoFileIOBottomSheet> createState() =>
      _ShareGoFileIOBottomSheetState();
}

class _ShareGoFileIOBottomSheetState extends State<ShareGoFileIOBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.code,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: widget.code),
                    );
                    Utils.showInfo(
                      context,
                      msg: AppLocalizationsManager
                          .localizations.strCopiedToClipboard,
                      type: InfoType.success,
                    );
                  },
                  icon: const Icon(Icons.copy),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Text(
              AppLocalizationsManager.localizations.strDataSavedViaGoFile,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 12,
            ),
            ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(8),
              child: AspectRatio(
                aspectRatio: 1,
                child: QrImageView(
                  padding: const EdgeInsets.all(16),
                  data: widget.code,
                  errorCorrectionLevel: QrErrorCorrectLevel.Q,
                  version: QrVersions.auto,
                  gapless: true,
                  constrainErrorBounds: true,
                  backgroundColor: Theme.of(context).canvasColor,
                  eyeStyle: QrEyeStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    eyeShape: QrEyeShape.square,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    dataModuleShape: QrDataModuleShape.square,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    final box = context.findRenderObject() as RenderBox?;

                    Rect sharePositionOrigin =
                        box!.localToGlobal(Offset.zero) & box.size;

                    Navigator.of(context).pop();
                    Share.share(
                      widget.code,
                      sharePositionOrigin: sharePositionOrigin,
                      subject:
                          "${widget.shareText}\n${AppLocalizationsManager.localizations.strCode}: ${widget.code}",
                    );
                  },
                  child: Text(
                    widget.shareText,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
