part of 'user_model.dart';

// ignore_for_file: type=lint

User _$UserFromJson(Map<String, dynamic> json) => User(
      uniqueID: json['uniqueID'] as String,
      name: json['name'] as String,
      photo: json['photo'] as String?,
      homeHubID: json['homeHubID'] as String,
      currentHubID: json['currentHubID'] as String,
      publicKey: json['publicKey'] as String,
      privateKey: json['privateKey'] as String,
      deviceID: json['deviceID'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'uniqueID': instance.uniqueID,
      'name': instance.name,
      'photo': instance.photo,
      'homeHubID': instance.homeHubID,
      'currentHubID': instance.currentHubID,
      'publicKey': instance.publicKey,
      'privateKey': instance.privateKey,
      'deviceID': instance.deviceID,
      'createdAt': instance.createdAt.toIso8601String(),
    };
