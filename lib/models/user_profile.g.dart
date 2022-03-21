// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile()
  ..id = json['id'] as String?
  ..createdBy = json['created_by'] as String?
  ..createdOn = DateTime.parse(json['created_on'] as String)
  ..modifiedBy = json['modified_by'] as String?
  ..modifiedOn = json['modified_on'] == null
      ? null
      : DateTime.parse(json['modified_on'] as String)
  ..deleted = json['deleted'] as bool?
  ..name = json['name'] as String?
  ..nameseparated = (json['name_separated'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList()
  ..userCode = json['user_code'] as String?
  ..email = json['email'] as String?
  ..photoUrl = json['photo_url'] as String?
  ..phoneNumber = json['phone_number'] as String?
  ..loggedIn = json['logged_in'] as bool?
  ..lastLoggedIn = json['last_logged_in'] == null
      ? null
      : DateTime.parse(json['last_logged_in'] as String)
  ..isAdmin = json['is_admin'] as bool?
  ..registeredUsing = json['registered_using'] as String?
  ..billingDate = json['billing_date'] == null
      ? null
      : DateTime.parse(json['billing_date'] as String)
  ..userType = json['user_type'] as String?
  ..pin = json['pin'] as String?
  ..palletteSwatch = json['pallette_swatch'] == null
      ? null
      : PalletteSwatch.fromJson(json['pallette_swatch'] as Map<String, dynamic>)
  ..members = (json['members'] as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .toList();

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) {
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
  val['name'] = instance.name;
  val['name_separated'] = instance.nameseparated;
  val['user_code'] = instance.userCode;
  val['email'] = instance.email;
  val['photo_url'] = instance.photoUrl;
  val['phone_number'] = instance.phoneNumber;
  val['logged_in'] = instance.loggedIn;
  val['last_logged_in'] = instance.lastLoggedIn?.toIso8601String();
  val['is_admin'] = instance.isAdmin;
  val['registered_using'] = instance.registeredUsing;
  val['billing_date'] = instance.billingDate?.toIso8601String();
  val['user_type'] = instance.userType;
  val['pin'] = instance.pin;
  val['pallette_swatch'] = instance.palletteSwatch;
  val['members'] = instance.members;
  return val;
}
