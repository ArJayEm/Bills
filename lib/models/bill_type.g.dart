// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BillType _$BillTypeFromJson(Map<String, dynamic> json) => BillType(
      id: json['id'],
      description: json['description'] as String? ?? "",
      hasReading: json['has_reading'] as bool? ?? false,
      iconData: json['icon_data'] == null
          ? null
          : CustomIconData.fromJson(json['icon_data'] as Map<String, dynamic>),
      quantification: json['quantification'] as String? ?? "",
      isdebit: json['is_debit'] as bool? ?? false,
    )
      ..createdOn = DateTime.parse(json['created_on'] as String)
      ..modifiedOn = json['modified_on'] == null
          ? null
          : DateTime.parse(json['modified_on'] as String)
      ..deleted = json['deleted'] as bool?;

Map<String, dynamic> _$BillTypeToJson(BillType instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['created_on'] = instance.createdOn.toIso8601String();
  val['modified_on'] = instance.modifiedOn?.toIso8601String();
  val['deleted'] = instance.deleted;
  val['description'] = instance.description;
  val['has_reading'] = instance.hasReading;
  val['icon_data'] = instance.iconData;
  val['is_debit'] = instance.isdebit;
  val['quantification'] = instance.quantification;
  return val;
}
