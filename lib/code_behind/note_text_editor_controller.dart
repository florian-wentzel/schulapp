import 'package:flutter/material.dart';

class NoteTextEditorController extends TextEditingController {
  static const Map<String, TextStyle> defaultMap = {
    r"@.\w+": TextStyle(
      color: Colors.blue,
    ),
    r"#.\w+": TextStyle(
      color: Colors.blue,
    ),
    r'_(.*?)\_': TextStyle(
      fontStyle: FontStyle.italic,
    ),
    '~(.*?)~': TextStyle(
      decoration: TextDecoration.lineThrough,
    ),
    r'\*(.*?)\*': TextStyle(
      fontWeight: FontWeight.bold,
    ),
  };

  final Map<String, TextStyle> map;
  final Pattern pattern;

  NoteTextEditorController({this.map = defaultMap})
      : pattern = RegExp(
            map.keys.map((key) {
              return key;
            }).join('|'),
            multiLine: true);

  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty,
    );
  }

  @override
  TextSpan buildTextSpan(
      {required BuildContext context, TextStyle? style, bool? withComposing}) {
    final List<InlineSpan> children = [];
    String? patternMatched;
    String? formatText;
    TextStyle? myStyle;
    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        myStyle = map[map.keys.firstWhere(
          (e) {
            bool ret = false;
            RegExp(e).allMatches(text).forEach((element) {
              if (element.group(0) == match[0]) {
                patternMatched = e;
                ret = true;
              }
            });
            return ret;
          },
        )];

        if (patternMatched == r"_(.*?)\_") {
          formatText = match[0]!.replaceAll("_", " ");
        } else if (patternMatched == r'\*(.*?)\*') {
          formatText = match[0]!.replaceAll("*", " ");
        } else if (patternMatched == "~(.*?)~") {
          formatText = match[0]!.replaceAll("~", " ");
        } else if (patternMatched == r'```(.*?)```') {
          formatText = match[0]!.replaceAll("```", "   ");
        } else {
          formatText = match[0];
        }

        children.add(TextSpan(
          text: formatText,
          style: style!.merge(myStyle),
        ));
        return "";
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return "";
      },
    );

    return TextSpan(style: style, children: children);
  }
}
