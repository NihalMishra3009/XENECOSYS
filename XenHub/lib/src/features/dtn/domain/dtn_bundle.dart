import 'dtn_bundle_status.dart';

class DtnBundle {
  const DtnBundle({
    required this.id,
    required this.label,
    required this.originHubId,
    required this.destinationHubId,
    required this.currentHubId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String label;
  final int originHubId;
  final int destinationHubId;
  final int currentHubId;
  final DtnBundleStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
}
