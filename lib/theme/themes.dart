import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//TODO: eigene farben reinmachen

final lightTheme = ThemeData.light().copyWith(
  cardColor:
      const Color.fromARGB(225, 18, 17, 20), //TODO setze white mode color
  textTheme: GoogleFonts.preahvihearTextTheme(),
);

final darkTheme = ThemeData.dark().copyWith(
  cardColor: const Color.fromARGB(225, 18, 17, 20),
  textTheme: GoogleFonts.preahvihearTextTheme(Typography.whiteCupertino),
);
