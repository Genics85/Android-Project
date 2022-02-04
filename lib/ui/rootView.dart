// import 'package:flutter/material.dart';
// import 'package:go_find_me/blocs/authenticationBloc.dart';
// import 'package:go_find_me/locator.dart';
// import 'package:go_find_me/models/UserModel.dart';
// import 'package:go_find_me/ui/home_view.dart';
// import 'package:go_find_me/ui/login_view.dart';

// class RootView extends StatelessWidget {
//   RootView({Key? key}) : super(key: key);
//   // AuthenticationBloc _authBloc = sl<AuthenticationBloc>();

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder<UserModel?>(
//         stream: _authBloc.userModelStream,
//         builder: (context, snapshot) {
//           return snapshot.data == null ? Login() : HomeView();
//         });
//   }
// }
