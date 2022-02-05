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

enum ContributedPostsState { idle, isloading, error, success }

class ContributedPostEvent<T> {
  final T? data;
  final ContributedPostsState state;

  ContributedPostEvent({this.data, required this.state});
}

class ContributedPostsProvider extends BaseProvider<ContributedPostEvent> {
  BuildContext rootContext;
  bool confirmDelete = false;
  Api _api = sl<Api>();
  bool reload = false;
  List<Post?>? currentData;
  String? nextPostPage;
  late ScrollController _scrollController;

  ScrollController get scrollController => _scrollController;

  ContributedPostsProvider({required this.rootContext}) {
    _scrollController = ScrollController()
      ..addListener(scrollListenerForPagination);
    getFeedBody();
  }

  bookmarkPost(BuildContext context, String id) async {
    addEvent(ContributedPostEvent(state: ContributedPostsState.isloading));

    try {
      if (Provider.of<AuthenticationProvider>(rootContext, listen: false)
          .currentUser!
          .bookmarked_posts!
          .contains(id))
        await _api.unBookmarkPost(
          userId:
              Provider.of<AuthenticationProvider>(rootContext, listen: false)
                  .currentUser!
                  .id!,
          postId: id,
        );
      else
        await _api.bookmarkPost(
          userId:
              Provider.of<AuthenticationProvider>(rootContext, listen: false)
                  .currentUser!
                  .id!,
          postId: id,
        );
      Navigator.of(context).pop();
      addEvent(ContributedPostEvent(state: ContributedPostsState.success));
    } on NetworkError catch (netErr) {
      Navigator.of(context).pop();
      addEvent(ContributedPostEvent(state: ContributedPostsState.error));
      Dialogs.errorDialog(rootContext, netErr.error);
    }
  }

  void scrollListenerForPagination() {
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent ==
          _scrollController.position.pixels) _getMorePosts();
    });
  }

  Future<void> _getMorePosts() async {
    if (lastEvent!.state == ContributedPostsState.isloading ||
        nextPostPage == null) return;

    try {
      addEvent(ContributedPostEvent(state: ContributedPostsState.isloading));
      PostQueryResponse response = await _api.getContributedPosts(
          userId:
              Provider.of<AuthenticationProvider>(rootContext, listen: false)
                  .currentUser!
                  .id!,
          url: nextPostPage);
      currentData!.addAll(response.posts!);
      nextPostPage = response.next;
      if (response == null) {
        addEvent(ContributedPostEvent(state: ContributedPostsState.error));
        return;
      }

      addEvent(ContributedPostEvent(state: ContributedPostsState.success));
    } on NetworkError catch (netErr) {
      addEvent(ContributedPostEvent(state: ContributedPostsState.error));
      Dialogs.errorDialog(rootContext, netErr.error);
    }
  }

  Future<void> getFeedBody() async {
    addEvent(ContributedPostEvent(state: ContributedPostsState.isloading));

    try {
      PostQueryResponse response = await _api.getContributedPosts(
        userId: Provider.of<AuthenticationProvider>(rootContext, listen: false)
            .currentUser!
            .id!,
      );
      currentData = response.posts;
      nextPostPage = response.next;
      if (response == null) {
        addEvent(ContributedPostEvent(state: ContributedPostsState.error));
        return;
      }

      addEvent(ContributedPostEvent(state: ContributedPostsState.success));
    } on NetworkError catch (netErr) {
      addEvent(ContributedPostEvent(state: ContributedPostsState.error));
      Dialogs.errorDialog(rootContext, netErr.error);
    }
  }

  deletePost(String postId, BuildContext context) async {
    addEvent(ContributedPostEvent(state: ContributedPostsState.isloading));

    try {
      var response = await _api.deletePost(postId);

      Navigator.of(context).pop();
      currentData?.removeWhere((element) => element?.id == postId);
      addEvent(ContributedPostEvent(state: ContributedPostsState.success));
    } on NetworkError catch (err) {
      addEvent(ContributedPostEvent(state: ContributedPostsState.error));
      Navigator.of(context).pop();
      Dialogs.errorDialog(context, err.error);
    }
  }
}
