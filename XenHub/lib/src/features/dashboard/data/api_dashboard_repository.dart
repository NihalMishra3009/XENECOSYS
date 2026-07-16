import '../../../core/api/hub_api_client.dart';
import '../domain/dashboard_repository.dart';
import '../domain/dashboard_stats.dart';

class ApiDashboardRepository implements DashboardRepository {
  ApiDashboardRepository(this._client);

  final HubApiClient _client;

  @override
  Future<DashboardStats> loadStats() async {
    final json = await _client.getObject('dashboard');
    return DashboardStats(
      totalTasks: json['totalTasks'] as int? ?? 0,
      completedTasks: json['completedTasks'] as int? ?? 0,
      pendingTasks: json['pendingTasks'] as int? ?? 0,
    );
  }
}
