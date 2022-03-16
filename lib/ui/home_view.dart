import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:go_find_me/locator.dart';
import 'package:go_find_me/models/PostModel.dart';
import 'package:go_find_me/modules/auth/authProvider.dart';
import 'package:go_find_me/themes/theme_colors.dart';
import 'package:go_find_me/ui/create_post.dart';
import 'package:go_find_me/ui/dashboard_view.dart';
import 'package:go_find_me/ui/profile_view.dart';
import 'package:go_find_me/ui/single_post_page.dart';
import 'package:provider/provider.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class HomeView extends StatefulWidget {
  HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      _initNotification();
      PendingDynamicLinkData? dynamicLinkData =
          Provider.of<AuthenticationProvider>(context, listen: false)
              .dynamicLinkData;
      if (dynamicLinkData != null) {
        final Uri uri = dynamicLinkData.link;
        if (uri.path == "/post")
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SinglePostPage(postId: uri.queryParameters["id"] ?? ""),
            ),
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DashboardView(),
      ),
    );
  }

  _initNotification() {
    OneSignal.shared.setExternalUserId(
        Provider.of<AuthenticationProvider>(context, listen: false)
            .currentUser!
            .id!);
  }
}
