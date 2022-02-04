import 'package:flutter/material.dart';
import 'package:go_find_me/core/network/networkError.dart';
import 'package:go_find_me/locator.dart';
import 'package:go_find_me/modules/auth/forgotPassword/forgot_password_provider.dart';
import 'package:go_find_me/modules/base_provider.dart';
import 'package:go_find_me/services/api.dart';

class ChangePasswordProvider extends BaseProvider<ForgotPasswordEvent> {
  Api _api = sl<Api>();
  TextEditingController pinPutEmailController = TextEditingController();

// Password Change Variables
  TextEditingController newPassword = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey();
  GlobalKey<FormState> get formKey => _formKey;

  ChangePasswordProvider() {
    addEvent(ForgotPasswordEvent(state: ForgotPasswordEventState.idle));
  }

  Future<void> submitOtp() async {
    if (pinPutEmailController.text.length < 6) return;
    try {
      addEvent(ForgotPasswordEvent(state: ForgotPasswordEventState.loading));
      await _api.confirmForgotPasswordCode(pinPutEmailController.text);
      addEvent(ForgotPasswordEvent(state: ForgotPasswordEventState.changePass));
    } on NetworkError catch (error) {
      addEvent(ForgotPasswordEvent(
          state: ForgotPasswordEventState.error, data: error.errorMessage));
    }
  }

  Future<void> submitNewPassword() async {
    final formState = _formKey.currentState;
    if (!formState!.validate()) return;
    try {
      addEvent(ForgotPasswordEvent(state: ForgotPasswordEventState.loading));
      await _api.submitNewPassword(newPassword.text);
      addEvent(ForgotPasswordEvent(state: ForgotPasswordEventState.success));
    } on NetworkError catch (error) {
      addEvent(ForgotPasswordEvent(
          state: ForgotPasswordEventState.error, data: error.errorMessage));
    }
  }
}
