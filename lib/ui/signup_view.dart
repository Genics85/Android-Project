import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:go_find_me/components/passwordTextField.dart';
import 'package:go_find_me/components/text_fields.dart';
import 'package:go_find_me/modules/auth/authProvider.dart';
import 'package:go_find_me/modules/auth/validators.dart';
import 'package:go_find_me/themes/borderRadius.dart';
import 'package:go_find_me/components/buttons.dart';
import 'package:go_find_me/themes/dropShadows.dart';
import 'package:go_find_me/themes/padding.dart';
import 'package:go_find_me/themes/textStyle.dart';
import 'package:go_find_me/themes/theme_colors.dart';
import 'package:go_find_me/ui/login_view.dart';
import 'package:provider/provider.dart';

class SignUp extends StatelessWidget with InputDec {
  SignUp({Key? key}) : super(key: key);

  GlobalKey _scaffold = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(builder: (context, authProv, _) {
      return Scaffold(
        key: _scaffold,
        backgroundColor: ThemeColors.white,
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
                    authProv.lastEvent?.state == AuthEventState.loading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: ThemeColors.primary,
                            ),
                          )
                        : Container(
                            // height: 620,
                            padding: EdgeInsets.all(2 * ThemePadding.padBase),
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
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Login()));
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
                          )
                  ]),
            ),
          ),
        ),
      );
    });
  }

  Widget signup() {
    return Consumer<AuthenticationProvider>(builder: (context, authProv, _) {
      return Form(
        key: authProv.signUpEmailFormKey,
        child: Column(
          children: [
            TextFormField(
              controller: authProv.signUpUsername,
              decoration: inputDec(hint: "Username*"),
              validator: (val) {
                return AuthValidators.isEmptyValidator(val!);
              },
            ),
            SizedBox(height: 2 * ThemePadding.padBase),
            TextFormField(
              controller: authProv.singupEmail,
              decoration: inputDec(hint: "Email*"),
              validator: (val) {
                return AuthValidators.isEmptyValidator(val!);
              },
            ),
            SizedBox(height: 2 * ThemePadding.padBase),
            Container(
              decoration: BoxDecoration(
                color: ThemeColors.primary.withOpacity(0.07),
                borderRadius: ThemeBorderRadius.smallRadiusAll,
              ),
              child: InternationalPhoneNumberInput(
                  inputDecoration: inputDec(hint: "Phone number"),
                  ignoreBlank: true,
                  spaceBetweenSelectorAndTextField: 2,
                  keyboardType: TextInputType.number,
                  selectorConfig: SelectorConfig(
                      leadingPadding: 0,
                      showFlags: false,
                      selectorType: PhoneInputSelectorType.DIALOG),
                  maxLength: 11,
                  onInputChanged: authProv.setSignupPhoneNumber),
            ),
            SizedBox(height: 2 * ThemePadding.padBase),
            PasswordTextField(
              inputDec: inputDec(hint: "Password*"),
              controller: authProv.signUpPassword,
              validator: (val) {
                return AuthValidators.isEmptyValidator(val!);
              },
            ),
            SizedBox(height: 2 * ThemePadding.padBase),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                return AuthValidators.passwordValidate(
                    value, authProv.signUpPassword);
              },
              decoration: inputDec(hint: "Confirm Password"),
              obscureText: true,
            ),
            SizedBox(height: 50),
            ThemeButton.longButtonPrim(
              text: "Sign Up",
              onpressed: () {
                if (authProv.signUpEmailFormKey.currentState!.validate())
                  authProv.emailSignup(_scaffold.currentContext!);
              },
            ),
          ],
        ),
      );
    });
  }
}
