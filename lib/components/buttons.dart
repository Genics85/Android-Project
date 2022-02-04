import 'package:flutter/material.dart';
import 'package:go_find_me/themes/borderRadius.dart';
import 'package:go_find_me/themes/dropShadows.dart';
import 'package:go_find_me/themes/textStyle.dart';
import 'package:go_find_me/themes/theme_colors.dart';

class ThemeButton {
  static Widget longButtonPrim({String? text, onpressed}) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.primary,
        borderRadius: ThemeBorderRadius.smallRadiusAll,
      ),
      width: double.infinity,
      child: TextButton(
        child: Text(
          text ?? "",
          style: ThemeTexTStyle.buttonTextStylePrime,
        ),
        onPressed: () {
          onpressed();
        },
      ),
    );
  }

  static Widget longButtonSec({String? text, onpressed}) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.white,
        borderRadius: ThemeBorderRadius.smallRadiusAll,
        boxShadow: ThemeDropShadow.smallShadow,
      ),
      width: double.infinity,
      child: TextButton(
        child: Text(
          text ?? "",
          style: ThemeTexTStyle.buttonTextStyleSec,
        ),
        onPressed: () {
          onpressed();
        },
      ),
    );
  }

  static Widget ButtonPrim({String? text, onpressed}) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeColors.primary,
        borderRadius: ThemeBorderRadius.smallRadiusAll,
      ),
      width: double.infinity,
      child: TextButton(
        child: Text(
          text ?? "",
          style: ThemeTexTStyle.buttonTextStylePrime,
        ),
        onPressed: () {
          onpressed();
        },
      ),
    );
  }

  static Widget ButtonSec(
      {String? text, VoidCallback? onpressed, double? width}) {
    return Container(
      width: width,
      decoration: BoxDecoration(
          color: ThemeColors.white,
          borderRadius: ThemeBorderRadius.smallRadiusAll,
          boxShadow: ThemeDropShadow.smallShadow,
          border: Border.all(color: ThemeColors.primary)),
      child: TextButton(
          child: Text(
            text ?? "",
            style: ThemeTexTStyle.buttonTextStyleSec,
          ),
          onPressed: onpressed),
    );
  }
}
