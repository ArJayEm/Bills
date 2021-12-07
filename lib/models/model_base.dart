import 'package:json_annotation/json_annotation.dart';

class ModelBase {
  @JsonKey(includeIfNull: false)
  String? id;
  @JsonKey(name: "created_on")
  DateTime createdOn = DateTime.now();
  @JsonKey(name: "modified_on")
  DateTime? modifiedOn;
  @JsonKey(name: "deleted")
  bool? deleted;
}
