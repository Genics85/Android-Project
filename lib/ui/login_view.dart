import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_android/blocs/authenticationBloc.dart';
import 'package:project_android/components/text_fields.dart';
import 'package:project_android/locator.dart';
import 'package:project_android/themes/borderRadius.dart';
import 'package:project_android/components/buttons.dart';
import 'package:project_android/themes/dropShadows.dart';
import 'package:project_android/themes/padding.dart';
import 'package:project_android/themes/textStyle.dart';
import 'package:project_android/themes/theme_colors.dart';

class Login extends StatelessWidget {
  Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            color: ThemeColors.white,
            padding: EdgeInsets.all(2 * ThemePadding.padBase),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30,
                ),
                CircleAvatar(
                  backgroundColor: ThemeColors.primary,
                  radius: 20,
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  height: 500,
                  padding: EdgeInsets.all(2.5 * ThemePadding.padBase),
                  decoration: BoxDecoration(
                    color: ThemeColors.white,
                    borderRadius: ThemeBorderRadius.bigRadiusAll,
                    boxShadow: ThemeDropShadow.bigShadow,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: ThemePadding.padBase * 3,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Login",
                            style: ThemeTexTStyle.headerPrim,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, '/signup');
                            },
                            child: Text(
                              "Sign Up",
                              style: ThemeTexTStyle.regular(),
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 2.5 * ThemePadding.padBase),
                      LoginForm(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginForm extends InputDec {
  LoginForm({Key? key}) : super(key: key);

  AuthenticationBloc _authbloc = sl<AuthenticationBloc>();

  @override
  Widget build(BuildContext context) {
    return Form(
      child: StreamBuilder<bool>(
          initialData: false,
          stream: _authbloc.setGooglePasswordStream,
          builder: (context, snapshot) {
            return snapshot.data!
                ? Column(
                    children: [
                      TextFormField(
                        controller: _authbloc.googlePassword,
                        decoration: inputDec(hint: "Password"),
                      ),
                      SizedBox(height: 2 * ThemePadding.padBase),
                      TextFormField(
                        validator: (String? value) {
                          return _authbloc.googlePasswordValidate(value);
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        // controller: _authbloc.googlePasswordConfirm,
                        decoration: inputDec(hint: "Confirm Password"),
                        obscureText: true,
                      ),
                      SizedBox(height: 50),
                      ThemeButton.longButtonPrim(
                        text: "Done",
                        onpressed: () {
                          _authbloc.googleSignUp();
                        },
                      ),
                      // Divider(
                      //   height: ThemePadding.padBase * 3,
                      // ),
                      // Text(
                      //   "or",
                      //   style: ThemeTexTStyle.regular(),
                      // ),
                      // SizedBox(
                      //   height: ThemePadding.padBase,
                      // ),
                      // ThemeButton.longButtonSec(
                      //     text: "Google",
                      //     onpressed: () async {
                      //       _authbloc.googleSignUp();
                      //     })
                    ],
                  )
                : Column(
                    children: [
                      TextFormField(
                        controller: _authbloc.loginEmail,
                        decoration: inputDec(hint: "Username or Email"),
                      ),
                      SizedBox(height: 2 * ThemePadding.padBase),
                      TextFormField(
                        controller: _authbloc.loginPassworrd,
                        decoration: inputDec(hint: "Password"),
                        obscureText: true,
                      ),
                      SizedBox(height: 50),
                      ThemeButton.longButtonPrim(
                        text: "Login",
                        onpressed: () {
                          // Navigator.pushReplacementNamed(context, '/');
                          _authbloc.emailLogin();
                        },
                      ),
                      Divider(
                        height: ThemePadding.padBase * 3,
                      ),
                      Text(
                        "or",
                        style: ThemeTexTStyle.regular(),
                      ),
                      SizedBox(
                        height: ThemePadding.padBase,
                      ),
                      ThemeButton.longButtonSec(
                          text: "Google",
                          onpressed: () async {
                            _authbloc.googleSignIn();
                          })
                    ],
                  );
          }),
    );
  }
}
