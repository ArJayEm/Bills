import 'package:bills/models/model_base.dart';

import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

@JsonSerializable()
class UserProfile extends ModelBase {
  @JsonKey(name: "display_name")
  String? displayName;
  @JsonKey(name: "email")
  String? email;
  @JsonKey(name: "photo_url")
  String? photoUrl;
  @JsonKey(name: "phone_number")
  String? phoneNumber;
  @JsonKey(name: "logged_in")
  bool loggedIn;
  int? members;

  UserProfile({id, this.displayName, this.members, this.loggedIn = false});

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}
