import 'package:flutter/material.dart';

class TutorialStep {
  final GlobalKey highlightKey;
  final Widget tutorialWidget;
  //wird ausgeführt wenn der Step dran ist
  final VoidCallback? action;

  TutorialStep({
    required this.highlightKey,
    required this.tutorialWidget,
    this.action,
  });
}
