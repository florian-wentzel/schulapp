import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/time_table.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/screens/time_table/create_timetable_screen.dart';
import 'package:schulapp/screens/timetable_screen.dart';
import 'package:schulapp/widgets/timetable_util_functions.dart';
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
    return Scaffold(
      drawer: NavigationBarDrawer(selectedRoute: AllTimetablesScreen.route),
      appBar: AppBar(
        title: const Text("Timetables"),
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
          child: const Text("Create a Timetable"),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ListView.builder(
        itemCount: TimetableManager().timetables.length,
        itemBuilder: _itemBuilder,
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    Timetable tt = TimetableManager().timetables[index];

    String mainTimetableName =
        TimetableManager().settings.mainTimetableName ?? "";

    return ListTile(
      onTap: () async {
        await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (context) => TimetableScreen(
              timetable: tt,
              title: "Timetable: ${tt.name}",
            ),
          ),
        );

        setState(() {});
      },
      title: Text(tt.name),
      leading: Text(
        (index + 1).toString(),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      trailing: Wrap(
        spacing: 12, // space between two icons
        children: <Widget>[
          Switch.adaptive(
            value: mainTimetableName == tt.name,
            onChanged: (bool value) {
              if (value) {
                TimetableManager().settings.mainTimetableName = tt.name;
              } else {
                TimetableManager().settings.mainTimetableName = null;
              }
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
                question: "Do you want to delete ${tt.name}?",
              );

              if (!delete) return;

              bool removed = TimetableManager().removeTimetable(tt);

              setState(() {});

              if (!mounted) return;

              if (removed) {
                Utils.showInfo(
                  context,
                  type: InfoType.success,
                  msg: "${tt.name} successfully removed!",
                );
              } else {
                Utils.showInfo(
                  context,
                  type: InfoType.error,
                  msg: "${tt.name} could not be removed!",
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
    );
  }
}
