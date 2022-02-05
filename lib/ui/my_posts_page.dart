import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_find_me/components/buttons.dart';
import 'package:go_find_me/components/post_component.dart';
import 'package:go_find_me/components/text_fields.dart';
import 'package:go_find_me/modules/auth/authProvider.dart';
// import 'package:go_find_me/modules/post/dashboard_provider.dart';
import 'package:go_find_me/modules/post/my_posts-provider.dart';
import 'package:go_find_me/themes/textStyle.dart';
import 'package:go_find_me/themes/theme_colors.dart';

import 'package:provider/provider.dart';

class MyPostsPage extends StatefulWidget {
  MyPostsPage({Key? key}) : super(key: key);

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  MyPostsProvider? _myPostsProvider;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark // status bar color
        ));
    _myPostsProvider = MyPostsProvider(rootContext: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => _myPostsProvider,
        builder: (context, _) {
          return Scaffold(body:
              Consumer<MyPostsProvider>(builder: (context, myPostProv, _) {
            return SafeArea(
                child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: RefreshIndicator(
                        onRefresh: () async {
                          await myPostProv.getFeedBody();
                        },
                        child: CustomScrollView(
                            controller: myPostProv.scrollController,
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
                                  delegate: SliverChildListDelegate(myPostProv
                                                  .lastEvent?.state ==
                                              MyPostEventState.isloading &&
                                          (myPostProv.currentData?.length ==
                                                  0 ||
                                              myPostProv.currentData == null)
                                      ? [
                                          Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        ]
                                      : myPostProv.currentData?.length == 0 ||
                                              myPostProv.currentData == null
                                          ? [
                                              Center(
                                                child: Text(
                                                  "No Posts To Show",
                                                  style:
                                                      ThemeTexTStyle.headerPrim,
                                                ),
                                              ),
                                              SizedBox(height: 15),
                                              Center(
                                                  child: ThemeButton.ButtonSec(
                                                      text: "Retry",
                                                      onpressed: () {
                                                        myPostProv
                                                            .getFeedBody();
                                                      }))
                                            ]
                                          : [
                                              myPostProv.lastEvent?.state ==
                                                      MyPostEventState.isloading
                                                  ? LinearProgressIndicator()
                                                  : SizedBox(),
                                              ...List.generate(
                                                  myPostProv
                                                          .currentData!.length +
                                                      1, (index) {
                                                if (index ==
                                                    myPostProv
                                                        .currentData!.length)
                                                  return Visibility(
                                                    visible: myPostProv
                                                            .lastEvent?.state ==
                                                        MyPostEventState
                                                            .isloading,
                                                    child: Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  );
                                                return PostCard(
                                                  isBookmarked: Provider.of<
                                                              AuthenticationProvider>(
                                                          context,
                                                          listen: false)
                                                      .currentUser!
                                                      .bookmarked_posts!
                                                      .contains(myPostProv
                                                          .currentData![index]!
                                                          .id!),
                                                  onBookmarkPost: () async {
                                                    myPostProv.bookmarkPost(
                                                      context,
                                                      myPostProv
                                                          .currentData![index]!
                                                          .id!,
                                                    );
                                                  },
                                                  post: myPostProv
                                                      .currentData![index]!,
                                                  callBack:
                                                      myPostProv.getFeedBody,
                                                  deletePost: () async {
                                                    await myPostProv.deletePost(
                                                        myPostProv
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
          "My Posts",
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
