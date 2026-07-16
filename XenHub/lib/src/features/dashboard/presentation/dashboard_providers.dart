import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/dashboard_repository.dart';
import '../domain/dashboard_stats.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  throw UnimplementedError(
    'dashboardRepositoryProvider must be overridden in main or tests.',
  );
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) {
  return ref.watch(dashboardRepositoryProvider).loadStats();
});
