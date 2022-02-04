import 'package:flutter/material.dart';
import 'package:go_find_me/locator.dart';
import 'package:go_find_me/modules/auth/authProvider.dart';
import 'package:go_find_me/services/sharedPref.dart';
import 'package:go_find_me/themes/theme_colors.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key, required this.firstTime}) : super(key: key);
  final bool firstTime;

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 1500), () {
      Provider.of<AuthenticationProvider>(context, listen: false)
          .getStoredUser(context, firstTime: widget.firstTime);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationProvider>(builder: (context, authProv, _) {
      return Scaffold(
        body: Container(
          color: ThemeColors.primary,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "GoFindMe",
                        style: TextStyle(
                            color: ThemeColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 30),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 40,
              )
            ],
          ),
        ),
      );
    });
  }
}
