import 'package:flutter/material.dart';
import 'package:go_find_me/locator.dart';
import 'package:go_find_me/modules/auth/authProvider.dart';
import 'package:go_find_me/services/sharedPref.dart';
import 'package:go_find_me/themes/theme_colors.dart';
import 'package:go_find_me/ui/splash_view.dart';
import 'package:provider/provider.dart';

void main() {
  setuplocator();
  runApp(GoFindMeApp());
}

class GoFindMeApp extends StatelessWidget {
  SharedPreferencesService _sharedPref = sl<SharedPreferencesService>();
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
