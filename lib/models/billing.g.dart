// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Billing _$BillingFromJson(Map<String, dynamic> json) => Billing()
  ..id = json['id'] as String?
  ..createdOn = DateTime.parse(json['created_on'] as String)
  ..modifiedOn = json['modified_on'] == null
      ? null
      : DateTime.parse(json['modified_on'] as String)
  ..billdate = json['bill_date'] == null
      ? null
      : DateTime.parse(json['bill_date'] as String)
  ..deleted = json['deleted'] as bool?
  ..payerId = json['payer_id'] as String?
  ..creditamount = json['credit_amount'] as num?;

Map<String, dynamic> _$BillingToJson(Billing instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['created_on'] = instance.createdOn.toIso8601String();
  val['modified_on'] = instance.modifiedOn?.toIso8601String();
  val['bill_date'] = instance.billdate?.toIso8601String();
  val['deleted'] = instance.deleted;
  val['payer_id'] = instance.payerId;
  val['credit_amount'] = instance.creditamount;
  return val;
}
