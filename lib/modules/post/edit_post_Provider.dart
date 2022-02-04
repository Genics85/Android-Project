import 'dart:async';
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

enum EditPostEventState { idle, loading }

class EditPostEvent<T> {
  final EditPostEventState state;
  final T? data;

  EditPostEvent({required this.state, this.data});
}

// Create Post Provider
class EditPostProvider extends BaseProvider<EditPostEvent> {
  Post? post;

  TextEditingController? title;
  TextEditingController? postDescription;
  TextEditingController? lastSeenLocation;
  DateTime? _lastSeenDate;
  List<String>? oldImages = [];

  GlobalKey<FormState> _formKey = GlobalKey();

  // Get formkey
  GlobalKey<FormState> get formKey => _formKey;

  DateTime? get lastSeenDate => _lastSeenDate;

  EditPostProvider({this.post}) {
    title = TextEditingController(text: post?.title);
    lastSeenLocation = TextEditingController(text: post?.lastSeen?.location);
    postDescription = TextEditingController(text: post?.desc);
    _lastSeenDate = post?.lastSeen?.date;
    oldImages = post?.imgs;
    displayImages = [...oldImages!];
    status = post?.status;
    addEvent(EditPostEvent(state: EditPostEventState.idle));
  }

  Api _api = sl<Api>();

  List<XFile>? _images = [];
  List<Uint8List> memImages = [];
  List<dynamic> displayImages = [];

  String? status = "Not Found";

  // Form Key

  String? isEmptyValidator(String value, String Fieldname) {
    if (Validators.stringLengthValidator(value)) {
      return "Please enter value for $Fieldname field";
    }

    return null;
  }

  onStatusChange(String? value) {
    status = value;
    notifyListeners();
  }

  onImageUpload() async {
    print(displayImages.length);
    final ImagePicker _picker = ImagePicker();
    _images = [..._images ?? [], ...(await _picker.pickMultiImage()) ?? []];
    print(_images!.length);

    memImages = await Future.wait(
        _images!.map((e) async => await e.readAsBytes()).toList());

    displayImages = [...oldImages!, ...memImages];
    print(displayImages.length);

    notifyListeners();
  }

  removeImage(int index) async {
    if (index < oldImages!.length) {
      oldImages!.removeAt(index);
    } else {
      _images!.removeAt(index - oldImages!.length);
      memImages.removeAt(index - oldImages!.length);
    }

    displayImages = [...oldImages!, ...memImages];
    notifyListeners();
  }

  onSubmitPost(BuildContext context, String postId, String userId) async {
    if ((_images!.length + oldImages!.length) < 2) {
      Dialogs.errorDialog(context, "Please add 2 or more images");
      return;
    }
    if (formKey.currentState!.validate()) {
      addEvent(EditPostEvent(state: EditPostEventState.loading));
      try {
        List<dynamic>? imgPaths = [];
        List<MultipartFile> files = [];
        if (_images!.isNotEmpty) {
          _images?.forEach((element) async {
            files.add(MultipartFile.fromFileSync(element.path));
          });
          imgPaths = await _api.uploadImages({"upload": files});
          if (imgPaths == null) return;
        }

        if (oldImages!.length < post!.imgs!.length) {
          List<String> oldImagesToDelete = [];
          post!.imgs!.forEach((element) {
            if (!oldImages!.contains(element)) oldImagesToDelete.add(element);
          });

          await _api.deleteImages(oldImagesToDelete);
          post!.imgs!.forEach((element) {
            if (oldImages!.contains(element)) oldImagesToDelete.add(element);
          });
        }
        try {
          var response = await _api.editPost({
            "user_id": userId,
            "status": status,
            "id": postId,
            "desc": postDescription!.text,
            "title": title!.text,
            "imgs": [...oldImages!, ...imgPaths],
            "last_seen": {
              "location": lastSeenLocation!.text,
              "date": lastSeenDate!.toIso8601String()
            }
          }, postId);
          if (response) Navigator.pop(context, OnPopModel(reloadPrev: true));
        } on NetworkError catch (err) {
          Dialogs.errorDialog(context, err.errorMessage!);
        }
      } on NetworkError catch (err) {
        Dialogs.errorDialog(context, err.errorMessage!);
      }
    }

    addEvent(EditPostEvent(state: EditPostEventState.idle));
  }

  setLastSeenDate(DateTime? date) {
    _lastSeenDate = date;
    notifyListeners();
  }
}
