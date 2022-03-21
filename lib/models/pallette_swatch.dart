import 'package:bills/models/model_base.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pallette_swatch.g.dart';

@JsonSerializable()
class PalletteSwatch extends ModelBase {
  @JsonKey(name: "dominant_color")
  int? dominantColor = 0;
  @JsonKey(name: "light_vibrant_color")
  int? lightVibrantColor = 0;
  @JsonKey(name: "vibrant_color")
  int? vibrantColor = 0;
  @JsonKey(name: "dark_vibrant_color")
  int? darkVibrantColor = 0;
  @JsonKey(name: "light_muted_color")
  int? lightMutedColor = 0;
  @JsonKey(name: "muted_color")
  int? mutedColor = 0;
  @JsonKey(name: "dark_muted_color")
  int? darkMutedColor = 0;

  PalletteSwatch();

  factory PalletteSwatch.fromJson(Map<String, dynamic> json) =>
      _$PalletteSwatchFromJson(json);
  Map<String, dynamic> toJson() => _$PalletteSwatchToJson(this);
}
