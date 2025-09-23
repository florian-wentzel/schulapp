import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// No description provided for @language_name.
  ///
  /// In en, this message translates to:
  /// **'Englisch'**
  String get language_name;

  /// No description provided for @version_0_10_2.
  ///
  /// In en, this message translates to:
  /// **'Small bug fixes: Edge-to-Edge (#4)'**
  String get version_0_10_2;

  /// No description provided for @version_0_10_1.
  ///
  /// In en, this message translates to:
  /// **'Bug fixes when sharing the timetable via online code'**
  String get version_0_10_1;

  /// No description provided for @version_0_10_0.
  ///
  /// In en, this message translates to:
  /// **'Added lesson notifications (configurable in settings)'**
  String get version_0_10_0;

  /// No description provided for @version_0_9_9.
  ///
  /// In en, this message translates to:
  /// **'Added QR code sharing'**
  String get version_0_9_9;

  /// No description provided for @version_0_9_8.
  ///
  /// In en, this message translates to:
  /// **'Tasks can now be easily shared'**
  String get version_0_9_8;

  /// No description provided for @version_0_9_7.
  ///
  /// In en, this message translates to:
  /// **'Added option to display the whole week on the home screen. Abbreviations are used when space is limited. (Customizable)'**
  String get version_0_9_7;

  /// No description provided for @version_0_9_6.
  ///
  /// In en, this message translates to:
  /// **'Lessons can now be marked as absent due to illness (long press on lesson)'**
  String get version_0_9_6;

  /// No description provided for @version_0_9_5.
  ///
  /// In en, this message translates to:
  /// **'Added setting to automatically display the next day'**
  String get version_0_9_5;

  /// No description provided for @version_0_9_4.
  ///
  /// In en, this message translates to:
  /// **'Added extended functionality by long-pressing the day name'**
  String get version_0_9_4;

  /// No description provided for @version_0_9_3.
  ///
  /// In en, this message translates to:
  /// **'Added calendar to the home screen'**
  String get version_0_9_3;

  /// No description provided for @version_0_9_2.
  ///
  /// In en, this message translates to:
  /// **'Further UI improvements and minor extensions, e.g., for substitute lessons or timetable creation'**
  String get version_0_9_2;

  /// No description provided for @version_0_9_1.
  ///
  /// In en, this message translates to:
  /// **'Improved grades and tasks UI, and enhanced timetable and semester creation'**
  String get version_0_9_1;

  /// No description provided for @version_0_9_0.
  ///
  /// In en, this message translates to:
  /// **'Added A-level calculator'**
  String get version_0_9_0;

  /// No description provided for @version_0_8_7.
  ///
  /// In en, this message translates to:
  /// **'Substitute lessons can now be marked'**
  String get version_0_8_7;

  /// No description provided for @version_0_8_6.
  ///
  /// In en, this message translates to:
  /// **'Added Feedback functionality in Settings'**
  String get version_0_8_6;

  /// No description provided for @version_0_8_5.
  ///
  /// In en, this message translates to:
  /// **'Added timetable sharing as Image'**
  String get version_0_8_5;

  /// No description provided for @version_0_8_4.
  ///
  /// In en, this message translates to:
  /// **'Added timetable sharing via online code'**
  String get version_0_8_4;

  /// No description provided for @version_0_8_3.
  ///
  /// In en, this message translates to:
  /// **'Added Tutorials'**
  String get version_0_8_3;

  /// No description provided for @version_0_8_2.
  ///
  /// In en, this message translates to:
  /// **'Improvements to the user interface and school lesson prefabs are now saved'**
  String get version_0_8_2;

  /// No description provided for @version_0_8_1.
  ///
  /// In en, this message translates to:
  /// **'Added extra timetable to home screen'**
  String get version_0_8_1;

  /// No description provided for @version_0_8_0.
  ///
  /// In en, this message translates to:
  /// **'A and B weeks added'**
  String get version_0_8_0;

  /// No description provided for @version_0_7_4.
  ///
  /// In en, this message translates to:
  /// **'Completed tasks are now marked with a checkmark on the home screen'**
  String get version_0_7_4;

  /// No description provided for @version_0_7_3.
  ///
  /// In en, this message translates to:
  /// **'Added Day Progress to Statistics'**
  String get version_0_7_3;

  /// No description provided for @version_0_7_2.
  ///
  /// In en, this message translates to:
  /// **'Added timetable sharing functionality in the export screen'**
  String get version_0_7_2;

  /// No description provided for @version_0_7_1.
  ///
  /// In en, this message translates to:
  /// **'Task notifications are now customizable'**
  String get version_0_7_1;

  /// No description provided for @version_0_7_0.
  ///
  /// In en, this message translates to:
  /// **'Added Notes which can be connected to Tasks\n(Long-press the bottom bar to access Notes)'**
  String get version_0_7_0;

  /// No description provided for @version_0_6_0.
  ///
  /// In en, this message translates to:
  /// **'Completed tasks are displayed separately'**
  String get version_0_6_0;

  /// No description provided for @version_0_5_2.
  ///
  /// In en, this message translates to:
  /// **'Tasks without End Date added'**
  String get version_0_5_2;

  /// No description provided for @version_0_5_1.
  ///
  /// In en, this message translates to:
  /// **'Added long press on the day name to mark all hours of the day as canceled.'**
  String get version_0_5_1;

  /// No description provided for @version_0_5_0.
  ///
  /// In en, this message translates to:
  /// **'Reduced times added'**
  String get version_0_5_0;

  /// No description provided for @version_0_4_9.
  ///
  /// In en, this message translates to:
  /// **'Text contrast on homescreen adjustable'**
  String get version_0_4_9;

  /// No description provided for @version_0_4_8.
  ///
  /// In en, this message translates to:
  /// **'Substitution plan of Paul Dessau Comprehensive School now available (beta)'**
  String get version_0_4_8;

  /// No description provided for @version_0_4_7.
  ///
  /// In en, this message translates to:
  /// **'Selectable grading systems added'**
  String get version_0_4_7;

  /// No description provided for @version_0_4_6.
  ///
  /// In en, this message translates to:
  /// **'User Interface improvements'**
  String get version_0_4_6;

  /// No description provided for @version_0_4_5.
  ///
  /// In en, this message translates to:
  /// **'Subjects can now be arranged differently within the semesters'**
  String get version_0_4_5;

  /// No description provided for @version_0_4_4.
  ///
  /// In en, this message translates to:
  /// **'Weights have been added to subjects in the semesters'**
  String get version_0_4_4;

  /// No description provided for @version_0_4_3.
  ///
  /// In en, this message translates to:
  /// **'Tasks can be shown or hidden on the homescreen'**
  String get version_0_4_3;

  /// No description provided for @version_0_4_2.
  ///
  /// In en, this message translates to:
  /// **'Tasks can be created on the homescreen'**
  String get version_0_4_2;

  /// No description provided for @version_0_4_1.
  ///
  /// In en, this message translates to:
  /// **'Bug fix when opening \".timetable\" files'**
  String get version_0_4_1;

  /// No description provided for @version_0_4_0.
  ///
  /// In en, this message translates to:
  /// **'The timetable can now be added to the home screen, and \".timetable\" files can now be opened directly.'**
  String get version_0_4_0;

  /// No description provided for @version_0_3_0.
  ///
  /// In en, this message translates to:
  /// **'Custom tasks are now displayed above the day name & many UI improvements'**
  String get version_0_3_0;

  /// No description provided for @version_0_2_8.
  ///
  /// In en, this message translates to:
  /// **'Holidays are displayed on the timetable'**
  String get version_0_2_8;

  /// No description provided for @version_0_2_7.
  ///
  /// In en, this message translates to:
  /// **'Added public holidays'**
  String get version_0_2_7;

  /// No description provided for @version_0_2_6.
  ///
  /// In en, this message translates to:
  /// **'New file-extensions (.timetable & .schulbackup)'**
  String get version_0_2_6;

  /// No description provided for @version_0_2_5.
  ///
  /// In en, this message translates to:
  /// **'Added backup and restore functionality'**
  String get version_0_2_5;

  /// No description provided for @version_0_2_4.
  ///
  /// In en, this message translates to:
  /// **'Added lesson cancellations and redesigned holiday UI'**
  String get version_0_2_4;

  /// No description provided for @version_0_2_3.
  ///
  /// In en, this message translates to:
  /// **'Holidays revised and other bug fixes'**
  String get version_0_2_3;

  /// No description provided for @version_0_2_2.
  ///
  /// In en, this message translates to:
  /// **'Updated grades average'**
  String get version_0_2_2;

  /// No description provided for @version_0_2_1.
  ///
  /// In en, this message translates to:
  /// **'Remade create new timetable functionality'**
  String get version_0_2_1;

  /// No description provided for @version_0_2_0.
  ///
  /// In en, this message translates to:
  /// **'Remade Edit-timetable-screen'**
  String get version_0_2_0;

  /// No description provided for @version_0_1_8.
  ///
  /// In en, this message translates to:
  /// **'Added custom subject task visuals'**
  String get version_0_1_8;

  /// No description provided for @version_0_1_7.
  ///
  /// In en, this message translates to:
  /// **'Translate semester grade groups and timetable names'**
  String get version_0_1_7;

  /// No description provided for @version_0_1_6.
  ///
  /// In en, this message translates to:
  /// **'Added custom holidays'**
  String get version_0_1_6;

  /// No description provided for @version_0_1_5.
  ///
  /// In en, this message translates to:
  /// **'Added custom subject names to Tasks-screen'**
  String get version_0_1_5;

  /// No description provided for @version_0_1_4.
  ///
  /// In en, this message translates to:
  /// **'Added statistics page to Home-screen'**
  String get version_0_1_4;

  /// No description provided for @version_0_1_3.
  ///
  /// In en, this message translates to:
  /// **'Remade Settings-Manager'**
  String get version_0_1_3;

  /// No description provided for @version_0_1_2.
  ///
  /// In en, this message translates to:
  /// **'Added intro slider'**
  String get version_0_1_2;

  /// No description provided for @version_0_1_1.
  ///
  /// In en, this message translates to:
  /// **'Added update informaion'**
  String get version_0_1_1;

  /// No description provided for @version_0_1_0.
  ///
  /// In en, this message translates to:
  /// **'Added multiple Languages'**
  String get version_0_1_0;

  /// No description provided for @strStartScreen.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get strStartScreen;

  /// No description provided for @strTimetableDirNotCreated.
  ///
  /// In en, this message translates to:
  /// **'timetable dir could not be created: {timetablePath}'**
  String strTimetableDirNotCreated(String timetablePath);

  /// No description provided for @strWrittenAndVerbalGrades.
  ///
  /// In en, this message translates to:
  /// **'Written & Oral grades'**
  String get strWrittenAndVerbalGrades;

  /// No description provided for @strExamGrades.
  ///
  /// In en, this message translates to:
  /// **'Exam grades'**
  String get strExamGrades;

  /// No description provided for @strMonday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get strMonday;

  /// No description provided for @strTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get strTuesday;

  /// No description provided for @strWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get strWednesday;

  /// No description provided for @strThursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get strThursday;

  /// No description provided for @strFriday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get strFriday;

  /// No description provided for @strSaturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get strSaturday;

  /// No description provided for @strSunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get strSunday;

  /// No description provided for @strCreateTimetable.
  ///
  /// In en, this message translates to:
  /// **'Create Timetable'**
  String get strCreateTimetable;

  /// No description provided for @strName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get strName;

  /// No description provided for @strLessonCount.
  ///
  /// In en, this message translates to:
  /// **'Lesson Count'**
  String get strLessonCount;

  /// No description provided for @strCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get strCreate;

  /// No description provided for @strFinished.
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get strFinished;

  /// No description provided for @strFinish.
  ///
  /// In en, this message translates to:
  /// **'finish'**
  String get strFinish;

  /// No description provided for @strUnfinish.
  ///
  /// In en, this message translates to:
  /// **'unfinish'**
  String get strUnfinish;

  /// No description provided for @strNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get strNow;

  /// No description provided for @strOK.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get strOK;

  /// No description provided for @strCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get strCancel;

  /// No description provided for @strCreateSemester.
  ///
  /// In en, this message translates to:
  /// **'Create Semester'**
  String get strCreateSemester;

  /// No description provided for @strSemesterX.
  ///
  /// In en, this message translates to:
  /// **'Semester: {name}'**
  String strSemesterX(String name);

  /// No description provided for @strSemesterNameCanNotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Semester name can not be empty!'**
  String get strSemesterNameCanNotBeEmpty;

  /// No description provided for @strTimetableNameCanNotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Timetable name can not be empty!'**
  String get strTimetableNameCanNotBeEmpty;

  /// No description provided for @strLessonCountMustBeInRange.
  ///
  /// In en, this message translates to:
  /// **'Lesson count must be greater than: {minLessonCount} and less than: {maxLessonCount}!'**
  String strLessonCountMustBeInRange(int minLessonCount, int maxLessonCount);

  /// No description provided for @strTimetableWithName.
  ///
  /// In en, this message translates to:
  /// **'Timetable Info: {timetableName}'**
  String strTimetableWithName(String timetableName);

  /// No description provided for @strInXDays.
  ///
  /// In en, this message translates to:
  /// **'In {daysLeft, plural, =0 {zero days} =1 {one day} other {{daysLeft} days}}'**
  String strInXDays(int daysLeft);

  /// No description provided for @strStartsTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Starts Tomorrow :)'**
  String get strStartsTomorrow;

  /// No description provided for @strAlreadyOver.
  ///
  /// In en, this message translates to:
  /// **'Already Over :('**
  String get strAlreadyOver;

  /// No description provided for @strToday.
  ///
  /// In en, this message translates to:
  /// **'Today :)'**
  String get strToday;

  /// No description provided for @strStartsToday.
  ///
  /// In en, this message translates to:
  /// **'Starts Today :)'**
  String get strStartsToday;

  /// No description provided for @strEndsTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Ends Tomorrow :('**
  String get strEndsTomorrow;

  /// No description provided for @strExpiredXDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Expired {daysLeft, plural, =0 {zero days} =1 {one day} other {{daysLeft} days}} ago'**
  String strExpiredXDaysAgo(int daysLeft);

  /// No description provided for @strInXHours.
  ///
  /// In en, this message translates to:
  /// **'In {hoursLeft, plural, =0 {zero hours} =1 {one hour} other {{hoursLeft} hours}}'**
  String strInXHours(int hoursLeft);

  /// No description provided for @strExpiredXHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'Expired {hoursLeft, plural, =0 {zero hours} =1 {one hour} other {{hoursLeft} hours}} ago'**
  String strExpiredXHoursAgo(int hoursLeft);

  /// No description provided for @strInXMinutes.
  ///
  /// In en, this message translates to:
  /// **'In {minutesLeft, plural, =0 {zero minutes} =1 {one minute} other {{minutesLeft} minutes}}'**
  String strInXMinutes(int minutesLeft);

  /// No description provided for @strXMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutesLeft, plural, =0 {Zero minutes} =1 {One minute} other {{minutesLeft} minutes}}'**
  String strXMinutes(int minutesLeft);

  /// No description provided for @strExpiredXMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'Expired {minutesLeft, plural, =0 {zero minutes} =1 {one minute} other {{minutesLeft} minutes}} ago'**
  String strExpiredXMinutesAgo(int minutesLeft);

  /// No description provided for @strInXSeconds.
  ///
  /// In en, this message translates to:
  /// **'In {secondsLeft, plural, =0 {zero seconds} =1 {one second} other {{secondsLeft} seconds}}'**
  String strInXSeconds(int secondsLeft);

  /// No description provided for @strExpiredXSecondsAgo.
  ///
  /// In en, this message translates to:
  /// **'Expired {secondsLeft, plural, =0 {zero seconds} =1 {one second} other {{secondsLeft} seconds}} ago'**
  String strExpiredXSecondsAgo(int secondsLeft);

  /// No description provided for @strExam.
  ///
  /// In en, this message translates to:
  /// **'Exam'**
  String get strExam;

  /// No description provided for @strTest.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get strTest;

  /// No description provided for @strPresentation.
  ///
  /// In en, this message translates to:
  /// **'Presentation'**
  String get strPresentation;

  /// No description provided for @strHomework.
  ///
  /// In en, this message translates to:
  /// **'Homework'**
  String get strHomework;

  /// No description provided for @strTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get strTomorrow;

  /// No description provided for @strColorPicker.
  ///
  /// In en, this message translates to:
  /// **'Color Picker'**
  String get strColorPicker;

  /// No description provided for @strTimetables.
  ///
  /// In en, this message translates to:
  /// **'Timetables'**
  String get strTimetables;

  /// No description provided for @strImportExport.
  ///
  /// In en, this message translates to:
  /// **'Import / Export'**
  String get strImportExport;

  /// No description provided for @strDoYouWantToDeleteX.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete {name}?'**
  String strDoYouWantToDeleteX(String name);

  /// No description provided for @strDoYouWantToDeleteTaskX.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the Task: {x}?'**
  String strDoYouWantToDeleteTaskX(String x);

  /// No description provided for @strSuccessfullyRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} successfully removed!'**
  String strSuccessfullyRemoved(String name);

  /// No description provided for @strCouldNotBeRemoved.
  ///
  /// In en, this message translates to:
  /// **'{name} could not be removed!'**
  String strCouldNotBeRemoved(String name);

  /// No description provided for @strGrades.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get strGrades;

  /// No description provided for @strEditSemester.
  ///
  /// In en, this message translates to:
  /// **'Edit Semester:\n{semesterName}'**
  String strEditSemester(String semesterName);

  /// No description provided for @strHolidaysInfoText.
  ///
  /// In en, this message translates to:
  /// **'All date information is provided without guarantee. I assume no responsibility for the accuracy of the data, nor do I accept liability for any economic damages that may arise from the use of this data.'**
  String get strHolidaysInfoText;

  /// No description provided for @strHolidaysThanksText.
  ///
  /// In en, this message translates to:
  /// **'Thank you to https://ferien-api.de/ for providing the holiday API free of charge.\nThank you to https://www.api-feiertage.de/ for providing the holiday API free of charge.'**
  String get strHolidaysThanksText;

  /// No description provided for @strHolidaysWithStateName.
  ///
  /// In en, this message translates to:
  /// **'Holidays {federalStateName}'**
  String strHolidaysWithStateName(String federalStateName);

  /// No description provided for @strHolidays.
  ///
  /// In en, this message translates to:
  /// **'Holidays'**
  String get strHolidays;

  /// No description provided for @strSelectFederalState.
  ///
  /// In en, this message translates to:
  /// **'Select Federal State'**
  String get strSelectFederalState;

  /// No description provided for @strTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get strTryAgain;

  /// No description provided for @strInformation.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get strInformation;

  /// No description provided for @strRemoveHolidays.
  ///
  /// In en, this message translates to:
  /// **'Remove Holidays'**
  String get strRemoveHolidays;

  /// No description provided for @strHolidaysLengthXDays.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1 {One day} other {{days} days}}'**
  String strHolidaysLengthXDays(int days);

  /// No description provided for @strEndsInXDays.
  ///
  /// In en, this message translates to:
  /// **'Ends in {days, plural, =0 {Zero days} =1{One day} other {{days} days}}'**
  String strEndsInXDays(int days);

  /// No description provided for @strEndsToday.
  ///
  /// In en, this message translates to:
  /// **'Ends today :('**
  String get strEndsToday;

  /// No description provided for @strSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get strSettings;

  /// No description provided for @strTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get strTheme;

  /// No description provided for @strDark.
  ///
  /// In en, this message translates to:
  /// **'dark'**
  String get strDark;

  /// No description provided for @strLight.
  ///
  /// In en, this message translates to:
  /// **'light'**
  String get strLight;

  /// No description provided for @strSystem.
  ///
  /// In en, this message translates to:
  /// **'system'**
  String get strSystem;

  /// No description provided for @strOpenMainSemesterAutomatically.
  ///
  /// In en, this message translates to:
  /// **'Open main semester automatically'**
  String get strOpenMainSemesterAutomatically;

  /// No description provided for @strLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get strLanguage;

  /// No description provided for @strSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get strSelectLanguage;

  /// No description provided for @strChangeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get strChangeLanguage;

  /// No description provided for @strVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get strVersion;

  /// No description provided for @strNameCanNotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name can not be empty!'**
  String get strNameCanNotBeEmpty;

  /// No description provided for @strPasswordCanNotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Password can not be empty!'**
  String get strPasswordCanNotBeEmpty;

  /// No description provided for @strNameIsToLong.
  ///
  /// In en, this message translates to:
  /// **'Name is to long!'**
  String get strNameIsToLong;

  /// No description provided for @strSelectedDirDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'Selected dir does not Exist!'**
  String get strSelectedDirDoesNotExist;

  /// No description provided for @strTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get strTasks;

  /// No description provided for @strMarkAsUNfinished.
  ///
  /// In en, this message translates to:
  /// **'mark as (un)finished'**
  String get strMarkAsUNfinished;

  /// No description provided for @strDeleteSelectedItems.
  ///
  /// In en, this message translates to:
  /// **'delete selected items'**
  String get strDeleteSelectedItems;

  /// No description provided for @strSelectSubjectToAddTaskTo.
  ///
  /// In en, this message translates to:
  /// **'Select Subject to add to Task:'**
  String get strSelectSubjectToAddTaskTo;

  /// No description provided for @strCreateATask.
  ///
  /// In en, this message translates to:
  /// **'Create a Task'**
  String get strCreateATask;

  /// No description provided for @strSelectAllFinishedTasks.
  ///
  /// In en, this message translates to:
  /// **'Select all finished Tasks'**
  String get strSelectAllFinishedTasks;

  /// No description provided for @strSelectAllExpiredTasks.
  ///
  /// In en, this message translates to:
  /// **'Select all expired Tasks'**
  String get strSelectAllExpiredTasks;

  /// No description provided for @strSelectAllTasks.
  ///
  /// In en, this message translates to:
  /// **'Select all Tasks'**
  String get strSelectAllTasks;

  /// No description provided for @strDoYouWantToFinishXTasks.
  ///
  /// In en, this message translates to:
  /// **'Do you want to {finishString} {count, plural, =1 {one Task} other {{count} Tasks}}?'**
  String strDoYouWantToFinishXTasks(String finishString, int count);

  /// No description provided for @strDoYouWantToDeleteXTasks.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete {count} tasks?'**
  String strDoYouWantToDeleteXTasks(int count);

  /// No description provided for @strEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get strEdit;

  /// No description provided for @strEditSchoolGradeSubject.
  ///
  /// In en, this message translates to:
  /// **'Edit Grading'**
  String get strEditSchoolGradeSubject;

  /// No description provided for @strSchoolGradeSubjectX.
  ///
  /// In en, this message translates to:
  /// **'Subject: {subjectName}'**
  String strSchoolGradeSubjectX(String subjectName);

  /// No description provided for @strSubjectName.
  ///
  /// In en, this message translates to:
  /// **'Subject name'**
  String get strSubjectName;

  /// No description provided for @strAddGradegroup.
  ///
  /// In en, this message translates to:
  /// **'Add Gradegroup'**
  String get strAddGradegroup;

  /// No description provided for @strEditSubject.
  ///
  /// In en, this message translates to:
  /// **'Edit Subject'**
  String get strEditSubject;

  /// No description provided for @strDeleteSubject.
  ///
  /// In en, this message translates to:
  /// **'Delete Subject'**
  String get strDeleteSubject;

  /// No description provided for @strEditGrade.
  ///
  /// In en, this message translates to:
  /// **'Edit Grade'**
  String get strEditGrade;

  /// No description provided for @strAddGrade.
  ///
  /// In en, this message translates to:
  /// **'Add Grade'**
  String get strAddGrade;

  /// No description provided for @strExtraInfo.
  ///
  /// In en, this message translates to:
  /// **'Extra info'**
  String get strExtraInfo;

  /// No description provided for @strDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get strDate;

  /// No description provided for @strSetEndGrade.
  ///
  /// In en, this message translates to:
  /// **'Set end Grade'**
  String get strSetEndGrade;

  /// No description provided for @strShowGradesGraph.
  ///
  /// In en, this message translates to:
  /// **'Show Grades Graph'**
  String get strShowGradesGraph;

  /// No description provided for @strCreateNewSubject.
  ///
  /// In en, this message translates to:
  /// **'Create new Subject'**
  String get strCreateNewSubject;

  /// No description provided for @strImportSubjectsFromTimetable.
  ///
  /// In en, this message translates to:
  /// **'Import Subjects from other Timetable'**
  String get strImportSubjectsFromTimetable;

  /// No description provided for @strDoYouWantToExitWithoutSaving.
  ///
  /// In en, this message translates to:
  /// **'Do you want to exit without saving?'**
  String get strDoYouWantToExitWithoutSaving;

  /// No description provided for @strYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get strYes;

  /// No description provided for @strNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get strNo;

  /// No description provided for @strEnterTimetableName.
  ///
  /// In en, this message translates to:
  /// **'Enter Timetable name'**
  String get strEnterTimetableName;

  /// No description provided for @strSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get strSave;

  /// No description provided for @strSelectTimetableToImportSubjectsFrom.
  ///
  /// In en, this message translates to:
  /// **'Select Timetable to import Subjects from:'**
  String get strSelectTimetableToImportSubjectsFrom;

  /// No description provided for @strChangeSchoolLesson.
  ///
  /// In en, this message translates to:
  /// **'Change School lesson'**
  String get strChangeSchoolLesson;

  /// No description provided for @strDoYouWantToUpdateAllLessons.
  ///
  /// In en, this message translates to:
  /// **'Do you want to update all Lessons?'**
  String get strDoYouWantToUpdateAllLessons;

  /// No description provided for @strRoomsWontChange.
  ///
  /// In en, this message translates to:
  /// **'(rooms wont change)'**
  String get strRoomsWontChange;

  /// No description provided for @strTeacher.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get strTeacher;

  /// No description provided for @strRoom.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get strRoom;

  /// No description provided for @strSelectTimetableToExport.
  ///
  /// In en, this message translates to:
  /// **'Select timetable to export: '**
  String get strSelectTimetableToExport;

  /// No description provided for @strBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get strBack;

  /// No description provided for @strTimetableX.
  ///
  /// In en, this message translates to:
  /// **'Timetable: {name}'**
  String strTimetableX(String name);

  /// No description provided for @strExporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting..'**
  String get strExporting;

  /// No description provided for @strFileSavedInDownloadsDirectory.
  ///
  /// In en, this message translates to:
  /// **'File saved in Downloads Directory.'**
  String get strFileSavedInDownloadsDirectory;

  /// No description provided for @strExportingSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Exporting Successful!'**
  String get strExportingSuccessful;

  /// No description provided for @strImportExportTimetable.
  ///
  /// In en, this message translates to:
  /// **'Import / Export Timetable'**
  String get strImportExportTimetable;

  /// No description provided for @strImportTimetable.
  ///
  /// In en, this message translates to:
  /// **'Import Timetable'**
  String get strImportTimetable;

  /// No description provided for @strExportTimetable.
  ///
  /// In en, this message translates to:
  /// **'Export Timetable'**
  String get strExportTimetable;

  /// No description provided for @strImport.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get strImport;

  /// No description provided for @strExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get strExport;

  /// No description provided for @strSelectTimetableFile.
  ///
  /// In en, this message translates to:
  /// **'Select timetable file ({extension})'**
  String strSelectTimetableFile(String extension);

  /// No description provided for @strExportAsFile.
  ///
  /// In en, this message translates to:
  /// **'Exportieren als ({extension})-Datei'**
  String strExportAsFile(String extension);

  /// No description provided for @strNoFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file Selected!'**
  String get strNoFileSelected;

  /// No description provided for @strSelectedFileDoesNotExist.
  ///
  /// In en, this message translates to:
  /// **'Selected file does not exist!'**
  String get strSelectedFileDoesNotExist;

  /// No description provided for @strImportingTimetable.
  ///
  /// In en, this message translates to:
  /// **'Importing timetable...'**
  String get strImportingTimetable;

  /// No description provided for @strImportingFailed.
  ///
  /// In en, this message translates to:
  /// **'Importing failed!'**
  String get strImportingFailed;

  /// No description provided for @strImportSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Import successful!'**
  String get strImportSuccessful;

  /// No description provided for @strTimes.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get strTimes;

  /// No description provided for @strWarningXIsEmptyContinue.
  ///
  /// In en, this message translates to:
  /// **'Warning: {x} is empty do you want to continue?'**
  String strWarningXIsEmptyContinue(String x);

  /// No description provided for @strRoomX.
  ///
  /// In en, this message translates to:
  /// **'Room: {room}'**
  String strRoomX(String room);

  /// No description provided for @strTimeNotValid.
  ///
  /// In en, this message translates to:
  /// **'Time is not valid.'**
  String get strTimeNotValid;

  /// No description provided for @strTaskSuccessfullyCreated.
  ///
  /// In en, this message translates to:
  /// **'Task successfully created'**
  String get strTaskSuccessfullyCreated;

  /// No description provided for @strYourSelectedSemesterDoesNotContainSubjectNamedX.
  ///
  /// In en, this message translates to:
  /// **'Your Selected Semester does not\n contain a Subject named: {name}'**
  String strYourSelectedSemesterDoesNotContainSubjectNamedX(String name);

  /// No description provided for @strCreateSubjectNamedX.
  ///
  /// In en, this message translates to:
  /// **'Create a Subject named: {name}'**
  String strCreateSubjectNamedX(String name);

  /// No description provided for @strYouDidNotSelectASemesterToShowOnHomescreen.
  ///
  /// In en, this message translates to:
  /// **'You did not select a Semester\n to show on homescreen.\nGo to the Grades page\nand select a Semester:)'**
  String get strYouDidNotSelectASemesterToShowOnHomescreen;

  /// No description provided for @strGoToGradesScreen.
  ///
  /// In en, this message translates to:
  /// **'Go to Grades screen'**
  String get strGoToGradesScreen;

  /// No description provided for @strTopic.
  ///
  /// In en, this message translates to:
  /// **'Topic'**
  String get strTopic;

  /// No description provided for @strEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date:'**
  String get strEndDate;

  /// No description provided for @strNoEndDate.
  ///
  /// In en, this message translates to:
  /// **'No End Date'**
  String get strNoEndDate;

  /// No description provided for @strHello.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get strHello;

  /// No description provided for @strYouUpdatedYourAppWantToSeeNewFeatures.
  ///
  /// In en, this message translates to:
  /// **'Ohh you updated your app! Do you want to see the new features?'**
  String get strYouUpdatedYourAppWantToSeeNewFeatures;

  /// No description provided for @strShowNewFeatures.
  ///
  /// In en, this message translates to:
  /// **'Show new Features'**
  String get strShowNewFeatures;

  /// No description provided for @strSchoolApp.
  ///
  /// In en, this message translates to:
  /// **'School App'**
  String get strSchoolApp;

  /// No description provided for @strWelcomeToYourNewSchoolApp.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your new School App!\nHere you can save not only your Timetables but also the ones from your friends!'**
  String get strWelcomeToYourNewSchoolApp;

  /// No description provided for @strTimetable.
  ///
  /// In en, this message translates to:
  /// **'Timetable'**
  String get strTimetable;

  /// No description provided for @strDoYouWantToCreateYourTimetable.
  ///
  /// In en, this message translates to:
  /// **'Do you want to create your Timetable?'**
  String get strDoYouWantToCreateYourTimetable;

  /// No description provided for @strCreateYourSemesterAndLetTheAppHandleTheRest.
  ///
  /// In en, this message translates to:
  /// **'Create your semester and let the app handle the rest!'**
  String get strCreateYourSemesterAndLetTheAppHandleTheRest;

  /// No description provided for @strFeelFreeToCreateATaskForTheFuture.
  ///
  /// In en, this message translates to:
  /// **'Feel free to create a Task for the future so you dont forget it:)\nOf course, you will get notified if you so desire!'**
  String get strFeelFreeToCreateATaskForTheFuture;

  /// No description provided for @strDoYouWantToSeeTheUpcomingHolidays.
  ///
  /// In en, this message translates to:
  /// **'Do you want to see the upcoming holidays?'**
  String get strDoYouWantToSeeTheUpcomingHolidays;

  /// No description provided for @strYourReadyToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Your ready to get started!'**
  String get strYourReadyToGetStarted;

  /// No description provided for @strStart.
  ///
  /// In en, this message translates to:
  /// **'Start!'**
  String get strStart;

  /// No description provided for @strSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get strSkip;

  /// No description provided for @strNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get strNext;

  /// No description provided for @strVersions.
  ///
  /// In en, this message translates to:
  /// **'Versions'**
  String get strVersions;

  /// No description provided for @strStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get strStatistics;

  /// No description provided for @strCustomSubject.
  ///
  /// In en, this message translates to:
  /// **'Custom Subject'**
  String get strCustomSubject;

  /// No description provided for @strEditCustomHolidays.
  ///
  /// In en, this message translates to:
  /// **'Edit custom Holidays'**
  String get strEditCustomHolidays;

  /// No description provided for @strHolidaysEnd.
  ///
  /// In en, this message translates to:
  /// **'End of Holidays'**
  String get strHolidaysEnd;

  /// No description provided for @strHolidaysStart.
  ///
  /// In en, this message translates to:
  /// **'Start of Holidays'**
  String get strHolidaysStart;

  /// No description provided for @strCreateCustomHolidays.
  ///
  /// In en, this message translates to:
  /// **'Create custom Holidays'**
  String get strCreateCustomHolidays;

  /// No description provided for @strHolidaysDateError.
  ///
  /// In en, this message translates to:
  /// **'There appears to be an issue with your dates!'**
  String get strHolidaysDateError;

  /// No description provided for @strWhichTimetableWouldYouLikeToTranslate.
  ///
  /// In en, this message translates to:
  /// **'Which Timetable would you like to Translate?'**
  String get strWhichTimetableWouldYouLikeToTranslate;

  /// No description provided for @strOnlyTheDayNames.
  ///
  /// In en, this message translates to:
  /// **'(Only the Day names)'**
  String get strOnlyTheDayNames;

  /// No description provided for @strWhichSemestersWouldYouLikeToTranslate.
  ///
  /// In en, this message translates to:
  /// **'Which Semesters would you like to Translate?'**
  String get strWhichSemestersWouldYouLikeToTranslate;

  /// No description provided for @strOnlyTheGradeGroups.
  ///
  /// In en, this message translates to:
  /// **'(Only the Gradegroups)'**
  String get strOnlyTheGradeGroups;

  /// No description provided for @strSuccessfullyTranslated.
  ///
  /// In en, this message translates to:
  /// **'Successfully translated!'**
  String get strSuccessfullyTranslated;

  /// No description provided for @strSaturdayLessons.
  ///
  /// In en, this message translates to:
  /// **'Saturday lessons'**
  String get strSaturdayLessons;

  /// No description provided for @strBreaksBetweenLessons.
  ///
  /// In en, this message translates to:
  /// **'Breaks between lessons'**
  String get strBreaksBetweenLessons;

  /// No description provided for @strLengthOfSchoolHours.
  ///
  /// In en, this message translates to:
  /// **'Lesson Length'**
  String get strLengthOfSchoolHours;

  /// No description provided for @strStartOfSchool.
  ///
  /// In en, this message translates to:
  /// **'Start of school'**
  String get strStartOfSchool;

  /// No description provided for @strSetTimes.
  ///
  /// In en, this message translates to:
  /// **'Set Times'**
  String get strSetTimes;

  /// No description provided for @strSetBreaks.
  ///
  /// In en, this message translates to:
  /// **'Set Breaks'**
  String get strSetBreaks;

  /// No description provided for @strXLesson.
  ///
  /// In en, this message translates to:
  /// **'{number}. Lesson'**
  String strXLesson(int number);

  /// No description provided for @strBreakXMin.
  ///
  /// In en, this message translates to:
  /// **'Break: {minutes} minutes'**
  String strBreakXMin(int minutes);

  /// No description provided for @strMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get strMinutes;

  /// No description provided for @strSelectBreakLength.
  ///
  /// In en, this message translates to:
  /// **'Select break length'**
  String get strSelectBreakLength;

  /// No description provided for @strSuccessfullyAddedBreak.
  ///
  /// In en, this message translates to:
  /// **'Break successfully added!'**
  String get strSuccessfullyAddedBreak;

  /// No description provided for @strAddBreak.
  ///
  /// In en, this message translates to:
  /// **'Add Break'**
  String get strAddBreak;

  /// No description provided for @strDoYouWantToRemoveTheLastLesson.
  ///
  /// In en, this message translates to:
  /// **'Do you want to remove the last Lesson?'**
  String get strDoYouWantToRemoveTheLastLesson;

  /// No description provided for @strDoYouWantToAddALesson.
  ///
  /// In en, this message translates to:
  /// **'Do you want to add a Lesson?'**
  String get strDoYouWantToAddALesson;

  /// No description provided for @strSecureBackupFileDoesNot.
  ///
  /// In en, this message translates to:
  /// **'Secure-Backup file does not exist! (do you know what you\'re doing?)'**
  String get strSecureBackupFileDoesNot;

  /// No description provided for @strFilesHaveBeenDeleteOrAddedBackup.
  ///
  /// In en, this message translates to:
  /// **'Files have been deleted or added to the backup!'**
  String get strFilesHaveBeenDeleteOrAddedBackup;

  /// No description provided for @strVersionOfAppDoesNotMatchWithBackup.
  ///
  /// In en, this message translates to:
  /// **'The version of your app does not match the version of the backup!'**
  String get strVersionOfAppDoesNotMatchWithBackup;

  /// No description provided for @strBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get strBackup;

  /// No description provided for @strCreateBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup-Data'**
  String get strCreateBackup;

  /// No description provided for @strRestoreBackup.
  ///
  /// In en, this message translates to:
  /// **'Restore-Data'**
  String get strRestoreBackup;

  /// No description provided for @strTheBackupIsNotEncrypted.
  ///
  /// In en, this message translates to:
  /// **'The backup is not encrypted!'**
  String get strTheBackupIsNotEncrypted;

  /// No description provided for @strAreYouSureThatYouWantToCreateABackup.
  ///
  /// In en, this message translates to:
  /// **'Are you sure that you want to create a backup?'**
  String get strAreYouSureThatYouWantToCreateABackup;

  /// No description provided for @strBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed!'**
  String get strBackupFailed;

  /// No description provided for @strBackupSuccessfullyCreatedUnder.
  ///
  /// In en, this message translates to:
  /// **'Backup successfully created!\n{path}'**
  String strBackupSuccessfullyCreatedUnder(String path);

  /// No description provided for @strAllOfYourDataWillBeOverwritten.
  ///
  /// In en, this message translates to:
  /// **'All of your data will be overwritten!'**
  String get strAllOfYourDataWillBeOverwritten;

  /// No description provided for @strAreYouSureThatYouWantToRestoreYourData.
  ///
  /// In en, this message translates to:
  /// **'Are you sure that you want to restore your data?'**
  String get strAreYouSureThatYouWantToRestoreYourData;

  /// No description provided for @strDoYouWantToContinue.
  ///
  /// In en, this message translates to:
  /// **'Do you want to continue?'**
  String get strDoYouWantToContinue;

  /// No description provided for @strRestoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Restore failed!\n{path}'**
  String strRestoreFailed(String path);

  /// No description provided for @strRestoredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Restored successfully!\n{path}'**
  String strRestoredSuccessfully(String path);

  /// No description provided for @strThereWasAnError.
  ///
  /// In en, this message translates to:
  /// **'There was an error! :('**
  String get strThereWasAnError;

  /// No description provided for @strThereWasAnErrorWhileSaving.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while saving! :('**
  String get strThereWasAnErrorWhileSaving;

  /// No description provided for @strWidgets.
  ///
  /// In en, this message translates to:
  /// **'Widgets'**
  String get strWidgets;

  /// No description provided for @strPinToHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Add timetable to home screen'**
  String get strPinToHomeScreen;

  /// No description provided for @strYouDontHaveATimetableJet.
  ///
  /// In en, this message translates to:
  /// **'It looks like you don\'t have a timetable set up yet.\nPlease create one and try again.'**
  String get strYouDontHaveATimetableJet;

  /// No description provided for @strShowTasksOnHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Show tasks on homescreen'**
  String get strShowTasksOnHomeScreen;

  /// No description provided for @strWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get strWeight;

  /// No description provided for @strPinWeightedSubjectsAtTop.
  ///
  /// In en, this message translates to:
  /// **'Pin weighted subjects at the top'**
  String get strPinWeightedSubjectsAtTop;

  /// No description provided for @strSortSubjects.
  ///
  /// In en, this message translates to:
  /// **'Sort Subjects'**
  String get strSortSubjects;

  /// No description provided for @strByName.
  ///
  /// In en, this message translates to:
  /// **'by name'**
  String get strByName;

  /// No description provided for @strByGrade.
  ///
  /// In en, this message translates to:
  /// **'by grade'**
  String get strByGrade;

  /// No description provided for @strManually.
  ///
  /// In en, this message translates to:
  /// **'manually'**
  String get strManually;

  /// No description provided for @strDragSubjectsIntoDesiredOrder.
  ///
  /// In en, this message translates to:
  /// **'Drag the subjects listed below into the desired order.'**
  String get strDragSubjectsIntoDesiredOrder;

  /// No description provided for @strGradeSystem.
  ///
  /// In en, this message translates to:
  /// **'Grading system'**
  String get strGradeSystem;

  /// No description provided for @strPoints_0_15.
  ///
  /// In en, this message translates to:
  /// **'Points 0 - 15'**
  String get strPoints_0_15;

  /// No description provided for @strGrade_1_6.
  ///
  /// In en, this message translates to:
  /// **'Grades 1 - 6'**
  String get strGrade_1_6;

  /// No description provided for @strGrade_6_1.
  ///
  /// In en, this message translates to:
  /// **'Grades 6 - 1'**
  String get strGrade_6_1;

  /// No description provided for @strGrade_A_F.
  ///
  /// In en, this message translates to:
  /// **'Grades A - F'**
  String get strGrade_A_F;

  /// No description provided for @strNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'not logged in'**
  String get strNotLoggedIn;

  /// No description provided for @strLogindataSuccessfullySaved.
  ///
  /// In en, this message translates to:
  /// **'Login data successfully saved'**
  String get strLogindataSuccessfullySaved;

  /// No description provided for @strSuccessfullySaved.
  ///
  /// In en, this message translates to:
  /// **'Successfully saved'**
  String get strSuccessfullySaved;

  /// No description provided for @strSubstitutionPlan.
  ///
  /// In en, this message translates to:
  /// **'Open substitution plan'**
  String get strSubstitutionPlan;

  /// No description provided for @strHighContrastOnHomeScreen.
  ///
  /// In en, this message translates to:
  /// **'Increase text contrast on homescreen'**
  String get strHighContrastOnHomeScreen;

  /// No description provided for @strReducedClassHours.
  ///
  /// In en, this message translates to:
  /// **'Reduced class hours'**
  String get strReducedClassHours;

  /// No description provided for @strYouDontHaveAnyReducedTimesSetUpYet.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any reduced times set up yet.'**
  String get strYouDontHaveAnyReducedTimesSetUpYet;

  /// No description provided for @strReducedTimesCannotBeUsed.
  ///
  /// In en, this message translates to:
  /// **'Reduced times cannot be used because the timetable has too many lessons.'**
  String get strReducedTimesCannotBeUsed;

  /// No description provided for @strFinishedTasks.
  ///
  /// In en, this message translates to:
  /// **'Completed Tasks'**
  String get strFinishedTasks;

  /// No description provided for @strShowFinishedTasks.
  ///
  /// In en, this message translates to:
  /// **'show Completed Tasks'**
  String get strShowFinishedTasks;

  /// No description provided for @strNoTasksFinishedYet.
  ///
  /// In en, this message translates to:
  /// **'No tasks completed yet. Keep going!'**
  String get strNoTasksFinishedYet;

  /// No description provided for @strNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get strNotes;

  /// No description provided for @strAddNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get strAddNote;

  /// No description provided for @strSelectNote.
  ///
  /// In en, this message translates to:
  /// **'Select Note'**
  String get strSelectNote;

  /// No description provided for @strTaskNote.
  ///
  /// In en, this message translates to:
  /// **'Task Note: {linkedSubjectName}'**
  String strTaskNote(String linkedSubjectName);

  /// No description provided for @strTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get strTitle;

  /// No description provided for @strEditNote.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get strEditNote;

  /// No description provided for @strCreateANote.
  ///
  /// In en, this message translates to:
  /// **'Create a note'**
  String get strCreateANote;

  /// No description provided for @strDoYouWantToDeleteLinkedNote.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the linked note?'**
  String get strDoYouWantToDeleteLinkedNote;

  /// No description provided for @strDoYouWantToDeleteAllLinkedNote.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the linked notes?'**
  String get strDoYouWantToDeleteAllLinkedNote;

  /// No description provided for @strImagePreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get strImagePreviewTitle;

  /// No description provided for @strDoYouWantToCreateACopyOfTheFile.
  ///
  /// In en, this message translates to:
  /// **'Would you like to create a copy of the file?'**
  String get strDoYouWantToCreateACopyOfTheFile;

  /// No description provided for @strDoYouWantToCreateACopyOfTheFileDescription.
  ///
  /// In en, this message translates to:
  /// **'If you do not create a copy, the file cannot be shared.'**
  String get strDoYouWantToCreateACopyOfTheFileDescription;

  /// No description provided for @strLastModifiedOn.
  ///
  /// In en, this message translates to:
  /// **'Last modified on'**
  String get strLastModifiedOn;

  /// No description provided for @strCreatedOn.
  ///
  /// In en, this message translates to:
  /// **'Created on'**
  String get strCreatedOn;

  /// No description provided for @strAddReminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get strAddReminder;

  /// No description provided for @strAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get strAdd;

  /// No description provided for @strXDaysBefore.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{When the set time is reached} =1 {One day before} other {{days} days before}}'**
  String strXDaysBefore(int days);

  /// No description provided for @strAtXOClock.
  ///
  /// In en, this message translates to:
  /// **'at {time}'**
  String strAtXOClock(String time);

  /// No description provided for @strMustAtLeastOneNotificationPresent.
  ///
  /// In en, this message translates to:
  /// **'There must be at least one notification present.'**
  String get strMustAtLeastOneNotificationPresent;

  /// No description provided for @strTaskNotification.
  ///
  /// In en, this message translates to:
  /// **'Task Notification'**
  String get strTaskNotification;

  /// No description provided for @strSetTaskNotification.
  ///
  /// In en, this message translates to:
  /// **'Set Task Notification'**
  String get strSetTaskNotification;

  /// No description provided for @strAt.
  ///
  /// In en, this message translates to:
  /// **'At'**
  String get strAt;

  /// No description provided for @strShareYourTimetable.
  ///
  /// In en, this message translates to:
  /// **'Share your Timetable!'**
  String get strShareYourTimetable;

  /// No description provided for @strDayProgress.
  ///
  /// In en, this message translates to:
  /// **'Day Progress'**
  String get strDayProgress;

  /// No description provided for @strAddXWeek.
  ///
  /// In en, this message translates to:
  /// **'Add {weekName}-Week'**
  String strAddXWeek(String weekName);

  /// No description provided for @strRemoveXWeek.
  ///
  /// In en, this message translates to:
  /// **'Remove {weekName}-Week'**
  String strRemoveXWeek(String weekName);

  /// No description provided for @strXWeek.
  ///
  /// In en, this message translates to:
  /// **'{weekName}-Week'**
  String strXWeek(String weekName);

  /// No description provided for @strDoYouWantToRemoveWeekX.
  ///
  /// In en, this message translates to:
  /// **'Möchtest Du die {weekName}-Woche löschen?'**
  String strDoYouWantToRemoveWeekX(String weekName);

  /// No description provided for @strDoYouWantToOverrideTimetableX.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to overwrite the timetable \"{timetableName}\"?'**
  String strDoYouWantToOverrideTimetableX(String timetableName);

  /// No description provided for @strSetXWeekAsTheCurrentWeek.
  ///
  /// In en, this message translates to:
  /// **'Set {weekName}-Week as the current week'**
  String strSetXWeekAsTheCurrentWeek(String weekName);

  /// No description provided for @strCurrentWeek.
  ///
  /// In en, this message translates to:
  /// **'(Current Week)'**
  String get strCurrentWeek;

  /// No description provided for @strActions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get strActions;

  /// No description provided for @strRemoveLesson.
  ///
  /// In en, this message translates to:
  /// **'Remove last Lesson'**
  String get strRemoveLesson;

  /// No description provided for @strAddLesson.
  ///
  /// In en, this message translates to:
  /// **'Add Lesson'**
  String get strAddLesson;

  /// No description provided for @strDisplayFreePeriodsWithLessonNumber.
  ///
  /// In en, this message translates to:
  /// **'Display free periods with period number'**
  String get strDisplayFreePeriodsWithLessonNumber;

  /// No description provided for @strDisplayFreePeriodsWithoutPeriodNumber.
  ///
  /// In en, this message translates to:
  /// **'Display free periods without period number'**
  String get strDisplayFreePeriodsWithoutPeriodNumber;

  /// No description provided for @strSetHomeScreenTimetable.
  ///
  /// In en, this message translates to:
  /// **'Set Timetable for Homescreen'**
  String get strSetHomeScreenTimetable;

  /// No description provided for @strSetExtraHomeScreenTimetable.
  ///
  /// In en, this message translates to:
  /// **'Set Extra Timetable for Homescreen'**
  String get strSetExtraHomeScreenTimetable;

  /// No description provided for @strAddNewLessons.
  ///
  /// In en, this message translates to:
  /// **'Use this area to add new lessons to your schedule.'**
  String get strAddNewLessons;

  /// No description provided for @strDragAndDropLessonsAndClickToEdit.
  ///
  /// In en, this message translates to:
  /// **'Once you\'ve created lessons, you can drag and drop them into the timetable. \nSimply click on any lesson to change its details.'**
  String get strDragAndDropLessonsAndClickToEdit;

  /// No description provided for @strAccessAdditionalOptions.
  ///
  /// In en, this message translates to:
  /// **'Access more options like adding A-Week and B-Week for more flexibility in your schedule.'**
  String get strAccessAdditionalOptions;

  /// No description provided for @strSaveTimetable.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to save your timetable once you\'re happy with the changes!'**
  String get strSaveTimetable;

  /// No description provided for @strChangeTimetableNameByClickingOnIt.
  ///
  /// In en, this message translates to:
  /// **'Change the timetable name by clicking on it.'**
  String get strChangeTimetableNameByClickingOnIt;

  /// No description provided for @strYouCanSeeTheComingWeeksTimetable.
  ///
  /// In en, this message translates to:
  /// **'You can see the coming weeks by swiping.'**
  String get strYouCanSeeTheComingWeeksTimetable;

  /// No description provided for @strByClickingOnSubjectsYouCanAddHomework.
  ///
  /// In en, this message translates to:
  /// **'By clicking on subjects, you can add homework and grades. To mark it as canceled, long press.'**
  String get strByClickingOnSubjectsYouCanAddHomework;

  /// No description provided for @strByClickingOnTheDayNameYouReturnToToday.
  ///
  /// In en, this message translates to:
  /// **'By clicking on the day name, you return to today\'s date. Long pressing marks the entire day as canceled.'**
  String get strByClickingOnTheDayNameYouReturnToToday;

  /// No description provided for @strDisplayOfTheRemainingTime.
  ///
  /// In en, this message translates to:
  /// **'This displays the remaining time until the next class or break.'**
  String get strDisplayOfTheRemainingTime;

  /// No description provided for @strTapHereToSwitchTimetablesEtc.
  ///
  /// In en, this message translates to:
  /// **'Tap here to switch timetables, export them, or create tasks.'**
  String get strTapHereToSwitchTimetablesEtc;

  /// No description provided for @strDoYouWantToOverrideAllSubjects.
  ///
  /// In en, this message translates to:
  /// **'Do you want to overwrite all existing lessons?'**
  String get strDoYouWantToOverrideAllSubjects;

  /// No description provided for @strDoYouWantToOverrideSemesterX.
  ///
  /// In en, this message translates to:
  /// **'Do you really want to overwrite the timetable \"{semesterName}\"?'**
  String strDoYouWantToOverrideSemesterX(String semesterName);

  /// No description provided for @strCopiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get strCopiedToClipboard;

  /// No description provided for @strImportViaCode.
  ///
  /// In en, this message translates to:
  /// **'Import via online Code'**
  String get strImportViaCode;

  /// No description provided for @strShareViaOnlineCode.
  ///
  /// In en, this message translates to:
  /// **'Share via online Code'**
  String get strShareViaOnlineCode;

  /// No description provided for @strCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get strCode;

  /// No description provided for @strDataSavedViaGoFile.
  ///
  /// In en, this message translates to:
  /// **'The data is stored on GoFile.io and will be automatically deleted after 10 days unless accessed regularly.'**
  String get strDataSavedViaGoFile;

  /// No description provided for @strFailedToUploadFile.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload file. Status code: {statusCode}\nResponse: {body}'**
  String strFailedToUploadFile(String statusCode, String body);

  /// No description provided for @strDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed with status: \${statusCode}\nResponse: \${body}'**
  String strDownloadFailed(String statusCode, String body);

  /// No description provided for @strFailedToRetrieveAccountToken.
  ///
  /// In en, this message translates to:
  /// **'Failed to retrieve account token. Status code: \${statusCode}\nResponse: \${body}'**
  String strFailedToRetrieveAccountToken(String statusCode, String body);

  /// No description provided for @strCouldNotGetFileLink.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t get file link. Status code: \${statusCode}\nResponse: \${body}'**
  String strCouldNotGetFileLink(String statusCode, String body);

  /// No description provided for @strNoDataAvailablePleaseCheckCode.
  ///
  /// In en, this message translates to:
  /// **'No data available. Please check the code!'**
  String get strNoDataAvailablePleaseCheckCode;

  /// No description provided for @strDoYouAgreeToTermsAndServiceOfGoFileIo.
  ///
  /// In en, this message translates to:
  /// **'Do you agree to the Terms of Service of GoFile.io?'**
  String get strDoYouAgreeToTermsAndServiceOfGoFileIo;

  /// No description provided for @strFeatureUsesGoFileIoToStoreDataOnline.
  ///
  /// In en, this message translates to:
  /// **'This feature uses GoFile.io to store data online for a few days. Have you read and agreed to the Terms of Service and Privacy Policy?'**
  String get strFeatureUsesGoFileIoToStoreDataOnline;

  /// No description provided for @strYouMustAgreeToTheTermsOfServiceToUseThisFeature.
  ///
  /// In en, this message translates to:
  /// **'You must agree to the Terms of Service in order to use this feature.'**
  String get strYouMustAgreeToTheTermsOfServiceToUseThisFeature;

  /// No description provided for @strTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get strTermsOfService;

  /// No description provided for @strShareImage.
  ///
  /// In en, this message translates to:
  /// **'Share as Image'**
  String get strShareImage;

  /// No description provided for @strFeedbackSent.
  ///
  /// In en, this message translates to:
  /// **'Feedback sent!'**
  String get strFeedbackSent;

  /// No description provided for @strSendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get strSendFeedback;

  /// No description provided for @strBugReport.
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get strBugReport;

  /// No description provided for @strFeatureRequest.
  ///
  /// In en, this message translates to:
  /// **'Feature Request'**
  String get strFeatureRequest;

  /// No description provided for @strGeneralFeedback.
  ///
  /// In en, this message translates to:
  /// **'General Feedback'**
  String get strGeneralFeedback;

  /// No description provided for @strInformationCanNotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Information can not be empty!'**
  String get strInformationCanNotBeEmpty;

  /// No description provided for @strWhatDoYouWantToTellTheDeveloper.
  ///
  /// In en, this message translates to:
  /// **'What do you want to tell the developer?'**
  String get strWhatDoYouWantToTellTheDeveloper;

  /// No description provided for @strDoYoutWantToOpenFeedbackMenu.
  ///
  /// In en, this message translates to:
  /// **'Do you want to open the feedback menu?'**
  String get strDoYoutWantToOpenFeedbackMenu;

  /// No description provided for @strOpenFeedbackDescription.
  ///
  /// In en, this message translates to:
  /// **'When you\'re in \"Feedback\" mode, go to any page in the app and click the \"Draw\" button on the right side to visually show the developer what you mean. Use the text input at the bottom to add extra details. Once you\'re done, submit it and wait a moment. Your email will open automatically — no need to write anything, just hit send. :)'**
  String get strOpenFeedbackDescription;

  /// No description provided for @strMarkAsCancelled.
  ///
  /// In en, this message translates to:
  /// **'Mark as Cancelled'**
  String get strMarkAsCancelled;

  /// No description provided for @strMarkAsSubstitute.
  ///
  /// In en, this message translates to:
  /// **'Mark as substitute'**
  String get strMarkAsSubstitute;

  /// No description provided for @strAbiCalculator.
  ///
  /// In en, this message translates to:
  /// **'A-level Calculator'**
  String get strAbiCalculator;

  /// No description provided for @strLongPressDragBreaksToReorder.
  ///
  /// In en, this message translates to:
  /// **'Long press and drag breaks to reorder.'**
  String get strLongPressDragBreaksToReorder;

  /// No description provided for @strReplaceBreaks.
  ///
  /// In en, this message translates to:
  /// **'Breaks replace the previously set time between lessons.'**
  String get strReplaceBreaks;

  /// No description provided for @strSelectSemester.
  ///
  /// In en, this message translates to:
  /// **'Select Semester'**
  String get strSelectSemester;

  /// No description provided for @strSelectSemesterX.
  ///
  /// In en, this message translates to:
  /// **'Select Q{index}'**
  String strSelectSemesterX(int index);

  /// No description provided for @strQX.
  ///
  /// In en, this message translates to:
  /// **'Q{index}'**
  String strQX(int index);

  /// No description provided for @strSectionI.
  ///
  /// In en, this message translates to:
  /// **'Section I'**
  String get strSectionI;

  /// No description provided for @strSectionII.
  ///
  /// In en, this message translates to:
  /// **'Section II'**
  String get strSectionII;

  /// No description provided for @strShowSimulatedGrades.
  ///
  /// In en, this message translates to:
  /// **'Show simulated grades'**
  String get strShowSimulatedGrades;

  /// No description provided for @strGrade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get strGrade;

  /// No description provided for @strWeighting.
  ///
  /// In en, this message translates to:
  /// **'Weighting'**
  String get strWeighting;

  /// No description provided for @strWeightedPoints.
  ///
  /// In en, this message translates to:
  /// **'Weighted Points'**
  String get strWeightedPoints;

  /// No description provided for @strSubject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get strSubject;

  /// No description provided for @strSetWeighting.
  ///
  /// In en, this message translates to:
  /// **'Set Weighting'**
  String get strSetWeighting;

  /// No description provided for @strChangeWeighting.
  ///
  /// In en, this message translates to:
  /// **'Change Weighting'**
  String get strChangeWeighting;

  /// No description provided for @strWrittenExamType.
  ///
  /// In en, this message translates to:
  /// **'Written'**
  String get strWrittenExamType;

  /// No description provided for @strVerbalExamType.
  ///
  /// In en, this message translates to:
  /// **'Verbal'**
  String get strVerbalExamType;

  /// No description provided for @strPresentationExamType.
  ///
  /// In en, this message translates to:
  /// **'Presentation'**
  String get strPresentationExamType;

  /// No description provided for @strYouHaveToSelectASubject.
  ///
  /// In en, this message translates to:
  /// **'You have to select a subject!'**
  String get strYouHaveToSelectASubject;

  /// No description provided for @strYouHaveToSelectAGrade.
  ///
  /// In en, this message translates to:
  /// **'You have to select a grade!'**
  String get strYouHaveToSelectAGrade;

  /// No description provided for @strSelectExamType.
  ///
  /// In en, this message translates to:
  /// **'Select Exam Type'**
  String get strSelectExamType;

  /// No description provided for @strDoYouWantToDeleteTheExam.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete the exam?'**
  String get strDoYouWantToDeleteTheExam;

  /// No description provided for @strAddExam.
  ///
  /// In en, this message translates to:
  /// **'Add Exam'**
  String get strAddExam;

  /// Klassentext je nach Jahrgangsstufe: unter 11 ohne Semester, ab 11 mit.
  ///
  /// In en, this message translates to:
  /// **'{lowerThan11, select, true{Grade {classNumber}} false{Grade {classNumber}, Semester {semesterNumber}} other{Grade {classNumber}}}'**
  String strClassNameText(String lowerThan11, int classNumber, int semesterNumber);

  /// No description provided for @strConnectTimetable.
  ///
  /// In en, this message translates to:
  /// **'Connect Timetable'**
  String get strConnectTimetable;

  /// Jahrgangsstufe
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get strYearGrade;

  /// No description provided for @strSemester.
  ///
  /// In en, this message translates to:
  /// **'Semester'**
  String get strSemester;

  /// No description provided for @strSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get strSearch;

  /// No description provided for @strYouHavntSetTheRoom.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t set the room!\nDo you want to set it?'**
  String get strYouHavntSetTheRoom;

  /// No description provided for @strSetRoom.
  ///
  /// In en, this message translates to:
  /// **'Set room'**
  String get strSetRoom;

  /// No description provided for @strToSetTheRoomDrag.
  ///
  /// In en, this message translates to:
  /// **'To set the room, drag it onto the lesson again.'**
  String get strToSetTheRoomDrag;

  /// No description provided for @strSetEndTime.
  ///
  /// In en, this message translates to:
  /// **'Set end time'**
  String get strSetEndTime;

  /// No description provided for @strSetStartTime.
  ///
  /// In en, this message translates to:
  /// **'Set start time'**
  String get strSetStartTime;

  /// No description provided for @strAskForFeedback.
  ///
  /// In en, this message translates to:
  /// **'Would you like to give us feedback?\nWe would greatly appreciate it, after all, we are doing it for free for you :)'**
  String get strAskForFeedback;

  /// No description provided for @strOpenExtraTimetable.
  ///
  /// In en, this message translates to:
  /// **'open extra timetable'**
  String get strOpenExtraTimetable;

  /// No description provided for @strOpenCalendar.
  ///
  /// In en, this message translates to:
  /// **'Open Calendar'**
  String get strOpenCalendar;

  /// No description provided for @strCloseCalendar.
  ///
  /// In en, this message translates to:
  /// **'Close Calendar'**
  String get strCloseCalendar;

  /// No description provided for @strDateXNotFound.
  ///
  /// In en, this message translates to:
  /// **'The specified date could not be found: {date}'**
  String strDateXNotFound(String date);

  /// No description provided for @strRemoveSubstitutionLesson.
  ///
  /// In en, this message translates to:
  /// **'Remove substitution lesson'**
  String get strRemoveSubstitutionLesson;

  /// No description provided for @strDeleteTask.
  ///
  /// In en, this message translates to:
  /// **'Delete Task'**
  String get strDeleteTask;

  /// No description provided for @strColorsOfTasksInTheCalendar.
  ///
  /// In en, this message translates to:
  /// **'Colors of tasks in the calendar'**
  String get strColorsOfTasksInTheCalendar;

  /// No description provided for @strHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get strHide;

  /// No description provided for @strBlackAndWhite.
  ///
  /// In en, this message translates to:
  /// **'Black and White'**
  String get strBlackAndWhite;

  /// No description provided for @strColorOfType.
  ///
  /// In en, this message translates to:
  /// **'Color of Type'**
  String get strColorOfType;

  /// No description provided for @strSubjectColor.
  ///
  /// In en, this message translates to:
  /// **'Subject Color'**
  String get strSubjectColor;

  /// No description provided for @strMarkDayAsCancelled.
  ///
  /// In en, this message translates to:
  /// **'Mark day as cancelled'**
  String get strMarkDayAsCancelled;

  /// No description provided for @strMarkDayAsNotCancelled.
  ///
  /// In en, this message translates to:
  /// **'Mark day as not cancelled'**
  String get strMarkDayAsNotCancelled;

  /// No description provided for @strMarkDayAsSubstituted.
  ///
  /// In en, this message translates to:
  /// **'Mark day as substituted'**
  String get strMarkDayAsSubstituted;

  /// No description provided for @strMarkDayAsNotSubstituted.
  ///
  /// In en, this message translates to:
  /// **'Mark day as not substituted'**
  String get strMarkDayAsNotSubstituted;

  /// No description provided for @strShowNextDayAfterSchoolEnd.
  ///
  /// In en, this message translates to:
  /// **'Show next day after school ends'**
  String get strShowNextDayAfterSchoolEnd;

  /// No description provided for @strMarkAsSick.
  ///
  /// In en, this message translates to:
  /// **'Mark lesson as absent due to illness'**
  String get strMarkAsSick;

  /// No description provided for @strMarkDayAsSick.
  ///
  /// In en, this message translates to:
  /// **'Mark day as absent due to illness'**
  String get strMarkDayAsSick;

  /// No description provided for @strMarkDayAsNotSick.
  ///
  /// In en, this message translates to:
  /// **'Mark day as not sick'**
  String get strMarkDayAsNotSick;

  /// No description provided for @strShowAlwaysWeekTimetable.
  ///
  /// In en, this message translates to:
  /// **'Show week instead of day on home screen'**
  String get strShowAlwaysWeekTimetable;

  /// No description provided for @strShortName.
  ///
  /// In en, this message translates to:
  /// **'Abbreviation'**
  String get strShortName;

  /// No description provided for @strShortNameExplanation.
  ///
  /// In en, this message translates to:
  /// **'The abbreviation is shown in the timetable when space is limited.'**
  String get strShortNameExplanation;

  /// No description provided for @strShareTodoEventWarning.
  ///
  /// In en, this message translates to:
  /// **'Only import tasks from trusted people'**
  String get strShareTodoEventWarning;

  /// No description provided for @strShareTodoEventWarningDescription.
  ///
  /// In en, this message translates to:
  /// **'When you import a task, it may contain a note with harmful files. So be careful before opening a file!'**
  String get strShareTodoEventWarningDescription;

  /// No description provided for @strDoNotShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Do not show again'**
  String get strDoNotShowAgain;

  /// No description provided for @strShareYourTodoEvents.
  ///
  /// In en, this message translates to:
  /// **'Share your tasks!'**
  String get strShareYourTodoEvents;

  /// No description provided for @strWhichTodoEventsWouldYouLikeToImport.
  ///
  /// In en, this message translates to:
  /// **'Which tasks would you like to import?'**
  String get strWhichTodoEventsWouldYouLikeToImport;

  /// No description provided for @strAbiAverageNotAlwaysCorrectInfo.
  ///
  /// In en, this message translates to:
  /// **'The average calculation may be incorrect! This is only an approximation, calculated as follows: 5.66 - (total score / 180)'**
  String get strAbiAverageNotAlwaysCorrectInfo;

  /// No description provided for @strLessonReminderNotification.
  ///
  /// In en, this message translates to:
  /// **'Lesson reminder notification'**
  String get strLessonReminderNotification;

  /// No description provided for @strSetPreLessonReminderNotificationDuration.
  ///
  /// In en, this message translates to:
  /// **'Set reminder time\n({minutes} minutes before)'**
  String strSetPreLessonReminderNotificationDuration(int minutes);

  /// No description provided for @strSetPreLessonReminderNotificationDurationTitle.
  ///
  /// In en, this message translates to:
  /// **'Set reminder time'**
  String get strSetPreLessonReminderNotificationDurationTitle;

  /// No description provided for @strLessonStartsSoon.
  ///
  /// In en, this message translates to:
  /// **'{lesson} starts soon'**
  String strLessonStartsSoon(String lesson);

  /// No description provided for @strLessonIsSubstite.
  ///
  /// In en, this message translates to:
  /// **'{lesson} (Substitute)'**
  String strLessonIsSubstite(String lesson);

  /// No description provided for @strLessonInRoom.
  ///
  /// In en, this message translates to:
  /// **'In room {room}'**
  String strLessonInRoom(String room);

  /// No description provided for @strSelectSubjects.
  ///
  /// In en, this message translates to:
  /// **'Select your subjects'**
  String get strSelectSubjects;

  /// No description provided for @strScanQRCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR-Code'**
  String get strScanQRCode;

  /// No description provided for @subject_Altgriechisch.
  ///
  /// In en, this message translates to:
  /// **'Ancient Greek'**
  String get subject_Altgriechisch;

  /// No description provided for @subject_Astronomie.
  ///
  /// In en, this message translates to:
  /// **'Astronomy'**
  String get subject_Astronomie;

  /// No description provided for @subject_Biologie.
  ///
  /// In en, this message translates to:
  /// **'Biology'**
  String get subject_Biologie;

  /// No description provided for @subject_Chemie.
  ///
  /// In en, this message translates to:
  /// **'Chemistry'**
  String get subject_Chemie;

  /// No description provided for @subject_Chinesisch.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get subject_Chinesisch;

  /// No description provided for @subject_Deutsch.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get subject_Deutsch;

  /// No description provided for @subject_DtGebardensprache.
  ///
  /// In en, this message translates to:
  /// **'German Sign Language'**
  String get subject_DtGebardensprache;

  /// No description provided for @subject_Englisch.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get subject_Englisch;

  /// No description provided for @subject_Ethik.
  ///
  /// In en, this message translates to:
  /// **'Ethics'**
  String get subject_Ethik;

  /// No description provided for @subject_Franzosisch.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get subject_Franzosisch;

  /// No description provided for @subject_Geographie.
  ///
  /// In en, this message translates to:
  /// **'Geography'**
  String get subject_Geographie;

  /// No description provided for @subject_Erdkunde.
  ///
  /// In en, this message translates to:
  /// **'Geography'**
  String get subject_Erdkunde;

  /// No description provided for @subject_Geschichte.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get subject_Geschichte;

  /// No description provided for @subject_Sozialkunde.
  ///
  /// In en, this message translates to:
  /// **'Social Studies'**
  String get subject_Sozialkunde;

  /// No description provided for @subject_Sozialpadagogik.
  ///
  /// In en, this message translates to:
  /// **'Social Pedagogy'**
  String get subject_Sozialpadagogik;

  /// No description provided for @subject_Sozialwissenschaften.
  ///
  /// In en, this message translates to:
  /// **'Social Sciences'**
  String get subject_Sozialwissenschaften;

  /// No description provided for @subject_Hebraisch.
  ///
  /// In en, this message translates to:
  /// **'Hebrew'**
  String get subject_Hebraisch;

  /// No description provided for @subject_Informatik.
  ///
  /// In en, this message translates to:
  /// **'Computer Science'**
  String get subject_Informatik;

  /// No description provided for @subject_Italienisch.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get subject_Italienisch;

  /// No description provided for @subject_Japanisch.
  ///
  /// In en, this message translates to:
  /// **'Japanese'**
  String get subject_Japanisch;

  /// No description provided for @subject_Kunst.
  ///
  /// In en, this message translates to:
  /// **'Art'**
  String get subject_Kunst;

  /// No description provided for @subject_Latein.
  ///
  /// In en, this message translates to:
  /// **'Latin'**
  String get subject_Latein;

  /// No description provided for @subject_LER.
  ///
  /// In en, this message translates to:
  /// **'LER'**
  String get subject_LER;

  /// No description provided for @subject_Mathematik.
  ///
  /// In en, this message translates to:
  /// **'Mathematics'**
  String get subject_Mathematik;

  /// No description provided for @subject_Musik.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get subject_Musik;

  /// No description provided for @subject_Naturwissenschaften.
  ///
  /// In en, this message translates to:
  /// **'Natural Sciences'**
  String get subject_Naturwissenschaften;

  /// No description provided for @subject_Neugriechisch.
  ///
  /// In en, this message translates to:
  /// **'Modern Greek'**
  String get subject_Neugriechisch;

  /// No description provided for @subject_Philosophie.
  ///
  /// In en, this message translates to:
  /// **'Philosophy'**
  String get subject_Philosophie;

  /// No description provided for @subject_Physik.
  ///
  /// In en, this message translates to:
  /// **'Physics'**
  String get subject_Physik;

  /// No description provided for @subject_PolitischeBildung.
  ///
  /// In en, this message translates to:
  /// **'Political Education'**
  String get subject_PolitischeBildung;

  /// No description provided for @subject_Polnisch.
  ///
  /// In en, this message translates to:
  /// **'Polish'**
  String get subject_Polnisch;

  /// No description provided for @subject_Portugiesisch.
  ///
  /// In en, this message translates to:
  /// **'Portuguese'**
  String get subject_Portugiesisch;

  /// No description provided for @subject_Psychologie.
  ///
  /// In en, this message translates to:
  /// **'Psychology'**
  String get subject_Psychologie;

  /// No description provided for @subject_Russisch.
  ///
  /// In en, this message translates to:
  /// **'Russian'**
  String get subject_Russisch;

  /// No description provided for @subject_Sachunterricht.
  ///
  /// In en, this message translates to:
  /// **'General Studies'**
  String get subject_Sachunterricht;

  /// No description provided for @subject_SorbischWendisch.
  ///
  /// In en, this message translates to:
  /// **'Sorbian-Wendish'**
  String get subject_SorbischWendisch;

  /// No description provided for @subject_SozWirtschaftswissenschaften.
  ///
  /// In en, this message translates to:
  /// **'Social/Economic Sciences'**
  String get subject_SozWirtschaftswissenschaften;

  /// No description provided for @subject_Wirtschaftskunde.
  ///
  /// In en, this message translates to:
  /// **'Economics'**
  String get subject_Wirtschaftskunde;

  /// No description provided for @subject_Spanisch.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get subject_Spanisch;

  /// No description provided for @subject_Sport.
  ///
  /// In en, this message translates to:
  /// **'Physical Education'**
  String get subject_Sport;

  /// No description provided for @subject_Theater.
  ///
  /// In en, this message translates to:
  /// **'Theater'**
  String get subject_Theater;

  /// No description provided for @subject_Turkisch.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get subject_Turkisch;

  /// No description provided for @subject_WAT.
  ///
  /// In en, this message translates to:
  /// **'W-A-T'**
  String get subject_WAT;

  /// No description provided for @subject_DarstellendesSpiel.
  ///
  /// In en, this message translates to:
  /// **'Performing Arts'**
  String get subject_DarstellendesSpiel;

  /// No description provided for @subject_Politikwissenschaft.
  ///
  /// In en, this message translates to:
  /// **'Political Science'**
  String get subject_Politikwissenschaft;

  /// No description provided for @subject_Recht.
  ///
  /// In en, this message translates to:
  /// **'Law'**
  String get subject_Recht;

  /// No description provided for @subject_Relogion.
  ///
  /// In en, this message translates to:
  /// **'Religion'**
  String get subject_Relogion;

  /// No description provided for @subject_Werken.
  ///
  /// In en, this message translates to:
  /// **'Crafts'**
  String get subject_Werken;

  /// No description provided for @subject_Weltkunde.
  ///
  /// In en, this message translates to:
  /// **'World Studies'**
  String get subject_Weltkunde;

  /// No description provided for @subject_Gesellschaftswissenschaften.
  ///
  /// In en, this message translates to:
  /// **'Social Sciences'**
  String get subject_Gesellschaftswissenschaften;

  /// No description provided for @subject_Literatur.
  ///
  /// In en, this message translates to:
  /// **'Literature'**
  String get subject_Literatur;

  /// No description provided for @subject_Astrophysik.
  ///
  /// In en, this message translates to:
  /// **'Astrophysics'**
  String get subject_Astrophysik;

  /// No description provided for @subject_Staatsburgerkunde.
  ///
  /// In en, this message translates to:
  /// **'Civics'**
  String get subject_Staatsburgerkunde;

  /// No description provided for @subject_Hauswirtschaft.
  ///
  /// In en, this message translates to:
  /// **'Home Economics'**
  String get subject_Hauswirtschaft;

  /// No description provided for @subject_TechnikWerken.
  ///
  /// In en, this message translates to:
  /// **'Technology/Crafts'**
  String get subject_TechnikWerken;

  /// No description provided for @subject_IslamischeReligion.
  ///
  /// In en, this message translates to:
  /// **'Islamic Religion'**
  String get subject_IslamischeReligion;

  /// No description provided for @subject_EvangelischeReligion.
  ///
  /// In en, this message translates to:
  /// **'Protestant Religion'**
  String get subject_EvangelischeReligion;

  /// No description provided for @subject_KatholischeReligion.
  ///
  /// In en, this message translates to:
  /// **'Catholic Religion'**
  String get subject_KatholischeReligion;

  /// No description provided for @subject_Medien.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get subject_Medien;

  /// No description provided for @subject_Niederlandisch.
  ///
  /// In en, this message translates to:
  /// **'Dutch'**
  String get subject_Niederlandisch;

  /// No description provided for @subject_OrthodoxeReligion.
  ///
  /// In en, this message translates to:
  /// **'Orthodox Religion'**
  String get subject_OrthodoxeReligion;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
