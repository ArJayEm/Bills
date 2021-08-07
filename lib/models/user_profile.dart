import 'package:bills/models/model_base.dart';

import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile extends ModelBase {
  @JsonKey(name: "display_name")
  String? displayName = "";
  @JsonKey(name: "user_code")
  String? userCode = "";
  @JsonKey(name: "email")
  String? email = "";
  @JsonKey(name: "photo_url")
  String? photoUrl = "";
  @JsonKey(name: "phone_number")
  String? phoneNumber = "";
  @JsonKey(name: "logged_in")
  bool? loggedIn = false;
  @JsonKey(name: "members")
  int? members = 1;
  @JsonKey(name: "registered_using")
  String? registeredUsing = "";
  @JsonKey(name: "billing_generation_date")
  DateTime? billingGenDate;
  @JsonKey(name: "user_type")
  String? userType = "";

  @JsonKey(name: "pin")
  String? pin = "";

  UserProfile();

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}

@JsonSerializable()
class UserLogin extends ModelBase {
  @JsonKey(name: "display_name")
  String? displayName = "";
  @JsonKey(name: "email")
  String? email = "";
  @JsonKey(name: "photo_url")
  String? photoUrl = "";
  @JsonKey(name: "phone_number")
  String? phoneNumber = "";
  @JsonKey(name: "logged_in")
  bool? loggedIn = false;
  @JsonKey(name: "pin")
  String? pin = "";
  @JsonKey(name: "registered_using")
  String? registeredUsing = "";

  UserLogin();

  factory UserLogin.fromJson(Map<String, dynamic> json) =>
      _$UserLoginFromJson(json);
  Map<String, dynamic> toJson() => _$UserLoginToJson(this);
}
