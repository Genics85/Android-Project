import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_find_me/core/network/networkError.dart';
import 'package:go_find_me/locator.dart';
import 'package:go_find_me/models/PostModel.dart';
import 'package:go_find_me/models/PostQueryResponse.dart';
import 'package:go_find_me/models/UserModel.dart';
import 'package:go_find_me/services/sharedPref.dart';

class Api {
  SharedPreferencesService sharedPref = sl<SharedPreferencesService>();
  Dio dio = Dio(
    BaseOptions(
        baseUrl: 'https://go-find-me.herokuapp.com/api',
        validateStatus: (status) {
          return status! <= 300;
        }),
  );

  Api() {
    dio.interceptors
        .add(InterceptorsWrapper(onRequest: (request, handler) async {
      String? token = await sharedPref.getStringValuesSF("accessToken");
      if (token != null && token != '') {
        request.headers['Authorization'] = "Bearer " + token;
      }
      return handler.next(request);
    }, onError: (DioError e, handler) async {
      if (e.response?.statusCode == 401) {
        try {
          String? refreshToken =
              await sharedPref.getStringValuesSF("refreshToken");

          if (refreshToken != null && refreshToken != '') {
            await dio.post('/auth/refresh',
                data: {"refreshToken": refreshToken}).then((value) async {
              if (value.statusCode == 201) {
                String token = value.data["accessToken"];
                await sharedPref.addStringToSF(
                    "accessToken", value.data?["accessToken"]);
                await sharedPref.addStringToSF(
                    "refreshToken", value.data?["refreshToken"]);

                e.requestOptions.headers["Authorization"] = "Bearer " + token;

                // Create request with new access Token
                final opts = new Options(
                  method: e.requestOptions.method,
                  headers: e.requestOptions.headers,
                );
                final cloneReq = await dio.request(e.requestOptions.path,
                    options: opts,
                    data: e.requestOptions.data,
                    queryParameters: e.requestOptions.queryParameters);

                return handler.resolve(cloneReq);
              }
              // return e;
            });
            // return dio;
          }
        } catch (err) {
          print(err);
        }
      }

      return handler.next(e);
    }));
  }

  Future<UserModel?> tokenAuthentication() async {
    try {
      Response<Map<String, dynamic>> response =
          await dio.get('/users/login/token_auth');

      UserModel user = UserModel.fromJson(response.data ?? {});

      return user;
    } on DioError catch (err) {
      throw NetworkError(err);
    }
  }

  // Authentication Apis
  Future<UserModel?> emailLogin(Map<String, dynamic> map) async {
    try {
      Response response = await dio.post('/auth/login/email/', data: map);
      print(response.data?["user"]);
      UserModel user = UserModel.fromJson(response.data?["user"] ?? {});
      await sharedPref.addStringToSF(
          "accessToken", response.data?["accessToken"]);
      await sharedPref.addStringToSF(
          "refreshToken", response.data?["refreshToken"]);

      return user;
    } on DioError catch (err) {
      throw NetworkError(err);
    }
  }

  Future<UserModel?> emailSignUp(Map<String, dynamic> data) async {
    try {
      print(data);
      Response response = await dio.post('/auth/sign_up/email', data: data);

      UserModel user = UserModel.fromJson(response.data?["user"] ?? {});
      await sharedPref.addStringToSF(
          "accessToken", response.data?["accessToken"]);
      await sharedPref.addStringToSF(
          "refreshToken", response.data?["refreshToken"]);

      return user;
    } on DioError catch (err) {
      throw NetworkError(err);
    }
  }

  Future<void> sendOTPemail(Map<String, dynamic> map) async {
    try {
      Response<Map<String, dynamic>> response =
          await dio.post("/auth/email/send_otp", data: map);

      await sharedPref.addStringToSF(
          "confirmation_token", response.data!["confirmation_token"]);
    } on DioError catch (error) {
      throw new NetworkError(error);
    }
  }

  Future<UserModel> confirmEmail(Map<String, dynamic> map) async {
    try {
      Response<Map<String, dynamic>> response =
          await dio.post("/auth/confirm_email", data: map);
      await sharedPref.removeFromSF("confirmation_token");
      print(response.data);
      UserModel user = UserModel.fromJson(response.data ?? {});
      return user;
    } on DioError catch (error) {
      throw new NetworkError(error);
    }
  }

  Future<void> sendOTPPhone(Map<String, dynamic> map) async {
    try {
      Response<Map<String, dynamic>> response =
          await dio.post("/auth/phone-number/send_otp", data: map);

      await sharedPref.addStringToSF(
          "confirmation_token", response.data!["confirmation_token"]);
    } on DioError catch (error) {
      throw new NetworkError(error);
    }
  }

  Future<void> sendForgotPasswordCode(String email) async {
    try {
      Response<Map<String, dynamic>> response = await dio.post(
          '/auth/email/forgotten_password/send_code',
          data: {'email': email});
      await sharedPref.addStringToSF(
          'forgotten_password_token', response.data!["confirmation_token"]);
    } on DioError catch (error) {
      throw new NetworkError(error);
    }
  }

  Future<void> confirmForgotPasswordCode(String code) async {
    String? token =
        await sharedPref.getStringValuesSF('forgotten_password_token');

    if (token == null)
      throw new NetworkError(DioError(
          requestOptions: RequestOptions(
        path: '',
      )));
    try {
      Response<Map<String, dynamic>> response = await dio.post(
          '/auth/email/confirm_code/forgotten_password',
          data: {"confirmation_token": token, "otp": code});
      await sharedPref.removeFromSF('forgotten_password_token');
      await sharedPref.addStringToSF(
          'change_password_token', response.data!['token']);
    } on DioError catch (err) {
      throw new NetworkError(err);
    }
  }

  Future<void> submitNewPassword(String newPassword) async {
    String? token = await sharedPref.getStringValuesSF('change_password_token');
    try {
      Response<Map<String, dynamic>> response = await dio.put(
          '/auth/change_password/forgotten_password',
          data: {'token': token, 'newPassword': newPassword});
    } on DioError catch (error) {
      throw new NetworkError(error);
    }
  }

  Future<UserModel> confirmPhone(Map<String, dynamic> map) async {
    try {
      Response<Map<String, dynamic>> response =
          await dio.post("/auth/confirm_phone", data: map);
      await sharedPref.removeFromSF("confirmation_token");
      print(response.data);
      UserModel user = UserModel.fromJson(response.data ?? {});
      return user;
    } on DioError catch (error) {
      throw new NetworkError(error);
    }
  }

  ///////////////////////////////////////////////////////

  Future<Post?> createPost(Map<String, dynamic> map) async {
    try {
      print(map);
      // final formdata = FormData.fromMap(map);

      var response = await dio.post('/post/', data: map);

      return Post.fromJson(response.data);
    } on DioError catch (err) {
      throw NetworkError(err);
    }
  }

  contribution(Map<String, dynamic> map) async {
    try {
      var response = await dio.post('/post/create_contribution/', data: map);

      print(json.encode(response.data));
      return response.data;
    } on DioError catch (e) {
      return NetworkError(e);
    }
  }

  editPost(Map<String, dynamic> map, String postId) async {
    try {
      print(map);
      Response response = await dio.put("/post/$postId", data: map);

      return true;
    } on DioError catch (err) {
      throw NetworkError(err);
    }
  }

  deleteImages(List<String> images) async {
    try {
      Response response = await dio.delete(
          "https://go-find-me.herokuapp.com/file/delete",
          data: {"imgs": images});
    } on DioError catch (err) {
      throw NetworkError(err);
    }
  }

  deletePost(String postId) async {
    try {
      Response response = await dio.delete("/post/delete_post/$postId");

      return true;
    } on DioError catch (err) {
      throw NetworkError(err);
    }
  }

  Future<PostQueryResponse> getPosts({String? url}) async {
    try {
      Response<Map<String, dynamic>> response = await dio.get(url ?? "/post/");

      Map<String, dynamic> resultData = response.data!;

      PostQueryResponse postQueryResponse =
          PostQueryResponse.fromJson(resultData);

      return postQueryResponse;
    } on DioError catch (err) {
      throw NetworkError(err);
    }
  }

  Future<PostQueryResponse> getMyPosts(
      {required String userId, String? url}) async {
    try {
      Response<Map<String, dynamic>> response =
          await dio.get(url ?? "/post/myposts/$userId");

      Map<String, dynamic> resultData = response.data!;

      PostQueryResponse postQueryResponse =
          PostQueryResponse.fromJson(resultData);
      return postQueryResponse;
    } on DioError catch (err) {
      throw NetworkError(err);
    }
  }

  Future<PostQueryResponse> getContributedPosts(
      {required String userId, String? url}) async {
    try {
      Response<Map<String, dynamic>> response =
          await dio.get(url ?? "/post/contributed_posts/$userId");

      Map<String, dynamic> resultData = response.data!;

      PostQueryResponse postQueryResponse =
          PostQueryResponse.fromJson(resultData);
      return postQueryResponse;
    } on DioError catch (err) {
      throw NetworkError(err);
    }
  }

  Future<PostQueryResponse> getBookmarkedPost(
      {required String userId, String? url}) async {
    try {
      Response<Map<String, dynamic>> response =
          await dio.get(url ?? "/post/bookmarked_posts/$userId");

      Map<String, dynamic> resultData = response.data!;

      PostQueryResponse postQueryResponse =
          PostQueryResponse.fromJson(resultData);
      return postQueryResponse;
    } on DioError catch (err) {
      throw NetworkError(err);
    }
  }

  Future<UserModel> bookmarkPost(
      {required String userId, required String postId}) async {
    try {
      Response<Map<String, dynamic>> response = await dio
          .post("/post/bookmark_post/$userId", data: {"postId": postId});
      return UserModel.fromJson(response.data?["user"]);
    } on DioError catch (err) {
      throw NetworkError(err);
    }
  }

  Future<UserModel> unBookmarkPost(
      {required String userId, required String postId}) async {
    try {
      Response<Map<String, dynamic>> response = await dio
          .post("/post/unbookmark_post/$userId", data: {"postId": postId});

      return UserModel.fromJson(response.data?["user"]);
    } on DioError catch (err) {
      throw NetworkError(err);
    }
  }

  Future<List<dynamic>> uploadImages(Map<String, dynamic> map) async {
    try {
      final FormData formData = FormData.fromMap(map);
      Response<List<dynamic>> response = await dio
          .post("https://go-find-me.herokuapp.com/file", data: formData);
      List<dynamic> imagePaths = response.data!;
      return imagePaths;
    } on DioError catch (err) {
      throw NetworkError(err);
    }
  }
}
