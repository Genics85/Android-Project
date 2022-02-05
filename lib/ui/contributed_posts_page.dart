import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_find_me/components/buttons.dart';
import 'package:go_find_me/components/post_component.dart';
import 'package:go_find_me/components/text_fields.dart';
import 'package:go_find_me/modules/post/contributed_posts_provider.dart';
// import 'package:go_find_me/modules/post/dashboard_provider.dart';
import 'package:go_find_me/modules/post/my_posts-provider.dart';
import 'package:go_find_me/themes/textStyle.dart';
import 'package:go_find_me/themes/theme_colors.dart';

import 'package:provider/provider.dart';

class EngagedPosts extends StatefulWidget {
  EngagedPosts({Key? key}) : super(key: key);

  @override
  State<EngagedPosts> createState() => _EngagedPostsState();
}

class _EngagedPostsState extends State<EngagedPosts> {
  ContributedPostsProvider? _myPostsProvider;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark // status bar color
        ));
    _myPostsProvider = ContributedPostsProvider(rootContext: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => _myPostsProvider,
        builder: (context, _) {
          return Scaffold(body: Consumer<ContributedPostsProvider>(
              builder: (context, contributedPostsProv, _) {
            return SafeArea(
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: RefreshIndicator(
                        onRefresh: () async {
                          await contributedPostsProv.getFeedBody();
                        },
                        child: CustomScrollView(
                            controller: contributedPostsProv.scrollController,
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
                                      contributedPostsProv.lastEvent?.state ==
                                                  ContributedPostsState
                                                      .isloading &&
                                              (contributedPostsProv.currentData
                                                          ?.length ==
                                                      0 ||
                                                  contributedPostsProv
                                                          .currentData ==
                                                      null)
                                          ? [
                                              Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ]
                                          : contributedPostsProv.currentData
                                                          ?.length ==
                                                      0 ||
                                                  contributedPostsProv
                                                          .currentData ==
                                                      null
                                              ? [
                                                  Center(
                                                    child: Text(
                                                      "No Posts To Show",
                                                      style: ThemeTexTStyle
                                                          .headerPrim,
                                                    ),
                                                  ),
                                                  SizedBox(height: 15),
                                                  Center(
                                                      child:
                                                          ThemeButton.ButtonSec(
                                                              text: "Retry",
                                                              onpressed: () {
                                                                contributedPostsProv
                                                                    .getFeedBody();
                                                              }))
                                                ]
                                              : [
                                                  contributedPostsProv.lastEvent
                                                              ?.state ==
                                                          ContributedPostsState
                                                              .isloading
                                                      ? LinearProgressIndicator()
                                                      : SizedBox(),
                                                  ...List.generate(
                                                      contributedPostsProv
                                                              .currentData!
                                                              .length +
                                                          1, (index) {
                                                    if (index ==
                                                        contributedPostsProv
                                                            .currentData!
                                                            .length)
                                                      return Visibility(
                                                        visible:
                                                            contributedPostsProv
                                                                    .lastEvent
                                                                    ?.state ==
                                                                ContributedPostsState
                                                                    .isloading,
                                                        child: Center(
                                                          child:
                                                              CircularProgressIndicator(),
                                                        ),
                                                      );
                                                    return PostCard(
                                                      onBookmarkPost: () async {
                                                        contributedPostsProv
                                                            .bookmarkPost(
                                                          context,
                                                          contributedPostsProv
                                                              .currentData![
                                                                  index]!
                                                              .id!,
                                                        );
                                                      },
                                                      post: contributedPostsProv
                                                          .currentData![index]!,
                                                      callBack:
                                                          contributedPostsProv
                                                              .getFeedBody,
                                                      deletePost: () async {
                                                        await contributedPostsProv
                                                            .deletePost(
                                                                contributedPostsProv
                                                                    .currentData![
                                                                        index]!
                                                                    .id!,
                                                                context);
                                                      },
                                                    );
                                                  }),
                                                  SizedBox(height: 30)
                                                ]))
                            ]))));
          }));
        });
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
