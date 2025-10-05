import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

abstract class SchoolFileBase {
  /// Not Path!
  String get name;

  /// UTC
  DateTime get modifiedTime;

  @override
  String toString() {
    return "$name (Base)";
  }
}

class SchoolFile extends SchoolFileBase {
  @override
  String get name => _name;
  @override
  DateTime get modifiedTime => _modifiedTime;
  String? get driveId => _driveId;

  final String _name;
  final DateTime _modifiedTime;
  final String? _driveId;
  final FutureOr<Uint8List> Function() _contentGenerator;

  SchoolFile(
    String name, {
    required FutureOr<Uint8List> Function() contentGenerator,
    required DateTime modifiedTime,
    String? driveId,
  })  : _name = name,
        _contentGenerator = contentGenerator,
        _driveId = driveId,
        _modifiedTime = modifiedTime;

  FutureOr<Uint8List> get content => _contentGenerator();

  FutureOr<Map<String, dynamic>> getContentAsJson() async => jsonDecode(
        utf8.decode(
          await _contentGenerator(),
        ),
      );

  @override
  String toString() {
    return "$_name (File)";
  }
}

class SchoolDirectory extends SchoolFileBase {
  @override
  String get name => _name;
  @override
  DateTime get modifiedTime {
    throw "modifiedTime getter not implemented!";
  }

  UnmodifiableListView<SchoolFileBase> get children =>
      UnmodifiableListView(_children);
  String? get driveId => _driveId;

  final String _name;
  final List<SchoolFileBase> _children;
  final String? _driveId;

  SchoolDirectory(
    String name, {
    List<SchoolFileBase>? children,
    String? driveId,
  })  : _name = name,
        _children = children ?? [],
        _driveId = driveId {
    _children.sort((a, b) {
      if (a is SchoolDirectory && b is! SchoolDirectory) {
        return -1;
      } else if (a is! SchoolDirectory && b is SchoolDirectory) {
        return 1;
      } else {
        return a.name.compareTo(b.name);
      }
    });
  }

  void addChild(SchoolFileBase file) {
    _children.add(file);
  }

  SchoolFileBase? getChildByName(String name) {
    try {
      return _children.firstWhere((element) => element.name == name);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return "$name (dir) children Count: ${_children.length}";
  }
}
