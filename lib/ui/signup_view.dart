import 'package:flutter/material.dart';
import 'package:project_android/blocs/authenticationBloc.dart';
import 'package:project_android/components/passwordTextField.dart';
import 'package:project_android/components/text_fields.dart';
import 'package:project_android/locator.dart';
import 'package:project_android/themes/borderRadius.dart';
import 'package:project_android/components/buttons.dart';
import 'package:project_android/themes/dropShadows.dart';
import 'package:project_android/themes/padding.dart';
import 'package:project_android/themes/textStyle.dart';
import 'package:project_android/themes/theme_colors.dart';

class SignUp extends StatelessWidget with InputDec {
  SignUp({Key? key}) : super(key: key);

  AuthenticationBloc _authBloc = sl<AuthenticationBloc>();
  GlobalKey _scaffold = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: ThemeColors.primary,
                      radius: 20,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      "GoFindMe",
                      style: TextStyle(
                          color: ThemeColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 30),
                    )
                  ],
                ),
                SizedBox(
                  height: 30,
                ),
                StreamBuilder<bool>(
                    initialData: false,
                    stream: _authBloc.isAuthenticatingStream,
                    builder: (context, snapshot) {
                      return snapshot.data!
                          ? Center(
                              child: CircularProgressIndicator(
                                color: ThemeColors.primary,
                              ),
                            )
                          : Container(
                              // height: 620,
                              padding:
                                  EdgeInsets.all(2.5 * ThemePadding.padBase),
                              decoration: BoxDecoration(
                                color: ThemeColors.white,
                                borderRadius: ThemeBorderRadius.bigRadiusAll,
                                boxShadow: ThemeDropShadow.bigShadow,
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: ThemePadding.padBase * 2,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Sign Up ",
                                        style: ThemeTexTStyle.headerPrim,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacementNamed(
                                              context, '/login');
                                        },
                                        child: Text(
                                          "Login",
                                          style: ThemeTexTStyle.regular(),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 2.5 * ThemePadding.padBase),
                                  signup()
                                ],
                              ),
                            );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Form signup() {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: _authBloc.signUpUsername,
            decoration: inputDec(hint: "Username"),
          ),
          SizedBox(height: 2 * ThemePadding.padBase),
          TextFormField(
            controller: _authBloc.singupEmail,
            decoration: inputDec(hint: "Email"),
          ),
          SizedBox(height: 2 * ThemePadding.padBase),
          PasswordTextField(
            inputDec: inputDec(hint: "Password"),
            controller: _authBloc.signUpPassword,
          ),
          SizedBox(height: 2 * ThemePadding.padBase),
          TextFormField(
            autovalidateMode: AutovalidateMode.always,
            validator: (value) {
              return _authBloc.passwordValidate(
                  value, _authBloc.signUpPassword);
            },
            decoration: inputDec(hint: "Confirm Password"),
            obscureText: true,
          ),
          SizedBox(height: 50),
          ThemeButton.longButtonPrim(
            text: "Sign Up",
            onpressed: () {
              _authBloc.emailSignUp(_scaffold.currentContext!);
              // Navigator.pushReplacementNamed(_scaffold.currentContext!, '/');
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
              await _authBloc.googleSignUp(_scaffold.currentContext!);
            },
          )
        ],
      ),
    );
  }
}

class SignUpForm extends StatelessWidget with InputDec {
  SignUpForm({Key? key}) : super(key: key);

  AuthenticationBloc _authBloc = sl<AuthenticationBloc>();

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            decoration: inputDec(hint: "Name"),
          ),
          SizedBox(height: 2 * ThemePadding.padBase),
          TextFormField(
            decoration: inputDec(hint: "Email"),
          ),
          SizedBox(height: 2 * ThemePadding.padBase),
          PasswordTextField(
            inputDec: inputDec(hint: "Password"),
            controller: TextEditingController(),
          ),
          SizedBox(height: 2 * ThemePadding.padBase),
          TextFormField(
            decoration: inputDec(hint: "Confirm Password"),
            obscureText: true,
          ),
          SizedBox(height: 50),
          ThemeButton.longButtonPrim(
            text: "Sign Up",
            onpressed: () {
              Navigator.pushReplacementNamed(context, '/');
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
                await _authBloc.googleSignUp(context);
              })
        ],
      ),
    );
  }
}
