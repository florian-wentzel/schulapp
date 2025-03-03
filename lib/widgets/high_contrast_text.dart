import 'package:flutter/material.dart';

class HighContrastText extends StatefulWidget {
  final String text;
  final Color? fillColor;
  final bool highContrastEnabled;
  final double outlineWidth;
  final TextStyle? textStyle;
  final FontWeight? fontWeight;

  const HighContrastText({
    super.key,
    required this.text,
    this.outlineWidth = 4,
    this.highContrastEnabled = true,
    this.textStyle,
    this.fontWeight,
    this.fillColor,
  });

  @override
  State<HighContrastText> createState() => _HighContrastTextState();
}

class _HighContrastTextState extends State<HighContrastText> {
  TextStyle? textStyle;

  @override
  void initState() {
    textStyle = widget.textStyle;
    super.initState();
  }

  TextStyle? _defaultTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (widget.highContrastEnabled)
          Text(
            widget.text,
            textAlign: TextAlign.justify,
            overflow: TextOverflow.fade,
            style: (widget.textStyle ?? _defaultTextStyle(context))?.copyWith(
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = widget.outlineWidth
                ..color = Theme.of(context).canvasColor.withAlpha(255),
              // ..color = outlineColor.withAlpha(80),
            ),
          ),
        Text(
          widget.text,
          textAlign: TextAlign.justify,
          overflow: TextOverflow.fade,
          style: (widget.textStyle ?? _defaultTextStyle(context))?.copyWith(
            fontWeight: widget.fontWeight,
            color: widget.fillColor,
          ),
        ),
      ],
    );
  }
}
