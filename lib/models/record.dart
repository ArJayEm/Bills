import 'package:bills/models/model_base.dart';

import 'package:json_annotation/json_annotation.dart';

part 'record.g.dart';

@JsonSerializable()
class Record extends ModelBase {
  @JsonKey(name: "display_name")
  String? displayName;

  //List<Payer?> payers;

  Record();

  factory Record.fromJson(Map<String, dynamic> json) => _$RecordFromJson(json);
  Map<String, dynamic> toJson() => _$RecordToJson(this);
}
