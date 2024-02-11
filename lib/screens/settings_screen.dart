import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/theme/theme_manager.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';

class SettingsScreen extends StatefulWidget {
  static const String route = "/settings";

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Set<ThemeMode> selection = {};

  @override
  void initState() {
    selection = {
      ThemeManager().themeMode,
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationBarDrawer(selectedRoute: SettingsScreen.route),
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return ListView(
      children: [
        _themeSelector(),
        _openMainSemesterAutomatically(),
        _currentVersion(),
      ],
    );
  }

  Widget _themeSelector() {
    return listItem(
      title: "Theme",
      body: [
        SegmentedButton<ThemeMode>(
          segments: const <ButtonSegment<ThemeMode>>[
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              label: Text('dark'),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.system,
              label: Text('system'),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              label: Text('light'),
            ),
          ],
          selected: selection,
          onSelectionChanged: (Set<ThemeMode> newSelection) {
            selection = newSelection;
            ThemeManager().themeMode = selection.first;
            setState(() {});
          },
          showSelectedIcon: false,
          multiSelectionEnabled: false,
          emptySelectionAllowed: false,
        ),
      ],
    );
  }

  Widget _openMainSemesterAutomatically() {
    return listItem(
      title: "Open main semester automatically",
      afterTitle: [
        Switch.adaptive(
          value: TimetableManager().settings.openMainSemesterAutomatically,
          onChanged: (value) {
            TimetableManager().settings.openMainSemesterAutomatically = value;
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _currentVersion() {
    return listItem(
      title: "Version",
      body: [
        //später wenn wir richtige Versionen haben kann man:
        //"package_info_plus" benutzten
        Text(
          "beta",
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget listItem({
    required String title,
    List<Widget>? body,
    List<Widget>? afterTitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              ...afterTitle ?? [Container()],
            ],
          ),
          body != null
              ? const SizedBox(
                  height: 12,
                )
              : Container(),
          ...body ?? [Container()],
        ],
      ),
    );
  }
}
