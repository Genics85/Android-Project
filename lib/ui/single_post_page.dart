import 'package:flutter/material.dart';
import 'package:go_find_me/components/buttons.dart';
import 'package:go_find_me/components/post_component.dart';
import 'package:go_find_me/components/text_fields.dart';
import 'package:go_find_me/models/PostModel.dart';
import 'package:go_find_me/themes/textStyle.dart';
import 'package:go_find_me/themes/theme_colors.dart';

class SinglePostPage extends StatelessWidget {
  SinglePostPage(
      {Key? key,
      required this.postId,
      this.postModel,
      required this.isBookmarked,
      required this.callBack,
      required this.onBookmarkPost,
      required this.deletePost})
      : super(key: key);
  final String postId;
  final bool isBookmarked;
  final Future<void> Function() callBack;
  final Future<void> Function() onBookmarkPost;
  final Future<void> Function() deletePost;

  Post? postModel;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: RefreshIndicator(
            onRefresh: () async {},
            child: CustomScrollView(
              // controller: bookmarkedPostProv.scrollController,
              clipBehavior: Clip.none,
              slivers: [
                SliverAppBar(
                  floating: true,
                  title: AppBarWidget(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  automaticallyImplyLeading: false,
                  elevation: 20,
                  shadowColor: ThemeColors.black,
                  backgroundColor: ThemeColors.white,
                ),
                SliverList(
                    delegate: SliverChildListDelegate(
                  isLoading
                      ? [
                          Center(
                            child: CircularProgressIndicator(),
                          ),
                        ]
                      : postModel == null
                          ? [
                              Center(
                                child: Text(
                                  "No Posts To Show",
                                  style: ThemeTexTStyle.headerPrim,
                                ),
                              ),
                              SizedBox(height: 15),
                              Center(
                                  child: ThemeButton.ButtonSec(
                                      text: "Retry",
                                      onpressed: () {
                                        // bookmarkedPostProv.getFeedBody();
                                      }))
                            ]
                          : [
                              PostCard(
                                  post: postModel!,
                                  callBack: callBack,
                                  deletePost: deletePost,
                                  onBookmarkPost: onBookmarkPost,
                                  isBookmarked: isBookmarked,
                                  onShare: () async {})
                            ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppBarWidget extends StatelessWidget with InputDec {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          color: ThemeColors.primary,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        Expanded(
            child: Text(
          "Engaged Posts",
          style: ThemeTexTStyle.titleTextStyleBlack
              .copyWith(color: ThemeColors.primary),
        )),
        // Icon(
        //   Icons.settings,
        //   color: ThemeColors.primary,
        // ),
      ],
    );
  }
}
