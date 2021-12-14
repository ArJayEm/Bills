// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coins.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Coins _$CoinsFromJson(Map<String, dynamic> json) => Coins()
  ..id = json['id'] as String?
  ..createdOn = DateTime.parse(json['created_on'] as String)
  ..modifiedOn = json['modified_on'] == null
      ? null
      : DateTime.parse(json['modified_on'] as String)
  ..deleted = json['deleted'] as bool?
  ..amount = json['amount'] as num?
  ..payerId = json['payer_id'] as String?
  ..payerIdDeleted = json['payerid_deleted'] as String?;

Map<String, dynamic> _$CoinsToJson(Coins instance) {
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
  val['amount'] = instance.amount;
  val['payer_id'] = instance.payerId;
  val['payerid_deleted'] = instance.payerIdDeleted;
  return val;
}
