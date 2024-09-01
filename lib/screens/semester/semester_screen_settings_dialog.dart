import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/settings.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/settings_screen.dart';

// ignore: must_be_immutable
class SemesterScreenSettingsDialog extends StatefulWidget {
  SchoolSemester semester;

  SemesterScreenSettingsDialog({super.key, required this.semester});

  @override
  State<SemesterScreenSettingsDialog> createState() =>
      _SemesterScreenSettingsDialogState();
}

class _SemesterScreenSettingsDialogState
    extends State<SemesterScreenSettingsDialog> {
  Set<String> sortSubjectBySelection = {};

  @override
  void initState() {
    sortSubjectBySelection = {
      TimetableManager().settings.getVar(Settings.sortSubjectsByKey),
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizationsManager.localizations.strSettings,
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _sortSubjectsBy()),
                  SliverToBoxAdapter(child: _sortSubjectsManuallyInfo()),
                  SliverToBoxAdapter(child: _pinWeightedSubjectsAtTop()),
                  SliverReorderableList(
                    itemBuilder: _itemBuilder,
                    itemCount: widget.semester.subjects.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) {
                        newIndex -= 1;
                      }
                      final item = widget.semester.subjects.removeAt(oldIndex);
                      widget.semester.subjects.insert(newIndex, item);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizationsManager.localizations.strOK),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sortSubjectsBy() {
    return SettingsScreen.listItem(
      context,
      title: AppLocalizationsManager.localizations.strSortSubjects,
      body: [
        SegmentedButton<String>(
          segments: <ButtonSegment<String>>[
            ButtonSegment<String>(
              value: SchoolSemester.sortByNameValue,
              label: Text(
                AppLocalizationsManager.localizations.strByName,
              ),
            ),
            ButtonSegment<String>(
              value: SchoolSemester.sortByGradeValue,
              label: Text(
                AppLocalizationsManager.localizations.strByGrade,
              ),
            ),
            ButtonSegment<String>(
              value: SchoolSemester.sortByCustomValue,
              label: Text(
                AppLocalizationsManager.localizations.strManually,
              ),
            ),
          ],
          selected: sortSubjectBySelection,
          onSelectionChanged: (Set<String> newSelection) {
            sortSubjectBySelection = newSelection;
            TimetableManager().settings.setVar<String>(
                  Settings.sortSubjectsByKey,
                  sortSubjectBySelection.first,
                );
            setState(() {});
          },
          showSelectedIcon: false,
          multiSelectionEnabled: false,
          emptySelectionAllowed: false,
        ),
      ],
    );
  }

  Widget _sortSubjectsManuallyInfo() {
    if (sortSubjectBySelection.first != SchoolSemester.sortByCustomValue) {
      return const SizedBox.shrink();
    }
    return SettingsScreen.listItem(
      context,
      title: AppLocalizationsManager.localizations.strInformation,
      body: [
        Text("Bka bkab ka"),
      ],
    );
  }

  Widget _pinWeightedSubjectsAtTop() {
    if (sortSubjectBySelection.first == SchoolSemester.sortByCustomValue) {
      return const SizedBox.shrink();
    }
    return SettingsScreen.listItem(
      context,
      title: AppLocalizationsManager.localizations.strPinWeightedSubjectsAtTop,
      afterTitle: [
        Switch.adaptive(
          value: TimetableManager().settings.getVar(
                Settings.pinWeightedSubjectsAtTopKey,
              ),
          onChanged: (value) {
            TimetableManager().settings.setVar(
                  Settings.pinWeightedSubjectsAtTopKey,
                  value,
                );
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _reordableListView() {
    if (sortSubjectBySelection.first != SchoolSemester.sortByCustomValue) {
      return const SizedBox.shrink();
    }

    // return ConstrainedBox(
    //   constraints: BoxConstraints(
    //     maxHeight: 400,
    //   ),
    //   child: ReorderableListView.builder(
    //     itemBuilder: _itemBuilder,
    //     itemCount: widget.semester.subjects.length,
    //     onReorder: (oldIndex, newIndex) {},
    //   ),
    // );
    return SettingsScreen.listItem(
      context,
      title: "List",
      body: [],
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    // Container(
    //   padding: const EdgeInsets.all(12),
    //   margin: const EdgeInsets.symmetric(
    //     horizontal: 8,
    //     vertical: 4,
    //   ),
    //   decoration: BoxDecoration(
    //     borderRadius: BorderRadius.circular(16),
    //     color: Theme.of(context).cardColor,
    //   ),
    return ListTile(
      key: ValueKey(widget.semester.subjects[index]),
      title: Text(widget.semester.subjects[index].name),
      trailing: const Icon(Icons.drag_handle), // Handle for dragging
    );
  }
}
