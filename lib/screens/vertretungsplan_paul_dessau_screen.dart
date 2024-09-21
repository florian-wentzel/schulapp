import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:schulapp/code_behind/paul_dessau_downloader.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

class VertretungsplanPaulDessauScreen extends StatefulWidget {
  const VertretungsplanPaulDessauScreen({super.key});

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
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  // mainAxisAlignment: MainAxisAlignment.,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(
                        seconds: 1,
                      ),
                      child: Padding(
                        key: const ValueKey("text"),
                        padding: EdgeInsets.symmetric(
                          vertical: _loadedPDF == null ? 84.0 : 8,
                          horizontal: 8,
                        ),
                        child: _loadedPDF != null
                            ? const SizedBox.shrink(
                                key: ValueKey(""),
                              )
                            : const Column(
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
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(
                        seconds: 1,
                      ),
                      child: TimetableManager()
                                  .settings
                                  .getVar(Settings.username) ==
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
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.all(12),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(
                  seconds: 1,
                ),
                child: _logInOutButton(),
              ),
            ],
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
                loginButtonPressed();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _logInOutButton() {
    final username =
        TimetableManager().settings.getVar<String?>(Settings.username);

    if (username != null) {
      return TextButton(
        key: const ValueKey("logout"),
        onPressed: () {},
        child: Text(
          "Abmelden",
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      );
    }
    return ElevatedButton(
      key: const ValueKey("login"),
      onPressed: _loading ? null : loginButtonPressed,
      child: const Text(
        "Anmelden",
      ),
    );
  }

  void loginButtonPressed() async {
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
          Settings.username,
          username,
        );

    b = TimetableManager().settings.setVar(
          Settings.securePassword,
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
      msg: AppLocalizationsManager.localizations.strLoginSuccessful,
      type: InfoType.success,
    );

    _loading = false;

    setState(() {});
  }

  Uint8List? _loadedPDF;

  void getPDFBytes() async {
    if (_loading) return;
    _loading = true;

    setState(() {});

    final username = TimetableManager().settings.getVar<String?>(
          Settings.username,
        );
    final password = TimetableManager().settings.getVar<String?>(
          Settings.securePassword,
        );

    if (username == null || password == null) {
      return;
    }

    try {
      var pdfBytes = await PaulDessauDownloader.getPdfAsBytes(
        username: username,
        password: password,
      );

      _loadedPDF = pdfBytes;
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
    if (_loadedPDF == null) {
      return Center(
        key: const ValueKey("button"),
        child: ElevatedButton(
          onPressed: getPDFBytes,
          child: const Text("Vertretungsplan Herunterladen"),
        ),
      );
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.9,
      child: PdfViewer.data(
        _loadedPDF!,
        key: const ValueKey("pdfViewer"),
        sourceName: "Vertretungsplan",
      ),
    );
  }
}
