import 'package:flutter/material.dart';
import 'package:go_find_me/themes/theme_colors.dart';

class ThemeDropShadow {
  static List<BoxShadow> bigShadow = [
    BoxShadow(
        offset: Offset(0, 8),
        blurRadius: 20,
        spreadRadius: 2,
        color: ThemeColors.black.withOpacity(0.1))
  ];

  static List<BoxShadow> smallShadow = [
    BoxShadow(
        offset: Offset(0, 4),
        blurRadius: 4,
        spreadRadius: 0,
        color: ThemeColors.black.withOpacity(0.1))
  ];
}
