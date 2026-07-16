import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:xenhub/src/core/api/hub_api_server.dart';
import 'package:xenhub/src/features/dashboard/domain/dashboard_repository.dart';
import 'package:xenhub/src/features/dashboard/domain/dashboard_stats.dart';
import 'package:xenhub/src/features/dtn/domain/dtn_bundle.dart';
import 'package:xenhub/src/features/dtn/domain/dtn_bundle_status.dart';
import 'package:xenhub/src/features/dtn/domain/dtn_bus.dart';
import 'package:xenhub/src/features/dtn/domain/dtn_hub.dart';
import 'package:xenhub/src/features/dtn/domain/dtn_simulator_repository.dart';
import 'package:xenhub/src/features/dtn/domain/dtn_simulator_snapshot.dart';
import 'package:xenhub/src/features/message_queue/domain/message_bundle.dart';
import 'package:xenhub/src/features/message_queue/domain/message_queue_repository.dart';
import 'package:xenhub/src/features/message_queue/domain/message_queue_row.dart';
import 'package:xenhub/src/features/message_queue/domain/message_status.dart';
import 'package:xenhub/src/features/users/domain/user_account.dart';
import 'package:xenhub/src/features/users/domain/user_repository.dart';

void main() {
  test('hub api serves dashboard, users, and queue endpoints', () async {
    final dashboardRepository = _FakeDashboardRepository();
    final userRepository = _FakeUserRepository();
    final queueRepository = _FakeQueueRepository();
    final dtnRepository = _FakeDtnRepository();
    final server = HubApiServer(
      dashboardRepository: dashboardRepository,
      userRepository: userRepository,
      messageQueueRepository: queueRepository,
      dtnSimulatorRepository: dtnRepository,
      port: 0,
    );

    await server.start();
    addTearDown(server.stop);

    final baseUri = Uri.parse('http://127.0.0.1:${server.boundPort}/api');

    final health = await _getJson(_api(baseUri, 'health'));
    expect(health['ok'], isTrue);

    final dashboard = await _getJson(_api(baseUri, 'dashboard'));
    expect(dashboard['totalTasks'], 7);

    final createdUser = await _requestJson(
      'POST',
      _api(baseUri, 'users'),
      body: {
        'fullName': 'Grace Hopper',
        'email': 'grace@example.com',
        'phone': '+1 555 000 1111',
      },
    );
    expect(createdUser['email'], 'grace@example.com');

    final users = await _getJson(_api(baseUri, 'users'));
    expect((users['items'] as List).length, 1);

    final createdBundle = await _requestJson(
      'POST',
      _api(baseUri, 'queue/bundles'),
      body: {
        'destinationAddress': 'North Hub',
        'messages': ['hello hub', 'second line'],
      },
    );
    expect(createdBundle['ok'], isTrue);

    final bundlesBefore = await _getJson(_api(baseUri, 'queue/bundles'));
    expect((bundlesBefore['items'] as List).single['messageCount'], 2);
    expect((bundlesBefore['items'] as List).single['destinationAddress'], 'North Hub');

    final messageId = ((bundlesBefore['items'] as List).single['messages'] as List)
        .first['id'] as int;
    final statusResponse = await _request(
      'PATCH',
      _api(baseUri, 'queue/messages/$messageId/status'),
      body: {'status': 'sent'},
    );
    expect(statusResponse.statusCode, HttpStatus.noContent);

    final bundlesAfter = await _getJson(_api(baseUri, 'queue/bundles'));
    final firstBundle = (bundlesAfter['items'] as List).single as Map<String, dynamic>;
    expect(firstBundle['sentCount'], 1);

    final bundleId = firstBundle['id'] as int;
    final deleteResponse = await _request(
      'DELETE',
      _api(baseUri, 'queue/bundles/$bundleId'),
    );
    expect(deleteResponse.statusCode, HttpStatus.noContent);

    final autoBundleA = await _requestJson(
      'POST',
      _api(baseUri, 'queue/bundles'),
      body: {
        'destinationAddress': 'North Hub',
        'messages': ['third line'],
      },
    );
    expect(autoBundleA['ok'], isTrue);

    final autoBundleB = await _requestJson(
      'POST',
      _api(baseUri, 'queue/bundles'),
      body: {
        'destinationAddress': 'North Hub',
        'messages': ['fourth line'],
      },
    );
    expect(autoBundleB['ok'], isTrue);

    final autoBundles = await _getJson(_api(baseUri, 'queue/bundles'));
    final autoBundle = (autoBundles['items'] as List).single as Map<String, dynamic>;
    expect(autoBundle['destinationAddress'], 'North Hub');
    expect(autoBundle['messageCount'], 2);

    final dtn = await _getJson(_api(baseUri, 'dtn'));
    expect((dtn['hubs'] as List).length, 3);

    final createdBus = await _requestJson(
      'POST',
      _api(baseUri, 'dtn/buses'),
      body: {
        'name': 'North Runner',
        'originHubId': 1,
        'destinationHubId': 2,
      },
    );
    expect(createdBus['name'], 'North Runner');

    final createdDtnBundle = await _requestJson(
      'POST',
      _api(baseUri, 'dtn/bundles'),
      body: {
        'label': 'Parcel A',
        'originHubId': 1,
        'destinationHubId': 2,
      },
    );
    expect(createdDtnBundle['label'], 'Parcel A');

    final dispatch = await _request(
      'POST',
      _api(baseUri, 'dtn/buses/1/dispatch'),
    );
    expect(dispatch.statusCode, HttpStatus.noContent);

    final dtnAfter = await _getJson(_api(baseUri, 'dtn'));
    final bundle = (dtnAfter['bundles'] as List).single as Map<String, dynamic>;
    expect(bundle['status'], 'delivered');
  });
}

Uri _api(Uri baseUri, String path) {
  return Uri.parse('${baseUri.toString()}/$path');
}

Future<Map<String, dynamic>> _getJson(Uri uri) async {
  final response = await _request('GET', uri);
  return jsonDecode(response.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> _requestJson(
  String method,
  Uri uri, {
  Map<String, Object?>? body,
}) async {
  final response = await _request(method, uri, body: body);
  return jsonDecode(response.body) as Map<String, dynamic>;
}

Future<_HttpResult> _request(
  String method,
  Uri uri, {
  Map<String, Object?>? body,
}) async {
  final client = HttpClient();
  final request = await client.openUrl(method, uri);
  request.headers.contentType = ContentType.json;
  if (body != null) {
    request.write(jsonEncode(body));
  }
  final response = await request.close();
  final text = await utf8.decodeStream(response);
  client.close(force: true);
  return _HttpResult(statusCode: response.statusCode, body: text);
}

class _HttpResult {
  const _HttpResult({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}

class _FakeDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardStats> loadStats() async {
    return const DashboardStats(
      totalTasks: 7,
      completedTasks: 4,
      pendingTasks: 3,
    );
  }
}

class _FakeUserRepository implements UserRepository {
  final List<UserAccount> users = [];
  var _nextId = 1;

  @override
  Future<UserAccount> createUser(UserAccount user) async {
    final created = user.copyWith(id: _nextId++);
    users.add(created);
    return created;
  }

  @override
  Future<void> deleteUser(int id) async {
    users.removeWhere((user) => user.id == id);
  }

  @override
  Future<List<UserAccount>> listUsers() async {
    return List<UserAccount>.from(users);
  }

  @override
  Future<UserAccount> updateUser(UserAccount user) async {
    final index = users.indexWhere((item) => item.id == user.id);
    users[index] = user;
    return user;
  }
}

class _FakeQueueRepository implements MessageQueueRepository {
  final List<MessageBundle> bundles = [];
  var _nextBundleId = 1;
  var _nextMessageId = 1;

  @override
  Future<void> createBundle(String destinationAddress, List<String> messages) async {
    final now = DateTime(2026, 1, 1);
    final existingIndex = bundles.indexWhere(
      (bundle) => bundle.destinationAddress == destinationAddress,
    );
    final bundleId = existingIndex == -1 ? _nextBundleId++ : bundles[existingIndex].id;
    final rows = messages
        .map(
          (message) => MessageQueueRow(
            id: _nextMessageId++,
            bundleId: bundleId,
            destinationAddress: destinationAddress,
            body: message,
            status: MessageStatus.queued,
            createdAt: now,
            updatedAt: now,
          ),
        )
        .toList(growable: false);

    if (existingIndex == -1) {
      bundles.add(
        MessageBundle(
          id: bundleId,
          name: destinationAddress,
          destinationAddress: destinationAddress,
          createdAt: now,
          messageCount: rows.length,
          queuedCount: rows.length,
          sentCount: 0,
          failedCount: 0,
          messages: rows,
        ),
      );
      return;
    }

    final existing = bundles[existingIndex];
    final combinedMessages = [...existing.messages, ...rows];
    bundles[existingIndex] = MessageBundle(
      id: existing.id,
      name: existing.name,
      destinationAddress: existing.destinationAddress,
      createdAt: existing.createdAt,
      messageCount: combinedMessages.length,
      queuedCount: combinedMessages.where((message) => message.status == MessageStatus.queued).length,
      sentCount: combinedMessages.where((message) => message.status == MessageStatus.sent).length,
      failedCount: combinedMessages.where((message) => message.status == MessageStatus.failed).length,
      messages: combinedMessages,
    );
  }

  @override
  Future<void> deleteBundle(int bundleId) async {
    bundles.removeWhere((bundle) => bundle.id == bundleId);
  }

  @override
  Future<List<MessageBundle>> listBundles() async {
    return List<MessageBundle>.from(bundles);
  }

  @override
  Future<void> updateMessageStatus(int messageId, MessageStatus status) async {
    final bundleIndex = bundles.indexWhere(
      (bundle) => bundle.messages.any((message) => message.id == messageId),
    );
    final bundle = bundles[bundleIndex];
    final messages = bundle.messages
        .map(
          (message) => message.id == messageId
              ? MessageQueueRow(
                  id: message.id,
                  bundleId: message.bundleId,
                  destinationAddress: message.destinationAddress,
                  body: message.body,
                  status: status,
                  createdAt: message.createdAt,
                  updatedAt: message.updatedAt,
                )
              : message,
        )
        .toList(growable: false);

    bundles[bundleIndex] = MessageBundle(
      id: bundle.id,
      name: bundle.name,
      destinationAddress: bundle.destinationAddress,
      createdAt: bundle.createdAt,
      messageCount: bundle.messageCount,
      queuedCount: messages.where((message) => message.status == MessageStatus.queued).length,
      sentCount: messages.where((message) => message.status == MessageStatus.sent).length,
      failedCount: messages.where((message) => message.status == MessageStatus.failed).length,
      messages: messages,
    );
  }
}

class _FakeDtnRepository implements DtnSimulatorRepository {
  final List<DtnHub> hubs = const [
    DtnHub(id: 1, name: 'North Hub', bundleCount: 0, busCount: 0),
    DtnHub(id: 2, name: 'Central Hub', bundleCount: 0, busCount: 0),
    DtnHub(id: 3, name: 'South Hub', bundleCount: 0, busCount: 0),
  ];
  final List<DtnBus> buses = [];
  final List<DtnBundle> bundles = [];
  var _nextBusId = 1;
  var _nextBundleId = 1;

  @override
  Future<DtnBus> createBus({
    required String name,
    required int originHubId,
    required int destinationHubId,
  }) async {
    final bus = DtnBus(
      id: _nextBusId++,
      name: name,
      originHubId: originHubId,
      destinationHubId: destinationHubId,
      currentHubId: originHubId,
      status: 'idle',
      lastUpdatedAt: DateTime(2026, 1, 1),
    );
    buses.add(bus);
    return bus;
  }

  @override
  Future<DtnBundle> createBundle({
    required String label,
    required int originHubId,
    required int destinationHubId,
  }) async {
    final bundle = DtnBundle(
      id: _nextBundleId++,
      label: label,
      originHubId: originHubId,
      destinationHubId: destinationHubId,
      currentHubId: originHubId,
      status: DtnBundleStatus.queued,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    bundles.add(bundle);
    return bundle;
  }

  @override
  Future<void> dispatchBus(int busId) async {
    final busIndex = buses.indexWhere((bus) => bus.id == busId);
    if (busIndex == -1) {
      return;
    }
    final bus = buses[busIndex];
    final nextHubId = bus.currentHubId == bus.originHubId ? bus.destinationHubId : bus.originHubId;
    buses[busIndex] = DtnBus(
      id: bus.id,
      name: bus.name,
      originHubId: bus.originHubId,
      destinationHubId: bus.destinationHubId,
      currentHubId: nextHubId,
      status: 'idle',
      lastUpdatedAt: DateTime(2026, 1, 1),
    );

    for (var i = 0; i < bundles.length; i++) {
      final bundle = bundles[i];
      if (bundle.currentHubId == bus.currentHubId) {
        bundles[i] = DtnBundle(
          id: bundle.id,
          label: bundle.label,
          originHubId: bundle.originHubId,
          destinationHubId: bundle.destinationHubId,
          currentHubId: nextHubId,
          status: nextHubId == bundle.destinationHubId
              ? DtnBundleStatus.delivered
              : DtnBundleStatus.queued,
          createdAt: bundle.createdAt,
          updatedAt: DateTime(2026, 1, 1),
        );
      }
    }
  }

  @override
  Future<DtnSimulatorSnapshot> loadSnapshot() async {
    return DtnSimulatorSnapshot(
      hubs: hubs,
      buses: List<DtnBus>.from(buses),
      bundles: List<DtnBundle>.from(bundles),
    );
  }
}
