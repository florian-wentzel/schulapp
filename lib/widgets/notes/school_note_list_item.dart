import 'package:flutter/material.dart';
import 'package:schulapp/app.dart';
import 'package:schulapp/code_behind/school_note.dart';
import 'package:schulapp/code_behind/school_notes_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/notes/edit_note_screen.dart';

class SchoolNoteListItem extends StatefulWidget {
  final SchoolNote schoolNote;
  //gets called if the delete iconbutten gets pressed
  final Future<void> Function()? onDelete;
  final Future<void> Function()? onDeletePressed;
  final bool showDeleteBtn;

  const SchoolNoteListItem({
    super.key,
    required this.schoolNote,
    this.onDelete,
    this.onDeletePressed,
    this.showDeleteBtn = true,
  });

  @override
  State<SchoolNoteListItem> createState() => _SchoolNoteListItemState();

  static Future<T?> openNote<T>(
    BuildContext context,
    SchoolNote note, {
    bool isCustomSchoolNote = false,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(
          schoolNote: note,
          isImportSchoolNote: isCustomSchoolNote,
        ),
      ),
    );
  }
}

class _SchoolNoteListItemState extends State<SchoolNoteListItem> {
  @override
  Widget build(BuildContext context) {
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
          await SchoolNoteListItem.openNote(
            context,
            widget.schoolNote,
          );
          MainApp.changeNavBarVisibility(true);

          setState(() {});
        },
        title: Text(widget.schoolNote.getTitle(context)),
        trailing: !widget.showDeleteBtn
            ? const Icon(
                Icons.description,
              )
            : Wrap(
                spacing: 12, // space between two icons
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  IconButton(
                    onPressed: () async {
                      await widget.onDeletePressed?.call();
                      if (!context.mounted) return;

                      bool delete = await Utils.showBoolInputDialog(
                        context,
                        question: AppLocalizationsManager.localizations
                            .strDoYouWantToDeleteX(
                          widget.schoolNote.getTitle(context),
                        ),
                        showYesAndNoInsteadOfOK: true,
                        markTrueAsRed: true,
                      );

                      if (!delete) return;

                      bool removed = SchoolNotesManager()
                          .removeSchoolNote(widget.schoolNote);

                      if (removed) {
                        await widget.onDelete?.call();
                      }

                      if (!context.mounted) return;

                      if (mounted) {
                        setState(() {});
                      }

                      if (removed) {
                        Utils.showInfo(
                          context,
                          type: InfoType.success,
                          msg: AppLocalizationsManager.localizations
                              .strSuccessfullyRemoved(
                            widget.schoolNote.getTitle(context),
                          ),
                        );
                      } else {
                        Utils.showInfo(
                          context,
                          type: InfoType.error,
                          msg: AppLocalizationsManager.localizations
                              .strCouldNotBeRemoved(
                            widget.schoolNote.getTitle(context),
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
