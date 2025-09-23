import 'dart:ui';

import 'package:schulapp/code_behind/school_lesson_prefab.dart';

List<SchoolLessonPrefab> get allDefaultLessons {
  _allDefaultLessons.sort(
    (a, b) => a.name.compareTo(b.name),
  );
  return _allDefaultLessons;
}

final List<SchoolLessonPrefab> _allDefaultLessons = [
  SchoolLessonPrefab(
    name: "Altgriechisch",
    localizationKey: "subject_Altgriechisch",
    color: const Color(0xFF8B0000),
  ),
  SchoolLessonPrefab(
    name: "Astronomie",
    localizationKey: "subject_Astronomie",
    color: const Color(0xFF191970),
  ),
  SchoolLessonPrefab(
    name: "Biologie",
    localizationKey: "subject_Biologie",
    color: const Color(0xFF228B22),
  ),
  SchoolLessonPrefab(
    name: "Chemie",
    localizationKey: "subject_Chemie",
    color: const Color(0xFF00CED1),
  ),
  SchoolLessonPrefab(
    name: "Chinesisch",
    localizationKey: "subject_Chinesisch",
    color: const Color(0xFFDC143C),
  ),
  SchoolLessonPrefab(
    name: "Deutsch",
    localizationKey: "subject_Deutsch",
    color: const Color(0xFF8B4513),
  ),
  SchoolLessonPrefab(
    name: "Dt. Gebärdensprache",
    localizationKey: "subject_DtGebardensprache",
    color: const Color(0xFFFFD700),
  ),
  SchoolLessonPrefab(
    name: "Englisch",
    localizationKey: "subject_Englisch",
    color: const Color(0xFF1E90FF),
  ),
  SchoolLessonPrefab(
    name: "Ethik",
    localizationKey: "subject_Ethik",
    color: const Color(0xFF9370DB),
  ),
  SchoolLessonPrefab(
    name: "Französisch",
    localizationKey: "subject_Franzosisch",
    color: const Color(0xFF4169E1),
  ),
  SchoolLessonPrefab(
    name: "Geographie",
    localizationKey: "subject_Geographie",
    color: const Color(0xFF2E8B57),
  ),
  SchoolLessonPrefab(
    name: "Erdkunde",
    localizationKey: "subject_Erdkunde",
    color: const Color(0xFF2E8B57),
  ),
  SchoolLessonPrefab(
    name: "Geschichte",
    localizationKey: "subject_Geschichte",
    color: const Color(0xFFA0522D),
  ),
  SchoolLessonPrefab(
    name: "Sozialkunde",
    localizationKey: "subject_Sozialkunde",
    color: const Color(0xFFFF8C00),
  ),
  SchoolLessonPrefab(
    name: "Sozialpädagogik",
    localizationKey: "subject_Sozialpadagogik",
    color: const Color(0xFFFFA500),
  ),
  SchoolLessonPrefab(
    name: "Sozialwissenschaften",
    localizationKey: "subject_Sozialwissenschaften",
    color: const Color(0xFFFFA07A),
  ),
  SchoolLessonPrefab(
    name: "Hebräisch",
    localizationKey: "subject_Hebraisch",
    color: const Color(0xFF4B0082),
  ),
  SchoolLessonPrefab(
    name: "Informatik",
    localizationKey: "subject_Informatik",
    color: const Color(0xFF008080),
  ),
  SchoolLessonPrefab(
    name: "Italienisch",
    localizationKey: "subject_Italienisch",
    color: const Color(0xFF3CB371),
  ),
  SchoolLessonPrefab(
    name: "Japanisch",
    localizationKey: "subject_Japanisch",
    color: const Color(0xFFFF1493),
  ),
  SchoolLessonPrefab(
    name: "Kunst",
    localizationKey: "subject_Kunst",
    color: const Color(0xFFFF69B4),
  ),
  SchoolLessonPrefab(
    name: "Latein",
    localizationKey: "subject_Latein",
    color: const Color(0xFF800000),
  ),
  SchoolLessonPrefab(
    name: "LER",
    localizationKey: "subject_LER",
    color: const Color(0xFFFFA500),
  ),
  SchoolLessonPrefab(
    name: "Mathematik",
    localizationKey: "subject_Mathematik",
    color: const Color(0xFF000080),
  ),
  SchoolLessonPrefab(
    name: "Musik",
    localizationKey: "subject_Musik",
    color: const Color(0xFFBA55D3),
  ),
  SchoolLessonPrefab(
    name: "Naturwissenschaften",
    localizationKey: "subject_Naturwissenschaften",
    color: const Color(0xFF006400),
  ),
  SchoolLessonPrefab(
    name: "Neugriechisch",
    localizationKey: "subject_Neugriechisch",
    color: const Color(0xFF800000),
  ),
  SchoolLessonPrefab(
    name: "Philosophie",
    localizationKey: "subject_Philosophie",
    color: const Color(0xFF708090),
  ),
  SchoolLessonPrefab(
    name: "Physik",
    localizationKey: "subject_Physik",
    color: const Color(0xFF1E90FF),
  ),
  SchoolLessonPrefab(
    name: "Politische Bildung",
    localizationKey: "subject_PolitischeBildung",
    color: const Color(0xFFFF6347),
  ),
  SchoolLessonPrefab(
    name: "Polnisch",
    localizationKey: "subject_Polnisch",
    color: const Color(0xFFB22222),
  ),
  SchoolLessonPrefab(
    name: "Portugiesisch",
    localizationKey: "subject_Portugiesisch",
    color: const Color(0xFF32CD32),
  ),
  SchoolLessonPrefab(
    name: "Psychologie",
    localizationKey: "subject_Psychologie",
    color: const Color(0xFFFFB6C1),
  ),
  SchoolLessonPrefab(
    name: "Russisch",
    localizationKey: "subject_Russisch",
    color: const Color(0xFF4682B4),
  ),
  SchoolLessonPrefab(
    name: "Sachunterricht",
    localizationKey: "subject_Sachunterricht",
    color: const Color(0xFF6B8E23),
  ),
  SchoolLessonPrefab(
    name: "Sorbisch-Wendisch",
    localizationKey: "subject_SorbischWendisch",
    color: const Color(0xFFFF4500),
  ),
  SchoolLessonPrefab(
    name: "Soz.-/ Wirtschaftswissenschaften",
    localizationKey: "subject_SozWirtschaftswissenschaften",
    color: const Color(0xFFFFD700),
  ),
  SchoolLessonPrefab(
    name: "Wirtschaftskunde",
    localizationKey: "subject_Wirtschaftskunde",
    color: const Color(0xFFFFD700),
  ),
  SchoolLessonPrefab(
    name: "Spanisch",
    localizationKey: "subject_Spanisch",
    color: const Color(0xFFFFA500),
  ),
  SchoolLessonPrefab(
    name: "Sport",
    localizationKey: "subject_Sport",
    color: const Color(0xFF228B22),
  ),
  SchoolLessonPrefab(
    name: "Theater",
    localizationKey: "subject_Theater",
    color: const Color(0xFF8A2BE2),
  ),
  SchoolLessonPrefab(
    name: "Türkisch",
    localizationKey: "subject_Turkisch",
    color: const Color(0xFFFF0000),
  ),
  SchoolLessonPrefab(
    name: "W-A-T",
    localizationKey: "subject_WAT",
    color: const Color(0xFF40E0D0),
  ),
  SchoolLessonPrefab(
    name: "Darstellendes Spiel",
    localizationKey: "subject_DarstellendesSpiel",
    color: const Color(0xFFFF1493),
  ),
  SchoolLessonPrefab(
    name: "Politikwissenschaft",
    localizationKey: "subject_Politikwissenschaft",
    color: const Color(0xFFFF4500),
  ),
  SchoolLessonPrefab(
    name: "Recht",
    localizationKey: "subject_Recht",
    color: const Color(0xFF808080),
  ),
  SchoolLessonPrefab(
    name: "Relogion",
    localizationKey: "subject_Relogion",
    color: const Color(0xFFD3D3D3),
  ),
  SchoolLessonPrefab(
    name: "Werken",
    localizationKey: "subject_Werken",
    color: const Color(0xFFA9A9A9),
  ),
  SchoolLessonPrefab(
    name: "Weltkunde",
    localizationKey: "subject_Weltkunde",
    color: const Color(0xFFBDB76B),
  ),
  SchoolLessonPrefab(
    name: "Gesellschaftswissenschaften",
    localizationKey: "subject_Gesellschaftswissenschaften",
    color: const Color(0xFFFF8C00),
  ),
  SchoolLessonPrefab(
    name: "Literatur",
    localizationKey: "subject_Literatur",
    color: const Color(0xFFDAA520),
  ),
  SchoolLessonPrefab(
    name: "Astrophysik",
    localizationKey: "subject_Astrophysik",
    color: const Color(0xFF8A2BE2),
  ),
  SchoolLessonPrefab(
    name: "Staatsbürgerkunde",
    localizationKey: "subject_Staatsburgerkunde",
    color: const Color(0xFFFF8C00),
  ),
  SchoolLessonPrefab(
    name: "Hauswirtschaft",
    localizationKey: "subject_Hauswirtschaft",
    color: const Color(0xFFFFE4B5),
  ),
  SchoolLessonPrefab(
    name: "Technik / Werken",
    localizationKey: "subject_TechnikWerken",
    color: const Color(0xFF808080),
  ),
  SchoolLessonPrefab(
    name: "Islamische Religion",
    localizationKey: "subject_IslamischeReligion",
    color: const Color(0xFF006400),
  ),
  SchoolLessonPrefab(
    name: "Evangelische Religion",
    localizationKey: "subject_EvangelischeReligion",
    color: const Color(0xFFFFFF00),
  ),
  SchoolLessonPrefab(
    name: "Katholische Religion",
    localizationKey: "subject_KatholischeReligion",
    color: const Color(0xFFFFD700),
  ),
  SchoolLessonPrefab(
    name: "Medien",
    localizationKey: "subject_Medien",
    color: const Color(0xFF4682B4),
  ),
  SchoolLessonPrefab(
    name: "Niederländisch",
    localizationKey: "subject_Niederlandisch",
    color: const Color(0xFFFFA500),
  ),
  SchoolLessonPrefab(
    name: "Orthodoxe Religion",
    localizationKey: "subject_OrthodoxeReligion",
    color: const Color(0xFF800080),
  ),
];
