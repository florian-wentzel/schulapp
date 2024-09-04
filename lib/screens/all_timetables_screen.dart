import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:schulapp/app.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/home_widget/home_widget_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/time_table/create_timetable_screen.dart';
import 'package:schulapp/screens/time_table/import_export_timetable_screen.dart';
import 'package:schulapp/screens/timetable_screen.dart';
import 'package:schulapp/code_behind/timetable_util_functions.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';

class AllTimetablesScreen extends StatefulWidget {
  static const route = "/all-timetables";
  const AllTimetablesScreen({super.key});

  @override
  State<AllTimetablesScreen> createState() => _AllTimetablesScreenState();
}

class _AllTimetablesScreenState extends State<AllTimetablesScreen> {
  @override
  Widget build(BuildContext context) {
    MainApp.changeNavBarVisibilitySecure(context, value: true);
    return Scaffold(
      drawer: NavigationBarDrawer(selectedRoute: AllTimetablesScreen.route),
      appBar: AppBar(
        title: Text(
          AppLocalizationsManager.localizations.strTimetables,
        ),
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.more_horiz_outlined,
        activeIcon: Icons.close,
        spacing: 3,
        useRotationAnimation: true,
        tooltip: '',
        animationCurve: Curves.elasticInOut,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            label: AppLocalizationsManager.localizations.strCreateTimetable,
            onTap: () async {
              await createNewTimetable(context);

              if (!mounted) return;

              setState(() {});
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.import_export),
            backgroundColor: Colors.lightBlue,
            foregroundColor: Colors.white,
            label: AppLocalizationsManager.localizations.strImportExport,
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
    if (TimetableManager().timetables.isEmpty) {
      return Center(
        child: ElevatedButton(
          onPressed: () async {
            await createNewTimetable(context);
            setState(() {});
          },
          child: Text(
            AppLocalizationsManager.localizations.strCreateTimetable,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: TimetableManager().timetables.length,
      itemBuilder: _itemBuilder,
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    Timetable tt = TimetableManager().timetables[index];

    String mainTimetableName = TimetableManager().settings.getVar(
              Settings.mainTimetableNameKey,
            ) ??
        "";

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).cardColor,
      ),
      child: ListTile(
        onTap: () async {
          await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => TimetableScreen(
                timetable: tt,
                title:
                    AppLocalizationsManager.localizations.strTimetableWithName(
                  tt.name,
                ),
              ),
            ),
          );

          setState(() {});
        },
        title: Text(tt.name),
        // leading: Text(
        //   (index + 1).toString(),
        //   style: Theme.of(context).textTheme.bodyLarge,
        // ),
        trailing: Wrap(
          spacing: 12, // space between two icons
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Checkbox.adaptive(
              value: mainTimetableName == tt.name,
              onChanged: (bool? value) {
                assert(value != null);
                if (value == null) return;
                if (value) {
                  TimetableManager().settings.setVar(
                        Settings.mainTimetableNameKey,
                        tt.name,
                      );
                } else {
                  TimetableManager().settings.setVar(
                        Settings.mainTimetableNameKey,
                        null,
                      );
                }
                HomeWidgetManager.updateWithDefaultTimetable();
                setState(() {});
              },
            ),
            IconButton(
              onPressed: () async {
                await Navigator.of(context).push<bool>(
                  MaterialPageRoute(
                    builder: (context) => CreateTimeTableScreen(timetable: tt),
                  ),
                );

                setState(() {});
              },
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () async {
                bool delete = await Utils.showBoolInputDialog(
                  context,
                  question: AppLocalizationsManager.localizations
                      .strDoYouWantToDeleteX(
                    tt.name,
                  ),
                );

                if (!delete) return;

                bool removed = TimetableManager().removeTimetable(tt);

                setState(() {});

                if (!context.mounted) return;

                if (removed) {
                  Utils.showInfo(
                    context,
                    type: InfoType.success,
                    msg: AppLocalizationsManager.localizations
                        .strSuccessfullyRemoved(
                      tt.name,
                    ),
                  );
                } else {
                  Utils.showInfo(
                    context,
                    type: InfoType.error,
                    msg: AppLocalizationsManager.localizations
                        .strCouldNotBeRemoved(
                      tt.name,
                    ),
                  );
                }
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              ),
            )
          ],
        ),
      ),
    );
  }
}
