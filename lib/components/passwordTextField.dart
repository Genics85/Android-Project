import 'package:flutter/material.dart';
import 'package:go_find_me/themes/borderRadius.dart';
import 'package:go_find_me/themes/theme_colors.dart';

class PasswordTextField extends StatefulWidget {
  const PasswordTextField(
      {Key? key, this.controller, this.inputDec, this.validator})
      : super(key: key);
  final TextEditingController? controller;
  final InputDecoration? inputDec;
  final String? Function(String?)? validator;

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              validator: widget.validator,
              controller: widget.controller,
              decoration: widget.inputDec,
              obscureText: obscureText,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3, vertical: 5),
            decoration: BoxDecoration(
                color: ThemeColors.primary.withOpacity(0.1),
                borderRadius: ThemeBorderRadius.smallRadiusAll),
            child: IconButton(
              onPressed: () {
                setState(() {
                  obscureText = !obscureText;
                });
              },
              icon: Icon(
                !obscureText ? Icons.visibility : Icons.visibility_off,
                color: ThemeColors.grey,
              ),
            ),
          )
        ],
      ),
    );
  }
}
