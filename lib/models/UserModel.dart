import 'dart:convert';

class UserModel {
  UserModel({
    this.id,
    this.email,
    this.photoUrl,
    this.username,
    this.confirmedAt,
    this.phoneNumber,
  });

  String? username;
  String? id;
  String? email;
  String? photoUrl;
  String? phoneNumber;
  DateTime? confirmedAt;

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
          : DateTime.parse(json["confirmed_at"]));

  Map<String, dynamic> toJson() => {
        "email": email,
        "id": id,
        "photo_url": photoUrl,
        "username": username,
        "phone_number": phoneNumber,
        "confirmed_at": confirmedAt?.toIso8601String(),
      };
}
