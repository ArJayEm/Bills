// ignore_for_file: unnecessary_new

import 'package:bills/models/icon_data.dart';
import 'package:bills/models/model_base.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bill_type.g.dart';

@JsonSerializable()
class BillType extends ModelBase {
  @JsonKey(name: "description")
  String? description = "";
  @JsonKey(name: "icon_data")
  CustomIconData? iconData = new CustomIconData();
  @JsonKey(name: "is_debit")
  bool? isdebit = false;
  @JsonKey(name: "quantification")
  String? quantification = "";

  BillType({id, this.description, this.iconData, this.quantification, this.isdebit = false});

  factory BillType.fromJson(Map<String, dynamic> json) =>
      _$BillTypeFromJson(json);
  Map<String, dynamic> toJson() => _$BillTypeToJson(this);
}
