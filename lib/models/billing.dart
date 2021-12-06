import 'package:bills/models/model_base.dart';

import 'package:json_annotation/json_annotation.dart';

part 'billing.g.dart';

@JsonSerializable()
class Billing extends ModelBase {
  @JsonKey(name: "bill_date")
  DateTime? billdate = DateTime.now();
  @JsonKey(name: "deleted")
  bool? deleted = false;
  @JsonKey(name: "payer_id")
  String? payerId = "";
  @JsonKey(name: "credit_amount")
  num? creditamount = 0;

  //List<Payer?> payers;

  Billing();

  factory Billing.fromJson(Map<String, dynamic> json) =>
      _$BillingFromJson(json);
  Map<String, dynamic> toJson() => _$BillingToJson(this);
}
