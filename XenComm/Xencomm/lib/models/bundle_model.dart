import 'package:json_annotation/json_annotation.dart';

part 'bundle_model.g.dart';

@JsonSerializable()
class Bundle {
  final String bundleID;
  final String sourceHub;
  final String destinationHub;
  final List<String> messageIDs;
  final DateTime createdAt;
  final String checksum;
  final String status;
  final int sizeBytes;

  Bundle({
    required this.bundleID,
    required this.sourceHub,
    required this.destinationHub,
    required this.messageIDs,
    required this.createdAt,
    required this.checksum,
    required this.status,
    required this.sizeBytes,
  });

  factory Bundle.fromJson(Map<String, dynamic> json) => _$BundleFromJson(json);
  Map<String, dynamic> toJson() => _$BundleToJson(this);

  Bundle copyWith({
    String? bundleID,
    String? sourceHub,
    String? destinationHub,
    List<String>? messageIDs,
    DateTime? createdAt,
    String? checksum,
    String? status,
    int? sizeBytes,
  }) {
    return Bundle(
      bundleID: bundleID ?? this.bundleID,
      sourceHub: sourceHub ?? this.sourceHub,
      destinationHub: destinationHub ?? this.destinationHub,
      messageIDs: messageIDs ?? this.messageIDs,
      createdAt: createdAt ?? this.createdAt,
      checksum: checksum ?? this.checksum,
      status: status ?? this.status,
      sizeBytes: sizeBytes ?? this.sizeBytes,
    );
  }
}
