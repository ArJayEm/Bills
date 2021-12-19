import 'package:bills/models/bill_type.dart';
import 'package:bills/models/model_base.dart';

import 'package:json_annotation/json_annotation.dart';

part 'meter_readings.g.dart';

@JsonSerializable()
class Reading extends ModelBase {
  @JsonKey(name: "meter_reading")
  int? meterReading;
  @JsonKey(name: "reading")
  int? reading = 0;
  @JsonKey(name: "reading_date")
  DateTime? date = DateTime.now();
  @JsonKey(name: "reading_type")
  int? type;
  @JsonKey(name: "user_id")
  String? userid;
  @JsonKey(name: "userid_deleted")
  List<String?>? userIdDeleted = [];

  @JsonKey(ignore: true)
  BillType? billType = BillType();
  @JsonKey(ignore: true)
  String? payerNames = "";

  Reading({id, this.meterReading = 0, this.date, this.reading = 0, this.type = 0, this.userid = ""});

  factory Reading.fromJson(Map<String, dynamic> json) =>
      _$ReadingFromJson(json);
  Map<String, dynamic> toJson() => _$ReadingToJson(this);
}
