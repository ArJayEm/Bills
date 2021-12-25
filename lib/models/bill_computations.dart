import 'package:json_annotation/json_annotation.dart';

part 'bill_computations.g.dart';

@JsonSerializable()
class Computations {
  @JsonKey(name: "id")
  String? id;
  @JsonKey(name: "computation")
  String? computation;

  Computations({this.id, this.computation});

  factory Computations.fromJson(Map<String, dynamic> json) =>
      _$ComputationsFromJson(json);
  Map<String, dynamic> toJson() => _$ComputationsToJson(this);
}
