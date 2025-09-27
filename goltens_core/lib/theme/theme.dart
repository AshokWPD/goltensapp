import 'package:flutter/material.dart';

const Color primaryColor = Color(0xff80d6ff);

const MaterialColor primaryMaterialColor = MaterialColor(
  4286633727,
  <int, Color>{
    50: Color.fromRGBO(
      128,
      214,
      255,
      .1,
    ),
    100: Color.fromRGBO(
      128,
      214,
      255,
      .2,
    ),
    200: Color.fromRGBO(
      128,
      214,
      255,
      .3,
    ),
    300: Color.fromRGBO(
      128,
      214,
      255,
      .4,
    ),
    400: Color.fromRGBO(
      128,
      214,
      255,
      .5,
    ),
    500: Color.fromRGBO(
      128,
      214,
      255,
      .6,
    ),
    600: Color.fromRGBO(
      128,
      214,
      255,
      .7,
    ),
    700: Color.fromRGBO(
      128,
      214,
      255,
      .8,
    ),
    800: Color.fromRGBO(
      128,
      214,
      255,
      .9,
    ),
    900: Color.fromRGBO(
      128,
      214,
      255,
      1,
    ),
  },
);

ThemeData customTheme = ThemeData(
  primaryColor: const Color(0xff80d6ff),
  primarySwatch: primaryMaterialColor,
  progressIndicatorTheme:
      const ProgressIndicatorThemeData(color: Color(0xff80d6ff)),
  scrollbarTheme: const ScrollbarThemeData().copyWith(
    thumbColor: MaterialStateProperty.all(primaryMaterialColor[500]),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      shape: MaterialStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(20.0),
          ),
        ),
      ),
      backgroundColor: MaterialStateProperty.all(
        const Color(0xff80d6ff),
      ),
      foregroundColor: MaterialStateProperty.all(
        Colors.black,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all(
        const Color(0xff80d6ff),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: const BorderSide(
        color: Color(0xff80d6ff),
      ),
      borderRadius: BorderRadius.circular(20.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: Color(0xff80d6ff),
      ),
      borderRadius: BorderRadius.circular(20.0),
    ),
    labelStyle: const TextStyle(
      color: Colors.grey,
    ),
  ),
  radioTheme: RadioThemeData(
    fillColor:
        MaterialStateColor.resolveWith((states) => const Color(0xff80d6ff)),
  ),
  textSelectionTheme: TextSelectionThemeData(
      cursorColor: const Color(0xff80d6ff),
      selectionHandleColor: const Color(0xff80d6ff),
      selectionColor: Colors.grey.shade300),
  appBarTheme: const AppBarTheme(
    color: Color(0xff80d6ff),
    foregroundColor: Colors.black,
    iconTheme: IconThemeData(color: Colors.black),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStateColor.resolveWith((states) => Colors.white),
    checkColor:
        MaterialStateColor.resolveWith((states) => const Color(0xff80d6ff)),
  ),
);
