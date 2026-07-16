import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xenhub/src/app.dart';
import 'package:xenhub/src/features/dashboard/domain/dashboard_repository.dart';
import 'package:xenhub/src/features/dashboard/domain/dashboard_stats.dart';
import 'package:xenhub/src/features/dtn/domain/dtn_bundle.dart';
import 'package:xenhub/src/features/dtn/domain/dtn_bundle_status.dart';
import 'package:xenhub/src/features/dtn/domain/dtn_bus.dart';
import 'package:xenhub/src/features/dtn/domain/dtn_hub.dart';
import 'package:xenhub/src/features/dtn/domain/dtn_simulator_repository.dart';
import 'package:xenhub/src/features/dtn/domain/dtn_simulator_snapshot.dart';
import 'package:xenhub/src/features/dashboard/presentation/dashboard_providers.dart';
import 'package:xenhub/src/features/message_queue/domain/message_bundle.dart';
import 'package:xenhub/src/features/message_queue/domain/message_queue_row.dart';
import 'package:xenhub/src/features/message_queue/domain/message_queue_repository.dart';
import 'package:xenhub/src/features/message_queue/domain/message_status.dart';
import 'package:xenhub/src/features/dtn/presentation/dtn_simulator_providers.dart';
import 'package:xenhub/src/features/message_queue/presentation/message_queue_providers.dart';
import 'package:xenhub/src/features/users/domain/user_account.dart';
import 'package:xenhub/src/features/users/domain/user_repository.dart';
import 'package:xenhub/src/features/users/presentation/users_providers.dart';

void main() {
  testWidgets('shell covers users and queue flows', (tester) async {
    tester.view.physicalSize = const Size(1400, 2200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final usersRepo = _FakeUsersRepository();
    final queueRepo = _FakeQueueRepository();
    final dtnRepo = _FakeDtnRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(_FakeDashboardRepository()),
          userRepositoryProvider.overrideWithValue(usersRepo),
          messageQueueRepositoryProvider.overrideWithValue(queueRepo),
          dtnSimulatorRepositoryProvider.overrideWithValue(dtnRepo),
        ],
        child: const XenHubApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Operations Command Center'), findsOneWidget);
    expect(find.text('Queue groups'), findsOneWidget);
    expect(find.text('Relay fleet'), findsOneWidget);

    await tester.tap(find.text('Users'));
    await tester.pumpAndSettle();

    expect(find.text('Auto-Registered Users'), findsOneWidget);
    expect(find.text('Nearby hub detections'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('Vedh Pokharkar'), findsOneWidget);
    expect(find.text('Nihal Mishra'), findsOneWidget);
    expect(find.text('Disha Mohite'), findsOneWidget);
    expect(find.text('Hemant Thakur'), findsOneWidget);
    expect(find.text('Auto registered'), findsAtLeastNWidgets(4));
    expect(find.text('Inside range'), findsAtLeastNWidgets(4));
    expect(find.text('Lina Torres'), findsNothing);
    expect(find.text('Ethan Cole'), findsNothing);

    await tester.tap(find.text('Queue'));
    await tester.pumpAndSettle();

    expect(find.text('Message Queue'), findsOneWidget);
    expect(find.text('Destination groups'), findsOneWidget);
    expect(find.text('North Hub'), findsOneWidget);
    expect(find.text('South Hub'), findsOneWidget);
    expect(find.text('Message #1'), findsOneWidget);
    expect(find.text('Message #3'), findsOneWidget);
    expect(find.text('Destination: North Hub'), findsAtLeastNWidgets(2));
    expect(find.text('Destination: South Hub'), findsOneWidget);
    expect(queueRepo.bundles.length, 2);

    await tester.tap(find.byType(DropdownButton<MessageStatus>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('sent').last);
    await tester.pumpAndSettle();

    expect(queueRepo.bundles.first.messages.first.status, MessageStatus.sent);

    await tester.tap(find.byKey(const ValueKey('delete-bundle-2')));
    await tester.pumpAndSettle();

    expect(queueRepo.bundles.length, 1);
    expect(queueRepo.bundles.single.destinationAddress, 'North Hub');

    await tester.tap(find.text('DTN'));
    await tester.pumpAndSettle();

    expect(find.text('DTN Relay Monitor'), findsOneWidget);
    expect(find.text('Relay buses'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
    expect(find.text('North Relay 01'), findsOneWidget);
    expect(find.text('Central Relay 02'), findsOneWidget);
    expect(find.text('South Relay 03'), findsOneWidget);
    expect(find.text('Route North Hub -> Central Hub'), findsOneWidget);
    expect(find.text('Route Central Hub -> South Hub'), findsOneWidget);
    expect(find.text('North Hub'), findsAtLeastNWidgets(2));
    expect(find.text('Central Hub'), findsAtLeastNWidgets(2));
    expect(find.text('South Hub'), findsAtLeastNWidgets(2));

    await tester.tap(find.byKey(const ValueKey('bundles-onboard-3')));
    await tester.pumpAndSettle();

    expect(find.text('Message #1'), findsAtLeastNWidgets(1));
    expect(find.text('Parcel 101'), findsAtLeastNWidgets(1));
    expect(find.text('Parcel 102'), findsAtLeastNWidgets(1));

    await tester.tap(find.text('Relay'));
    await tester.pumpAndSettle();

    expect(find.text('Relay Network'), findsOneWidget);
    expect(find.text('North Relay 01'), findsOneWidget);
  });
}

class _FakeDashboardRepository implements DashboardRepository {
  @override
  Future<DashboardStats> loadStats() async {
    return const DashboardStats(
      totalTasks: 4,
      completedTasks: 2,
      pendingTasks: 2,
    );
  }
}

class _FakeUsersRepository implements UserRepository {
  final List<UserAccount> users = [
    UserAccount(
      id: 1,
      fullName: 'Vedh Pokharkar',
      email: 'vedh.pokharkar@gmail.com',
      phone: '+91 98765 43210',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    UserAccount(
      id: 2,
      fullName: 'Nihal Mishra',
      email: 'nihal.mishra@gmail.com',
      phone: '+91 98765 43211',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    UserAccount(
      id: 3,
      fullName: 'Disha Mohite',
      email: 'disha.mohite@gmail.com',
      phone: '+91 98765 43212',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    UserAccount(
      id: 4,
      fullName: 'Hemant Thakur',
      email: 'hemant.thakur@gmail.com',
      phone: '+91 98765 43213',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  ];

  @override
  Future<UserAccount> createUser(UserAccount user) async {
    final created = user.copyWith(id: users.length + 1);
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
    if (index == -1) {
      throw StateError('User not found.');
    }
    users[index] = user;
    return user;
  }
}

class _FakeQueueRepository implements MessageQueueRepository {
  final List<MessageBundle> bundles = [
    MessageBundle(
      id: 1,
      name: 'North Hub',
      destinationAddress: 'North Hub',
      createdAt: DateTime(2026, 1, 1),
      messageCount: 2,
      queuedCount: 2,
      sentCount: 0,
      failedCount: 0,
      messages: [
        MessageQueueRow(
          id: 1,
          bundleId: 1,
          destinationAddress: 'North Hub',
          body: 'Parcel 101',
          status: MessageStatus.queued,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
        MessageQueueRow(
          id: 2,
          bundleId: 1,
          destinationAddress: 'North Hub',
          body: 'Parcel 102',
          status: MessageStatus.queued,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ],
    ),
    MessageBundle(
      id: 2,
      name: 'South Hub',
      destinationAddress: 'South Hub',
      createdAt: DateTime(2026, 1, 1),
      messageCount: 1,
      queuedCount: 1,
      sentCount: 0,
      failedCount: 0,
      messages: [
        MessageQueueRow(
          id: 3,
          bundleId: 2,
          destinationAddress: 'South Hub',
          body: 'Return manifest',
          status: MessageStatus.queued,
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      ],
    ),
  ];
  var _nextBundleId = 3;
  var _nextMessageId = 4;

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

    final bundle = MessageBundle(
      id: bundleId,
      name: destinationAddress,
      destinationAddress: destinationAddress,
      createdAt: now,
      messageCount: rows.length,
      queuedCount: rows.length,
      sentCount: 0,
      failedCount: 0,
      messages: rows,
    );

    if (existingIndex == -1) {
      bundles.insert(0, bundle);
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
    if (bundleIndex == -1) {
      throw StateError('Message not found.');
    }

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
  final List<DtnBus> buses = [
    DtnBus(
      id: 1,
      name: 'North Relay 01',
      originHubId: 1,
      destinationHubId: 2,
      currentHubId: 1,
      status: 'loading',
      lastUpdatedAt: DateTime(2026, 1, 1),
    ),
    DtnBus(
      id: 2,
      name: 'Central Relay 02',
      originHubId: 2,
      destinationHubId: 3,
      currentHubId: 2,
      status: 'in-transit',
      lastUpdatedAt: DateTime(2026, 1, 1),
    ),
    DtnBus(
      id: 3,
      name: 'South Relay 03',
      originHubId: 3,
      destinationHubId: 1,
      currentHubId: 3,
      status: 'waiting',
      lastUpdatedAt: DateTime(2026, 1, 1),
    ),
  ];
  final List<DtnBundle> bundles = [
    DtnBundle(
      id: 1,
      label: 'North Hub',
      originHubId: 1,
      destinationHubId: 2,
      currentHubId: 1,
      status: DtnBundleStatus.queued,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    DtnBundle(
      id: 2,
      label: 'Central Hub',
      originHubId: 2,
      destinationHubId: 3,
      currentHubId: 2,
      status: DtnBundleStatus.queued,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
    DtnBundle(
      id: 3,
      label: 'South Hub',
      originHubId: 3,
      destinationHubId: 1,
      currentHubId: 3,
      status: DtnBundleStatus.queued,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  ];
  var _nextBusId = 4;
  var _nextBundleId = 4;

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
