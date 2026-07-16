import 'dtn_bus.dart';
import 'dtn_bundle.dart';
import 'dtn_hub.dart';

class DtnSimulatorSnapshot {
  const DtnSimulatorSnapshot({
    required this.hubs,
    required this.buses,
    required this.bundles,
  });

  final List<DtnHub> hubs;
  final List<DtnBus> buses;
  final List<DtnBundle> bundles;
}
