import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_find_me/blocs/authenticationBloc.dart';

import 'package:go_find_me/components/dialogs.dart';
import 'package:go_find_me/core/network/networkError.dart';
import 'package:go_find_me/locator.dart';
import 'package:go_find_me/models/OnPopModel.dart';
import 'package:go_find_me/models/PostModel.dart';
import 'package:go_find_me/modules/auth/authProvider.dart';
import 'package:go_find_me/modules/base_provider.dart';
import 'package:go_find_me/services/api.dart';
import 'package:go_find_me/util/validators.dart';
import 'package:provider/provider.dart';

enum ContribuionEventState { idle, loading, error, success }

class ContributionsEvent<T> {
  final ContribuionEventState state;
  final T? data;

  ContributionsEvent({required this.state, this.data});
}

// Create Post Provider
class ContributionsProvider extends BaseProvider<ContributionsEvent> {
  Api _api = sl<Api>();

  DateTime? dateValue;
  DateTime? timeValue;
  String postId = '';

  ContributionsProvider() {
    addEvent(ContributionsEvent(state: ContribuionEventState.idle));
  }

  TextEditingController locationController = TextEditingController();

  setDate(DateTime x) {
    dateValue = x;
    notifyListeners();
  }

  onSubmit(BuildContext context) async {
    try {
      addEvent(ContributionsEvent(state: ContribuionEventState.loading));
      var response = await _api.contribution({
        "location_sighted": locationController.text,
        "post_id": postId,
        "user_id": Provider.of<AuthenticationProvider>(context, listen: false)
            .currentUser!
            .id!,
        "time_sighted": timeValue!.toIso8601String(),
        "date_sighted": (dateValue ?? DateTime.now()).toIso8601String(),
      });

      if (response != null) {
        addEvent(ContributionsEvent(state: ContribuionEventState.success));
      }
    } on NetworkError catch (err) {
      addEvent(ContributionsEvent(
          state: ContribuionEventState.error, data: err.errorMessage));
    }
  }
}
