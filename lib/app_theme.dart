import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nb_utils/nb_utils.dart';

import '../utils/colors.dart';

class AppTheme {
  //
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: createMaterialColor(const Color.fromRGBO(168, 45, 134, 1)),
      primaryColor: const Color.fromRGBO(168, 45, 134, 1),
      scaffoldBackgroundColor: const Color.fromRGBO(250, 248, 255, 1),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromRGBO(168, 45, 134, 1),
        outlineVariant: const Color.fromRGBO(204, 205, 205, 1),
      ),
      fontFamily: GoogleFonts.lexendDeca().fontFamily,
      useMaterial3: true,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: const Color.fromRGBO(255, 255, 255, 1)),
      iconTheme: IconThemeData(color: textPrimaryColorGlobal),
      textTheme: GoogleFonts.lexendDecaTextTheme(),
      unselectedWidgetColor: const Color.fromRGBO(0, 0, 0, 1),
      dividerColor: const Color.fromRGBO(204, 205, 205, 1),
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      ),
      cardColor: const Color.fromRGBO(255, 255, 255, 1),
      appBarTheme: AppBarTheme(systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light)),
      dialogTheme: DialogThemeData(shape: dialogShape()),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: createMaterialColor(primaryColor),
      primaryColor: const Color.fromARGB(255, 168, 45, 134),
      appBarTheme: AppBarTheme(
        systemOverlayStyle: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
      ),
      scaffoldBackgroundColor: const Color.fromRGBO(14, 17, 22, 1),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 168, 45, 134),
        outlineVariant: const Color.fromRGBO(204, 205, 205, 1),
        onSurface: textPrimaryColorGlobal,
        surface: const Color.fromRGBO(14, 17, 22, 1)
      ),
      fontFamily: GoogleFonts.lexendDeca().fontFamily,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(backgroundColor: scaffoldSecondaryDark),
      iconTheme: IconThemeData(color: const Color.fromRGBO(255, 255, 255, 1)),
      textTheme: GoogleFonts.lexendDecaTextTheme(),
      unselectedWidgetColor: const Color.fromRGBO(255, 255, 255, 0.6),
      useMaterial3: true,
      bottomSheetTheme: BottomSheetThemeData(
        shape: RoundedRectangleBorder(borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius)),
        backgroundColor: const Color.fromRGBO(14, 17, 22, 1),
      ),
      dividerColor: const Color.fromRGBO(57, 61, 69, 1),
      cardColor: const Color.fromRGBO(28, 31, 38, 1),
      dialogTheme: DialogThemeData(shape: dialogShape()),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.linux: OpenUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}