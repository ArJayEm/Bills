import 'package:json_annotation/json_annotation.dart';

part 'icon_data.g.dart';

@JsonSerializable()
class CustomIconData {
  @JsonKey(name: "code_point")
  int? codepoint;
  @JsonKey(name: "color")
  int? color;
  @JsonKey(name: "font_family")
  String? fontfamily;

  CustomIconData(
      {this.codepoint, this.color, this.fontfamily});

  factory CustomIconData.fromJson(Map<String, dynamic> json) =>
      _$CustomIconDataFromJson(json);
  Map<String, dynamic> toJson() => _$CustomIconDataToJson(this);
}
