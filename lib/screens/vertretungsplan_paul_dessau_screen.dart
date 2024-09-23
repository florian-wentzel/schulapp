import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:schulapp/code_behind/paul_dessau_downloader.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

// ignore: must_be_immutable
class VertretungsplanPaulDessauScreen extends StatefulWidget {
  bool loadPDFDirectly;

  VertretungsplanPaulDessauScreen({
    super.key,
    this.loadPDFDirectly = false,
  });

  @override
  State<VertretungsplanPaulDessauScreen> createState() =>
      _VertretungsplanPaulDessauScreenState();
}

class _VertretungsplanPaulDessauScreenState
    extends State<VertretungsplanPaulDessauScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late FocusNode _passwordFocusNode;

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _passwordFocusNode = FocusNode();
    if (widget.loadPDFDirectly) {
      Future.delayed(
        Duration.zero,
        () {
          _getPDFBytes();
        },
      );
    }
  }

  @override
  void dispose() {
    _passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vertretungsplan"),
        actions: [
          Visibility(
            visible: TimetableManager().settings.getVar(Settings.usernameKey) !=
                null,
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logoutButtonPressed,
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(
          seconds: 1,
        ),
        child: _body(),
      ),
      bottomNavigationBar: AnimatedSwitcher(
        duration: const Duration(
          seconds: 1,
        ),
        child: TimetableManager().settings.getVar(Settings.usernameKey) != null
            ? const SizedBox.shrink(
                key: ValueKey("nothing"),
              )
            : Container(
                margin: const EdgeInsets.all(12),
                height: kBottomNavigationBarHeight,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _loginButtonPressed,
                    child: const Text(
                      "Anmelden",
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _body() {
    if (_loadedPDFbytes != null) {
      return _pdfViewer();
    }

    return Column(
      key: const ValueKey("login"),
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 84.0,
                        horizontal: 8,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Vertretungsplan",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 32.0,
                            ),
                          ),
                          Text(
                            "von Gesamtschule Paul Dessau\n(beta)",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(
                        seconds: 1,
                      ),
                      child: TimetableManager()
                                  .settings
                                  .getVar(Settings.usernameKey) ==
                              null
                          ? _textFields()
                          : _pdfViewer(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Container _textFields() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: _usernameController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "vorname.nachname",
                labelText: 'Benutzername',
              ),
              onSubmitted: (value) {
                _passwordFocusNode.requestFocus();
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: TextField(
              focusNode: _passwordFocusNode,
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Passwort',
              ),
              onSubmitted: (value) {
                _loginButtonPressed();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _logoutButtonPressed() {
    _loadedPDFbytes = null;

    _usernameController.text = TimetableManager().settings.getVar(
          Settings.usernameKey,
        );
    _passwordController.text = "";

    TimetableManager().settings.setVar(
          Settings.usernameKey,
          null,
        );

    TimetableManager().settings.setVar(
          Settings.securePasswordKey,
          null,
        );

    setState(() {});
  }

  Future<void> _loginButtonPressed() async {
    if (_loading) return;

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty) {
      Utils.showInfo(
        context,
        msg: AppLocalizationsManager.localizations.strNameCanNotBeEmpty,
        type: InfoType.error,
      );
      return;
    }
    if (password.isEmpty) {
      Utils.showInfo(
        context,
        msg: AppLocalizationsManager.localizations.strPasswordCanNotBeEmpty,
        type: InfoType.error,
      );
      return;
    }

    _loading = true;
    setState(() {});

    bool a = true;
    bool b = true;

    a = TimetableManager().settings.setVar(
          Settings.usernameKey,
          username,
        );

    b = TimetableManager().settings.setVar(
          Settings.securePasswordKey,
          password,
        );

    if (!a || !b) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg: AppLocalizationsManager
              .localizations.strThereWasAnErrorWhileSaving,
          type: InfoType.error,
        );
      }
      return;
    }

    if (!mounted) return;

    Utils.showInfo(
      context,
      msg: AppLocalizationsManager.localizations.strLogindataSuccessfullySaved,
      type: InfoType.success,
    );

    _loading = false;

    setState(() {});
  }

  Uint8List? _loadedPDFbytes;

  void _getPDFBytes() async {
    if (_loading) return;
    _loading = true;

    setState(() {});

    final username = TimetableManager().settings.getVar<String?>(
          Settings.usernameKey,
        );
    final password = TimetableManager().settings.getVar<String?>(
          Settings.securePasswordKey,
        );

    if (username == null || password == null) {
      return;
    }

    try {
      var pdfBytes = await PaulDessauDownloader.getPdfAsBytes(
        username: username,
        password: password,
      );

      _loadedPDFbytes = pdfBytes;
    } catch (e) {
      if (mounted) {
        Utils.showInfo(
          context,
          msg: e.toString(),
          type: InfoType.error,
        );
      }
    }
    _loading = false;
    setState(() {});
  }

  Widget _pdfViewer() {
    if (_loading) {
      return const Center(
        key: ValueKey("loading"),
        child: CircularProgressIndicator(),
      );
    }
    if (_loadedPDFbytes == null) {
      return Center(
        key: const ValueKey("button"),
        child: ElevatedButton(
          onPressed: _getPDFBytes,
          child: const Text("Vertretungsplan Herunterladen"),
        ),
      );
    }

    return PdfViewer.data(
      _loadedPDFbytes!,
      key: const ValueKey("pdfViewer"),
      sourceName: "Vertretungsplan",
    );
  }
}
