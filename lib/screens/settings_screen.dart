import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/notification_manager.dart';
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
        _currentVersion(),
        ElevatedButton(
          onPressed: () {
            NotificationManager().showNotifications(
              id: 0,
              title: "Test",
              body: "Notification",
            );
          },
          child: const Text("Send test Notification"),
        ),
      ],
    );
  }

  Widget _themeSelector() {
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
          Text(
            "Theme",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(
            height: 12,
          ),
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
      ),
    );
  }

  Widget _currentVersion() {
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
          Text(
            "Version",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(
            height: 12,
          ),
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
      ),
    );
  }
}
