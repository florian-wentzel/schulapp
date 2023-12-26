import 'package:flutter/material.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';

class SettingsScreen extends StatefulWidget {
  static const String route = "/settings";

  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
    return const Placeholder();
  }
}
