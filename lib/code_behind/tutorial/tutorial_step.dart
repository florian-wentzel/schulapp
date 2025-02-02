import 'package:flutter/material.dart';

class TutorialStep {
  final GlobalKey highlightKey;
  final Widget tutorialWidget;

  TutorialStep({
    required this.highlightKey,
    required this.tutorialWidget,
  });
}
