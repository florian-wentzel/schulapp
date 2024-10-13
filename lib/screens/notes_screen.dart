import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_note.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/notes/edit_note_screen.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';

class NotesScreen extends StatefulWidget {
  static const String route = "/notes";

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
        title: Text(
          AppLocalizationsManager.localizations.strNotes,
        ),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    SchoolNote note = SchoolNote();
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => ListTile(
        title: Text("$index"),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EditNoteScreen(
              schoolNote: note,
            ),
          ));
        },
      ),
    );
  }
}
