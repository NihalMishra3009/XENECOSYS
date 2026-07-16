import 'dtn_bundle.dart';
import 'dtn_bus.dart';
import 'dtn_simulator_snapshot.dart';

abstract class DtnSimulatorRepository {
  Future<DtnSimulatorSnapshot> loadSnapshot();
  Future<DtnBundle> createBundle({
    required String label,
    required int originHubId,
    required int destinationHubId,
  });
  Future<DtnBus> createBus({
    required String name,
    required int originHubId,
    required int destinationHubId,
  });
  Future<void> dispatchBus(int busId);
}
