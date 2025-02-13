import 'dart:collection';

import 'package:schulapp/code_behind/tutorial/tutorial_step.dart';

class Tutorial {
  UnmodifiableListView<TutorialStep> steps;

  Tutorial({
    required List<TutorialStep> steps,
  }) : steps = UnmodifiableListView(steps) {
    assert(steps.isNotEmpty);
  }

  int _currentStepIndex = 0;

  TutorialStep? get currentStep {
    if (_currentStepIndex < steps.length) {
      return steps[_currentStepIndex];
    }
    return null;
  }

  int _previousStepIndex = -1;
  TutorialStep? get previousStep {
    if (_previousStepIndex < 0 || _previousStepIndex >= steps.length) {
      return null;
    }

    return steps[_previousStepIndex];
  }

  void goToNextStep() {
    _previousStepIndex = _currentStepIndex;

    _currentStepIndex++;
    _stepChanged();
  }

  void goToPreviousStep() {
    _previousStepIndex = _currentStepIndex;

    if (_currentStepIndex > 0) {
      _currentStepIndex--;
    }
    _stepChanged();
  }

  bool get isOver => _currentStepIndex == steps.length;
  bool get lastStep => _currentStepIndex == steps.length - 1;
  bool get firstStep => _currentStepIndex == 0;

  void goToEnd() {
    _previousStepIndex = _currentStepIndex;
    _currentStepIndex = steps.length;
    _stepChanged();
  }

  void _stepChanged() {
    currentStep?.action?.call();
  }

  void init() {
    _stepChanged();
  }
}
