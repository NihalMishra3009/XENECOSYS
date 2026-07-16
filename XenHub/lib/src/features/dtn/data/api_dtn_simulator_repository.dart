import '../../../core/api/hub_api_client.dart';
import '../domain/dtn_bundle.dart';
import '../domain/dtn_bundle_status.dart';
import '../domain/dtn_bus.dart';
import '../domain/dtn_hub.dart';
import '../domain/dtn_simulator_repository.dart';
import '../domain/dtn_simulator_snapshot.dart';

class ApiDtnSimulatorRepository implements DtnSimulatorRepository {
  ApiDtnSimulatorRepository(this._client);

  final HubApiClient _client;

  @override
  Future<DtnBus> createBus({
    required String name,
    required int originHubId,
    required int destinationHubId,
  }) async {
    final json = await _client.postObject(
      'dtn/buses',
      body: {
        'name': name,
        'originHubId': originHubId,
        'destinationHubId': destinationHubId,
      },
    );
    return _busFromJson(json);
  }

  @override
  Future<DtnBundle> createBundle({
    required String label,
    required int originHubId,
    required int destinationHubId,
  }) async {
    final json = await _client.postObject(
      'dtn/bundles',
      body: {
        'label': label,
        'originHubId': originHubId,
        'destinationHubId': destinationHubId,
      },
    );
    return _bundleFromJson(json);
  }

  @override
  Future<void> dispatchBus(int busId) {
    return _client.postObject('dtn/buses/$busId/dispatch');
  }

  @override
  Future<DtnSimulatorSnapshot> loadSnapshot() async {
    final json = await _client.getObject('dtn');
    return DtnSimulatorSnapshot(
      hubs: (json['hubs'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(_hubFromJson)
          .toList(growable: false),
      buses: (json['buses'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(_busFromJson)
          .toList(growable: false),
      bundles: (json['bundles'] as List? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(_bundleFromJson)
          .toList(growable: false),
    );
  }

  DtnHub _hubFromJson(Map<String, dynamic> json) {
    return DtnHub(
      id: json['id'] as int,
      name: json['name'] as String,
      bundleCount: json['bundleCount'] as int? ?? 0,
      busCount: json['busCount'] as int? ?? 0,
    );
  }

  DtnBus _busFromJson(Map<String, dynamic> json) {
    return DtnBus(
      id: json['id'] as int,
      name: json['name'] as String,
      originHubId: json['originHubId'] as int,
      destinationHubId: json['destinationHubId'] as int,
      currentHubId: json['currentHubId'] as int,
      status: json['status'] as String,
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
    );
  }

  DtnBundle _bundleFromJson(Map<String, dynamic> json) {
    return DtnBundle(
      id: json['id'] as int,
      label: json['label'] as String,
      originHubId: json['originHubId'] as int,
      destinationHubId: json['destinationHubId'] as int,
      currentHubId: json['currentHubId'] as int,
      status: DtnBundleStatus.fromName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
