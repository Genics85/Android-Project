import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_find_me/components/buttons.dart';
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
                                      post: dashboardProv.currentData![index]!,
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

class PostCard extends StatefulWidget {
  const PostCard({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool descContainerSize = false;

  Future<void> _share({required String text, required String imageLink}) async {
    var response =
        await get(Uri.parse("https://go-find-me.herokuapp.com/$imageLink"));
    await WcFlutterShare.share(
      sharePopupTitle: "GoFindMe",
      text: """$text      
      $text""",
      bytesOfFile: response.bodyBytes,
      fileName: "Missing.png",
      mimeType: 'image/png',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardProvider>(builder: (context, dashboardProv, _) {
      return Container(
        padding: EdgeInsets.all(ThemePadding.padBase * 2.0),
        margin: EdgeInsets.symmetric(vertical: ThemePadding.padBase),
        decoration: BoxDecoration(
          color: ThemeColors.white,
          borderRadius: ThemeBorderRadius.smallRadiusAll,
          boxShadow: ThemeDropShadow.smallShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Missing: ${widget.post.title}",
                    style: ThemeTexTStyle.titleTextStyleBlack,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                widget.post.userId ==
                        Provider.of<AuthenticationProvider>(context)
                            .currentUser
                            ?.id
                    ? InkWell(
                        onTap: () async {
                          OnPopModel res = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                    "Post Actions",
                                    style: ThemeTexTStyle.headerPrim,
                                  ),
                                  content: PostOptionsDialog(
                                    post: widget.post,
                                    deletePost: () {
                                      dashboardProv.deletePost(
                                          widget.post.id!, context);
                                    },
                                  ),
                                );
                              });
                          if (res.reloadPrev) dashboardProv.getFeedBody();
                        },
                        child: Icon(
                          Icons.more_vert,
                          color: ThemeColors.grey,
                        ))
                    : SizedBox.shrink(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Last Seen: ${DateFormat("dd, MMM y").format(widget.post.lastSeen!.date ?? DateTime.now())}",
                    style: ThemeTexTStyle.regular(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: ThemePadding.padBase),
                Text(DateFormat("dd, MMM")
                    .format(widget.post.createdAt ?? DateTime.now()))
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "@ ${widget.post.lastSeen!.location}",
                    style: ThemeTexTStyle.regular(),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  "Status: ",
                  style: ThemeTexTStyle.regular(color: ThemeColors.grey),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: widget.post.status == "Not Found"
                        ? ThemeColors.accent
                        : ThemeColors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(
                      vertical: ThemePadding.padBase / 4,
                      horizontal: ThemePadding.padBase),
                  child: Text(
                    widget.post.status!,
                    style: ThemeTexTStyle.regular(color: ThemeColors.white),
                  ),
                )
              ],
            ),
            SizedBox(
              height: ThemePadding.padBase,
            ),
            ImagesLogic(
              imgs: widget.post.imgs,
            ),
            SizedBox(
              height: ThemePadding.padBase,
            ),
            Container(
              // constraints: descContainerSize == null
              //     ? null
              //     : BoxConstraints(maxHeight: descContainerSize!),
              child: Text(
                widget.post.desc ?? "",
                maxLines: descContainerSize ? null : 3,
                overflow: descContainerSize ? null : TextOverflow.fade,
                style: ThemeTexTStyle.regular(),
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  descContainerSize = !descContainerSize;
                });
              },
              child: Container(
                padding: EdgeInsets.all(5),
                child: Text(
                  descContainerSize ? "Show Less" : "Read More",
                  style: ThemeTexTStyle.regular(color: ThemeColors.primary),
                ),
              ),
            ),
            Container(
              // height: 50,
              padding: EdgeInsets.all(ThemePadding.padBase),
              child: widget.post.userId ==
                      Provider.of<AuthenticationProvider>(context)
                          .currentUser
                          ?.id
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.how_to_vote,
                              color: ThemeColors.grey,
                            ),
                            SizedBox(
                              width: ThemePadding.padBase / 2,
                            ),
                            Text(
                              "${widget.post.contributions!.length}",
                              style: ThemeTexTStyle.regular(
                                  color: ThemeColors.grey),
                            )
                          ],
                        ),
                        InkWell(
                          onTap: () async {
                            await _share(
                                text: widget.post.desc!,
                                imageLink: widget.post.imgs![0]);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.share,
                                color: ThemeColors.grey,
                              ),
                              SizedBox(
                                width: ThemePadding.padBase / 2,
                              ),
                              Text(
                                "${widget.post.shares!}",
                                style: ThemeTexTStyle.regular(
                                    color: ThemeColors.grey),
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ResultMapView();
                            }));
                          },
                          child: Icon(
                            Icons.list_alt,
                            color: ThemeColors.grey,
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.how_to_vote,
                              color: ThemeColors.grey,
                            ),
                            SizedBox(
                              width: ThemePadding.padBase / 2,
                            ),
                            Text(
                              "${widget.post.contributions!.length}",
                              style: ThemeTexTStyle.regular(
                                  color: ThemeColors.grey),
                            )
                          ],
                        ),
                        InkWell(
                          onTap: () async {
                            await _share(
                                text: widget.post.desc!,
                                imageLink: widget.post.imgs![0]);
                          },
                          child: Row(
                            children: [
                              Icon(
                                Icons.share,
                                color: ThemeColors.grey,
                              ),
                              SizedBox(
                                width: ThemePadding.padBase / 2,
                              ),
                              Text(
                                "${widget.post.shares!}",
                                style: ThemeTexTStyle.regular(
                                    color: ThemeColors.grey),
                              )
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            bool response = await showDialog(
                                context: context,
                                builder: (context) {
                                  return Contribute(
                                    images: widget.post.imgs,
                                  );
                                });
                            if (response) {
                              OnPopModel? onPopModel =
                                  await Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                return Contribution(
                                  postId: widget.post.id!,
                                );
                              }));
                              if (onPopModel != null && onPopModel.reloadPrev) {
                                dashboardProv.getFeedBody();
                              }
                            }
                          },
                          child: Icon(
                            Icons.comment,
                            color: ThemeColors.grey,
                          ),
                        ),
                      ],
                    ),
            )
          ],
        ),
      );
    });
  }
}

class PostOptionsDialog extends StatefulWidget {
  PostOptionsDialog({Key? key, required this.post, required this.deletePost})
      : super(key: key);
  final Post post;
  final Function deletePost;

  @override
  State<PostOptionsDialog> createState() => _PostOptionsDialogState();
}

class _PostOptionsDialogState extends State<PostOptionsDialog> {
  bool isConfirmDelete = false;

  @override
  Widget build(BuildContext context) {
    return isConfirmDelete
        ? Row(
            children: [
              Expanded(
                child: ThemeButton.ButtonPrim(
                  text: "Yes",
                  onpressed: widget.deletePost,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: ThemeButton.ButtonSec(
                    text: "No",
                    onpressed: () {
                      setState(() {
                        isConfirmDelete = !isConfirmDelete;
                      });
                    }),
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Edit Post"),
                onTap: () async {
                  OnPopModel res = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return EditPost(
                      post: widget.post,
                    );
                  }));
                  if (res.reloadPrev)
                    Navigator.of(context).pop(OnPopModel(reloadPrev: true));
                },
              ),
              ListTile(
                title: Text("Delete Post"),
                onTap: () {
                  setState(() {
                    isConfirmDelete = !isConfirmDelete;
                  });
                },
              )
            ],
          );

    ;
  }
}

class ImagesLogic extends StatelessWidget {
  ImagesLogic({Key? key, this.imgs}) : super(key: key);

  List<String>? imgs;
  BuildContext? context;

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Container(
      height: 200,
      child: imgs!.length == 2
          ? Column(
              children: [
                Expanded(
                  child: Row(children: [
                    Expanded(child: imageContainer(imgs![0], 0)),
                    SizedBox(
                      width: ThemePadding.padBase / 2,
                    ),
                    Expanded(child: imageContainer(imgs![1], 1)),
                  ]),
                ),
              ],
            )
          : imgs!.length == 3
              ? Row(
                  children: [
                    Expanded(
                      child: Column(children: [
                        Expanded(child: imageContainer(imgs![0], 0)),
                        SizedBox(
                          height: ThemePadding.padBase / 2,
                        ),
                        Expanded(child: imageContainer(imgs![2], 2)),
                      ]),
                    ),
                    SizedBox(
                      width: ThemePadding.padBase / 2,
                    ),
                    Expanded(
                      child: Column(children: [
                        Expanded(child: imageContainer(imgs![1], 1)),
                      ]),
                    ),
                  ],
                )
              : imgs!.length > 4
                  ? Column(
                      children: [
                        Expanded(
                          child: Row(children: [
                            Expanded(child: imageContainer(imgs![0], 0)),
                            SizedBox(
                              width: ThemePadding.padBase / 2,
                            ),
                            Expanded(child: imageContainer(imgs![1], 1)),
                          ]),
                        ),
                        SizedBox(
                          height: ThemePadding.padBase / 2,
                        ),
                        Expanded(
                          child: Row(children: [
                            Expanded(child: imageContainer(imgs![2], 1)),
                            SizedBox(
                              width: ThemePadding.padBase / 2,
                            ),
                            Expanded(
                                child: Stack(
                              children: [
                                imageContainer(imgs![3], 3),
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return DisplayImages(
                                            images: imgs,
                                            initialPage: 3,
                                          );
                                        });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          ThemeBorderRadius.smallRadiusAll,
                                      color: ThemeColors.black.withOpacity(0.5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "+${imgs!.length - 4} More",
                                        style: ThemeTexTStyle.regular(
                                            color: ThemeColors.white),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            )),
                          ]),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Row(children: [
                            Expanded(child: imageContainer(imgs![0], 1)),
                            SizedBox(
                              width: ThemePadding.padBase / 2,
                            ),
                            Expanded(child: imageContainer(imgs![1], 1)),
                          ]),
                        ),
                        SizedBox(
                          height: ThemePadding.padBase / 2,
                        ),
                        Expanded(
                          child: Row(children: [
                            Expanded(child: imageContainer(imgs![2], 2)),
                            SizedBox(
                              width: ThemePadding.padBase / 2,
                            ),
                            Expanded(child: imageContainer(imgs![3], 3)),
                          ]),
                        ),
                      ],
                    ),
    );
  }

  InkWell imageContainer(String src, index) {
    return InkWell(
      onTap: () {
        showDialog(
            context: context!,
            builder: (context) {
              return DisplayImages(
                images: imgs,
                initialPage: index,
              );
            });
      },
      child: Container(
        decoration: BoxDecoration(
            color: ThemeColors.grey.withOpacity(0.5),
            borderRadius: ThemeBorderRadius.smallRadiusAll,
            image: DecorationImage(
                image: NetworkImage(
                  "https://go-find-me.herokuapp.com/$src",
                ),
                fit: BoxFit.cover)),
      ),
    );
  }
}

class DisplayImages extends StatelessWidget {
  DisplayImages({
    Key? key,
    @required this.images,
    this.initialPage,
  }) : super(key: key);
  final List<String>? images;
  final int? initialPage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.black.withOpacity(0.5),
      appBar: AppBar(
        backgroundColor: ThemeColors.black.withOpacity(0.5),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Center(
            child: CarouselSlider.builder(
              itemCount: images!.length,
              options: CarouselOptions(
                initialPage: initialPage ?? 0,
                enlargeCenterPage: true,
                height: 500,
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
