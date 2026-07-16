import 'package:json_annotation/json_annotation.dart';

part 'data_mule_model.g.dart';

@JsonSerializable()
class DataMule {
  final String vehicleID;
  final String type;
  final int capacity;
  final String currentHub;
  final String nextHub;
  final double speed;
  final String status;
  final List<String> bundlesCarrying;
  final DateTime createdAt;

  DataMule({
    required this.vehicleID,
    required this.type,
    required this.capacity,
    required this.currentHub,
    required this.nextHub,
    required this.speed,
    required this.status,
    required this.bundlesCarrying,
    required this.createdAt,
  });

  factory DataMule.fromJson(Map<String, dynamic> json) => _$DataMuleFromJson(json);
  Map<String, dynamic> toJson() => _$DataMuleToJson(this);

  DataMule copyWith({
    String? vehicleID,
    String? type,
    int? capacity,
    String? currentHub,
    String? nextHub,
    double? speed,
    String? status,
    List<String>? bundlesCarrying,
    DateTime? createdAt,
  }) {
    return DataMule(
      vehicleID: vehicleID ?? this.vehicleID,
      type: type ?? this.type,
      capacity: capacity ?? this.capacity,
      currentHub: currentHub ?? this.currentHub,
      nextHub: nextHub ?? this.nextHub,
      speed: speed ?? this.speed,
      status: status ?? this.status,
      bundlesCarrying: bundlesCarrying ?? this.bundlesCarrying,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
