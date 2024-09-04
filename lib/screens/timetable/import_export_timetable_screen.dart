import 'package:flutter/material.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/timetable/export_timetable_page.dart';
import 'package:schulapp/screens/timetable/import_timetable_page.dart';
// import 'package:share_plus/share_plus.dart';

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

  static final importExportString =
      AppLocalizationsManager.localizations.strImportExportTimetable;
  static final importString =
      AppLocalizationsManager.localizations.strImportTimetable;
  static final exportString =
      AppLocalizationsManager.localizations.strExportTimetable;

  static const homePageIndex = 1;

  final PageController _pageController = PageController(
    initialPage: homePageIndex,
  );

  String _titleString = importExportString;

  int _currPageIndex = homePageIndex;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currPageIndex == homePageIndex,
      onPopInvoked: (didPop) async {
        if (_currPageIndex == homePageIndex) {
          return;
        }

        await _goToPage(homePageIndex);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_titleString),
        ),
        body: _body(),
      ),
    );
  }

  Widget _body() {
    return PageView(
      physics: const NeverScrollableScrollPhysics(),
      controller: _pageController,
      onPageChanged: (currPage) {
        _currPageIndex = currPage;
        setState(() {});
      },
      children: [
        ImportTimetablePage(
          goToHomePage: () {
            _titleString = importExportString;
            setState(() {});
            _goToPage(homePageIndex);
          },
        ),
        _importExportPage(),
        ExportTimetablePage(
          goToHomePage: () {
            _titleString = importExportString;
            setState(() {});
            _goToPage(homePageIndex);
          },
        ),
      ],
    );
  }

  Widget _importExportPage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () {
            _titleString = importString;
            setState(() {});
            _goToPage(0);
          },
          child: Text(
            AppLocalizationsManager.localizations.strImport,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            _titleString = exportString;
            setState(() {});
            _goToPage(2);
          },
          child: Text(
            AppLocalizationsManager.localizations.strExport,
          ),
        ),
      ],
    );
  }

  Future _goToPage(int index) {
    return _pageController.animateToPage(
      index,
      duration: animDuration,
      curve: animCurve,
    );
  }
}
