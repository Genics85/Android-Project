import 'package:flutter/material.dart';
import 'package:go_find_me/components/buttons.dart';
import 'package:go_find_me/components/text_fields.dart';
import 'package:go_find_me/modules/auth/authProvider.dart';
import 'package:go_find_me/modules/auth/verify_account_provider.dart';
import 'package:go_find_me/themes/padding.dart';
import 'package:go_find_me/themes/textStyle.dart';
import 'package:go_find_me/themes/theme_colors.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:provider/provider.dart';

class VerifyAccount extends StatelessWidget with InputDec {
  VerifyAccount({Key? key}) : super(key: key);

  GlobalKey<ScaffoldState> _scaffolKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => VerifyAccountProvider(context),
      child: Scaffold(
        key: _scaffolKey,
        body: SafeArea(
          child: Consumer<VerifyAccountProvider>(
              builder: (context, verifyAccProv, _) {
            return Container(
              height: double.infinity,
              padding: EdgeInsets.all(ThemePadding.padBase * 3),
              color: ThemeColors.white,
              child: verifyAccProv.lastEvent!.state ==
                      VerificationEventState.loading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : SingleChildScrollView(
                      child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Text(
                          "Verify Account",
                          style: ThemeTexTStyle.headerPrim,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        verifyAccProv.inputVerification
                            ? verifyAccProv.verificationType ==
                                    VerificationType.email
                                ? emailVerificationInput(
                                    _scaffolKey.currentContext!)
                                : phoneVerificationInput(
                                    _scaffolKey.currentContext!)
                            : verificationTypeSelect(
                                _scaffolKey.currentContext!),
                      ],
                    )),
            );
          }),
        ),
      ),
    );
  }

  Widget verificationTypeSelect(BuildContext c) {
    return Consumer2<AuthenticationProvider, VerifyAccountProvider>(
        builder: (context, authProv, verifyAccProv, _) {
      return Column(
        children: [
          Text(
            "Selecte method of verification",
            style: ThemeTexTStyle.regularPrim,
          ),
          SizedBox(
            height: 30,
          ),
          ThemeButton.ButtonPrim(
              text: "Verify Using Email",
              onpressed: () {
                verifyAccProv.sendOTPEmail(authProv.currentUser!.email!, c);
              }),
          SizedBox(
            height: 10,
          ),
          authProv.currentUser!.phoneNumber == null
              ? SizedBox.shrink()
              : ThemeButton.ButtonSec(
                  width: double.infinity,
                  text: "Verify using phone",
                  onpressed: () {
                    verifyAccProv.sendOTPPhone(
                        authProv.currentUser!.phoneNumber!, context);
                  },
                )
        ],
      );
    });
  }

  Widget emailVerificationInput(BuildContext c) {
    return Consumer2<VerifyAccountProvider, AuthenticationProvider>(
        builder: (context, verifyAccProv, authProv, _) {
      return Column(
        children: [
          Text(
            "Verification code sent to email",
            style: ThemeTexTStyle.regularPrim,
          ),
          SizedBox(
            height: 30,
          ),
          PinPut(
            fieldsCount: 6,
            selectedFieldDecoration: BoxDecoration(
              color: ThemeColors.white,
              border: Border.all(color: ThemeColors.primary),
              borderRadius: BorderRadius.circular(5),
            ),
            followingFieldDecoration: BoxDecoration(
              color: ThemeColors.primary.withOpacity(0.17),
              borderRadius: BorderRadius.circular(5),
            ),
            // onSubmit: (String pin) => _showSnackBar(pin, context),
            focusNode: verifyAccProv.pinPutFocusNode,
            keyboardType: TextInputType.numberWithOptions(),
            controller: verifyAccProv.pinPutEmailController,
            submittedFieldDecoration: BoxDecoration(
              color: ThemeColors.primary.withOpacity(0.17),
              border: Border.all(color: ThemeColors.primary),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              verifyAccProv.sendOTPEmail(authProv.currentUser!.email!, c);
            },
            child: Text(
              "Resend verification code?",
              style: ThemeTexTStyle.regularPrim,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ThemeButton.longButtonPrim(
              text: "Submit",
              onpressed: () {
                verifyAccProv.confirmEmail(c);
              })
        ],
      );
    });
  }

  Widget phoneVerificationInput(BuildContext c) {
    return Consumer2<VerifyAccountProvider, AuthenticationProvider>(
        builder: (context, verifyAccProv, authProv, _) {
      return Column(
        children: [
          Text(
            "Verification code sent to phone",
            style: ThemeTexTStyle.regularPrim,
          ),
          SizedBox(
            height: 30,
          ),
          PinPut(
            fieldsCount: 6,
            selectedFieldDecoration: BoxDecoration(
              color: ThemeColors.white,
              border: Border.all(color: ThemeColors.primary),
              borderRadius: BorderRadius.circular(5),
            ),
            followingFieldDecoration: BoxDecoration(
              color: ThemeColors.primary.withOpacity(0.17),
              borderRadius: BorderRadius.circular(5),
            ),
            // onSubmit: (String pin) => _showSnackBar(pin, context),
            focusNode: verifyAccProv.pinPutFocusNode,
            keyboardType: TextInputType.numberWithOptions(),
            controller: verifyAccProv.pinPutEmailController,
            submittedFieldDecoration: BoxDecoration(
              color: ThemeColors.primary.withOpacity(0.17),
              border: Border.all(color: ThemeColors.primary),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          GestureDetector(
            onTap: () {
              verifyAccProv.sendOTPPhone(authProv.currentUser!.phoneNumber!, c);
            },
            child: Text(
              "Resend verification code?",
              style: ThemeTexTStyle.regularPrim,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          ThemeButton.longButtonPrim(
              text: "Submit",
              onpressed: () {
                verifyAccProv.confirmPhone(c);
              })
        ],
      );
    });
  }
}
