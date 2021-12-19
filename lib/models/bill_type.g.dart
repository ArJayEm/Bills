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
      includeInBilling: json['include_in_billing'] as bool? ?? false,
      isCredit: json['is_credit'] as bool? ?? false,
      isdebit: json['is_debit'] as bool? ?? false,
    )
      ..createdBy = json['created_by'] as String?
      ..createdOn = DateTime.parse(json['created_on'] as String)
      ..modifiedBy = json['modified_by'] as String?
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
  val['created_by'] = instance.createdBy;
  val['created_on'] = instance.createdOn.toIso8601String();
  val['modified_by'] = instance.modifiedBy;
  val['modified_on'] = instance.modifiedOn?.toIso8601String();
  val['deleted'] = instance.deleted;
  val['description'] = instance.description;
  val['has_reading'] = instance.hasReading;
  val['icon_data'] = instance.iconData;
  val['include_in_billing'] = instance.includeInBilling;
  val['is_credit'] = instance.isCredit;
  val['is_debit'] = instance.isdebit;
  val['quantification'] = instance.quantification;
  return val;
}
