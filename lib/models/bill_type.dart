import 'package:bills/models/model_base.dart';

import 'package:json_annotation/json_annotation.dart';

part 'bill_type.g.dart';

@JsonSerializable()
class BillType extends ModelBase {
  @JsonKey(name: "description")
  String? desciption = "";
  @JsonKey(name: "is_debit")
  bool? isdebit;

  BillType({id, this.desciption, this.isdebit = false});

  factory BillType.fromJson(Map<String, dynamic> json) =>
      _$BillTypeFromJson(json);
  Map<String, dynamic> toJson() => _$BillTypeToJson(this);
}
