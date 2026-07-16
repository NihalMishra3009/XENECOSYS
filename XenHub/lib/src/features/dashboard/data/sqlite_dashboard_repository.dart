import '../../../core/database/app_database.dart';
import '../domain/dashboard_repository.dart';
import '../domain/dashboard_stats.dart';

class SqliteDashboardRepository implements DashboardRepository {
  SqliteDashboardRepository(this._database);

  final AppDatabase _database;

  @override
  Future<DashboardStats> loadStats() => _database.readDashboardStats();
}
