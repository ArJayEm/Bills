// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Bill _$BillFromJson(Map<String, dynamic> json) => Bill(
      id: json['id'],
      billDate: json['bill_date'] == null
          ? null
          : DateTime.parse(json['bill_date'] as String),
      description: json['description'] as String? ?? "",
      amount: json['amount'] as num? ?? 0.00,
      quantification: json['quantification'] as int? ?? 1,
      payerIds: (json['payer_ids'] as List<dynamic>?)
          ?.map((e) => e as String?)
          .toList(),
      payersBillType: (json['payers_billtype'] as List<dynamic>?)
          ?.map((e) => e as String?)
          .toList(),
      billTypeId: json['bill_type'] as int? ?? 0,
      clientMembers: json['client_members'] as int? ?? 0,
      collectorMembers: json['collector_members'] as int? ?? 0,
    )
      ..createdOn = DateTime.parse(json['created_on'] as String)
      ..modifiedOn = json['modified_on'] == null
          ? null
          : DateTime.parse(json['modified_on'] as String)
      ..deleted = json['deleted'] as bool?;

Map<String, dynamic> _$BillToJson(Bill instance) {
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
  val['bill_date'] = instance.billDate?.toIso8601String();
  val['description'] = instance.description;
  val['amount'] = instance.amount;
  val['quantification'] = instance.quantification;
  val['payer_ids'] = instance.payerIds;
  val['payers_billtype'] = instance.payersBillType;
  val['bill_type'] = instance.billTypeId;
  val['client_members'] = instance.clientMembers;
  val['collector_members'] = instance.collectorMembers;
  return val;
}
