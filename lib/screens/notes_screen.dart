import 'package:flutter/material.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';

class NotesScreen extends StatefulWidget {
  static const route = "/notes";

  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavigationBarDrawer(selectedRoute: NotesScreen.route),
      appBar: AppBar(
        title: const Text("Notes"),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return const Placeholder();
  }
}
