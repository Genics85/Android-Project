// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// // import 'package:email_validator/email_validator.dart';
// import 'package:go_find_me/locator.dart';
// import 'package:go_find_me/models/UserModel.dart';
// import 'package:go_find_me/services/api.dart';
// import 'package:go_find_me/themes/textStyle.dart';
// import 'package:go_find_me/themes/theme_colors.dart';
// import 'package:go_find_me/ui/home_view.dart';
// import 'package:go_find_me/ui/login_view.dart';

// class AuthenticationBloc {
//   GoogleSignIn _googleSignIn = GoogleSignIn();
//   Api _api = sl<Api>();

//   UserModel? user;
//   StreamController<UserModel?> userModel = StreamController<UserModel?>();
//   Stream<UserModel?> get userModelStream => userModel.stream;
//   Sink<UserModel?> get userModelSink => userModel.sink;

//   GoogleSignInAccount? googleAccount;

//   // Login TextEditor Controllers
//   TextEditingController loginPassworrd = TextEditingController();
//   TextEditingController loginEmail = TextEditingController();


//   // Signup TextEditor Controllers
//   TextEditingController signUpPassword = TextEditingController();
//   TextEditingController singupEmail = TextEditingController();
//   TextEditingController signUpUsername = TextEditingController();



//   StreamController<bool> isTokenAuthenticating = StreamController<bool>();
//   Stream<bool> get isTokenAuthenticatingStream => isTokenAuthenticating.stream;
//   Sink<bool> get isTokenAuthenticatingSink => isTokenAuthenticating.sink;

//   StreamController<bool> isAuthenticating = StreamController<bool>.broadcast();
//   Stream<bool> get isAuthenticatingStream => isAuthenticating.stream;
//   Sink<bool> get isAuthenticatingSink => isAuthenticating.sink;

//   tokenAuthentication(BuildContext context) async {
//     bool isInternetConnected = true;
//     isTokenAuthenticatingSink.add(true);
//     UserModel? result =
//         await _api.tokenAuthentication().onError((error, stackTrace) {
//       if (error is DioError &&
//           error.type == DioErrorType.other &&
//           error.error == SocketException) isInternetConnected = false;
//     });
//     if (result != null) {
//       user = result;
//       userModelSink.add(result);
//       print("dashboard");
//       isTokenAuthenticatingSink.add(false);
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => HomeView()));
//     } else if (!isInternetConnected) {
//       isTokenAuthenticatingSink.add(false);
//       postsenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             "Check internet Connectivity",
//             style: ThemeTexTStyle.regularwhite,
//           ),
//           backgroundColor: ThemeColors.accent,
//         ),
//       );
//     } else {
//       print("auth");
//       isTokenAuthenticatingSink.add(false);
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => Login()));
//     }
//   }

//   emailLogin(BuildContext context) async {
//     isAuthenticatingSink.add(true);
//     UserModel? result = await _api.emailLogin({
//       "identity": loginEmail.text,
//       "password": loginPassworrd.text,
//     }).onError((err, stacktrace) {
//       isAuthenticatingSink.add(false);
//       if (err is DioError) {
//         if (err is DioError &&
//             err.type == DioErrorType.other &&
//             err.error == SocketException) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 "Check internet Connectivity",
//                 style: ThemeTexTStyle.regularwhite,
//               ),
//               backgroundColor: ThemeColors.accent,
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(err.response?.data["message"]),
//               backgroundColor: ThemeColors.accent,
//             ),
//           );
//         }
//       }
//     });
//     isAuthenticatingSink.add(false);
//     if (result != null) {
//       user = result;
//       userModelSink.add(result);
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => HomeView()));
//     }
//   }

//   emailSignUp(BuildContext context) async {
//     isAuthenticatingSink.add(true);
//     UserModel? result = await _api.emailSignUp({
//       "username": signUpUsername.text,
//       "password": signUpPassword.text,
//       "email": singupEmail.text,
//     }).onError((err, stacktrace) {
//       isAuthenticatingSink.add(false);
//       if (err is DioError) {
//         if (err is DioError &&
//             err.type == DioErrorType.other &&
//             err.error == SocketException) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 "Check internet Connectivity",
//                 style: ThemeTexTStyle.regularwhite,
//               ),
//               backgroundColor: ThemeColors.accent,
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(err.response?.data["message"]),
//               backgroundColor: ThemeColors.accent,
//             ),
//           );
//         }
//       }
//     });
//     isAuthenticatingSink.add(false);
//     if (result != null) {
//       user = result;
//       userModelSink.add(result);
//       Navigator.pushReplacement(
//           context, MaterialPageRoute(builder: (context) => HomeView()));
//     }
//   }

//   String? passwordValidate(String? value, TextEditingController pass) {
//     print(value);
//     if (pass.text == value) {
//       return null;
//     } else {
//       return "Passwords do not match";
//     }
//   }

//   googleSignIn(BuildContext context) async {
//     googleAccount = await _googleSignIn.signIn();
//     if (googleAccount != null) {
//       isAuthenticatingSink.add(true);
//       UserModel? loginResult = await _api.googleSignInAip(
//           {"google_id": googleAccount?.id}).onError((error, stackTrace) {
//         isAuthenticatingSink.add(false);
//         if (error is DioError &&
//             error.type == DioErrorType.other &&
//             error.error == SocketException) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 "Check internet Connectivity",
//                 style: ThemeTexTStyle.regularwhite,
//               ),
//               backgroundColor: ThemeColors.accent,
//             ),
//           );
//         }
//       });
//       isAuthenticatingSink.add(false);
//       if (loginResult == null) {
//         setGooglePasswordSink.add(true);
//       } else {
//         user = loginResult;
//         userModelSink.add(loginResult);
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (context) => HomeView()));
//       }
//     }
//   }

//   googleSignUp(BuildContext context) async {
//     if (googleAccount != null) {
//       isAuthenticatingSink.add(true);
//       UserModel? result = await _api.googleSignUp({
//         "photo_url": googleAccount?.photoUrl,
//         "google_id": googleAccount?.id,
//         "email": googleAccount?.email,
//         "password": googlePassword.text,
//         "username": googleUsername.text,
//       }).onError((error, stackTrace) {
//         isAuthenticatingSink.add(false);
//         if (error is DioError &&
//             error.type == DioErrorType.other &&
//             error.error == SocketException) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 "Check internet Connectivity",
//                 style: ThemeTexTStyle.regularwhite,
//               ),
//               backgroundColor: ThemeColors.accent,
//             ),
//           );
//         }
//       });

//       isAuthenticatingSink.add(false);
//       if (result != null) {
//         user = result;
//         userModelSink.add(result);
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (context) => HomeView()));
//       }
//     } else {
//       googleAccount = await _googleSignIn.signIn();
//       var result = await _api.googleSignUp({
//         "photo_url": googleAccount?.photoUrl,
//         "google_id": googleAccount?.id,
//         "email": googleAccount?.email,
//         "password": googlePassword.text,
//       });
//       if (result != null) {
//         user = result;
//         userModelSink.add(result);
//         Navigator.pushReplacement(
//             context, MaterialPageRoute(builder: (context) => HomeView()));
//       }
//     }
//   }

//   dispose() {
//     setGooglePassword.close();
//     isAuthenticating.close();
//   }
// }
