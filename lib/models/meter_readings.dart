import 'package:bills/models/model_base.dart';

import 'package:json_annotation/json_annotation.dart';

part 'meter_readings.g.dart';

@JsonSerializable()
class MeterReadings extends ModelBase {
  @JsonKey(name: "reading_date")
  DateTime readingdate;
  @JsonKey(name: "reading")
  int reading;
  @JsonKey(name: "reading_type")
  int readingtype;
  @JsonKey(name: "user_id")
  String userid = "";

  @JsonKey(ignore: true)
  String? payerNames = "";

  MeterReadings(
      {id, required this.readingdate, required this.reading, required this.readingtype, required this.userid});

  factory MeterReadings.fromJson(Map<String, dynamic> json) =>
      _$MeterReadingsFromJson(json);
  Map<String, dynamic> toJson() => _$MeterReadingsToJson(this);
}
