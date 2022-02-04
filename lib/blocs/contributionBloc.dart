import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_find_me/locator.dart';
import 'package:go_find_me/models/OnPopModel.dart';
import 'package:go_find_me/services/api.dart';

class ContributionBloc {
  Api _api = sl<Api>();
  String postId = '';

  StreamController<bool> _contributionView = StreamController<bool>.broadcast();
  StreamSink<bool> get _contributionViewSink => _contributionView.sink;
  Stream<bool> get contributionStream => _contributionView.stream;

  DateTime? dateValue;
  DateTime? timeValue;

  TextEditingController locationController = TextEditingController();

  // Date picker
  StreamController<DateTime> date = StreamController<DateTime>.broadcast();
  Stream<DateTime> get dateStream => date.stream;
  Sink<DateTime> get dateSink => date.sink;

  onViewSwitchRequest(bool value) {
    _contributionViewSink.add(value);
  }

  onSubmit(BuildContext context) async {
    var response = await _api.contribution({
      "location_sighted": locationController.text,
      "post_id": postId,
      "time_sighted": timeValue!.toIso8601String(),
      "date_sighted": dateValue!.toIso8601String(),
    });

    if (response != null) {
      Navigator.pop(context, OnPopModel(reloadPrev: true));
    }
  }
}
