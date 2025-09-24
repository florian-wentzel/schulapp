import 'dart:ui';

import 'package:schulapp/code_behind/school_lesson_prefab.dart';
import 'package:schulapp/l10n/app_localizations_manager.dart';

List<SchoolLessonPrefab> get allDefaultLessons {
  if (_allDefaultLessons.isEmpty) {
    _createDefaultLessons();
  }
  _allDefaultLessons.sort(
    (a, b) => a.name.compareTo(b.name),
  );
  return _allDefaultLessons;
}

final List<SchoolLessonPrefab> _allDefaultLessons = [];

void _createDefaultLessons() {
  final loc = AppLocalizationsManager.localizations;
  _allDefaultLessons.addAll([
    SchoolLessonPrefab(
      name: loc.subject_ancient_greek,
      color: const Color(0xFF8B0000),
    ),
    SchoolLessonPrefab(
      name: loc.subject_astronomy,
      color: const Color(0xFF191970),
    ),
    SchoolLessonPrefab(
      name: loc.subject_biology,
      color: const Color(0xFF228B22),
    ),
    SchoolLessonPrefab(
      name: loc.subject_chemistry,
      color: const Color(0xFF00CED1),
    ),
    SchoolLessonPrefab(
      name: loc.subject_chinese,
      color: const Color(0xFFDC143C),
    ),
    SchoolLessonPrefab(
      name: loc.subject_german,
      color: const Color(0xFF8B4513),
    ),
    SchoolLessonPrefab(
      name: loc.subject_german_sign_language,
      color: const Color(0xFFFFD700),
    ),
    SchoolLessonPrefab(
      name: loc.subject_english,
      color: const Color(0xFF1E90FF),
    ),
    SchoolLessonPrefab(
      name: loc.subject_ethics,
      color: const Color(0xFF9370DB),
    ),
    SchoolLessonPrefab(
      name: loc.subject_french,
      color: const Color(0xFF4169E1),
    ),
    SchoolLessonPrefab(
      name: loc.subject_geography,
      color: const Color(0xFF2E8B57),
    ),
    SchoolLessonPrefab(
      name: loc.subject_geography,
      color: const Color(0xFF2E8B57),
    ),
    SchoolLessonPrefab(
      name: loc.subject_history,
      color: const Color(0xFFA0522D),
    ),
    SchoolLessonPrefab(
      name: loc.subject_social_studies,
      color: const Color(0xFFFF8C00),
    ),
    SchoolLessonPrefab(
      name: loc.subject_social_pedagogy,
      color: const Color(0xFFFFA500),
    ),
    SchoolLessonPrefab(
      name: loc.subject_social_sciences,
      color: const Color(0xFFFFA07A),
    ),
    SchoolLessonPrefab(
      name: loc.subject_hebrew,
      color: const Color(0xFF4B0082),
    ),
    SchoolLessonPrefab(
      name: loc.subject_computer_science,
      color: const Color(0xFF008080),
    ),
    SchoolLessonPrefab(
      name: loc.subject_italian,
      color: const Color(0xFF3CB371),
    ),
    SchoolLessonPrefab(
      name: loc.subject_japanese,
      color: const Color(0xFFFF1493),
    ),
    SchoolLessonPrefab(
      name: loc.subject_art,
      color: const Color(0xFFFF69B4),
    ),
    SchoolLessonPrefab(
      name: loc.subject_latin,
      color: const Color(0xFF800000),
    ),
    SchoolLessonPrefab(
      name: loc.subject_ler,
      color: const Color(0xFFFFA500),
    ),
    SchoolLessonPrefab(
      name: loc.subject_mathematics,
      color: const Color(0xFF000080),
    ),
    SchoolLessonPrefab(
      name: loc.subject_music,
      color: const Color(0xFFBA55D3),
    ),
    SchoolLessonPrefab(
      name: loc.subject_natural_sciences,
      color: const Color(0xFF006400),
    ),
    SchoolLessonPrefab(
      name: loc.subject_modern_greek,
      color: const Color(0xFF800000),
    ),
    SchoolLessonPrefab(
      name: loc.subject_philosophy,
      color: const Color(0xFF708090),
    ),
    SchoolLessonPrefab(
      name: loc.subject_physics,
      color: const Color(0xFF1E90FF),
    ),
    SchoolLessonPrefab(
      name: loc.subject_political_education,
      color: const Color(0xFFFF6347),
    ),
    SchoolLessonPrefab(
      name: loc.subject_polish,
      color: const Color(0xFFB22222),
    ),
    SchoolLessonPrefab(
      name: loc.subject_portuguese,
      color: const Color(0xFF32CD32),
    ),
    SchoolLessonPrefab(
      name: loc.subject_psychology,
      color: const Color(0xFFFFB6C1),
    ),
    SchoolLessonPrefab(
      name: loc.subject_russian,
      color: const Color(0xFF4682B4),
    ),
    SchoolLessonPrefab(
      name: loc.subject_general_studies,
      color: const Color(0xFF6B8E23),
    ),
    SchoolLessonPrefab(
      name: loc.subject_sorbian,
      color: const Color(0xFFFF4500),
    ),
    SchoolLessonPrefab(
      name: loc.subject_social_economic_sciences,
      color: const Color(0xFFFFD700),
    ),
    SchoolLessonPrefab(
      name: loc.subject_economics,
      color: const Color(0xFFFFD700),
    ),
    SchoolLessonPrefab(
      name: loc.subject_spanish,
      color: const Color(0xFFFFA500),
    ),
    SchoolLessonPrefab(
      name: loc.subject_sports,
      color: const Color(0xFF228B22),
    ),
    SchoolLessonPrefab(
      name: loc.subject_theater,
      color: const Color(0xFF8A2BE2),
    ),
    SchoolLessonPrefab(
      name: loc.subject_turkish,
      color: const Color(0xFFFF0000),
    ),
    SchoolLessonPrefab(
      name: loc.subject_w_a_t,
      color: const Color(0xFF40E0D0),
    ),
    SchoolLessonPrefab(
      name: loc.subject_performing_arts,
      color: const Color(0xFFFF1493),
    ),
    SchoolLessonPrefab(
      name: loc.subject_political_science,
      color: const Color(0xFFFF4500),
    ),
    SchoolLessonPrefab(
      name: loc.subject_law,
      color: const Color(0xFF808080),
    ),
    SchoolLessonPrefab(
      name: loc.subject_religion,
      color: const Color(0xFFD3D3D3),
    ),
    SchoolLessonPrefab(
      name: loc.subject_crafts,
      color: const Color(0xFFA9A9A9),
    ),
    SchoolLessonPrefab(
      name: loc.subject_world_studies,
      color: const Color(0xFFBDB76B),
    ),
    SchoolLessonPrefab(
      name: loc.subject_social_sciences,
      color: const Color(0xFFFF8C00),
    ),
    SchoolLessonPrefab(
      name: loc.subject_literature,
      color: const Color(0xFFDAA520),
    ),
    SchoolLessonPrefab(
      name: loc.subject_astrophysics,
      color: const Color(0xFF8A2BE2),
    ),
    SchoolLessonPrefab(
      name: loc.subject_civics,
      color: const Color(0xFFFF8C00),
    ),
    SchoolLessonPrefab(
      name: loc.subject_home_economics,
      color: const Color(0xFFFFE4B5),
    ),
    SchoolLessonPrefab(
      name: loc.subject_technology_crafts,
      color: const Color(0xFF808080),
    ),
    SchoolLessonPrefab(
      name: loc.subject_islamic_religion,
      color: const Color(0xFF006400),
    ),
    SchoolLessonPrefab(
      name: loc.subject_protestant_religion,
      color: const Color(0xFFFFFF00),
    ),
    SchoolLessonPrefab(
      name: loc.subject_catholic_religion,
      color: const Color(0xFFFFD700),
    ),
    SchoolLessonPrefab(
      name: loc.subject_media,
      color: const Color(0xFF4682B4),
    ),
    SchoolLessonPrefab(
      name: loc.subject_dutch,
      color: const Color(0xFFFFA500),
    ),
    SchoolLessonPrefab(
      name: loc.subject_orthodox_religion,
      color: const Color(0xFF800080),
    ),
  ]);
}
