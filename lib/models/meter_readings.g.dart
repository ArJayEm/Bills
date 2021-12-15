// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meter_readings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reading _$ReadingFromJson(Map<String, dynamic> json) => Reading(
      id: json['id'],
      readingDate: json['reading_date'] == null
          ? null
          : DateTime.parse(json['reading_date'] as String),
      reading: json['reading'] as int?,
      readingtype: json['reading_type'] as int?,
      userid: json['user_id'] as String?,
    )
      ..createdOn = DateTime.parse(json['created_on'] as String)
      ..modifiedOn = json['modified_on'] == null
          ? null
          : DateTime.parse(json['modified_on'] as String)
      ..deleted = json['deleted'] as bool?
      ..userIds = (json['user_ids'] as List<dynamic>?)
          ?.map((e) => e as String?)
          .toList();

Map<String, dynamic> _$ReadingToJson(Reading instance) {
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
  val['reading_date'] = instance.readingDate?.toIso8601String();
  val['reading'] = instance.reading;
  val['reading_type'] = instance.readingtype;
  val['user_id'] = instance.userid;
  val['user_ids'] = instance.userIds;
  return val;
}
