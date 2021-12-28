// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'members.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Members _$MembersFromJson(Map<String, dynamic> json) => Members()
  ..id = json['id'] as String?
  ..createdBy = json['created_by'] as String?
  ..createdOn = DateTime.parse(json['created_on'] as String)
  ..modifiedBy = json['modified_by'] as String?
  ..modifiedOn = json['modified_on'] == null
      ? null
      : DateTime.parse(json['modified_on'] as String)
  ..deleted = json['deleted'] as bool?
  ..count = json['count'] as int
  ..effectivityStart = DateTime.parse(json['effectivity_start'] as String)
  ..effectivityEnd = json['effectivity_end'] == null
      ? null
      : DateTime.parse(json['effectivity_end'] as String);

Map<String, dynamic> _$MembersToJson(Members instance) {
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
  val['count'] = instance.count;
  val['effectivity_start'] = instance.effectivityStart.toIso8601String();
  val['effectivity_end'] = instance.effectivityEnd?.toIso8601String();
  return val;
}
