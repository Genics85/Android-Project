import 'package:flutter/material.dart';
import 'package:go_find_me/components/buttons.dart';
import 'package:go_find_me/themes/theme_colors.dart';
import 'package:go_find_me/ui/login_view.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ThemeColors.primary,
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  "Welcome",
                  style: TextStyle(
                      color: ThemeColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    padding: EdgeInsets.only(right: 30),
                    child: ThemeButton.ButtonSec(
                        text: "Continue",
                        onpressed: () {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (context) => Login()));
                        })),
              ],
            ),
            SizedBox(
              height: 50,
            )
          ],
        )));
  }
}
