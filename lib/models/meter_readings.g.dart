// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meter_readings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Reading _$ReadingFromJson(Map<String, dynamic> json) => Reading(
      id: json['id'],
      readingCurrent: json['reading_current'] as int? ?? 0,
      date: json['reading_date'] == null
          ? null
          : DateTime.parse(json['reading_date'] as String),
      reading: json['reading'] as int? ?? 0,
      type: json['reading_type'] as int? ?? 0,
      userid: json['user_id'] as String? ?? "",
    )
      ..createdBy = json['created_by'] as String?
      ..createdOn = DateTime.parse(json['created_on'] as String)
      ..modifiedBy = json['modified_by'] as String?
      ..modifiedOn = json['modified_on'] == null
          ? null
          : DateTime.parse(json['modified_on'] as String)
      ..deleted = json['deleted'] as bool?
      ..readingprevious = json['reading_previous'] as int?
      ..userIdDeleted = (json['userid_deleted'] as List<dynamic>?)
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
  val['created_by'] = instance.createdBy;
  val['created_on'] = instance.createdOn.toIso8601String();
  val['modified_by'] = instance.modifiedBy;
  val['modified_on'] = instance.modifiedOn?.toIso8601String();
  val['deleted'] = instance.deleted;
  val['reading_current'] = instance.readingCurrent;
  val['reading_previous'] = instance.readingprevious;
  val['reading'] = instance.reading;
  val['reading_date'] = instance.date?.toIso8601String();
  val['reading_type'] = instance.type;
  val['user_id'] = instance.userid;
  val['userid_deleted'] = instance.userIdDeleted;
  return val;
}
