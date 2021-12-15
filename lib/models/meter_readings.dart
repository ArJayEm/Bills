import 'package:bills/models/model_base.dart';

import 'package:json_annotation/json_annotation.dart';

part 'meter_readings.g.dart';

@JsonSerializable()
class Reading extends ModelBase {
  @JsonKey(name: "reading_date")
  DateTime? readingDate = DateTime.now();
  @JsonKey(name: "reading")
  int? reading = 0;
  @JsonKey(name: "reading_type")
  int? readingtype = 0;
  @JsonKey(name: "user_id")
  String? userid = "";
  @JsonKey(name: "user_ids")
  List<String?>? userIds = [];

  @JsonKey(ignore: true)
  String? payerNames = "";

  Reading(
      {id, this.readingDate, this.reading, this.readingtype, this.userid});

  factory Reading.fromJson(Map<String, dynamic> json) =>
      _$ReadingFromJson(json);
  Map<String, dynamic> toJson() => _$ReadingToJson(this);
}
