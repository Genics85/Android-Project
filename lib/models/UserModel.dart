import 'dart:convert';

class UserModel {
  UserModel({
    this.id,
    this.email,
    this.photoUrl,
    this.username,
    this.confirmedAt,
    this.phoneNumber,
    this.bookmarked_posts,
  });

  String? username;
  String? id;
  String? email;
  String? photoUrl;
  String? phoneNumber;
  DateTime? confirmedAt;
  List<String>?
 bookmarked_posts;
  factory UserModel.fromRawJson(String str) =>
      UserModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
      email: json["email"],
      photoUrl: json["photo_url"],
      phoneNumber: json["phone_number"],
      username: json["username"],
      id: json["id"],
      confirmedAt: json["confirmed_at"] == null
          ? null
          : DateTime.parse(json["confirmed_at"]),
          bookmarked_posts:json["bookmarked_posts"],
          );

  Map<String, dynamic> toJson() => {
        "email": email,
        "id": id,
        "photo_url": photoUrl,
        "username": username,
        "phone_number": phoneNumber,
        "confirmed_at": confirmedAt?.toIso8601String(),
        "bookmarked_posts":bookmarked_posts,
      };
}
