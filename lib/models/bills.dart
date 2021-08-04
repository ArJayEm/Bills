import 'package:bills/models/model_base.dart';

import 'package:json_annotation/json_annotation.dart';

part 'bills.g.dart';

@JsonSerializable()
class Bills extends ModelBase {
  @JsonKey(name: "bill_date")
  DateTime? billdate = DateTime.now();
  @JsonKey(name: "amount")
  num? amount = 0;
  @JsonKey(name: "quantification")
  int? quantification = 0;
  @JsonKey(name: "payer_ids")
  List<dynamic>? payerIds = [];

  Bills(
      {id,
      this.billdate,
      this.amount = 0,
      this.quantification = 0,
      this.payerIds});

  factory Bills.fromJson(Map<String, dynamic> json) => _$BillsFromJson(json);
  Map<String, dynamic> toJson() => _$BillsToJson(this);
}
