// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Billing _$BillingFromJson(Map<String, dynamic> json) => Billing()
  ..id = json['id'] as String?
  ..createdBy = json['created_by'] as String?
  ..createdOn = DateTime.parse(json['created_on'] as String)
  ..modifiedBy = json['modified_by'] as String?
  ..modifiedOn = json['modified_on'] == null
      ? null
      : DateTime.parse(json['modified_on'] as String)
  ..deleted = json['deleted'] as bool?
  ..date = json['billing_date'] == null
      ? null
      : DateTime.parse(json['billing_date'] as String)
  ..coins = json['coins'] as num?
  ..previousUnpaid = json['previous_unpaid'] as num?
  ..subtotal = json['subtotal'] as num?
  ..totalPayment = json['total_payment'] as num?
  ..billIds =
      (json['bill_ids'] as List<dynamic>).map((e) => e as String?).toList()
  ..paymentIds =
      (json['payment_ids'] as List<dynamic>).map((e) => e as String?).toList()
  ..readingIds =
      (json['reading_ids'] as List<dynamic>).map((e) => e as String?).toList()
  ..userId =
      (json['user_id'] as List<dynamic>).map((e) => e as String?).toList();

Map<String, dynamic> _$BillingToJson(Billing instance) {
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
  val['billing_date'] = instance.date?.toIso8601String();
  val['coins'] = instance.coins;
  val['previous_unpaid'] = instance.previousUnpaid;
  val['subtotal'] = instance.subtotal;
  val['total_payment'] = instance.totalPayment;
  val['bill_ids'] = instance.billIds;
  val['payment_ids'] = instance.paymentIds;
  val['reading_ids'] = instance.readingIds;
  val['user_id'] = instance.userId;
  return val;
}
