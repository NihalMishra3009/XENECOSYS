import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../repositories/impl/bundle_repository_impl.dart';
import '../../repositories/impl/data_mule_repository_impl.dart';
import '../../repositories/impl/hub_repository_impl.dart';
import '../../simulation/dtn_simulator.dart';
import '../../simulation/dummy_data_generator.dart';
import '../widgets/feature_bottom_nav.dart';

class DTNSimulationScreen extends StatefulWidget {
  const DTNSimulationScreen({super.key});

  @override
  State<DTNSimulationScreen> createState() => _DTNSimulationScreenState();
}

class _DTNSimulationScreenState extends State<DTNSimulationScreen> {
  final _simulator = DTNSimulator();
  final _hubRepo = HubRepositoryImpl();
  final _muleRepo = DataMuleRepositoryImpl();
  final _bundleRepo = BundleRepositoryImpl();
  String _log = 'Simulator ready.\n';

  @override
  void initState() {
    super.initState();
    _seed();
  }

  Future<void> _seed() async {
    try {
      final hubs = DummyDataGenerator.generateHubs();
      final mules = DummyDataGenerator.generateDataMules();
      for (final hub in hubs) {
        await _hubRepo.createHub(hub.hubName, hub.location);
      }
      for (final mule in mules) {
        await _muleRepo.createDataMule(mule);
      }
      setState(() => _log += 'Loaded 3 hubs and 2 data mules.\n');
    } catch (e) {
      setState(() => _log += 'Init error: $e\n');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.dtnSimulatorTitle),
      ),
      body: Column(
        children: [
          Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Text(_log))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _button('Create Bundle', _createBundle),
                _button('Move Mule', _moveMule),
                _button('Transfer Bundle', _transferBundle),
                _button('Full Delivery', _fullDelivery),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const FeatureBottomNav(activeRoute: AppConstants.dtnSimulatorRoute),
    );
  }

  Widget _button(String label, VoidCallback onPressed) => FilledButton(
        onPressed: onPressed,
        child: Text(label),
      );

  Future<void> _createBundle() async {
    try {
      final bundle = await _simulator.createBundleFromMessages('HUB-001', 'HUB-002', const []);
      setState(() => _log += 'Bundle created: ${bundle.bundleID}\n');
    } catch (e) {
      setState(() => _log += 'Error: $e\n');
    }
  }

  Future<void> _moveMule() async {
    try {
      await _simulator.moveMuleToHub('MULE-BUS-001', 'HUB-002');
      setState(() => _log += 'Mule MULE-BUS-001 moved to HUB-002.\n');
    } catch (e) {
      setState(() => _log += 'Error: $e\n');
    }
  }

  Future<void> _transferBundle() async {
    try {
      final bundles = await _bundleRepo.getBundlesByStatus(AppConstants.bundleStatusCreated);
      if (bundles.isEmpty) {
        setState(() => _log += 'No bundles to transfer.\n');
        return;
      }
      final mule = await _muleRepo.getDataMuleByID('MULE-BUS-001');
      if (mule == null) throw Exception('Mule not found');
      await _simulator.assignBundleToMule(bundles.first.bundleID, mule.vehicleID);
      setState(() => _log += 'Bundle assigned to ${mule.vehicleID}\nStatus: InTransit\n');
    } catch (e) {
      setState(() => _log += 'Error: $e\n');
    }
  }

  Future<void> _fullDelivery() async {
    try {
      await _simulator.simulateEndToEndDelivery('HUB-001', 'HUB-002', const []);
      setState(() => _log += 'Delivery completed from HUB-001 to HUB-002.\n');
    } catch (e) {
      setState(() => _log += 'Error: $e\n');
    }
  }
}
