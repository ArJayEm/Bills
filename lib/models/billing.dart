import 'package:bills/models/model_base.dart';

import 'package:json_annotation/json_annotation.dart';

part 'billing.g.dart';

@JsonSerializable()
class Billing extends ModelBase {
  @JsonKey(name: "name")
  String? name = "";

  //List<Payer?> payers;

  Billing();

  factory Billing.fromJson(Map<String, dynamic> json) =>
      _$BillingFromJson(json);
  Map<String, dynamic> toJson() => _$BillingToJson(this);
}
