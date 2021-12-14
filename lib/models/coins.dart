import 'package:bills/models/model_base.dart';

import 'package:json_annotation/json_annotation.dart';

part 'coins.g.dart';

@JsonSerializable()
class Coins extends ModelBase {
  @JsonKey(name: "amount")
  num? amount = 0;
  @JsonKey(name: "payer_id")
  String? payerId = "";
  @JsonKey(name: "payerid_deleted")
  String? payerIdDeleted = "";

  Coins();

  factory Coins.fromJson(Map<String, dynamic> json) => _$CoinsFromJson(json);
  Map<String, dynamic> toJson() => _$CoinsToJson(this);
}
