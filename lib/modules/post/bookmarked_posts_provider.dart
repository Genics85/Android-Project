import 'package:flutter/material.dart';
import 'package:go_find_me/components/dialogs.dart';
import 'package:go_find_me/core/network/networkError.dart';
import 'package:go_find_me/locator.dart';
import 'package:go_find_me/models/PostModel.dart';
import 'package:go_find_me/models/PostQueryResponse.dart';
import 'package:go_find_me/models/UserModel.dart';
import 'package:go_find_me/modules/auth/authProvider.dart';
import 'package:go_find_me/modules/base_provider.dart';
import 'package:go_find_me/services/api.dart';
import 'package:provider/provider.dart';

enum BookMarkedPostsProviderState { idle, isloading, error, success }

class BookMarkedPostsEvent<T> {
  final T? data;
  final BookMarkedPostsProviderState state;

  BookMarkedPostsEvent({this.data, required this.state});
}

class BookMarkedPostsProvider extends BaseProvider<BookMarkedPostsEvent> {
  BuildContext rootContext;
  bool confirmDelete = false;
  Api _api = sl<Api>();
  bool reload = false;
  List<Post?>? currentData;
  String? nextPostPage;
  late ScrollController _scrollController;

  ScrollController get scrollController => _scrollController;

  BookMarkedPostsProvider({required this.rootContext}) {
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
    if (lastEvent!.state == BookMarkedPostsProviderState.isloading ||
        nextPostPage == null) return;

    try {
      addEvent(
          BookMarkedPostsEvent(state: BookMarkedPostsProviderState.isloading));
      PostQueryResponse response = await _api.getBookmarkedPost(
          userId:
              Provider.of<AuthenticationProvider>(rootContext, listen: false)
                  .currentUser!
                  .id!,
          url: nextPostPage);
      currentData!.addAll(response.posts!);
      nextPostPage = response.next;
      if (response == null) {
        addEvent(
            BookMarkedPostsEvent(state: BookMarkedPostsProviderState.error));
        return;
      }

      addEvent(
          BookMarkedPostsEvent(state: BookMarkedPostsProviderState.success));
    } on NetworkError catch (netErr) {
      addEvent(BookMarkedPostsEvent(state: BookMarkedPostsProviderState.error));
      Dialogs.errorDialog(rootContext, netErr.error);
    }
  }

  Future<void> getFeedBody() async {
    addEvent(
        BookMarkedPostsEvent(state: BookMarkedPostsProviderState.isloading));

    try {
      PostQueryResponse response = await _api.getBookmarkedPost(
        userId: Provider.of<AuthenticationProvider>(rootContext, listen: false)
            .currentUser!
            .id!,
      );
      currentData = response.posts;
      nextPostPage = response.next;
      if (response == null) {
        addEvent(
            BookMarkedPostsEvent(state: BookMarkedPostsProviderState.error));
        return;
      }

      addEvent(
          BookMarkedPostsEvent(state: BookMarkedPostsProviderState.success));
    } on NetworkError catch (netErr) {
      addEvent(BookMarkedPostsEvent(state: BookMarkedPostsProviderState.error));
      Dialogs.errorDialog(rootContext, netErr.error);
    }
  }

  bookmarkPost(BuildContext context, String id) async {
    addEvent(
        BookMarkedPostsEvent(state: BookMarkedPostsProviderState.isloading));

    try {
      if (Provider.of<AuthenticationProvider>(rootContext, listen: false)
          .currentUser!
          .bookmarked_posts!
          .contains(id)) {
        final UserModel user = await _api.unBookmarkPost(
          userId:
              Provider.of<AuthenticationProvider>(rootContext, listen: false)
                  .currentUser!
                  .id!,
          postId: id,
        );
        Provider.of<AuthenticationProvider>(context, listen: false)
            .addCurrentUser(user);
      } else {
        final UserModel user = await _api.bookmarkPost(
          userId:
              Provider.of<AuthenticationProvider>(rootContext, listen: false)
                  .currentUser!
                  .id!,
          postId: id,
        );

        Provider.of<AuthenticationProvider>(context, listen: false)
            .addCurrentUser(user);
      }
      Navigator.of(context).pop();
      addEvent(
          BookMarkedPostsEvent(state: BookMarkedPostsProviderState.success));
      getFeedBody();
    } on NetworkError catch (netErr) {
      Navigator.of(context).pop();
      addEvent(BookMarkedPostsEvent(state: BookMarkedPostsProviderState.error));
      Dialogs.errorDialog(rootContext, netErr.error);
    }
  }

  deletePost(String postId, BuildContext context) async {
    addEvent(
        BookMarkedPostsEvent(state: BookMarkedPostsProviderState.isloading));

    try {
      var response = await _api.deletePost(postId);

      Navigator.of(context).pop();
      currentData?.removeWhere((element) => element?.id == postId);
      addEvent(
          BookMarkedPostsEvent(state: BookMarkedPostsProviderState.success));
    } on NetworkError catch (err) {
      Navigator.of(context).pop();
      addEvent(BookMarkedPostsEvent(state: BookMarkedPostsProviderState.error));
      Dialogs.errorDialog(context, err.error);
    }
  }
}
