import 'package:flutter/material.dart';
import 'package:go_find_me/components/dialogs.dart';
import 'package:go_find_me/core/network/networkError.dart';
import 'package:go_find_me/locator.dart';
import 'package:go_find_me/models/PostModel.dart';
import 'package:go_find_me/models/PostQueryResponse.dart';
import 'package:go_find_me/modules/auth/authProvider.dart';
import 'package:go_find_me/modules/base_provider.dart';
import 'package:go_find_me/services/api.dart';
import 'package:provider/provider.dart';

enum MyPostEventState { idle, isloading, error, success }

class MyPostEvent<T> {
  final T? data;
  final MyPostEventState state;

  MyPostEvent({this.data, required this.state});
}

class MyPostsProvider extends BaseProvider<MyPostEvent> {
  BuildContext rootContext;
  bool confirmDelete = false;
  Api _api = sl<Api>();
  bool reload = false;
  List<Post?>? currentData;
  String? nextPostPage;
  late ScrollController _scrollController;

  ScrollController get scrollController => _scrollController;

  MyPostsProvider({required this.rootContext}) {
    _scrollController = ScrollController()
      ..addListener(scrollListenerForPagination);
    getFeedBody();
  }

  void scrollListenerForPagination() {
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.position.pixels) _getMorePosts();
    });
  }

  Future<void> _getMorePosts() async {
    if (lastEvent!.state == MyPostEventState.isloading || nextPostPage == null)
      return;

    try {
      addEvent(MyPostEvent(state: MyPostEventState.isloading));
      PostQueryResponse response = await _api.getMyPosts(
          userId:
              Provider.of<AuthenticationProvider>(rootContext, listen: false)
                  .currentUser!
                  .id!,
          url: nextPostPage);
      currentData!.addAll(response.posts!);
      nextPostPage = response.next;
      if (response == null) {
        addEvent(MyPostEvent(state: MyPostEventState.error));
        return;
      }

      addEvent(MyPostEvent(state: MyPostEventState.success));
    } on NetworkError catch (netErr) {
      addEvent(MyPostEvent(state: MyPostEventState.error));
      Dialogs.errorDialog(rootContext, netErr.error);
    }
  }

  Future<void> getFeedBody() async {
    addEvent(MyPostEvent(state: MyPostEventState.isloading));

    try {
      PostQueryResponse response = await _api.getMyPosts(
        userId: Provider.of<AuthenticationProvider>(rootContext, listen: false)
            .currentUser!
            .id!,
      );
      currentData = response.posts;
      nextPostPage = response.next;
      if (response == null) {
        addEvent(MyPostEvent(state: MyPostEventState.error));
        return;
      }

      addEvent(MyPostEvent(state: MyPostEventState.success));
    } on NetworkError catch (netErr) {
      addEvent(MyPostEvent(state: MyPostEventState.error));
      Dialogs.errorDialog(rootContext, netErr.error);
    }
  }

  deletePost(String postId, BuildContext context) async {
    addEvent(MyPostEvent(state: MyPostEventState.isloading));

    try {
      var response = await _api.deletePost(postId);

      Navigator.of(context).pop();
      currentData?.removeWhere((element) => element?.id == postId);
      addEvent(MyPostEvent(state: MyPostEventState.success));
    } on NetworkError catch (err) {
      addEvent(MyPostEvent(state: MyPostEventState.error));
      Dialogs.errorDialog(context, err.error);
      Navigator.of(context).pop();
    }
  }
}
