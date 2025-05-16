import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_note.dart';
import 'package:schulapp/code_behind/school_notes_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';
import 'package:schulapp/widgets/notes/school_note_list_item.dart';

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
      drawer: const NavigationBarDrawer(selectedRoute: NotesScreen.route),
      appBar: AppBar(
        title: Text(
          AppLocalizationsManager.localizations.strNotes,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewNote,
        child: const Icon(Icons.add),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    if (SchoolNotesManager().schoolNotes.isEmpty) {
      return Center(
        child: ElevatedButton(
          onPressed: _addNewNote,
          child: Text(
            AppLocalizationsManager.localizations.strCreateANote,
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: SchoolNotesManager().schoolNotes.length,
      itemBuilder: (context, index) => _itemBuilder(index),
    );
  }

  Widget _itemBuilder(int index) {
    final schoolNote = SchoolNotesManager().schoolNotes[index];

    return SchoolNoteListItem(
      schoolNote: schoolNote,
      onDelete: () async {
        setState(() {});
      },
    );
  }

  Future<void> _addNewNote() async {
    SchoolNote note = SchoolNote();

    SchoolNotesManager().addSchoolNote(note);

    await SchoolNoteListItem.openNote(context, note);

    setState(() {});
  }
}
