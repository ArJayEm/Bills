// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coins.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Coins _$CoinsFromJson(Map<String, dynamic> json) => Coins(
      amount: json['amount'] as num? ?? 0.00,
      totalAmount: json['total_amount'] as num? ?? 0.00,
    )
      ..id = json['id'] as String?
      ..createdBy = json['created_by'] as String?
      ..createdOn = DateTime.parse(json['created_on'] as String)
      ..modifiedBy = json['modified_by'] as String?
      ..modifiedOn = json['modified_on'] == null
          ? null
          : DateTime.parse(json['modified_on'] as String)
      ..deleted = json['deleted'] as bool?
      ..payerId = json['payer_id'] as String?
      ..payerIdDeleted = json['payerid_deleted'] as String?
      ..userIds =
          (json['user_ids'] as List<dynamic>).map((e) => e as String?).toList();

Map<String, dynamic> _$CoinsToJson(Coins instance) {
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
  val['amount'] = instance.amount;
  val['payer_id'] = instance.payerId;
  val['payerid_deleted'] = instance.payerIdDeleted;
  val['total_amount'] = instance.totalAmount;
  val['user_ids'] = instance.userIds;
  return val;
}
