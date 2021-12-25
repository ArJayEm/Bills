// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icon_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomIconData _$CustomIconDataFromJson(Map<String, dynamic> json) =>
    CustomIconData()
      ..codepoint = json['code_point'] as int?
      ..color = json['color'] as int?
      ..fontfamily = json['font_family'] as String?
      ..name = json['name'] as String?;

Map<String, dynamic> _$CustomIconDataToJson(CustomIconData instance) =>
    <String, dynamic>{
      'code_point': instance.codepoint,
      'color': instance.color,
      'font_family': instance.fontfamily,
      'name': instance.name,
    };
