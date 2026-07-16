import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'src/core/api/hub_api_client.dart';
import 'src/core/api/hub_api_server.dart';
import 'src/app.dart';
import 'src/core/database/app_database.dart';
import 'src/features/dtn/data/api_dtn_simulator_repository.dart';
import 'src/features/dtn/data/sqlite_dtn_simulator_repository.dart';
import 'src/features/dtn/presentation/dtn_simulator_providers.dart';
import 'src/features/dashboard/data/api_dashboard_repository.dart';
import 'src/features/dashboard/data/sqlite_dashboard_repository.dart';
import 'src/features/dashboard/presentation/dashboard_providers.dart';
import 'src/features/message_queue/data/api_message_queue_repository.dart';
import 'src/features/message_queue/data/sqlite_message_queue_repository.dart';
import 'src/features/message_queue/presentation/message_queue_providers.dart';
import 'src/features/users/data/api_user_repository.dart';
import 'src/features/users/data/sqlite_user_repository.dart';
import 'src/features/users/presentation/users_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  runApp(const _BootstrapApp());
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  late final Future<_BootstrapResult> _bootstrapFuture = _bootstrap();

  Future<_BootstrapResult> _bootstrap() async {
    final database = AppDatabase();
    await database.open();

    final apiServer = HubApiServer(
      dashboardRepository: SqliteDashboardRepository(database),
      userRepository: SqliteUserRepository(database),
      messageQueueRepository: SqliteMessageQueueRepository(database),
      dtnSimulatorRepository: SqliteDtnSimulatorRepository(database),
      port: int.tryParse(Platform.environment['XENHUB_API_PORT'] ?? '') ?? 8080,
    );
    await apiServer.start();

    final apiBaseUri = Uri.parse('http://127.0.0.1:${apiServer.boundPort}/api');
    return _BootstrapResult(
      apiClient: HubApiClient(apiBaseUri),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2457D6),
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'XenHub',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      ),
      home: FutureBuilder<_BootstrapResult>(
        future: _bootstrapFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Failed to start XenHub: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return Scaffold(
              body: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        'Starting XenHub...',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final bootstrap = snapshot.data!;
          return ProviderScope(
            overrides: [
              dashboardRepositoryProvider.overrideWithValue(
                ApiDashboardRepository(bootstrap.apiClient),
              ),
              userRepositoryProvider.overrideWithValue(
                ApiUserRepository(bootstrap.apiClient),
              ),
              messageQueueRepositoryProvider.overrideWithValue(
                ApiMessageQueueRepository(bootstrap.apiClient),
              ),
              dtnSimulatorRepositoryProvider.overrideWithValue(
                ApiDtnSimulatorRepository(bootstrap.apiClient),
              ),
            ],
            child: const XenHubApp(),
          );
        },
      ),
    );
  }
}

class _BootstrapResult {
  const _BootstrapResult({
    required this.apiClient,
  });

  final HubApiClient apiClient;
}
