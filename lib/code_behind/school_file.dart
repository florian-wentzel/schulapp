import 'dart:collection';
import 'dart:typed_data';

abstract class SchoolFileBase {
  /// Not Path!
  String get name;

  /// UTC
  DateTime get modifiedTime;
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
  final Uint8List Function() _contentGenerator;

  SchoolFile(
    String name, {
    required Uint8List Function() contentGenerator,
    required DateTime modifiedTime,
    String? driveId,
  })  : _name = name,
        _contentGenerator = contentGenerator,
        _driveId = driveId,
        _modifiedTime = modifiedTime;

  Uint8List get content => _contentGenerator();

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

  final String _name;
  final List<SchoolFileBase> _children;

  SchoolDirectory(
    String name, {
    List<SchoolFileBase>? children,
  })  : _name = name,
        _children = children ?? [];

  void addChild(SchoolFileBase file) {
    _children.add(file);
  }

  @override
  String toString() {
    return "$name (dir) children Count: ${_children.length}";
  }
}
