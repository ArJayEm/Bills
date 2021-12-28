// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bill _$BillFromJson(Map<String, dynamic> json) => Bill(
      amount: json['amount'] as num? ?? 0,
      quantification: json['quantification'] as int? ?? 1,
    )
      ..id = json['id'] as String?
      ..createdBy = json['created_by'] as String?
      ..createdOn = DateTime.parse(json['created_on'] as String)
      ..modifiedBy = json['modified_by'] as String?
      ..modifiedOn = json['modified_on'] == null
          ? null
          : DateTime.parse(json['modified_on'] as String)
      ..deleted = json['deleted'] as bool?
      ..billDate = json['bill_date'] == null
          ? null
          : DateTime.parse(json['bill_date'] as String)
      ..description = json['description'] as String?
      ..payerIds = (json['payer_ids'] as List<dynamic>?)
          ?.map((e) => e as String?)
          .toList()
      ..payersBillType = (json['payers_billtype'] as List<dynamic>?)
          ?.map((e) => e as String?)
          .toList()
      ..billTypeId = json['bill_type'] as int?;

Map<String, dynamic> _$BillToJson(Bill instance) {
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
  val['bill_date'] = instance.billDate?.toIso8601String();
  val['description'] = instance.description;
  val['amount'] = instance.amount;
  val['quantification'] = instance.quantification;
  val['payer_ids'] = instance.payerIds;
  val['payers_billtype'] = instance.payersBillType;
  val['bill_type'] = instance.billTypeId;
  return val;
}
