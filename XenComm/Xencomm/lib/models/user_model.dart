import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String uniqueID;
  final String name;
  final String? photo;
  final String homeHubID;
  final String currentHubID;
  final String publicKey;
  final String privateKey;
  final String deviceID;
  final DateTime createdAt;

  User({
    required this.uniqueID,
    required this.name,
    this.photo,
    required this.homeHubID,
    required this.currentHubID,
    required this.publicKey,
    required this.privateKey,
    required this.deviceID,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    String? uniqueID,
    String? name,
    String? photo,
    String? homeHubID,
    String? currentHubID,
    String? publicKey,
    String? privateKey,
    String? deviceID,
    DateTime? createdAt,
  }) {
    return User(
      uniqueID: uniqueID ?? this.uniqueID,
      name: name ?? this.name,
      photo: photo ?? this.photo,
      homeHubID: homeHubID ?? this.homeHubID,
      currentHubID: currentHubID ?? this.currentHubID,
      publicKey: publicKey ?? this.publicKey,
      privateKey: privateKey ?? this.privateKey,
      deviceID: deviceID ?? this.deviceID,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
