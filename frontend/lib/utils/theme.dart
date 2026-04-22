import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KairosColors {
  static const black = Color(0xFF000000);
  static const charcoal = Color(0xFF05060A);
  static const shadow = Color(0xFF15181C);
  static const ink = Color(0xFF0B0D11);
  static const bronze = Color(0xFF9A7C4E);
  static const bronzeLight = Color(0xFFC9A973);
  static const bone = Color(0xFFE8E4DB);
  static const blood = Color(0xFF6B1A1A);
  static const muted = Color(0xFF4A4A4A);
  static const hairline = Color(0xFF1F1F22);
}

class KairosTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: KairosColors.black,
      canvasColor: KairosColors.black,
      colorScheme: const ColorScheme.dark(
        primary: KairosColors.bronze,
        secondary: KairosColors.bronzeLight,
        surface: KairosColors.charcoal,
        onPrimary: KairosColors.black,
        onSecondary: KairosColors.black,
        onSurface: KairosColors.bone,
        error: KairosColors.blood,
        onError: KairosColors.bone,
      ),
      textTheme: GoogleFonts.cormorantGaramondTextTheme(base.textTheme).apply(
        bodyColor: KairosColors.bone,
        displayColor: KairosColors.bone,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: KairosColors.black,
        foregroundColor: KairosColors.bone,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: mono(size: 13, color: KairosColors.bone, letterSpacing: 4),
        iconTheme: const IconThemeData(color: KairosColors.bone),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: KairosColors.bronze,
          foregroundColor: KairosColors.black,
          disabledBackgroundColor: KairosColors.muted,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: KairosColors.bone),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: KairosColors.blood,
        contentTextStyle: TextStyle(color: KairosColors.bone),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      dividerTheme: const DividerThemeData(color: KairosColors.hairline, thickness: 1, space: 1),
    );
  }

  static TextStyle serif({double? size, FontWeight? weight, Color? color, double? height, FontStyle? style}) =>
      GoogleFonts.cormorantGaramond(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w400,
        color: color ?? KairosColors.bone,
        height: height,
        fontStyle: style,
      );

  static TextStyle mono({double? size, FontWeight? weight, Color? color, double letterSpacing = 2}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w400,
        color: color ?? KairosColors.bone,
        letterSpacing: letterSpacing,
      );
}
