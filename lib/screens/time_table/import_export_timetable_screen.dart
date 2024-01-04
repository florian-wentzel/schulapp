import 'package:flutter/material.dart';

class ImportExportTimetableScreen extends StatefulWidget {
  const ImportExportTimetableScreen({super.key});

  @override
  State<ImportExportTimetableScreen> createState() =>
      _ImportExportTimetableScreenState();
}

class _ImportExportTimetableScreenState
    extends State<ImportExportTimetableScreen> {
  static const animDuration = Duration(milliseconds: 350);
  static const animCurve = Curves.easeOut;
  static const importExportString = "Import / Export";
  static const importString = "Import";
  static const exportString = "Export";

  static const homePageIndex = 1;

  final PageController _pageController = PageController(
    initialPage: homePageIndex,
  );

  String titeString = importExportString;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titeString),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return PageView(
      controller: _pageController,
      children: [
        _importPage(),
        _importExportPage(),
        _exportPage(),
      ],
    );
  }

  Widget _importExportPage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            titeString = importString;
            setState(() {});
            _goToPage(0);
          },
          child: const Text("Import"),
        ),
        ElevatedButton(
          onPressed: () {
            titeString = exportString;
            setState(() {});
            _goToPage(2);
          },
          child: const Text("Export"),
        ),
      ],
    );
  }

  Widget _importPage() {
    return ElevatedButton(
      onPressed: () {
        titeString = importExportString;
        setState(() {});
        _goToPage(homePageIndex);
      },
      child: const Text("Back"),
    );
  }

  Widget _exportPage() {
    return ElevatedButton(
      onPressed: () {
        titeString = importExportString;
        setState(() {});
        _goToPage(homePageIndex);
      },
      child: const Text("Back"),
    );
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: animDuration,
      curve: animCurve,
    );
  }
}
