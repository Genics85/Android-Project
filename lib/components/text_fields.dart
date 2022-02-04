import 'package:flutter/material.dart';
import 'package:go_find_me/themes/borderRadius.dart';
import 'package:go_find_me/themes/textStyle.dart';
import 'package:go_find_me/themes/theme_colors.dart';

class InputDec {
  // const InputDec();

  InputDecoration inputDec({
    String? hint,
    Icon? prefixIcon,
  }) {
    return InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: ThemeBorderRadius.smallRadiusAll,
        ),
        filled: true,
        fillColor: ThemeColors.primary.withOpacity(0.07),
        hintText: hint,
        hintStyle: ThemeTexTStyle.textField,
        prefixIcon: prefixIcon);
  }

  // @override
  // Widget build(BuildContext context) {
  //   // TODO: implement build
  //   throw UnimplementedError();
  // }
}
