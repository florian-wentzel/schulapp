import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/save_manager.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/screens/timetable_screen.dart';
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
  static const importExportString = "Import / Export Timetable";
  static const importString = "Import Timetable";
  static const exportString = "Export Timetable";

  static const homePageIndex = 1;

  final PageController _pageController = PageController(
    initialPage: homePageIndex,
  );

  String _titeString = importExportString;

  bool _exporting = false;

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
          title: Text(_titeString),
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
            _titeString = importString;
            setState(() {});
            _goToPage(0);
          },
          child: const Text("Import"),
        ),
        ElevatedButton(
          onPressed: () {
            _titeString = exportString;
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
        _titeString = importExportString;
        setState(() {});
        _goToPage(homePageIndex);
      },
      child: const Text("Back"),
    );
  }

  Widget _exportPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          "Select timetable to export: ",
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        _timetableList(),
        ElevatedButton(
          onPressed: () {
            _titeString = importExportString;
            setState(() {});
            _goToPage(homePageIndex);
          },
          child: const Text("Back"),
        ),
        const SizedBox(
          height: 16,
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

  Widget _itemBuilder(context, index) {
    Timetable timetable = TimetableManager().timetables[index];

    return IgnorePointer(
      ignoring: _exporting,
      child: ListTile(
        title: Text(timetable.name),
        trailing: IconButton(
          onPressed: () {
            Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (context) => TimetableScreen(
                  timetable: timetable,
                  title: "Timetable: ${timetable.name}",
                ),
              ),
            );
          },
          icon: const Icon(Icons.info),
        ),
        onTap: () async {
          await _exportTimetable(index);
          _exporting = false;
          setState(() {});
        },
      ),
    );
  }

  Future<void> _exportTimetable(int index) async {
    _exporting = true;
    setState(() {});

    Timetable timetable = TimetableManager().timetables[index];

    Utils.showInfo(context, msg: "Exporting..");

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

    //damit es so rüberkommt als würde etwas geschehen
    await Future.delayed(
      Duration(seconds: 1, milliseconds: (Random().nextDouble() * 500).toInt()),
    );

    File? exportFile;

    try {
      exportFile = SaveManager().exportTimetable(timetable);
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
      Utils.showInfo(
        context,
        msg: "Exporting Successful!",
        type: InfoType.success,
      );
    }

    // final result = await MultiPlatformManager.shareFile(exportFile);

    // if (result == null) return;

    // if (result.status != ShareResultStatus.success) {
    //   return;
    // }

    _goToPage(homePageIndex);
  }
}
