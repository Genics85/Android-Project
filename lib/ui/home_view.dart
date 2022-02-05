import 'package:flutter/material.dart';
import 'package:go_find_me/locator.dart';
import 'package:go_find_me/modules/auth/authProvider.dart';
import 'package:go_find_me/themes/theme_colors.dart';
import 'package:go_find_me/ui/create_post.dart';
import 'package:go_find_me/ui/dashboard_view.dart';
import 'package:go_find_me/ui/profile_view.dart';
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
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _initNotification();
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
    OneSignal.shared.setAppId("d03e5a6b-6f44-4784-9a1b-5c12d791ef3f");
    OneSignal.shared.setExternalUserId(
        Provider.of<AuthenticationProvider>(context, listen: false)
            .currentUser!
            .id!);
  }
}
