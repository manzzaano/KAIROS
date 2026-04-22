import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KairosColors {
  static const neutral50 = Color(0xFFFAFAFA);
  static const neutral100 = Color(0xFFF4F4F5);
  static const neutral300 = Color(0xFFD4D4D8);
  static const neutral400 = Color(0xFFA1A1AA);
  static const neutral700 = Color(0xFF3F3F46);
  static const neutral900 = Color(0xFF18181B);

  static const error600 = Color(0xFFEF4444);

  static const black = neutral900;
  static const charcoal = neutral900;
  static const shadow = neutral900;
  static const ink = neutral900;
  static const bronze = neutral700;
  static const bronzeLight = neutral400;
  static const bone = neutral50;
  static const blood = error600;
  static const muted = neutral400;
  static const hairline = neutral300;
}

class KairosTheme {
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: KairosColors.neutral900,
      canvasColor: KairosColors.neutral900,
      colorScheme: const ColorScheme.dark(
        primary: KairosColors.neutral50,
        onPrimary: KairosColors.neutral900,
        secondary: KairosColors.neutral400,
        onSecondary: KairosColors.neutral900,
        surface: KairosColors.neutral900,
        onSurface: KairosColors.neutral50,
        error: KairosColors.error600,
        onError: KairosColors.neutral50,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: KairosColors.neutral50,
        displayColor: KairosColors.neutral50,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: KairosColors.neutral900,
        foregroundColor: KairosColors.neutral50,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: serif(size: 14, color: KairosColors.neutral50, weight: FontWeight.w500),
        iconTheme: const IconThemeData(color: KairosColors.neutral50),
        shape: const Border(bottom: BorderSide(color: KairosColors.neutral700, width: 0.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: KairosColors.neutral50,
          foregroundColor: KairosColors.neutral900,
          disabledBackgroundColor: KairosColors.neutral700,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          animationDuration: const Duration(milliseconds: 200),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: KairosColors.neutral50),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: KairosColors.neutral900,
        contentTextStyle: serif(size: 13, color: KairosColors.neutral50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: const DividerThemeData(color: KairosColors.neutral700, thickness: 0.5, space: 0.5),
    );
  }

  static TextStyle serif({double? size, FontWeight? weight, Color? color, double? height, FontStyle? style}) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w400,
        color: color ?? KairosColors.neutral50,
        height: height,
        fontStyle: style,
      );

  static TextStyle mono({double? size, FontWeight? weight, Color? color, double letterSpacing = 0.5}) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w400,
        color: color ?? KairosColors.neutral50,
        letterSpacing: letterSpacing,
      );
}
