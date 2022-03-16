import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:go_find_me/locator.dart';
import 'package:go_find_me/modules/auth/authProvider.dart';
import 'package:go_find_me/services/sharedPref.dart';
import 'package:go_find_me/services/sharing_service.dart';
import 'package:go_find_me/themes/theme_colors.dart';
import 'package:go_find_me/ui/splash_view.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  setuplocator();
  SharingService _sharingService = sl<SharingService>();
// get initial links
  final PendingDynamicLinkData? initalLink =
      await _sharingService.dynamicLinks.getInitialLink();
  runApp(GoFindMeApp(dynamicLink: initalLink));
}

class GoFindMeApp extends StatelessWidget {
  final PendingDynamicLinkData? dynamicLink;

  SharedPreferencesService _sharedPref = sl<SharedPreferencesService>();

  GoFindMeApp({Key? key, required this.dynamicLink}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthenticationProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          primaryColor: ThemeColors.primary,
        ),
        home: FutureBuilder<bool>(
            future: isFirstTime(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Container(
                  color: ThemeColors.primary,
                );
              return SplashScreen(
                dynamicLinkData: dynamicLink,
                firstTime: snapshot.data!,
              );
            }),
      ),
    );
  }

  Future<bool> isFirstTime() async {
    var isFirstTime = await _sharedPref.getBool('first_time');
    if (isFirstTime != null && !isFirstTime) {
      _sharedPref.setBool('first_time', false);
      return false;
    } else {
      _sharedPref.setBool('first_time', false);
      return true;
    }
  }
}
