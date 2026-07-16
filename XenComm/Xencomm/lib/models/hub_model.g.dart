part of 'hub_model.dart';

// ignore_for_file: type=lint

Hub _$HubFromJson(Map<String, dynamic> json) => Hub(
      hubID: json['hubID'] as String,
      hubName: json['hubName'] as String,
      location: json['location'] as Map<String, dynamic>,
      registeredUsers: (json['registeredUsers'] as List<dynamic>).cast<String>(),
      pendingBundles: (json['pendingBundles'] as List<dynamic>).cast<String>(),
      receivedBundles: (json['receivedBundles'] as List<dynamic>).cast<String>(),
      connectedDataMules: (json['connectedDataMules'] as List<dynamic>).cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$HubToJson(Hub instance) => <String, dynamic>{
      'hubID': instance.hubID,
      'hubName': instance.hubName,
      'location': instance.location,
      'registeredUsers': instance.registeredUsers,
      'pendingBundles': instance.pendingBundles,
      'receivedBundles': instance.receivedBundles,
      'connectedDataMules': instance.connectedDataMules,
      'createdAt': instance.createdAt.toIso8601String(),
    };
