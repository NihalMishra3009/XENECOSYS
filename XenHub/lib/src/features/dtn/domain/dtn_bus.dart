class DtnBus {
  const DtnBus({
    required this.id,
    required this.name,
    required this.originHubId,
    required this.destinationHubId,
    required this.currentHubId,
    required this.status,
    required this.lastUpdatedAt,
  });

  final int id;
  final String name;
  final int originHubId;
  final int destinationHubId;
  final int currentHubId;
  final String status;
  final DateTime lastUpdatedAt;
}
