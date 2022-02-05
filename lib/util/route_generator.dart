import 'package:flutter/material.dart';
import 'package:go_find_me/models/PostModel.dart';
import 'package:go_find_me/ui/contribution.dart';
import 'package:go_find_me/ui/editPost.dart';
import 'package:go_find_me/ui/home_view.dart';
import 'package:go_find_me/ui/login_view.dart';
import 'package:go_find_me/ui/result_map_view.dart';
import 'package:go_find_me/ui/rootView.dart';
import 'package:go_find_me/ui/signup_view.dart';
import 'package:go_find_me/ui/splash_view.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings setting) {
    switch (setting.name) {
      // case "/root":
      //   return MaterialPageRoute(builder: (context) => RootView());

      case "/dashboard":
        return MaterialPageRoute(builder: (context) => HomeView());
      // case "/":
      //   return MaterialPageRoute(builder: (context) => SplashScreen());
      case "/postResultMap":
        return MaterialPageRoute(builder: (context) => ResultMapView());
      case "/login":
        return MaterialPageRoute(builder: (context) => Login());
      case "/signup":
        return MaterialPageRoute(builder: (context) => SignUp());
      case "/edit_post":
        final post = setting.arguments as Post;
        return MaterialPageRoute(
            builder: (context) => EditPost(
                  post: post,
                ));
      case "/contribution":
        final postId = setting.arguments as String;
        return MaterialPageRoute(
            builder: (context) => Contribution(
                  postId: postId,
                ));

      default:
      // return MaterialPageRoute(builder: (context) => SplashScreen());
    }
  }
}

class Not extends StatelessWidget {
  const Not({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text("Not Found"),
      ),
    );
  }
}
