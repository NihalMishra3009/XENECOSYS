import 'package:json_annotation/json_annotation.dart';

part 'hub_model.g.dart';

@JsonSerializable()
class Hub {
  final String hubID;
  final String hubName;
  final Map<String, dynamic> location;
  final List<String> registeredUsers;
  final List<String> pendingBundles;
  final List<String> receivedBundles;
  final List<String> connectedDataMules;
  final DateTime createdAt;

  Hub({
    required this.hubID,
    required this.hubName,
    required this.location,
    required this.registeredUsers,
    required this.pendingBundles,
    required this.receivedBundles,
    required this.connectedDataMules,
    required this.createdAt,
  });

  factory Hub.fromJson(Map<String, dynamic> json) => _$HubFromJson(json);
  Map<String, dynamic> toJson() => _$HubToJson(this);

  Hub copyWith({
    String? hubID,
    String? hubName,
    Map<String, dynamic>? location,
    List<String>? registeredUsers,
    List<String>? pendingBundles,
    List<String>? receivedBundles,
    List<String>? connectedDataMules,
    DateTime? createdAt,
  }) {
    return Hub(
      hubID: hubID ?? this.hubID,
      hubName: hubName ?? this.hubName,
      location: location ?? this.location,
      registeredUsers: registeredUsers ?? this.registeredUsers,
      pendingBundles: pendingBundles ?? this.pendingBundles,
      receivedBundles: receivedBundles ?? this.receivedBundles,
      connectedDataMules: connectedDataMules ?? this.connectedDataMules,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
