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

enum CreatePostEventState { idle, loading, error, success }

class CreatePostEvent<T> {
  final CreatePostEventState state;
  final T? data;

  CreatePostEvent({required this.state, this.data});
}

// Create Post Provider
class CreatePostProvider extends BaseProvider<CreatePostEvent> {
  Api _api = sl<Api>();
  List<XFile>? _images = [];
  List<Uint8List> memImages = [];

  // Form Key
  GlobalKey<FormState> _formKey = GlobalKey();

  // Get formkey
  GlobalKey<FormState> get formKey => _formKey;

  // TextEditingController form
  TextEditingController title = TextEditingController();
  TextEditingController postDescription = TextEditingController();
  TextEditingController lastSeenLocation = TextEditingController();

  DateTime? _lastSeenDate = DateTime.now();
  DateTime? get lastSeenDate => _lastSeenDate;

  String? isEmptyValidator(String value, String Fieldname) {
    if (Validators.stringLengthValidator(value)) {
      return "Please enter value for $Fieldname field";
    }

    return null;
  }

  onCreatePost(BuildContext context) async {
    if (_images!.length < 2) {
      Dialogs.errorDialog(context, "Please add 2 or more images");
      return;
    }
    if (_formKey.currentState!.validate()) {
      addEvent(CreatePostEvent(state: CreatePostEventState.loading));
      try {
        List<MultipartFile> files = [];
        _images?.forEach((element) async {
          files.add(MultipartFile.fromFileSync(element.path));
        });

        List<dynamic>? imgPaths = await _api.uploadImages({"upload": files});
        if (imgPaths == null) return;
        try {
          Post? response = await _api.createPost({
            "user_id":
                Provider.of<AuthenticationProvider>(context, listen: false)
                    .currentUser
                    ?.id,
            "desc": postDescription.text,
            "title": title.text,
            "imgs": imgPaths,
            "last_seen": {
              "location": lastSeenLocation.text,
              "date": _lastSeenDate!.toIso8601String()
            }
          });

          if (response != null) {
            addEvent(CreatePostEvent(state: CreatePostEventState.success));
            Navigator.pop(context, OnPopModel(reloadPrev: true));
          }
        } on NetworkError catch (netErr) {
          addEvent(CreatePostEvent(
            state: CreatePostEventState.error,
          ));
          Dialogs.errorDialog(context, netErr.error);
        }
      } on NetworkError catch (netErr) {
        addEvent(CreatePostEvent(
          state: CreatePostEventState.error,
        ));
        Dialogs.errorDialog(context, netErr.error);
      }
    }
  }

  onImageUpload() async {
    final ImagePicker _picker = ImagePicker();
    _images = await _picker.pickMultiImage();

    memImages =
        await Future.wait(_images!.map((e) async => await e.readAsBytes()));
    notifyListeners();
  }

  removeImage(int index) async {
    _images!.removeAt(index);
    memImages.removeAt(index);
    notifyListeners();
  }

  onMoreImageUpload() async {
    final ImagePicker _picker = ImagePicker();
    _images = [..._images ?? [], ...(await _picker.pickMultiImage()) ?? []];
    memImages = [];
    _images!.forEach((element) async {
      final e = await element.readAsBytes();
      memImages.add(e);
    });

    notifyListeners();
  }

  setLastSeenDate(DateTime? date) {
    _lastSeenDate = date;
    notifyListeners();
  }
}
