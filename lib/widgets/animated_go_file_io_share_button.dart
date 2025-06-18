import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schulapp/code_behind/go_file_io_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/timetable/export_timetable_page.dart';

class AnimatedGoFileIOShareButton extends StatefulWidget {
  final Future<String?> Function() onPressed;
  final String? saveOnlineCode;
  final bool isSaveCode;

  const AnimatedGoFileIOShareButton({
    super.key,
    required this.onPressed,
    this.saveOnlineCode,
    this.isSaveCode = false,
  });

  @override
  State<AnimatedGoFileIOShareButton> createState() =>
      _AnimatedGoFileIOShareButtonState();
}

class _AnimatedGoFileIOShareButtonState
    extends State<AnimatedGoFileIOShareButton> {
  String? _saveOnlineCode;
  bool _loading = true;

  @override
  void initState() {
    _saveOnlineCode = widget.saveOnlineCode;

    _checkIfFileExists();

    super.initState();
  }

  Future<void> _checkIfFileExists() async {
    final onlineCode = _saveOnlineCode;

    if (onlineCode == null) {
      _loading = false;
      return;
    }

    final exists = await GoFileIoManager().doesFileExists(
      onlineCode,
      isSaveCode: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _saveOnlineCode = exists ? _saveOnlineCode : null;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding:
          _saveOnlineCode != null ? const EdgeInsets.only(right: 8.0) : null,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        child: _loading
            ? const CircularProgressIndicator(
                key: ValueKey('loading'),
              )
            : InkWell(
                onTap: _saveOnlineCode == null
                    ? null
                    : () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          useSafeArea: true,
                          builder: (context) {
                            return ShareGoFileIOBottomSheet(
                              shareText: AppLocalizationsManager
                                  .localizations.strShareYourTodoEvents,
                              code: _saveOnlineCode ?? '',
                            );
                          },
                        );
                      },
                child: Row(
                  key: const ValueKey('iconButton'),
                  children: [
                    if (_saveOnlineCode == null)
                      IconButton(
                        onPressed: () async {
                          final enabled = await GoFileIoManager()
                              .showTermsOfServicesEnabledDialog(context);

                          if (!enabled) return;

                          if (!mounted) return;

                          setState(() {
                            _loading = true;
                          });

                          final str = await widget.onPressed.call();

                          setState(() {
                            _loading = false;
                            _saveOnlineCode = str;
                          });
                        },
                        icon: const Icon(
                          Icons.share,
                        ),
                      ),
                    if (_saveOnlineCode != null)
                      IconButton(
                        onPressed: _copyCode,
                        icon: const Icon(Icons.copy),
                      ),
                    if (_saveOnlineCode != null)
                      Text(
                        _saveOnlineCode!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  void _copyCode() {
    final code = _saveOnlineCode;
    if (code == null || code.isEmpty) return;

    Clipboard.setData(
      ClipboardData(text: code),
    );

    Utils.showInfo(
      context,
      msg: AppLocalizationsManager.localizations.strCopiedToClipboard,
      type: InfoType.success,
    );
  }
}
