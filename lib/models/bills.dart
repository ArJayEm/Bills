import 'package:bills/models/model_base.dart';

import 'package:json_annotation/json_annotation.dart';

part 'bills.g.dart';

@JsonSerializable()
class Bills extends ModelBase {
  @JsonKey(name: "bill_date")
  int? billdate = DateTime.now().millisecondsSinceEpoch;
  @JsonKey(name: "amount")
  num? amount = 0;
  @JsonKey(name: "quantification")
  int? quantification = 0;
  @JsonKey(name: "payer_ids")
  List<dynamic>? payerIds = [];

  Bills(id, this.billdate, this.amount, this.quantification, this.payerIds);

  factory Bills.fromJson(Map<String, dynamic> json) => _$BillsFromJson(json);
  Map<String, dynamic> toJson() => _$BillsToJson(this);
}
