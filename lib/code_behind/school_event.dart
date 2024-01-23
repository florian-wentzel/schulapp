abstract class SchoolEvent {
  static const String _nameKey = "name";
  static const String _linkedSubjectNameKey = "linkedSubjectName";
  static const int maxNameLength = 25;

  //identifyer set at runtime
  int _key;
  final String _name;
  // final DateTime createDate;
  // final DateTime laseEditDate;
  final String _linkedSubjectName;

  int get key {
    return _key;
  }

  set key(int value) {
    _key = value;
  }

  String get name {
    return _name;
  }

  SchoolEvent({
    required int key,
    required String name,
    required String linkedSubjectName,
  })  : _key = key,
        _linkedSubjectName = linkedSubjectName,
        _name = name;

  Map<String, dynamic> toJson() {
    return {
      _nameKey: _name,
      _linkedSubjectNameKey: _linkedSubjectName,
    };
  }

  SchoolEvent fromJson();
}

enum TodoType {
  exam,
  test,
  homework,
}

class TodoEvent extends SchoolEvent {
  DateTime endTime;
  TodoType type;

  String desciption;
  bool finished;

  static const int maxDescriptionLength = 150;

  TodoEvent({
    required super.key,
    required super.name,
    required super.linkedSubjectName,
    required this.endTime,
    required this.type,
    required this.desciption,
    required this.finished,
  });

  @override
  SchoolEvent fromJson() {
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}
