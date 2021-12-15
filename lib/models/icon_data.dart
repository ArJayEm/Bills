import 'package:json_annotation/json_annotation.dart';

part 'icon_data.g.dart';

@JsonSerializable()
class CustomIconData {
  @JsonKey(name: "code_point")
  int? codepoint = 0;
  @JsonKey(name: "color")
  int? color = 0;
  @JsonKey(name: "font_family")
  String? fontfamily = "MaterialIcons";

  CustomIconData(
      {this.codepoint, this.color, this.fontfamily});

  factory CustomIconData.fromJson(Map<String, dynamic> json) =>
      _$CustomIconDataFromJson(json);
  Map<String, dynamic> toJson() => _$CustomIconDataToJson(this);
}
