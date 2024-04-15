import 'package:flutter/material.dart';
import 'package:schulapp/code_behind/version_manager.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

// ignore: must_be_immutable
class NewVersionsScreen extends StatefulWidget {
  String lastUsedVersion;

  NewVersionsScreen({
    super.key,
    required this.lastUsedVersion,
  });

  @override
  State<NewVersionsScreen> createState() => _NewVersionsScreenState();
}

class _NewVersionsScreenState extends State<NewVersionsScreen> {
  List<(String, String)> versionsToShow = [];

  @override
  Widget build(BuildContext context) {
    _updateVersionsToShow();
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizationsManager.localizations.strVersions),
      ),
      body: _body(),
    );
  }

  Widget _body() {
    return ListView.builder(
      prototypeItem: const ListTile(
        title: Text(""),
        subtitle: Text(""),
      ),
      itemCount: VersionHolder.versions.keys.length,
      itemBuilder: (context, index) {
        String version = VersionHolder.versions.keys.elementAt(index);
        String? description = VersionHolder.getVersionInfo(version);
        description ??= "";

        bool selected =
            VersionManager.compareVersions(widget.lastUsedVersion, version) ==
                -1;

        return ListTile(
          selected: selected,
          title: Text(version),
          subtitle: Text(description),
        );
      },
    );
  }

  Future<void> _updateVersionsToShow() async {
    versionsToShow.clear();

    for (int i = 0; i < VersionHolder.versions.keys.length; i++) {
      String version = VersionHolder.versions.keys.elementAt(i);
      final compareedVersions =
          VersionManager.compareVersions(widget.lastUsedVersion, version);

      if (compareedVersions < 0) {
        String? description = VersionHolder.getVersionInfo(version);

        if (description == null) continue;

        versionsToShow.add((version, description));
      }
    }

    if (mounted) {
      setState(() {});
    }
  }
}
