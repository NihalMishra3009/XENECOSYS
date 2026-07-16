import '../../../core/database/app_database.dart';
import '../domain/dtn_bundle.dart';
import '../domain/dtn_bus.dart';
import '../domain/dtn_simulator_repository.dart';
import '../domain/dtn_simulator_snapshot.dart';

class SqliteDtnSimulatorRepository implements DtnSimulatorRepository {
  SqliteDtnSimulatorRepository(this._database);

  final AppDatabase _database;

  @override
  Future<DtnBus> createBus({
    required String name,
    required int originHubId,
    required int destinationHubId,
  }) {
    return _database.createDtnBus(
      name: name,
      originHubId: originHubId,
      destinationHubId: destinationHubId,
    );
  }

  @override
  Future<DtnBundle> createBundle({
    required String label,
    required int originHubId,
    required int destinationHubId,
  }) {
    return _database.createDtnBundle(
      label: label,
      originHubId: originHubId,
      destinationHubId: destinationHubId,
    );
  }

  @override
  Future<void> dispatchBus(int busId) => _database.dispatchDtnBus(busId);

  @override
  Future<DtnSimulatorSnapshot> loadSnapshot() => _database.readDtnSnapshot();
}
