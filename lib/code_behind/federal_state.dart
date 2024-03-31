//https://de.wikipedia.org/wiki/ISO_3166-2:DE
class FederalStatesList {
  static final List<FederalState> states = [
    FederalState(
      name: "Baden-Württemberg",
      officialCode: "DE-BW",
      apiCode: "BW",
    ),
    FederalState(
      name: "Bayern",
      officialCode: "DE-BY",
      apiCode: "BY",
    ),
    FederalState(
      name: "Berlin",
      officialCode: "DE-BE",
      apiCode: "BE",
    ),
    FederalState(
      name: "Brandenburg",
      officialCode: "DE-BB",
      apiCode: "BB",
    ),
    FederalState(
      name: "Bremen",
      officialCode: "DE-HB",
      apiCode: "HB",
    ),
    FederalState(
      name: "Hamburg",
      officialCode: "DE-HH",
      apiCode: "HH",
    ),
    FederalState(
      name: "Hessen",
      officialCode: "DE-HE",
      apiCode: "HE",
    ),
    FederalState(
      name: "Mecklenburg-Vorpommern",
      officialCode: "DE-MV",
      apiCode: "MV",
    ),
    FederalState(
      name: "Niedersachsen",
      officialCode: "DE-NI",
      apiCode: "NI",
    ),
    FederalState(
      name: "Nordrhein-Westfalen",
      officialCode: "DE-NW",
      apiCode: "NW",
    ),
    FederalState(
      name: "Rheinland-Pfalz",
      officialCode: "DE-RP",
      apiCode: "RP",
    ),
    FederalState(
      name: "Saarland",
      officialCode: "DE-SL",
      apiCode: "SL",
    ),
    FederalState(
      name: "Sachsen",
      officialCode: "DE-SN",
      apiCode: "SN",
    ),
    FederalState(
      name: "Sachsen-Anhalt",
      officialCode: "DE-ST",
      apiCode: "ST",
    ),
    FederalState(
      name: "Schleswig-Holstein",
      officialCode: "DE-SH",
      apiCode: "SH",
    ),
    FederalState(
      name: "Thüringen",
      officialCode: "DE-TH",
      apiCode: "TH",
    ),
  ];
}

class FederalState {
  final String _name;
  final String _officialCode;
  final String _apiCode;

  get name {
    return _name;
  }

  get officialCode {
    return _officialCode;
  }

  get apiCode {
    return _apiCode;
  }

  FederalState({
    required String name,
    required String officialCode,
    required String apiCode,
  })  : _name = name,
        _officialCode = officialCode,
        _apiCode = apiCode;
}
