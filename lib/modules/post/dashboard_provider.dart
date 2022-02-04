import 'package:flutter/material.dart';
import 'package:go_find_me/components/dialogs.dart';
import 'package:go_find_me/core/network/networkError.dart';
import 'package:go_find_me/locator.dart';
import 'package:go_find_me/models/PostModel.dart';
import 'package:go_find_me/models/PostQueryResponse.dart';
import 'package:go_find_me/modules/base_provider.dart';
import 'package:go_find_me/services/api.dart';

enum DashBoardEventState { idel, isloading, error, success }

class DashBoardEvent<T> {
  final DashBoardEventState state;
  final T? data;

  DashBoardEvent({required this.state, this.data});
}

class DashboardProvider extends BaseProvider<DashBoardEvent> {
  BuildContext rootContext;
  bool confirmDelete = false;
  Api _api = sl<Api>();
  bool reload = false;
  List<Post?>? currentData;
  String? nextPostPage;
  late ScrollController _scrollController;

  ScrollController get scrollContoller => _scrollController;

  DashboardProvider({required this.rootContext}) {
    _scrollController = ScrollController()
      ..addListener(scrollListenerForPagination);
    getFeedBody();
  }

  void scrollListenerForPagination() {
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          scrollContoller.position.pixels) _getMorePosts();
    });
  }

  Future<void> _getMorePosts() async {
    if (lastEvent!.state == DashBoardEventState.isloading ||
        nextPostPage == null) return;

    try {
      addEvent(DashBoardEvent(state: DashBoardEventState.isloading));
      PostQueryResponse response = await _api.getPosts(url: nextPostPage);
      currentData!.addAll(response.posts!);
      nextPostPage = response.next;
      if (response == null) {
        addEvent(DashBoardEvent(state: DashBoardEventState.error));
        return;
      }

      addEvent(DashBoardEvent(state: DashBoardEventState.success));
    } on NetworkError catch (netErr) {
      addEvent(DashBoardEvent(state: DashBoardEventState.error));
      Dialogs.errorDialog(rootContext, netErr.error);
    }
  }

  Future<void> getFeedBody() async {
    addEvent(DashBoardEvent(state: DashBoardEventState.isloading));

    try {
      PostQueryResponse response = await _api.getPosts();
      currentData = response.posts;
      nextPostPage = response.next;
      if (response == null) {
        addEvent(DashBoardEvent(state: DashBoardEventState.error));
        return;
      }

      addEvent(DashBoardEvent(state: DashBoardEventState.success));
    } on NetworkError catch (netErr) {
      addEvent(DashBoardEvent(state: DashBoardEventState.error));
      Dialogs.errorDialog(rootContext, netErr.error);
    }
  }

  deletePost(String postId, BuildContext context) async {
    addEvent(DashBoardEvent(state: DashBoardEventState.isloading));

    try {
      var response = await _api.deletePost(postId);

      Navigator.of(context).pop();
      currentData?.removeWhere((element) => element?.id == postId);
      addEvent(DashBoardEvent(state: DashBoardEventState.success));
    } on NetworkError catch (err) {
      addEvent(DashBoardEvent(state: DashBoardEventState.error));
      Dialogs.errorDialog(context, err.error);
      Navigator.of(context).pop();
    }
  }
}
