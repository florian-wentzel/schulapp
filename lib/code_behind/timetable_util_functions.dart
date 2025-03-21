import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schulapp/code_behind/school_day.dart';
import 'package:schulapp/code_behind/school_lesson.dart';
import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/code_behind/school_semester.dart';
import 'package:schulapp/code_behind/school_time.dart';
import 'package:schulapp/code_behind/timetable.dart';
import 'package:schulapp/code_behind/timetable_manager.dart';
import 'package:schulapp/code_behind/todo_event.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/extensions.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/timetable/create_timetable_screen.dart';
import 'package:schulapp/screens/home_screen.dart';
import 'package:schulapp/widgets/date_selection_button.dart';
import 'package:schulapp/widgets/time_selection_button.dart';
import 'package:schulapp/widgets/timetable/timetable_widget.dart';

Future<SchoolSemester?> createNewSemester(BuildContext context) async {
  SchoolSemester? schoolSemester = await showCreateSemesterSheet(context);

  return schoolSemester;
}

Future<SchoolSemester?> showCreateSemesterSheet(
  BuildContext context, {
  String? headingText,
  String? initalNameValue,
}) async {
  const maxNameLength = SchoolSemester.maxNameLength;

  headingText ??= AppLocalizationsManager.localizations.strCreateSemester;

  final textColor =
      Theme.of(context).textTheme.bodyMedium?.color ?? Colors.white;

  TextEditingController nameController = TextEditingController();
  if (initalNameValue != null) {
    nameController.text = initalNameValue;
  }

  bool createPressed = false;

  await showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              headingText!,
              style: TextStyle(
                color: textColor,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: AppLocalizationsManager.localizations.strName,
              ),
              autofocus: true,
              maxLines: 1,
              maxLength: maxNameLength,
              textAlign: TextAlign.center,
              controller: nameController,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                createPressed = true;
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizationsManager.localizations.strCreate),
            ),
          ],
        ),
      );
    },
  );

  if (!createPressed) return null;

  if (nameController.text.trim().isEmpty) {
    //show error
    if (context.mounted) {
      Utils.showInfo(
        context,
        msg: AppLocalizationsManager.localizations.strSemesterNameCanNotBeEmpty,
        type: InfoType.error,
      );
    }
    return null;
  }

  return SchoolSemester(
    name: nameController.text.trim(),
    subjects: [],
  );
}

///set State after calling
Future<bool?> createNewTimetable(BuildContext context) async {
  Timetable? tt = await showCreateTimetableSheet(context);
  if (tt == null) return null;

  // bool? createdNewTimetable =
  if (!context.mounted) return null;

  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (context) => CreateTimetableScreen(timetable: tt),
    ),
  );
}

Future<Timetable?> showCreateTimetableSheet(
  BuildContext context, {
  bool onlySchoolTimes = false,
}) async {
  Timetable? timetable = await showModalBottomSheet<Timetable>(
    context: context,
    scrollControlDisabledMaxHeightRatio: 11.0 / 16.0,
    builder: (context) => CreateTimetableBottomSheet(
      onlySchoolTimes: onlySchoolTimes,
    ),
  );

  return timetable;
}

///setState after calling this method
Future<bool?> showSchoolLessonHomePopUp(
  BuildContext context,
  SchoolLessonPrefab lesson,
  SchoolDay day,
  SchoolTime schoolTime,
  TodoEvent? event,
  String heroString,
) async {
  return Navigator.push<bool>(
    context,
    PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext context, _, __) => CustomPopUpShowLesson(
        heroString: heroString,
        lesson: lesson,
        day: day,
        schoolTime: schoolTime,
        event: event,
      ),
      barrierDismissible: true,
      fullscreenDialog: true,
    ),
  );
}

Future<(String, bool)?> showSelectSubjectNameSheet(
  BuildContext context, {
  required String title,
  bool allowCustomNames = false,
}) async {
  Timetable? selectedTimetable = Utils.getHomescreenTimetable();
  if (selectedTimetable == null) return null;

  Map<String, SchoolLessonPrefab> prefabs = {};

  for (var p in selectedTimetable.lessonPrefabs) {
    prefabs[p.name] = p;
  }

  for (var tt in selectedTimetable.weekTimetables) {
    for (var p in tt.lessonPrefabs) {
      prefabs[p.name] = p;
    }
  }

  List<SchoolLessonPrefab> selectedTimetablePrefabs = prefabs.values.toList();

  selectedTimetablePrefabs.sort(
    (a, b) => a.name.compareTo(b.name),
  );

  if (allowCustomNames) {
    selectedTimetablePrefabs.add(
      SchoolLessonPrefab(
        name: AppLocalizationsManager.localizations.strCustomSubject,
        room: "",
        teacher: "",
        color: Colors.transparent,
      ),
    );
  }

  String? selectdSubjectName;

  await Utils.showListSelectionBottomSheet(
    context,
    title: title,
    items: selectedTimetablePrefabs,
    itemBuilder: (context, index) => ListTile(
      title: Text(selectedTimetablePrefabs[index].name),
      onTap: () {
        selectdSubjectName = selectedTimetablePrefabs[index].name;
        Navigator.of(context).pop();
      },
    ),
  );

  if (selectdSubjectName == null) return null;

  if (selectdSubjectName !=
      AppLocalizationsManager.localizations.strCustomSubject) {
    return (selectdSubjectName!, false);
  }

  if (!context.mounted) return null;

  String? customName = await Utils.showStringInputDialog(
    context,
    hintText: AppLocalizationsManager.localizations.strCustomSubject,
    autofocus: true,
    maxInputLength: 30,
  );

  if (customName == null) return null;

  customName = customName.trim();

  if (customName.isEmpty) {
    if (context.mounted) {
      Utils.showInfo(
        context,
        msg: AppLocalizationsManager.localizations.strNameCanNotBeEmpty,
        type: InfoType.error,
      );
    }
    return null;
  }

  bool isCustomTask = Utils.isCustomTask(
    linkedSubjectName: customName,
  );

  return (customName, isCustomTask);
}

Future<Timetable?> showSelectTimetableSheet(
  BuildContext context, {
  required String title,
  VoidCallback? onRemove,
}) async {
  List<Timetable> timetables = TimetableManager().timetables;

  Timetable? selectedTimetable;

  await showModalBottomSheet(
    context: context,
    scrollControlDisabledMaxHeightRatio: 0.7,
    builder: (context) {
      return Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.builder(
                  itemCount: timetables.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(timetables[index].name),
                    trailing: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => HomeScreen(
                            title: AppLocalizationsManager.localizations
                                .strTimetableWithName(
                              timetables[index].name,
                            ),
                            timetable: timetables[index],
                          ),
                        ));
                      },
                      icon: const Icon(Icons.info),
                    ),
                    onTap: () {
                      selectedTimetable = timetables[index];
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ),
            if (onRemove != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                    onRemove.call();
                  },
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
              ),
          ],
        ),
      );
    },
  );
  return selectedTimetable;
}

// ignore: must_be_immutable
class CreateTimetableBottomSheet extends StatefulWidget {
  bool onlySchoolTimes;

  CreateTimetableBottomSheet({
    super.key,
    this.onlySchoolTimes = false,
  });

  @override
  State<CreateTimetableBottomSheet> createState() =>
      _CreateTimetableBottomSheetState();
}

class _CreateTimetableBottomSheetPage {
  final _formKey = GlobalKey<FormState>();

  Widget Function() builder;

  _CreateTimetableBottomSheetPage({
    required this.builder,
  });

  Widget build() {
    return Form(
      key: _formKey,
      child: builder(),
    );
  }

  bool validate() {
    return _formKey.currentState?.validate() ?? false;
  }
}

class _CreateTimetableBottomSheetState
    extends State<CreateTimetableBottomSheet> {
  final _maxNameLength = Timetable.maxNameLength;
  final _minLessonCount = Timetable.minMaxLessonCount;
  final _maxLessonCount = Timetable.maxMaxLessonCount;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lessonCountController = TextEditingController();
  final PageController _pageController = PageController();
  final _dateSelectionButtonController = DateSelectionButtonController(
    date: DateTime.now().copyWith(
      hour: 7,
      minute: 45,
    ),
  );

  late final List<_CreateTimetableBottomSheetPage> _pages;

  //stunden wenn Wert = -1
  //pause = länge der Pause
  final List<int> _lessons = [];

  bool _addSaturday = false;
  //nochmal schauen ob man es in dem screen einstellen möchte
  // final bool _bWeeksEnabled = false;

  int _currPageIndex = 0;
  int _lessonLength = 45;
  int _timeBetweenLessons = 10;

  @override
  void initState() {
    _pages = [
      if (!widget.onlySchoolTimes)
        _CreateTimetableBottomSheetPage(
          builder: _page1,
        ),
      _CreateTimetableBottomSheetPage(
        builder: _page2,
      ),
      _CreateTimetableBottomSheetPage(
        builder: _page3,
      ),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: PageView.builder(
                physics: const NeverScrollableScrollPhysics(),
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (value) {
                  _currPageIndex = value;
                  setState(() {});
                },
                itemBuilder: (context, index) {
                  return _pages[index].build();
                },
              ),
            ),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

  Widget _bottomBar() {
    List<Widget> actions = [];

    if (_currPageIndex > 0) {
      actions.add(
        ElevatedButton(
          onPressed: _prevPage,
          child: Text(
            AppLocalizationsManager.localizations.strBack,
          ),
        ),
      );
    }
    if (_currPageIndex == _pages.length - 1) {
      actions.add(
        ElevatedButton(
          onPressed: _createTimetable,
          child: Text(AppLocalizationsManager.localizations.strCreate),
        ),
      );
    } else {
      actions.add(
        ElevatedButton(
          onPressed: _nextPage,
          child: Text(AppLocalizationsManager.localizations.strNext),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions,
      ),
    );
  }

  void _nextPage() {
    final currPage = _pages[_currPageIndex];

    bool nextPage = currPage.validate();

    if (!nextPage) {
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCirc,
    );
    _generateTimetableLessons();
  }

  void _generateTimetableLessons() {
    int lessonCount = -1;
    try {
      lessonCount = int.parse(
        _lessonCountController.text.trim(),
      );
      if (lessonCount < _minLessonCount || lessonCount > _maxLessonCount) {
        return;
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    if (lessonCount == -1) return;

    if (_lessons.where((element) => element == -1).length == lessonCount) {
      return;
    }

    _lessons.clear();
    _lessons.addAll(
      List.generate(lessonCount, (index) => -1),
    );
  }

  void _prevPage() {
    if (_currPageIndex <= 0) return;

    _pageController.previousPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCirc,
    );
  }

  void _createTimetable() {
    final currPage = _pages[_currPageIndex];

    bool nextPage = currPage.validate();

    if (!nextPage) {
      return;
    }
    int? lessonCount;
    try {
      lessonCount = int.parse(
        _lessonCountController.text.trim(),
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    if (lessonCount == null) return;

    final dayCount = 5 + (_addSaturday ? 1 : 0);

    List<SchoolDay> schoolDays = List.generate(
      dayCount,
      (index) => SchoolDay(
        name: Timetable.weekDayNames[index],
        lessons: List.generate(
          lessonCount!,
          (index) => EmptySchoolLesson(
            lessonIndex: index,
          ),
        ),
      ),
    );

    TimeOfDay currTime =
        TimeOfDay.fromDateTime(_dateSelectionButtonController.date);

    List<SchoolTime> schoolTimes = [];

    for (int i = 0; i < _lessons.length; i++) {
      int currValue = _lessons[i];

      TimeOfDay start = currTime.add();
      TimeOfDay end = currTime.add(minutes: _lessonLength);

      if (currValue == -1) {
        schoolTimes.add(
          SchoolTime(
            start: start,
            end: end,
          ),
        );
        currTime = end.add(
          minutes: _timeBetweenLessons,
        );
      } else {
        //"currValue - _timeBetweenLessons" because we add after every
        //schoolTime _timeBetweenLessons minutes as break
        currTime = currTime.add(minutes: currValue - _timeBetweenLessons);
      }
    }

    final Timetable timetable = Timetable(
      name: _nameController.text.trim(),
      maxLessonCount: lessonCount,
      schoolDays: schoolDays,
      schoolTimes: schoolTimes,
      weekTimetables: null,
      lessonPrefabs: null,
    );

    Navigator.of(context).pop(timetable);
  }

  Widget _page1() {
    return Column(
      children: [
        Text(
          AppLocalizationsManager.localizations.strCreateTimetable,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(
          height: 12,
        ),
        TextFormField(
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppLocalizationsManager.localizations.strNameCanNotBeEmpty;
            }

            return null;
          },
          decoration: InputDecoration(
            hintText: AppLocalizationsManager.localizations.strName,
          ),
          autofocus: true,
          maxLines: 1,
          maxLength: _maxNameLength,
          textAlign: TextAlign.center,
          controller: _nameController,
        ),
        const Spacer(),
      ],
    );
  }

  Widget _page2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          AppLocalizationsManager.localizations.strSetTimes,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(AppLocalizationsManager.localizations.strStartOfSchool),
                  const SizedBox(
                    height: 8,
                  ),
                  TimeSelectionButton(
                    controller: _dateSelectionButtonController,
                  ),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  Text(
                    AppLocalizationsManager
                        .localizations.strLengthOfSchoolHours,
                  ),
                  Slider.adaptive(
                    value: _lessonLength.toDouble(),
                    min: 30,
                    max: 90,
                    onChanged: (value) {
                      _lessonLength = value.toInt();
                      const snapPoint = 45;

                      double distToSnapPoint = (value - snapPoint).abs();
                      if (distToSnapPoint < 2) {
                        _lessonLength = snapPoint;
                      }
                      setState(() {});
                    },
                  ),
                  Text(
                    AppLocalizationsManager.localizations
                        .strXMinutes(_lessonLength),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              child: TextFormField(
                validator: (value) {
                  final errorMsg = AppLocalizationsManager.localizations
                      .strLessonCountMustBeInRange(
                    _minLessonCount,
                    _maxLessonCount,
                  );
                  if (_lessonCountController.text.trim().isEmpty) {
                    return errorMsg;
                  }

                  try {
                    final lessonCount = int.parse(
                      _lessonCountController.text.trim(),
                    );
                    if (lessonCount < _minLessonCount ||
                        lessonCount > _maxLessonCount) {
                      return errorMsg;
                    }
                  } catch (e) {
                    //
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText:
                      AppLocalizationsManager.localizations.strLessonCount,
                ),
                autofocus: false,
                maxLines: 1,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                controller: _lessonCountController,
              ),
            ),
            Column(
              children: [
                Text(
                  AppLocalizationsManager.localizations.strBreaksBetweenLessons,
                ),
                Slider.adaptive(
                  value: _timeBetweenLessons.toDouble(),
                  min: 0,
                  max: 45,
                  onChanged: (value) {
                    _timeBetweenLessons = value.toInt();
                    const snapPoint = 10;

                    double distToSnapPoint = (value - snapPoint).abs();
                    if (distToSnapPoint < 2) {
                      _timeBetweenLessons = snapPoint;
                    }
                    setState(() {});
                  },
                ),
                Text(
                  AppLocalizationsManager.localizations
                      .strXMinutes(_timeBetweenLessons),
                ),
              ],
            ),
          ],
        ),
        if (!widget.onlySchoolTimes)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizationsManager.localizations.strSaturdayLessons),
              const SizedBox(
                width: 4,
              ),
              Switch.adaptive(
                value: _addSaturday,
                onChanged: (value) {
                  _addSaturday = value;
                  setState(() {});
                },
              ),
            ],
          ),
      ],
    );
  }

  Widget _page3() {
    TimeOfDay currTime =
        TimeOfDay.fromDateTime(_dateSelectionButtonController.date);

    return SetTimetableBreaksWidget(
      lessons: _lessons,
      lessonLength: _lessonLength,
      timeBetweenLessons: _timeBetweenLessons,
      startTime: currTime,
    );
  }
}

class SetTimetableBreaksWidget extends StatefulWidget {
  final List<int> lessons;
  final TimeOfDay startTime;
  final int timeBetweenLessons;
  final int lessonLength;

  const SetTimetableBreaksWidget({
    super.key,
    required this.lessons,
    required this.startTime,
    required this.timeBetweenLessons,
    required this.lessonLength,
  });

  @override
  State<SetTimetableBreaksWidget> createState() =>
      _SetTimetableBreaksWidgetState();
}

class _SetTimetableBreaksWidgetState extends State<SetTimetableBreaksWidget> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int correctedIndex = 0;

    TimeOfDay currTime = widget.startTime.add();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          AppLocalizationsManager.localizations.strSetBreaks,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(
          height: 8,
        ),
        Expanded(
          child: ReorderableListView(
            scrollController: _scrollController,
            children: List.generate(
              widget.lessons.length,
              (index) {
                //-1 == Stunde
                if (widget.lessons[index] == -1) {
                  TimeOfDay endTime =
                      currTime.add(minutes: widget.lessonLength);

                  final str =
                      "${AppLocalizationsManager.localizations.strXLesson(index + 1 - correctedIndex)}   (${currTime.format(context)} - ${endTime.format(context)})";

                  currTime = endTime.add(minutes: widget.timeBetweenLessons);

                  return ListTile(
                    key: ValueKey(index),
                    title: Text(
                      str,
                    ),
                  );
                }
                correctedIndex++;

                currTime = currTime.add(
                  //weli wir nach einer stunde immer widget.timeBetweenLessons addieren
                  minutes: widget.lessons[index] - widget.timeBetweenLessons,
                );

                //everything else is a break with value = minutes
                return ListTile(
                  key: ValueKey(index),
                  onTap: () async {
                    double? value = await Utils.showRangeInputDialog(
                      context,
                      title: AppLocalizationsManager
                          .localizations.strSelectBreakLength,
                      textAfterValue:
                          AppLocalizationsManager.localizations.strMinutes,
                      minValue: 1,
                      maxValue: 90,
                      startValue: 20,
                      onlyIntegers: true,
                      snapPoints: [5, 10, 15, 20, 30, 45, 90],
                    );

                    if (value == null) return;
                    int intValue = value.toInt();
                    widget.lessons[index] = intValue;
                    setState(() {});
                  },
                  title: Text(
                    AppLocalizationsManager.localizations
                        .strBreakXMin(widget.lessons[index]),
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      widget.lessons.removeAt(index);
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                );
              },
            ),
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final int item = widget.lessons.removeAt(oldIndex);
              widget.lessons.insert(newIndex, item);
              setState(() {});
            },
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        ElevatedButton(
          onPressed: () async {
            double? value = await Utils.showRangeInputDialog(
              context,
              title: AppLocalizationsManager.localizations.strSelectBreakLength,
              textAfterValue: AppLocalizationsManager.localizations.strMinutes,
              minValue: 1,
              maxValue: 90,
              startValue: 20,
              onlyIntegers: true,
              snapPoints: [5, 10, 15, 20, 30, 45, 90],
            );

            if (value == null) return;
            int intValue = value.toInt();
            widget.lessons.add(intValue);
            setState(() {});
            if (context.mounted) {
              //scroll to end
              WidgetsBinding.instance.addPostFrameCallback(
                (timeStamp) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                  );
                },
              );
            }
          },
          child: Text(AppLocalizationsManager.localizations.strAddBreak),
        ),
      ],
    );
  }
}
