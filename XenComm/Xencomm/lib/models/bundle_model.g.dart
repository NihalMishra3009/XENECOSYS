part of 'bundle_model.dart';

// ignore_for_file: type=lint

Bundle _$BundleFromJson(Map<String, dynamic> json) => Bundle(
      bundleID: json['bundleID'] as String,
      sourceHub: json['sourceHub'] as String,
      destinationHub: json['destinationHub'] as String,
      messageIDs: (json['messageIDs'] as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      checksum: json['checksum'] as String,
      status: json['status'] as String,
      sizeBytes: (json['sizeBytes'] as num).toInt(),
    );

Map<String, dynamic> _$BundleToJson(Bundle instance) => <String, dynamic>{
      'bundleID': instance.bundleID,
      'sourceHub': instance.sourceHub,
      'destinationHub': instance.destinationHub,
      'messageIDs': instance.messageIDs,
      'createdAt': instance.createdAt.toIso8601String(),
      'checksum': instance.checksum,
      'status': instance.status,
      'sizeBytes': instance.sizeBytes,
    };
