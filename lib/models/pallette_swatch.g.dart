// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pallette_swatch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PalletteSwatch _$PalletteSwatchFromJson(Map<String, dynamic> json) =>
    PalletteSwatch()
      ..id = json['id'] as String?
      ..createdBy = json['created_by'] as String?
      ..createdOn = DateTime.parse(json['created_on'] as String)
      ..modifiedBy = json['modified_by'] as String?
      ..modifiedOn = json['modified_on'] == null
          ? null
          : DateTime.parse(json['modified_on'] as String)
      ..deleted = json['deleted'] as bool?
      ..dominantColor = json['dominant_color'] as int?
      ..lightVibrantColor = json['light_vibrant_color'] as int?
      ..vibrantColor = json['vibrant_color'] as int?
      ..darkVibrantColor = json['dark_vibrant_color'] as int?
      ..lightMutedColor = json['light_muted_color'] as int?
      ..mutedColor = json['muted_color'] as int?
      ..darkMutedColor = json['dark_muted_color'] as int?;

Map<String, dynamic> _$PalletteSwatchToJson(PalletteSwatch instance) {
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
  val['dominant_color'] = instance.dominantColor;
  val['light_vibrant_color'] = instance.lightVibrantColor;
  val['vibrant_color'] = instance.vibrantColor;
  val['dark_vibrant_color'] = instance.darkVibrantColor;
  val['light_muted_color'] = instance.lightMutedColor;
  val['muted_color'] = instance.mutedColor;
  val['dark_muted_color'] = instance.darkMutedColor;
  return val;
}
