import 'dart:ui';

import 'package:schulapp/code_behind/school_lesson_prefab.dart';

final List<SchoolLessonPrefab> allDefaultLessons = [
  SchoolLessonPrefab(
    name: "Altgriechisch",
    color: const Color.fromARGB(255, 153, 51, 51),
  ),
  SchoolLessonPrefab(
    name: "Astronomie",
    color: const Color.fromARGB(255, 25, 25, 112),
  ),
  SchoolLessonPrefab(
    name: "Biologie",
    color: const Color.fromARGB(255, 34, 139, 34),
  ),
  SchoolLessonPrefab(
    name: "Chemie",
    color: const Color.fromARGB(255, 0, 191, 255),
  ),
  SchoolLessonPrefab(
    name: "Chinesisch",
    color: const Color.fromARGB(255, 255, 87, 34),
  ),
  SchoolLessonPrefab(
    name: "Deutsch",
    color: const Color.fromARGB(255, 139, 69, 19),
  ),
  SchoolLessonPrefab(
    name: "Dt. Gebärdensprache",
    color: const Color.fromARGB(255, 255, 223, 0),
  ),
  SchoolLessonPrefab(
    name: "Englisch",
    color: const Color.fromARGB(255, 70, 130, 180),
  ),
  SchoolLessonPrefab(
    name: "Ethik",
    color: const Color.fromARGB(255, 128, 0, 128),
  ),
  SchoolLessonPrefab(
    name: "Französisch",
    color: const Color.fromARGB(255, 0, 0, 255),
  ),
  SchoolLessonPrefab(
    name: "Geographie",
    color: const Color.fromARGB(255, 46, 139, 87),
  ),
  SchoolLessonPrefab(
    name: "Erdkunde",
    color: const Color.fromARGB(255, 46, 139, 87),
  ),
  SchoolLessonPrefab(
    name: "Geschichte",
    color: const Color.fromARGB(255, 160, 82, 45),
  ),
  SchoolLessonPrefab(
    name: "Sozialkunde",
    color: const Color.fromARGB(255, 255, 140, 0),
  ),
  SchoolLessonPrefab(
    name: "Sozialpädagogik",
    color: const Color.fromARGB(255, 255, 165, 0),
  ),
  SchoolLessonPrefab(
    name: "Sozialwissenschaften",
    color: const Color.fromARGB(255, 255, 140, 0),
  ),
  SchoolLessonPrefab(
    name: "Hebräisch",
    color: const Color.fromARGB(255, 75, 0, 130),
  ),
  SchoolLessonPrefab(
    name: "Informatik",
    color: const Color.fromARGB(255, 0, 128, 128),
  ),
  SchoolLessonPrefab(
    name: "Italienisch",
    color: const Color.fromARGB(255, 0, 255, 127),
  ),
  SchoolLessonPrefab(
    name: "Japanisch",
    color: const Color.fromARGB(255, 255, 20, 147),
  ),
  SchoolLessonPrefab(
    name: "Kunst",
    color: const Color.fromARGB(255, 255, 105, 180),
  ),
  SchoolLessonPrefab(
    name: "Latein",
    color: const Color.fromARGB(255, 139, 0, 0),
  ),
  SchoolLessonPrefab(
    name: "LER",
    color: const Color.fromARGB(255, 255, 165, 0),
  ),
  SchoolLessonPrefab(
    name: "Mathematik",
    color: const Color.fromARGB(255, 0, 0, 128),
  ),
  SchoolLessonPrefab(
    name: "Musik",
    color: const Color.fromARGB(255, 186, 85, 211),
  ),
  SchoolLessonPrefab(
    name: "Naturwissenschaften",
    color: const Color.fromARGB(255, 0, 100, 0),
  ),
  SchoolLessonPrefab(
    name: "Neugriechisch",
    color: const Color.fromARGB(255, 128, 0, 0),
  ),
  SchoolLessonPrefab(
    name: "Philosophie",
    color: const Color.fromARGB(255, 112, 128, 144),
  ),
  SchoolLessonPrefab(
    name: "Physik",
    color: const Color.fromARGB(255, 30, 144, 255),
  ),
  SchoolLessonPrefab(
    name: "Politische Bildung",
    color: const Color.fromARGB(255, 255, 99, 71),
  ),
  SchoolLessonPrefab(
    name: "Polnisch",
    color: const Color.fromARGB(255, 220, 20, 60),
  ),
  SchoolLessonPrefab(
    name: "Portugiesisch",
    color: const Color.fromARGB(255, 0, 255, 0),
  ),
  SchoolLessonPrefab(
    name: "Psychologie",
    color: const Color.fromARGB(255, 255, 182, 193),
  ),
  SchoolLessonPrefab(
    name: "Russisch",
    color: const Color.fromARGB(255, 0, 191, 255),
  ),
  SchoolLessonPrefab(
    name: "Sachunterricht",
    color: const Color.fromARGB(255, 85, 107, 47),
  ),
  SchoolLessonPrefab(
    name: "Sorbisch-Wendisch",
    color: const Color.fromARGB(255, 255, 69, 0),
  ),
  SchoolLessonPrefab(
    name: "Soz.-/ Wirtschaftswissenschaften",
    color: const Color.fromARGB(255, 255, 215, 0),
  ),
  SchoolLessonPrefab(
    name: "Wirtschaftskunde",
    color: const Color.fromARGB(255, 255, 223, 0),
  ),
  SchoolLessonPrefab(
    name: "Spanisch",
    color: const Color.fromARGB(255, 255, 140, 0),
  ),
  SchoolLessonPrefab(
    name: "Sport",
    color: const Color.fromARGB(255, 0, 128, 0),
  ),
  SchoolLessonPrefab(
    name: "Theater",
    color: const Color.fromARGB(255, 138, 43, 226),
  ),
  SchoolLessonPrefab(
    name: "Türkisch",
    color: const Color.fromARGB(255, 255, 0, 0),
  ),
  SchoolLessonPrefab(
    name: "W-A-T",
    color: const Color.fromARGB(255, 0, 255, 255),
  ),
  SchoolLessonPrefab(
    name: "Darstellendes Spiel",
    color: const Color.fromARGB(255, 255, 20, 147),
  ),
  SchoolLessonPrefab(
    name: "Politikwissenschaft",
    color: const Color.fromARGB(255, 255, 69, 0),
  ),
  SchoolLessonPrefab(
    name: "Recht",
    color: const Color.fromARGB(255, 128, 128, 128),
  ),
  SchoolLessonPrefab(
    name: "Relogion",
    color: const Color.fromARGB(255, 211, 211, 211),
  ),
  SchoolLessonPrefab(
    name: "Werken",
    color: const Color.fromARGB(255, 211, 211, 211),
  ),
  SchoolLessonPrefab(
    name: "Weltkunde",
    color: const Color.fromARGB(255, 211, 211, 211),
  ),
  SchoolLessonPrefab(
    name: "Gesellschaftswissenschaften",
    color: const Color.fromARGB(255, 255, 140, 0),
  ),
  SchoolLessonPrefab(
    name: "Literatur",
    color: const Color.fromARGB(255, 255, 140, 0),
  ),
  SchoolLessonPrefab(
    name: "Astronomie",
    color: const Color.fromARGB(255, 25, 25, 112),
  ),
  SchoolLessonPrefab(
    name: "Astrophysik",
    color: const Color.fromARGB(255, 255, 140, 0),
  ),
  SchoolLessonPrefab(
    name: "Informatik",
    color: const Color.fromARGB(255, 255, 140, 0),
  ),
  SchoolLessonPrefab(
    name: "Philosophie",
    color: const Color.fromARGB(255, 255, 140, 0),
  ),
  SchoolLessonPrefab(
    name: "Staatsbürgerkunde",
    color: const Color.fromARGB(255, 255, 140, 0),
  ),
  SchoolLessonPrefab(
    name: "Psychologie",
    color: const Color.fromARGB(255, 255, 140, 0),
  ),
  SchoolLessonPrefab(
    name: "Hauswirtschaft",
    color: const Color.fromARGB(255, 255, 228, 181),
  ),
  SchoolLessonPrefab(
    name: "Technik / Werken",
    color: const Color.fromARGB(255, 169, 169, 169),
  ),
  SchoolLessonPrefab(
    name: "Islamische Religion",
    color: const Color.fromARGB(255, 0, 128, 0),
  ),
  SchoolLessonPrefab(
    name: "Evangelische Religion",
    color: const Color.fromARGB(255, 255, 255, 0),
  ),
  SchoolLessonPrefab(
    name: "Katholische Religion",
    color: const Color.fromARGB(255, 255, 215, 0),
  ),
  SchoolLessonPrefab(
    name: "Medien",
    color: const Color.fromARGB(255, 70, 130, 180),
  ),
  SchoolLessonPrefab(
    name: "Niederländisch",
    color: const Color.fromARGB(255, 255, 165, 0),
  ),
  SchoolLessonPrefab(
    name: "Orthodoxe Religion",
    color: const Color.fromARGB(255, 128, 0, 128),
  ),
];
