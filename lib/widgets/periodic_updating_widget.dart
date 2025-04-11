import 'dart:async';

import 'package:flutter/material.dart';

class PeriodicUpdatingWidget extends StatefulWidget {
  final Widget Function() updateWidget;
  final Duration timerDuration;

  const PeriodicUpdatingWidget({
    super.key,
    required this.updateWidget,
    required this.timerDuration,
  });

  @override
  State<PeriodicUpdatingWidget> createState() => _PeriodicUpdatingWidgetState();
}

class _PeriodicUpdatingWidgetState extends State<PeriodicUpdatingWidget> {
  Timer? _timer;

  @override
  void initState() {
    _timer ??= Timer.periodic(
      widget.timerDuration,
      onTimer,
    );
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void onTimer(Timer timer) {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.updateWidget();
  }
}
