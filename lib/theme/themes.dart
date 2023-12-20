import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//TODO: eigene farben reinmachen

final lightTheme = ThemeData.light().copyWith(
  textTheme: GoogleFonts.preahvihearTextTheme(),
);

final darkTheme = ThemeData.dark().copyWith(
  cardColor: const Color.fromARGB(255, 18, 17, 20),
  textTheme: GoogleFonts.preahvihearTextTheme(Typography.whiteCupertino),
);
