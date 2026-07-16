import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/dtn_simulator_repository.dart';
import '../domain/dtn_simulator_snapshot.dart';

final dtnSimulatorRepositoryProvider = Provider<DtnSimulatorRepository>((ref) {
  throw UnimplementedError(
    'dtnSimulatorRepositoryProvider must be overridden in main or tests.',
  );
});

final dtnSnapshotProvider = FutureProvider<DtnSimulatorSnapshot>((ref) {
  return ref.watch(dtnSimulatorRepositoryProvider).loadSnapshot();
});

final simulationClockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream<DateTime>.periodic(
    const Duration(seconds: 1),
    (_) => DateTime.now(),
  );
});
