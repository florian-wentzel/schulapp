import 'dart:collection';
import 'dart:typed_data';

abstract class SchoolFileBase {
  String get name;
}

class SchoolFile extends SchoolFileBase {
  @override
  String get name => _name;
  String? get driveId => _driveId;

  final String? _driveId;
  final String _name;
  final Uint8List Function() _contentGenerator;

  SchoolFile(
    String name, {
    required Uint8List Function() contentGenerator,
    String? driveId,
  })  : _name = name,
        _contentGenerator = contentGenerator,
        _driveId = driveId;

  Uint8List get content => _contentGenerator();

  @override
  String toString() {
    return "$_name (File)";
  }
}

class SchoolDirectory extends SchoolFileBase {
  @override
  String get name => _name;
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
