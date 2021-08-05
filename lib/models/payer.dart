import 'package:bills/models/model_base.dart';

import 'package:json_annotation/json_annotation.dart';

part 'payer.g.dart';

@JsonSerializable()
class Payer extends ModelBase {
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
  @JsonKey(name: "members")
  int? members = 0;

  Payer();

  factory Payer.fromJson(Map<String, dynamic> json) => _$PayerFromJson(json);
  Map<String, dynamic> toJson() => _$PayerToJson(this);
}
