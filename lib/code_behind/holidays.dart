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

  String getFormattedName() {
    //ist ein Feiertag also nichts mit dem Namen machen
    if (slug.isEmpty) {
      return name;
    }

    if (slug == Holidays.custom || stateCode == Holidays.custom) {
      return name;
    }
    List<String> words = name.split(" ");
    return _capitalizeWords(words.first);
  }

  String _capitalizeWords(String input) {
    // Split the input string into words
    List<String> words = input.split(' ');

    // Capitalize the first letter of each word
    List<String> capitalizedWords = words.map((word) {
      if (word.isEmpty) {
        return word; // If the word is empty, return it as is
      } else {
        // Capitalize the first letter of the word and concatenate with the rest
        return word[0].toUpperCase() + word.substring(1);
      }
    }).toList();

    // Join the capitalized words back into a single string
    return capitalizedWords.join(' ');
  }
}
