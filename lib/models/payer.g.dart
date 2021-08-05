// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payer _$PayerFromJson(Map<String, dynamic> json) {
  return Payer()
    ..id = json['id'] as String?
    ..createdOn = DateTime.parse(json['created_on'] as String)
    ..modifiedOn = json['modified_on'] == null
        ? null
        : DateTime.parse(json['modified_on'] as String)
    ..displayName = json['display_name'] as String?
    ..email = json['email'] as String?
    ..photoUrl = json['photo_url'] as String?
    ..phoneNumber = json['phone_number'] as String?
    ..loggedIn = json['logged_in'] as bool?
    ..members = json['members'] as int?;
}

Map<String, dynamic> _$PayerToJson(Payer instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  val['created_on'] = instance.createdOn.toIso8601String();
  val['modified_on'] = instance.modifiedOn?.toIso8601String();
  val['display_name'] = instance.displayName;
  val['email'] = instance.email;
  val['photo_url'] = instance.photoUrl;
  val['phone_number'] = instance.phoneNumber;
  val['logged_in'] = instance.loggedIn;
  val['members'] = instance.members;
  return val;
}
