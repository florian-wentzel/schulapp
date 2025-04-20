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
    color: const Color(0xFF8B0000),
  ),
  SchoolLessonPrefab(
    name: "Astronomie",
    color: const Color(0xFF191970),
  ),
  SchoolLessonPrefab(
    name: "Biologie",
    color: const Color(0xFF228B22),
  ),
  SchoolLessonPrefab(
    name: "Chemie",
    color: const Color(0xFF00CED1),
  ),
  SchoolLessonPrefab(
    name: "Chinesisch",
    color: const Color(0xFFDC143C),
  ),
  SchoolLessonPrefab(
    name: "Deutsch",
    color: const Color(0xFF8B4513),
  ),
  SchoolLessonPrefab(
    name: "Dt. Gebärdensprache",
    color: const Color(0xFFFFD700),
  ),
  SchoolLessonPrefab(
    name: "Englisch",
    color: const Color(0xFF1E90FF),
  ),
  SchoolLessonPrefab(
    name: "Ethik",
    color: const Color(0xFF9370DB),
  ),
  SchoolLessonPrefab(
    name: "Französisch",
    color: const Color(0xFF4169E1),
  ),
  SchoolLessonPrefab(
    name: "Geographie",
    color: const Color(0xFF2E8B57),
  ),
  SchoolLessonPrefab(
    name: "Erdkunde",
    color: const Color(0xFF2E8B57),
  ),
  SchoolLessonPrefab(
    name: "Geschichte",
    color: const Color(0xFFA0522D),
  ),
  SchoolLessonPrefab(
    name: "Sozialkunde",
    color: const Color(0xFFFF8C00),
  ),
  SchoolLessonPrefab(
    name: "Sozialpädagogik",
    color: const Color(0xFFFFA500),
  ),
  SchoolLessonPrefab(
    name: "Sozialwissenschaften",
    color: const Color(0xFFFFA07A),
  ),
  SchoolLessonPrefab(
    name: "Hebräisch",
    color: const Color(0xFF4B0082),
  ),
  SchoolLessonPrefab(
    name: "Informatik",
    color: const Color(0xFF008080),
  ),
  SchoolLessonPrefab(
    name: "Italienisch",
    color: const Color(0xFF3CB371),
  ),
  SchoolLessonPrefab(
    name: "Japanisch",
    color: const Color(0xFFFF1493),
  ),
  SchoolLessonPrefab(
    name: "Kunst",
    color: const Color(0xFFFF69B4),
  ),
  SchoolLessonPrefab(
    name: "Latein",
    color: const Color(0xFF800000),
  ),
  SchoolLessonPrefab(
    name: "LER",
    color: const Color(0xFFFFA500),
  ),
  SchoolLessonPrefab(
    name: "Mathematik",
    color: const Color(0xFF000080),
  ),
  SchoolLessonPrefab(
    name: "Musik",
    color: const Color(0xFFBA55D3),
  ),
  SchoolLessonPrefab(
    name: "Naturwissenschaften",
    color: const Color(0xFF006400),
  ),
  SchoolLessonPrefab(
    name: "Neugriechisch",
    color: const Color(0xFF800000),
  ),
  SchoolLessonPrefab(
    name: "Philosophie",
    color: const Color(0xFF708090),
  ),
  SchoolLessonPrefab(
    name: "Physik",
    color: const Color(0xFF1E90FF),
  ),
  SchoolLessonPrefab(
    name: "Politische Bildung",
    color: const Color(0xFFFF6347),
  ),
  SchoolLessonPrefab(
    name: "Polnisch",
    color: const Color(0xFFB22222),
  ),
  SchoolLessonPrefab(
    name: "Portugiesisch",
    color: const Color(0xFF32CD32),
  ),
  SchoolLessonPrefab(
    name: "Psychologie",
    color: const Color(0xFFFFB6C1),
  ),
  SchoolLessonPrefab(
    name: "Russisch",
    color: const Color(0xFF4682B4),
  ),
  SchoolLessonPrefab(
    name: "Sachunterricht",
    color: const Color(0xFF6B8E23),
  ),
  SchoolLessonPrefab(
    name: "Sorbisch-Wendisch",
    color: const Color(0xFFFF4500),
  ),
  SchoolLessonPrefab(
    name: "Soz.-/ Wirtschaftswissenschaften",
    color: const Color(0xFFFFD700),
  ),
  SchoolLessonPrefab(
    name: "Wirtschaftskunde",
    color: const Color(0xFFFFD700),
  ),
  SchoolLessonPrefab(
    name: "Spanisch",
    color: const Color(0xFFFFA500),
  ),
  SchoolLessonPrefab(
    name: "Sport",
    color: const Color(0xFF228B22),
  ),
  SchoolLessonPrefab(
    name: "Theater",
    color: const Color(0xFF8A2BE2),
  ),
  SchoolLessonPrefab(
    name: "Türkisch",
    color: const Color(0xFFFF0000),
  ),
  SchoolLessonPrefab(
    name: "W-A-T",
    color: const Color(0xFF40E0D0),
  ),
  SchoolLessonPrefab(
    name: "Darstellendes Spiel",
    color: const Color(0xFFFF1493),
  ),
  SchoolLessonPrefab(
    name: "Politikwissenschaft",
    color: const Color(0xFFFF4500),
  ),
  SchoolLessonPrefab(
    name: "Recht",
    color: const Color(0xFF808080),
  ),
  SchoolLessonPrefab(
    name: "Relogion",
    color: const Color(0xFFD3D3D3),
  ),
  SchoolLessonPrefab(
    name: "Werken",
    color: const Color(0xFFA9A9A9),
  ),
  SchoolLessonPrefab(
    name: "Weltkunde",
    color: const Color(0xFFBDB76B),
  ),
  SchoolLessonPrefab(
    name: "Gesellschaftswissenschaften",
    color: const Color(0xFFFF8C00),
  ),
  SchoolLessonPrefab(
    name: "Literatur",
    color: const Color(0xFFDAA520),
  ),
  SchoolLessonPrefab(
    name: "Astrophysik",
    color: const Color(0xFF8A2BE2),
  ),
  SchoolLessonPrefab(
    name: "Staatsbürgerkunde",
    color: const Color(0xFFFF8C00),
  ),
  SchoolLessonPrefab(
    name: "Hauswirtschaft",
    color: const Color(0xFFFFE4B5),
  ),
  SchoolLessonPrefab(
    name: "Technik / Werken",
    color: const Color(0xFF808080),
  ),
  SchoolLessonPrefab(
    name: "Islamische Religion",
    color: const Color(0xFF006400),
  ),
  SchoolLessonPrefab(
    name: "Evangelische Religion",
    color: const Color(0xFFFFFF00),
  ),
  SchoolLessonPrefab(
    name: "Katholische Religion",
    color: const Color(0xFFFFD700),
  ),
  SchoolLessonPrefab(
    name: "Medien",
    color: const Color(0xFF4682B4),
  ),
  SchoolLessonPrefab(
    name: "Niederländisch",
    color: const Color(0xFFFFA500),
  ),
  SchoolLessonPrefab(
    name: "Orthodoxe Religion",
    color: const Color(0xFF800080),
  ),
];
