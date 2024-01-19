import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/screens/time_table/create_timetable_screen.dart';
import 'package:schulapp/screens/time_table/import_export_timetable_screen.dart';
import 'package:schulapp/widgets/timetable_widget.dart';
import 'package:schulapp/widgets/timetable_util_functions.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';
import 'package:schulapp/widgets/timetable_one_day_widget.dart';

// ignore: must_be_immutable
class TimetableScreen extends StatefulWidget {
  static const String route = "/";

  String title;
  Timetable? timetable;
  bool isHomeScreen;

  TimetableScreen({
    super.key,
    required this.title,
    required this.timetable,
    this.isHomeScreen = false,
  });

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: widget.isHomeScreen
          ? NavigationBarDrawer(selectedRoute: TimetableScreen.route)
          : null,
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 3,
        useRotationAnimation: true,
        tooltip: '',
        animationCurve: Curves.elasticInOut,

        // onOpen: () => print('OPENING DIAL'),
        // onClose: () => print('DIAL CLOSED'),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            label: 'Create new timetable',
            onTap: () async {
              await createNewTimetable(context);

              if (!mounted) return;

              context.go(TimetableScreen.route);
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.edit),
            visible: widget.timetable != null,
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            label: 'Edit',
            onTap: () async {
              if (widget.timetable == null) return;

              await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (context) => CreateTimeTableScreen(
                    timetable: widget.timetable!,
                  ),
                ),
              );

              setState(() {});
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.import_export),
            backgroundColor: Colors.lightBlue,
            foregroundColor: Colors.white,
            label: 'Import / Export',
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ImportExportTimetableScreen(),
                ),
              );
              setState(() {});
            },
          ),
        ],
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (widget.timetable == null) {
      return Center(
        child: ElevatedButton(
          onPressed: () async {
            await createNewTimetable(context);
            if (!mounted) return;
            context.go(TimetableScreen.route);
          },
          child: const Text("Create a Timetable"),
        ),
      );
    }
    final aspectRatio = Utils.getAspectRatio(context);

    if (aspectRatio <= Utils.getMobileRatio()) {
      return TimetableOneDayWidget(
        timetable: widget.timetable!,
      );
    }

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TimetableWidget(
                  timetable: widget.timetable!,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
