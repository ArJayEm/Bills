import 'package:bills/models/bill_type.dart';
import 'package:bills/models/meter_readings.dart';
import 'package:bills/models/model_base.dart';
//import 'package:googleapis/content/v2_1.dart';
//import 'package:intl/intl.dart';

import 'package:json_annotation/json_annotation.dart';
//import 'package:bills/helpers/extensions/format_extension.dart';

part 'bill.g.dart';

@JsonSerializable()
class Bill extends ModelBase {
  @JsonKey(name: "bill_date")
  DateTime? billDate;
  @JsonKey(name: "description")
  String? description;
  @JsonKey(name: "amount")
  num amount;
  @JsonKey(name: "quantification")
  int quantification;
  @JsonKey(name: "payer_ids")
  List<String?>? payerIds = [];
  @JsonKey(name: "payers_billtype")
  List<String?>? payersBillType = [];
  @JsonKey(name: "bill_type")
  int? billTypeId;

  @JsonKey(ignore: true)
  String? payerNames;
  @JsonKey(ignore: true)
  DateTime? lastModified = DateTime.now();
  @JsonKey(ignore: true)
  BillType? billType = BillType();

  @JsonKey(ignore: true)
  String computation = "";
  @JsonKey(ignore: true)
  int currentReading;
  @JsonKey(ignore: true)
  num rate;
  @JsonKey(ignore: true)
  num amountToPay;
  @JsonKey(ignore: true)
  List<Reading> readings = [];

  Bill({this.amount = 0, this.currentReading = 0, this.amountToPay = 0, this.rate = 0, this.quantification = 1});

  factory Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);
  Map<String, dynamic> toJson() => _$BillToJson(this);
}
