import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_find_me/components/dialogs.dart';
import 'package:go_find_me/core/network/networkError.dart';
import 'package:go_find_me/locator.dart';
import 'package:go_find_me/models/UserModel.dart';
import 'package:go_find_me/modules/auth/authProvider.dart';
import 'package:go_find_me/modules/base_provider.dart';
import 'package:go_find_me/services/api.dart';
import 'package:go_find_me/services/sharedPref.dart';
import 'package:go_find_me/ui/home_view.dart';
import 'package:provider/provider.dart';

enum VerificationEventState { idle, loading, success, error }

class VerificationEvent<T> {
  final T? data;
  final VerificationEventState state;

  VerificationEvent({this.data, this.state = VerificationEventState.idle});
}

enum VerificationType { email, phone }

class VerifyAccountProvider extends BaseProvider<VerificationEvent> {
  BuildContext context;
  Api _api = sl<Api>();
  SharedPreferencesService _sharedPref = sl<SharedPreferencesService>();

  final TextEditingController pinPutEmailController = TextEditingController();
  final FocusNode pinPutFocusNode = FocusNode();

  VerifyAccountProvider(this.context) {
    addEvent(VerificationEvent(state: VerificationEventState.idle));
  }

  bool inputVerification = false;
  VerificationType verificationType = VerificationType.email;

  sendOTPEmail(String email, BuildContext contextt) async {
    try {
      addEvent(VerificationEvent(state: VerificationEventState.loading));

      await _api.sendOTPemail({"email": email});
      verificationType = VerificationType.email;
      inputVerification = true;
      addEvent(VerificationEvent(state: VerificationEventState.idle));
    } on NetworkError catch (err) {
      addEvent(VerificationEvent(state: VerificationEventState.error));
      Dialogs.errorDialog(context, err.errorMessage!);
    }
  }

  sendOTPPhone(String phoneNumber, BuildContext contextt) async {
    try {
      addEvent(VerificationEvent(state: VerificationEventState.loading));
      print(phoneNumber);
      await _api.sendOTPPhone({"phone_number": phoneNumber});
      verificationType = VerificationType.phone;
      inputVerification = true;
      addEvent(VerificationEvent(state: VerificationEventState.idle));
    } on NetworkError catch (err) {
      addEvent(VerificationEvent(state: VerificationEventState.error));
      Dialogs.errorDialog(context, err.errorMessage!);
    }
  }

  confirmPhone(BuildContext contextt) async {
    try {
      print("Hello");
      addEvent(VerificationEvent(state: VerificationEventState.loading));
      String? confirmationToken =
          await _sharedPref.getStringValuesSF("confirmation_token");
      UserModel user = await _api.confirmPhone({
        "otp": pinPutEmailController.text,
        "confirmation_token": confirmationToken
      });
      await _sharedPref.addStringToSF(
          "currentUser", json.encode(user.toJson()));

      print(user.toJson());
      Provider.of<AuthenticationProvider>(context, listen: false).currentUser =
          user;
      addEvent(VerificationEvent(state: VerificationEventState.idle));
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeView()));
    } on NetworkError catch (err) {
      addEvent(VerificationEvent(state: VerificationEventState.error));
      Dialogs.errorDialog(context, err.errorMessage!);
    }
  }

  confirmEmail(BuildContext contextt) async {
    try {
      addEvent(VerificationEvent(state: VerificationEventState.loading));
      String? confirmationToken =
          await _sharedPref.getStringValuesSF("confirmation_token");
      UserModel user = await _api.confirmEmail({
        "otp": pinPutEmailController.text,
        "confirmation_token": confirmationToken
      });
      await _sharedPref.addStringToSF(
          "currentUser", json.encode(user.toJson()));

      print(user.toJson());
      Provider.of<AuthenticationProvider>(context, listen: false).currentUser =
          user;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => HomeView()));
    } on NetworkError catch (err) {
      addEvent(VerificationEvent(state: VerificationEventState.error));
      Dialogs.errorDialog(context, err.errorMessage!);
    }
  }
}
