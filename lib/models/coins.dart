import 'package:bills/models/model_base.dart';

import 'package:json_annotation/json_annotation.dart';

part 'coins.g.dart';

@JsonSerializable()
class Coins extends ModelBase {
  @JsonKey(name: "amount")
  num amount;
  @JsonKey(name: "payer_id")
  String? payerId = "";
  @JsonKey(name: "payerid_deleted")
  String? payerIdDeleted = "";
  @JsonKey(name: "total_amount")
  num totalAmount;
  @JsonKey(name: "user_ids")
  List<String?> userIds = [];

  Coins({this.amount = 0.00, this.totalAmount = 0.00});

  factory Coins.fromJson(Map<String, dynamic> json) => _$CoinsFromJson(json);
  Map<String, dynamic> toJson() => _$CoinsToJson(this);
}
