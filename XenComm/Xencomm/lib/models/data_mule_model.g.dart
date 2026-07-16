part of 'data_mule_model.dart';

// ignore_for_file: type=lint

DataMule _$DataMuleFromJson(Map<String, dynamic> json) => DataMule(
      vehicleID: json['vehicleID'] as String,
      type: json['type'] as String,
      capacity: (json['capacity'] as num).toInt(),
      currentHub: json['currentHub'] as String,
      nextHub: json['nextHub'] as String,
      speed: (json['speed'] as num).toDouble(),
      status: json['status'] as String,
      bundlesCarrying: (json['bundlesCarrying'] as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$DataMuleToJson(DataMule instance) => <String, dynamic>{
      'vehicleID': instance.vehicleID,
      'type': instance.type,
      'capacity': instance.capacity,
      'currentHub': instance.currentHub,
      'nextHub': instance.nextHub,
      'speed': instance.speed,
      'status': instance.status,
      'bundlesCarrying': instance.bundlesCarrying,
      'createdAt': instance.createdAt.toIso8601String(),
    };
