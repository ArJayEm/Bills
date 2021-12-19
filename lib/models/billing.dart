import 'package:bills/models/model_base.dart';

import 'package:json_annotation/json_annotation.dart';

part 'billing.g.dart';

@JsonSerializable()
class Billing extends ModelBase {
  @JsonKey(name: "billing_date")
  DateTime? date = DateTime.now();
  @JsonKey(name: "coins")
  num? coins = 0;
  @JsonKey(name: "previous_unpaid")
  num? previousUnpaid = 0;
  @JsonKey(name: "subtotal")
  num? subtotal = 0;
  @JsonKey(name: "total_payment")
  num? totalPayment = 0;

  @JsonKey(name: "bill_ids")
  List<String?> billIds = [];
  @JsonKey(name: "payment_ids")
  List<String?> paymentIds = [];
  @JsonKey(name: "reading_ids")
  List<String?> readingIds = [];
  @JsonKey(name: "user_id")
  List<String?> userId = [];

  Billing();

  factory Billing.fromJson(Map<String, dynamic> json) =>
      _$BillingFromJson(json);
  Map<String, dynamic> toJson() => _$BillingToJson(this);
}
