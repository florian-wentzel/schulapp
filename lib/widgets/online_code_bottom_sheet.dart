import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

class OnlineCodeBottomSheet extends StatefulWidget {
  const OnlineCodeBottomSheet({super.key});

  @override
  State<OnlineCodeBottomSheet> createState() => _OnlineCodeBottomSheetState();
}

class _OnlineCodeBottomSheetState extends State<OnlineCodeBottomSheet> {
  static const maxCodeLength = 15;

  final _codeController = TextEditingController();
  final _scanController = MobileScannerController();

  bool _showQRScanner = false;

  String? code;

  Timer? _timer;

  @override
  void dispose() {
    _scanController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: bottomInset + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizationsManager.localizations.strImportViaCode,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                hintText: AppLocalizationsManager.localizations.strCode,
              ),
              onSubmitted: (value) {
                value = value.trim();
                Navigator.of(context).pop(value);
              },
              autofocus: true,
              maxLines: 1,
              maxLength: maxCodeLength,
              textAlign: TextAlign.center,
              controller: _codeController,
            ),
            const SizedBox(height: 8),
            Visibility(
              visible: Platform.isAndroid || Platform.isIOS,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: !_showQRScanner
                    ? ElevatedButton(
                        key: const ValueKey("button"),
                        onPressed: () async {
                          // Weil IOS nicht über .request() gefragt wird, müssen wir gleich das Widget zeigen, anschließend wird man gefragt..
                          if (Platform.isIOS) {
                            FocusManager.instance.primaryFocus?.unfocus();

                            await Future.delayed(
                                const Duration(milliseconds: 250));

                            setState(() {
                              _showQRScanner = true;
                            });
                            return;
                          }

                          final status = await Permission.camera.request();
                          if (!status.isGranted) {
                            if (context.mounted) {
                              Utils.showInfo(
                                context,
                                msg:
                                    "Du musst der App erlauben auf die Kamera zuzugreifen.",
                                type: InfoType.error,
                              );
                            }
                            return;
                          }
                          FocusManager.instance.primaryFocus?.unfocus();
                          await Future.delayed(
                              const Duration(milliseconds: 250));
                          setState(() {
                            _showQRScanner = true;
                          });
                        },
                        child: const Text("QR-Code Scannen"),
                      )
                    : ClipRRect(
                        key: const ValueKey("scanner"),
                        borderRadius: BorderRadius.circular(8),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              MobileScanner(
                                controller: _scanController,
                                onDetectError: (error, stackTrace) {
                                  print(error);
                                },
                                onDetect: (result) {
                                  final newCode =
                                      result.barcodes.first.rawValue;
                                  if (newCode == null) return;

                                  code = newCode;

                                  if (_timer != null) return;

                                  setState(() {
                                    _timer = Timer(
                                      const Duration(seconds: 1),
                                      () {
                                        if (mounted) {
                                          Navigator.of(context).pop(code);
                                        }
                                      },
                                    );
                                  });
                                },
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 700),
                                color: _timer != null
                                    ? Colors.green
                                    : Colors.transparent,
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final code = _codeController.text.trim();
                Navigator.of(context).pop(code);
              },
              child: Text(AppLocalizationsManager.localizations.strImport),
            ),
          ],
        ),
      ),
    );
  }
}
