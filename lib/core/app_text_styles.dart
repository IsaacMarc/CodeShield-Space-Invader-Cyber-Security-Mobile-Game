import 'package:flutter/material.dart';
import 'package:codeshield/core/app_fonts.dart';

class AppTextStyles {
  static const _fontSize = 64.0;
  static const _fontColor = Colors.white;

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: AppFonts.main,
    fontSize: _fontSize,
    color: _fontColor,
  );

  static const TextStyle titleText = TextStyle(
    fontFamily: AppFonts.main,
    fontSize: _fontSize,
    color: _fontColor,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: AppFonts.main,
    fontSize: 48.0,
    color: _fontColor,
  );

  static const TextStyle profileText = TextStyle(
    fontFamily: AppFonts.main,
    fontSize: 32,
    color: _fontColor,
  );
}
