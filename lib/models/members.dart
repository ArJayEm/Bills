import 'package:bills/models/model_base.dart';

import 'package:json_annotation/json_annotation.dart';

part 'members.g.dart';

@JsonSerializable()
class Members extends ModelBase {
  @JsonKey(name: "count")
  int count = 1;
  @JsonKey(name: "effectivity_start")
  DateTime effectivityStart = DateTime.now();
  @JsonKey(name: "effectivity_end")
  DateTime? effectivityEnd = DateTime.now();

  Members();

  factory Members.fromJson(Map<String, dynamic> json) =>
      _$MembersFromJson(json);
  Map<String, dynamic> toJson() => _$MembersToJson(this);
}
