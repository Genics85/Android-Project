import 'package:flutter/material.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:go_find_me/components/buttons.dart';
import 'package:go_find_me/components/passwordTextField.dart';
import 'package:go_find_me/components/text_fields.dart';
import 'package:go_find_me/modules/auth/forgotPassword/change_password_provider.dart';
import 'package:go_find_me/modules/auth/forgotPassword/forgot_password_provider.dart';
import 'package:go_find_me/modules/auth/validators.dart';
import 'package:go_find_me/themes/padding.dart';
import 'package:go_find_me/themes/textStyle.dart';
import 'package:go_find_me/themes/theme_colors.dart';
import 'package:go_find_me/ui/login_view.dart';
import 'package:provider/provider.dart';

class ForgottenPasswordCodeConfirmation extends StatefulWidget {
  const ForgottenPasswordCodeConfirmation({Key? key}) : super(key: key);

  @override
  State<ForgottenPasswordCodeConfirmation> createState() =>
      _ForgottenPasswordCodeConfirmationState();
}

class _ForgottenPasswordCodeConfirmationState
    extends State<ForgottenPasswordCodeConfirmation> with InputDec {
  final _changePasswordProvider = ChangePasswordProvider();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _changePasswordProvider.stream.listen((event) {
        switch (event.state) {
          case ForgotPasswordEventState.error:
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                event.data,
                style: ThemeTexTStyle.regular(color: ThemeColors.white),
              ),
              backgroundColor: ThemeColors.accent,
            ));
            break;
          case ForgotPasswordEventState.success:
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (_) => Login()), (_) => false);
            break;
          default:
            return;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => _changePasswordProvider,
        builder: (context, _) {
          return Consumer<ChangePasswordProvider>(builder: (context, model, _) {
            return Scaffold(
              backgroundColor: ThemeColors.white,
              body: SafeArea(
                child: Container(
                  padding: EdgeInsets.all(ThemePadding.padBase * 2),
                  child: model.lastEvent!.state ==
                          ForgotPasswordEventState.changePass
                      ? Column(
                          children: [
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
                              height: 60,
                            ),
                            Text(
                              "Please enter a password you would remember.",
                              style: ThemeTexTStyle.regular(
                                  color: ThemeColors.grey.withOpacity(0.5)),
                            ),
                            model.lastEvent!.state ==
                                    ForgotPasswordEventState.loading
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: ThemeColors.primary,
                                    ),
                                  )
                                : Form(
                                    key: model.formKey,
                                    child: Column(
                                      children: [
                                        PasswordTextField(
                                          inputDec: inputDec(hint: "Password*"),
                                          controller: model.newPassword,
                                          validator: (val) {
                                            return AuthValidators
                                                .isEmptyValidator(val!);
                                          },
                                        ),
                                        SizedBox(
                                            height: 2 * ThemePadding.padBase),
                                        TextFormField(
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          validator: (value) {
                                            return AuthValidators
                                                .passwordValidate(
                                                    value, model.newPassword);
                                          },
                                          decoration: inputDec(
                                              hint: "Confirm Password"),
                                          obscureText: true,
                                        ),
                                        SizedBox(
                                            height: ThemePadding.padBase * 1.5),
                                        ThemeButton.longButtonPrim(
                                            text: "Confirm",
                                            onpressed: model.submitNewPassword),
                                      ],
                                    ),
                                  ),
                          ],
                        )
                      : Column(
                          children: [
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
                              height: 60,
                            ),
                            Text(
                              "Please enter a confirmation code to be able to change password",
                              style: ThemeTexTStyle.regular(
                                  color: ThemeColors.grey.withOpacity(0.5)),
                            ),
                            SizedBox(height: ThemePadding.padBase),
                            model.lastEvent!.state ==
                                    ForgotPasswordEventState.loading
                                ? Center(
                                    child: CircularProgressIndicator(
                                      color: ThemeColors.primary,
                                    ),
                                  )
                                : Column(
                                    children: [
                                      PinPut(
                                        fieldsCount: 6,
                                        selectedFieldDecoration: BoxDecoration(
                                          color: ThemeColors.white,
                                          border: Border.all(
                                              color: ThemeColors.primary),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        followingFieldDecoration: BoxDecoration(
                                          color: ThemeColors.primary
                                              .withOpacity(0.17),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        keyboardType:
                                            TextInputType.numberWithOptions(),
                                        controller: model.pinPutEmailController,
                                        submittedFieldDecoration: BoxDecoration(
                                          color: ThemeColors.primary
                                              .withOpacity(0.17),
                                          border: Border.all(
                                              color: ThemeColors.primary),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                      SizedBox(
                                          height: ThemePadding.padBase * 1.5),
                                      ThemeButton.longButtonPrim(
                                          text: "Submit Code",
                                          onpressed: model.submitOtp),
                                    ],
                                  ),
                          ],
                        ),
                ),
              ),
            );
          });
        });
  }
}
