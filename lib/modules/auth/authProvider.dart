import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_find_me/ui/welcome_page.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:go_find_me/components/dialogs.dart';
import 'package:go_find_me/core/network/networkError.dart';
import 'package:go_find_me/locator.dart';
import 'package:go_find_me/models/UserModel.dart';
import 'package:go_find_me/modules/base_provider.dart';
import 'package:go_find_me/services/api.dart';
import 'package:go_find_me/services/sharedPref.dart';
import 'package:go_find_me/ui/home_view.dart';
import 'package:go_find_me/ui/login_view.dart';
import 'package:go_find_me/ui/verify_account.dart';

enum AuthEventState { idle, success, error, loading }

class AuthEvent<T> {
  AuthEventState state;
  T? data;
  AuthEvent({required this.state, this.data});
}

class AuthenticationProvider extends BaseProvider<AuthEvent> {
  UserModel? currentUser;

  Api _api = sl<Api>();
  SharedPreferencesService _sharedPref = sl<SharedPreferencesService>();

  // Login TextEditor Controllers
  TextEditingController loginPassworrd = TextEditingController();
  TextEditingController loginEmail = TextEditingController();
  PhoneNumber? loginPhoneNumber;

  // Signup TextEditor Controllers
  TextEditingController signUpPassword = TextEditingController();
  TextEditingController singupEmail = TextEditingController();
  TextEditingController signUpUsername = TextEditingController();
  PhoneNumber? signUpPhoneNumber;

  GlobalKey<FormState> loginEmailFormKey = GlobalKey();
  GlobalKey<FormState> signUpEmailFormKey = GlobalKey();

  bool isPhoneLogin = false;

  setLoginPhoneNumber(PhoneNumber phone) {
    loginPhoneNumber = phone;
  }

  setSignupPhoneNumber(PhoneNumber phone) {
    signUpPhoneNumber = phone;
  }

  _disposeContollers() {
    loginEmail.clear();
    loginPassworrd.clear();
    signUpPassword.clear();
    singupEmail.clear();
    signUpUsername.clear();
  }

  setIsPhoneLogin() {
    isPhoneLogin = !isPhoneLogin;
    notifyListeners();
  }

  getStoredUser(BuildContext context, {bool? firstTime}) async {
    if (firstTime ?? false) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => WelcomePage()));
      return;
    }
    Map<String, dynamic> userJson = json
        .decode((await _sharedPref.getStringValuesSF("currentUser")) ?? "{}");
    if (userJson.isEmpty) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    } else {
      currentUser = UserModel.fromJson(userJson);
      if (currentUser!.confirmedAt == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => VerifyAccount()));
      } else {
        _disposeContollers();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeView()));
      }
    }
  }

  logOut(BuildContext context) async {
    print("logout");
    await _sharedPref.removeFromSF("currentUser");
    await _sharedPref.removeFromSF("accessToken");
    await _sharedPref.removeFromSF("refreshToken");

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => Login()));
  }

  emailLogin(BuildContext context) async {
    if (loginEmailFormKey.currentState!.validate()) {
      addEvent(AuthEvent(state: AuthEventState.loading));
      try {
        UserModel? result = await _api.emailLogin({
          "identity": loginEmail.text,
          "password": loginPassworrd.text,
        });
        print("hello");
        print(result!.toJson());
        if (result != null) {
          currentUser = result;
          await _sharedPref.addStringToSF(
              "currentUser", json.encode(result.toJson()));
          addEvent(AuthEvent(state: AuthEventState.success));

          if (currentUser!.confirmedAt != null) {
            _disposeContollers();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeView(),
              ),
            );
          } else
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => VerifyAccount()));
        }
      } on NetworkError catch (err) {
        Dialogs.errorDialog(context, err.error);
        addEvent(AuthEvent(state: AuthEventState.error));
      }
    }
  }

  phoneLogin(BuildContext context) async {
    print(loginPhoneNumber!.phoneNumber);
    addEvent(AuthEvent(state: AuthEventState.loading));
    try {
      UserModel? result = await _api.emailLogin({
        "identity": loginPhoneNumber!.phoneNumber,
        "password": loginPassworrd.text,
      });
      if (result != null) {
        currentUser = result;
        await _sharedPref.addStringToSF(
            "currentUser", json.encode(result.toJson()));
        addEvent(AuthEvent(state: AuthEventState.success));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeView(),
          ),
        );
      }
    } on NetworkError catch (err) {
      Dialogs.errorDialog(context, err.error);
      addEvent(AuthEvent(state: AuthEventState.error));
    }
  }

  emailSignup(BuildContext context) async {
    addEvent(AuthEvent(state: AuthEventState.loading));
    try {
      UserModel? result = await _api.emailSignUp({
        "username": signUpUsername.text,
        "phone_number": signUpPhoneNumber?.phoneNumber ?? "",
        "password": signUpPassword.text,
        "email": singupEmail.text,
      });

      if (result != null) {
        currentUser = result;
        await _sharedPref.addStringToSF(
            "currentUser", json.encode(result.toJson()));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyAccount(),
          ),
        );
      }
    } on NetworkError catch (err) {
      Dialogs.errorDialog(context, err.error);
      addEvent(AuthEvent(state: AuthEventState.error));
    }
  }
}
