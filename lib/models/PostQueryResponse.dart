// To parse this JSON data, do
//
//     final postQueryResponse = postQueryResponseFromJson(jsonString);

import 'dart:convert';

import 'package:go_find_me/models/PostModel.dart';

class PostQueryResponse {
  PostQueryResponse({
    this.posts,
    this.next,
    this.prev,
  });

  List<Post>? posts;
  String? next;
  String? prev;

  factory PostQueryResponse.fromRawJson(String str) =>
      PostQueryResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PostQueryResponse.fromJson(Map<String, dynamic> json) =>
      PostQueryResponse(
        posts: List<Post>.from(json["posts"].map((x) => Post.fromJson(x))),
        next: json["next"],
        prev: json["prev"],
      );

  Map<String, dynamic> toJson() => {
        "posts": List<dynamic>.from(posts!.map((x) => x.toJson())),
        "next": next,
        "prev": prev,
      };
}
