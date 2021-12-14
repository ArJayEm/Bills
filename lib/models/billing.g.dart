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
  ..deleted = json['deleted'] as bool?
  ..billIds =
      (json['bill_ids'] as List<dynamic>?)?.map((e) => e as String?).toList()
  ..billingDate = json['billing_date'] == null
      ? null
      : DateTime.parse(json['billing_date'] as String)
  ..coins = json['coins'] as num?
  ..previousUnpaid = json['previous_unpaid'] as num?
  ..totalPayment = json['total_payment'] as num?
  ..userId =
      (json['user_id'] as List<dynamic>?)?.map((e) => e as String?).toList();

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
  val['deleted'] = instance.deleted;
  val['bill_ids'] = instance.billIds;
  val['billing_date'] = instance.billingDate?.toIso8601String();
  val['coins'] = instance.coins;
  val['previous_unpaid'] = instance.previousUnpaid;
  val['total_payment'] = instance.totalPayment;
  val['user_id'] = instance.userId;
  return val;
}
