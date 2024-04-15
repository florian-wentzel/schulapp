import 'package:flutter/material.dart';
import 'package:schulapp/app.dart';
import 'package:schulapp/code_behind/time_table_manager.dart';
import 'package:schulapp/code_behind/utils.dart';
import 'package:schulapp/code_behind/version_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';
import 'package:schulapp/screens/new_versions_screen.dart';
import 'package:schulapp/theme/theme_manager.dart';
import 'package:schulapp/widgets/navigation_bar_drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        title: Text(
          AppLocalizationsManager.localizations.strSettings,
        ),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return ListView(
      children: [
        _themeSelector(),
        _selectLanguage(),
        _openMainSemesterAutomatically(),
        _currentVersion(),
      ],
    );
  }

  Widget _themeSelector() {
    return listItem(
      title: AppLocalizationsManager.localizations.strTheme,
      body: [
        SegmentedButton<ThemeMode>(
          segments: <ButtonSegment<ThemeMode>>[
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              label: Text(
                AppLocalizationsManager.localizations.strDark,
              ),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.system,
              label: Text(
                AppLocalizationsManager.localizations.strSystem,
              ),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              label: Text(
                AppLocalizationsManager.localizations.strLight,
              ),
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

  Widget _selectLanguage() {
    return listItem(
      title: AppLocalizationsManager.localizations.strLanguage,
      body: [
        ElevatedButton(
          onPressed: () {
            Utils.showListSelectionBottomSheet(
              context,
              title: AppLocalizationsManager.localizations.strSelectLanguage,
              items: AppLocalizations.supportedLocales,
              itemBuilder: (itemContext, index) {
                final currLocale = AppLocalizations.supportedLocales[index];

                return Localizations.override(
                  context: itemContext,
                  locale: currLocale,
                  child: Builder(builder: (builderContext) {
                    return ListTile(
                      title: Text(
                        AppLocalizations.of(builderContext)!.language_name,
                      ),
                      onTap: () {
                        MainApp.setLocale(context, currLocale);
                        Navigator.of(itemContext).pop();
                      },
                    );
                  }),
                );
              },
            );
          },
          child: Text(AppLocalizationsManager.localizations.strChangeLanguage),
        ),
      ],
    );
  }

  Widget _openMainSemesterAutomatically() {
    return listItem(
      title: AppLocalizationsManager
          .localizations.strOpenMainSemesterAutomatically,
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
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NewVersionsScreen(
              lastUsedVersion:
                  TimetableManager().settings.lastUsedVersion ?? "",
            ),
          ),
        );
      },
      child: listItem(
        title: AppLocalizationsManager.localizations.strVersion,
        body: [
          FutureBuilder(
            future: VersionManager().getVersionString(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const LinearProgressIndicator();
              }

              String text = snapshot.data!;
              return Text(
                text,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey),
              );
            },
          ),
        ],
      ),
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
