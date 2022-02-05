import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_find_me/components/buttons.dart';
import 'package:go_find_me/components/post_component.dart';
import 'package:go_find_me/components/text_fields.dart';
import 'package:go_find_me/models/OnPopModel.dart';
import 'package:go_find_me/models/PostModel.dart';
import 'package:go_find_me/modules/auth/authProvider.dart';
import 'package:go_find_me/modules/post/dashboard_provider.dart';
import 'package:go_find_me/themes/borderRadius.dart';
import 'package:go_find_me/themes/dropShadows.dart';
import 'package:go_find_me/themes/padding.dart';
import 'package:go_find_me/themes/textStyle.dart';
import 'package:go_find_me/themes/theme_colors.dart';
import 'package:go_find_me/ui/bookmarked_post_page.dart';
import 'package:go_find_me/ui/contributed_posts_page.dart';
import 'package:go_find_me/ui/my_posts_page.dart';
import 'package:intl/intl.dart';
import 'package:go_find_me/ui/contribution.dart';
import 'package:go_find_me/ui/create_post.dart';
import 'package:go_find_me/ui/editPost.dart';
import 'package:go_find_me/ui/result_map_view.dart';
import 'package:provider/provider.dart';
import 'package:wc_flutter_share/wc_flutter_share.dart';
import 'package:http/http.dart' show get;

class DashboardView extends StatefulWidget {
  DashboardView({Key? key}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  DashboardProvider? _dashBoardProvider;

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark // status bar color
        ));
    _dashBoardProvider = DashboardProvider(rootContext: context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => _dashBoardProvider,
      child: Consumer2<DashboardProvider, AuthenticationProvider>(
          builder: (context, dashboardProv, authProv, _) {
        return Scaffold(
          drawer: Drawer(
            child: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: ThemeColors.grey.withOpacity(0.2),
                      radius: 50,
                      child: Icon(
                        Icons.person,
                        color: ThemeColors.grey,
                        size: 50,
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      authProv.currentUser!.username!,
                      style: ThemeTexTStyle.regular(color: ThemeColors.grey),
                    ),
                    Text(
                      authProv.currentUser!.email!,
                      style: ThemeTexTStyle.regular(color: ThemeColors.grey),
                    ),
                  ],
                ),
                Divider(),
                ListTile(
                  title: Text(
                    "My Posts",
                    style: ThemeTexTStyle.regularPrim,
                  ),
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => MyPostsPage()));
                  },
                ),
                ListTile(
                  title: Text(
                    "Bookmarked Posts",
                    style: ThemeTexTStyle.regularPrim,
                  ),
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => BookMarkedPostsPage()));
                  },
                ),
                ListTile(
                  title: Text(
                    "Engaged Posts",
                    style: ThemeTexTStyle.regularPrim,
                  ),
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => EngagedPosts()));
                  },
                ),
                ListTile(
                  title: Text(
                    "Logout",
                    style: ThemeTexTStyle.regularPrim,
                  ),
                  onTap: () {
                    Scaffold.of(context).openDrawer();
                    authProv.logOut(context);
                  },
                )
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            focusColor: ThemeColors.primary,
            child: Icon(Icons.add),
            onPressed: () async {
              OnPopModel? onPopModel = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CreatePostView()));
              if (onPopModel != null && onPopModel.reloadPrev) {
                dashboardProv.getFeedBody();
              }
            },
          ),
          body: SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: RefreshIndicator(
                onRefresh: () async {
                  await dashboardProv.getFeedBody();
                },
                child: CustomScrollView(
                  controller: dashboardProv.scrollContoller,
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
                      delegate: SliverChildListDelegate(dashboardProv
                                      .lastEvent?.state ==
                                  DashBoardEventState.isloading &&
                              (dashboardProv.currentData?.length == 0 ||
                                  dashboardProv.currentData == null)
                          ? [
                              Center(
                                child: CircularProgressIndicator(),
                              ),
                            ]
                          : dashboardProv.currentData?.length == 0 ||
                                  dashboardProv.currentData == null
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
                                            dashboardProv.getFeedBody();
                                          }))
                                ]
                              : [
                                  dashboardProv.lastEvent?.state ==
                                          DashBoardEventState.isloading
                                      ? LinearProgressIndicator()
                                      : SizedBox(),
                                  ...List.generate(
                                      dashboardProv.currentData!.length + 1,
                                      (index) {
                                    if (index ==
                                        dashboardProv.currentData!.length)
                                      return Visibility(
                                        visible:
                                            dashboardProv.lastEvent?.state ==
                                                DashBoardEventState.isloading,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    return PostCard(
                                      onBookmarkPost: () async {
                                        dashboardProv.bookmarkPost(
                                          context,
                                          dashboardProv
                                              .currentData![index]!.id!,
                                        );
                                      },
                                      post: dashboardProv.currentData![index]!,
                                      callBack: dashboardProv.getFeedBody,
                                      deletePost: () async {
                                        dashboardProv.deletePost(
                                            dashboardProv
                                                .currentData![index]!.id!,
                                            context);
                                      },
                                    );
                                  }),
                                  SizedBox(height: 30)
                                ]),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      }),
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
          icon: Icon(Icons.menu),
          color: ThemeColors.primary,
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 25),
            height: 40,
            child: TextField(
              decoration: inputDec(
                hint: "Search",
                prefixIcon: Icon(
                  Icons.search,
                  color: ThemeColors.grey,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        // Icon(
        //   Icons.settings,
        //   color: ThemeColors.primary,
        // ),
      ],
    );
  }
}

class Contribute extends StatelessWidget {
  const Contribute({Key? key, this.images}) : super(key: key);
  final List<String>? images;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(ThemePadding.padBase * 1.5),
        padding: EdgeInsets.all(ThemePadding.padBase * 1.5),
        decoration: BoxDecoration(
          color: ThemeColors.white,
          borderRadius: ThemeBorderRadius.smallRadiusAll,
        ),
        width: 500,
        child: Material(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Do you recognize the person??"),
            SizedBox(
              height: ThemePadding.padBase * 2,
            ),
            Center(
              child: CarouselSlider.builder(
                itemCount: images!.length,
                options: CarouselOptions(
                  enlargeCenterPage: true,
                  height: 350,
                  autoPlay: false,
                  enableInfiniteScroll: false,
                ),
                itemBuilder: (context, index, x) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: ThemeBorderRadius.smallRadiusAll,
                      image: DecorationImage(
                        image: NetworkImage(
                            "https://go-find-me.herokuapp.com/${images![index]}"),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              height: ThemePadding.padBase * 2,
            ),
            Container(
              height: 70,
              child: Row(
                children: [
                  Expanded(
                    child: ThemeButton.ButtonPrim(
                        text: "Yes",
                        onpressed: () {
                          Navigator.of(context).pop(true);
                        }),
                  ),
                  SizedBox(
                    width: ThemePadding.padBase * 1.5,
                  ),
                  Expanded(
                    child: ThemeButton.ButtonSec(
                        text: "No",
                        onpressed: () {
                          Navigator.of(context).pop(false);
                        }),
                  )
                ],
              ),
            )
          ],
        )),
      ),
    );
  }
}
