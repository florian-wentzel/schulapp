import 'dart:ui';

import 'package:schulapp/code_behind/school_lesson_prefab.dart';

final List<SchoolLessonPrefab> allDefaultLessons = [
  SchoolLessonPrefab(
    name: "Altgriechisch",
    color: const Color.fromARGB(255, 128, 0, 0), // Dark Red
  ),
  SchoolLessonPrefab(
    name: "Astronomie",
    color: const Color.fromARGB(255, 25, 25, 112), // Midnight Blue
  ),
  SchoolLessonPrefab(
    name: "Biologie",
    color: const Color.fromARGB(255, 34, 139, 34), // Forest Green
  ),
  SchoolLessonPrefab(
    name: "Chemie",
    color: const Color.fromARGB(255, 0, 191, 255), // Deep Sky Blue
  ),
  SchoolLessonPrefab(
    name: "Chinesisch",
    color: const Color.fromARGB(255, 255, 69, 0), // Red-Orange
  ),
  SchoolLessonPrefab(
    name: "Deutsch",
    color: const Color.fromARGB(255, 139, 69, 19), // Saddle Brown
  ),
  SchoolLessonPrefab(
    name: "Dt. Gebärdensprache",
    color: const Color.fromARGB(255, 255, 215, 0), // Gold
  ),
  SchoolLessonPrefab(
    name: "Englisch",
    color: const Color.fromARGB(255, 70, 130, 180), // Steel Blue
  ),
  SchoolLessonPrefab(
    name: "Ethik",
    color: const Color.fromARGB(255, 128, 0, 128), // Purple
  ),
  SchoolLessonPrefab(
    name: "Französisch",
    color: const Color.fromARGB(255, 0, 0, 255), // Blue
  ),
  SchoolLessonPrefab(
    name: "Geographie",
    color: const Color.fromARGB(255, 46, 139, 87), // Sea Green
  ),
  SchoolLessonPrefab(
    name: "Geschichte",
    color: const Color.fromARGB(255, 160, 82, 45), // Sienna
  ),
  SchoolLessonPrefab(
    name: "Gesellschaftswissenschaften",
    color: const Color.fromARGB(255, 255, 140, 0), // Dark Orange
  ),
  SchoolLessonPrefab(
    name: "Hebräisch",
    color: const Color.fromARGB(255, 75, 0, 130), // Indigo
  ),
  SchoolLessonPrefab(
    name: "Informatik",
    color: const Color.fromARGB(255, 0, 128, 128), // Teal
  ),
  SchoolLessonPrefab(
    name: "Italienisch",
    color: const Color.fromARGB(255, 0, 255, 127), // Spring Green
  ),
  SchoolLessonPrefab(
    name: "Japanisch",
    color: const Color.fromARGB(255, 255, 20, 147), // Deep Pink
  ),
  SchoolLessonPrefab(
    name: "Kunst",
    color: const Color.fromARGB(255, 255, 105, 180), // Hot Pink
  ),
  SchoolLessonPrefab(
    name: "Latein",
    color: const Color.fromARGB(255, 139, 0, 0), // Dark Red
  ),
  SchoolLessonPrefab(
    name: "LER",
    color: const Color.fromARGB(255, 255, 165, 0), // Orange
  ),
  SchoolLessonPrefab(
    name: "Mathematik",
    color: const Color.fromARGB(255, 0, 0, 128), // Navy
  ),
  SchoolLessonPrefab(
    name: "Musik",
    color: const Color.fromARGB(255, 186, 85, 211), // Medium Orchid
  ),
  SchoolLessonPrefab(
    name: "Naturwissenschaften",
    color: const Color.fromARGB(255, 0, 100, 0), // Dark Green
  ),
  SchoolLessonPrefab(
    name: "Neugriechisch",
    color: const Color.fromARGB(255, 128, 0, 0), // Maroon
  ),
  SchoolLessonPrefab(
    name: "Philosophie",
    color: const Color.fromARGB(255, 112, 128, 144), // Slate Gray
  ),
  SchoolLessonPrefab(
    name: "Physik",
    color: const Color.fromARGB(255, 30, 144, 255), // Dodger Blue
  ),
  SchoolLessonPrefab(
    name: "Politische Bildung",
    color: const Color.fromARGB(255, 255, 99, 71), // Tomato
  ),
  SchoolLessonPrefab(
    name: "Polnisch",
    color: const Color.fromARGB(255, 220, 20, 60), // Crimson
  ),
  SchoolLessonPrefab(
    name: "Portugiesisch",
    color: const Color.fromARGB(255, 0, 255, 0), // Lime
  ),
  SchoolLessonPrefab(
    name: "Psychologie",
    color: const Color.fromARGB(255, 255, 182, 193), // Light Pink
  ),
  SchoolLessonPrefab(
    name: "Russisch",
    color: const Color.fromARGB(255, 0, 191, 255), // Deep Sky Blue
  ),
  SchoolLessonPrefab(
    name: "Sachunterricht",
    color: const Color.fromARGB(255, 85, 107, 47), // Dark Olive Green
  ),
  SchoolLessonPrefab(
    name: "Sorbisch-Wendisch",
    color: const Color.fromARGB(255, 255, 69, 0), // Red-Orange
  ),
  SchoolLessonPrefab(
    name: "Soz.-/ Wirtschaftswissenschaften",
    color: const Color.fromARGB(255, 255, 215, 0), // Gold
  ),
  SchoolLessonPrefab(
    name: "Spanisch",
    color: const Color.fromARGB(255, 255, 140, 0), // Dark Orange
  ),
  SchoolLessonPrefab(
    name: "Sport",
    color: const Color.fromARGB(255, 0, 128, 0), // Green
  ),
  SchoolLessonPrefab(
    name: "Theater",
    color: const Color.fromARGB(255, 138, 43, 226), // Blue Violet
  ),
  SchoolLessonPrefab(
    name: "Türkisch",
    color: const Color.fromARGB(255, 255, 0, 0), // Red
  ),
  SchoolLessonPrefab(
    name: "W-A-T",
    color: const Color.fromARGB(255, 0, 255, 255), // Cyan
  ),
  SchoolLessonPrefab(
    name: "Darstellendes Spiel",
    color: const Color.fromARGB(255, 255, 20, 147), // Deep Pink
  ),
  SchoolLessonPrefab(
    name: "Politikwissenschaft",
    color: const Color.fromARGB(255, 255, 69, 0), // Red-Orange
  ),
  SchoolLessonPrefab(
    name: "Recht",
    color: const Color.fromARGB(255, 128, 128, 128), // Gray
  ),
  SchoolLessonPrefab(
    name: "",
    color: const Color.fromARGB(255, 211, 211, 211), // Light Gray
  ),
];
