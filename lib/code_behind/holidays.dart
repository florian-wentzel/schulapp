//https://ferien-api.de/

class Holidays {
  static const custom = "custom";

  final DateTime _start; //ISO8601 (UTC)	Ferienbeginn
  final DateTime _end; // ISO8601 (UTC)	Ferienende
  final String _stateCode; //	Zweistelliger Code des Bundeslandes
  final String _name; //Name der Schulferien
  final String _slug; //Kombination aus Ferienname, Jahr und Bundesland

  DateTime get start => _start;
  DateTime get end => _end;
  String get stateCode => _stateCode;
  String get name => _name;
  String get slug => _slug;

  Holidays({
    required DateTime start,
    required DateTime end,
    required String name,
    String stateCode = custom,
    String slug = custom,
  })  : _slug = slug,
        _name = name,
        _stateCode = stateCode,
        _end = end,
        _start = start;
}
