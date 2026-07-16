import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../features/dashboard/domain/dashboard_stats.dart';
import '../../features/dtn/domain/dtn_bundle.dart';
import '../../features/dtn/domain/dtn_bundle_status.dart';
import '../../features/dtn/domain/dtn_bus.dart';
import '../../features/dtn/domain/dtn_hub.dart';
import '../../features/dtn/domain/dtn_simulator_snapshot.dart';
import '../../features/message_queue/data/message_crypto.dart';
import '../../features/message_queue/domain/message_bundle.dart';
import '../../features/message_queue/domain/message_queue_row.dart';
import '../../features/message_queue/domain/message_status.dart';
import '../../features/users/domain/user_account.dart';

class AppDatabase {
  Database? _database;
  final MessageCrypto _messageCrypto = MessageCrypto();

  Future<void> open() async {
    if (_database != null) {
      return;
    }

    final databasesPath = await databaseFactory.getDatabasesPath();
    final dbPath = path.join(databasesPath, 'xenhub.db');

    _database = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 4,
        onCreate: (db, version) async {
          await _createSchema(db);
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await _createUsersTable(db);
          }
          if (oldVersion < 3) {
            await _createMessageQueueTables(db);
          }
          if (oldVersion < 4) {
            await _createDtnTables(db);
          }
        },
      ),
    );
    await _database!.execute('PRAGMA foreign_keys = ON');
    await _createMessageQueueTables(_database!);
    await _createDtnTables(_database!);
    await _normalizeLegacyDemoData(_database!);
    await _normalizeSeededUsers(_database!);

    await _seedIfEmpty();
  }

  Future<DashboardStats> readDashboardStats() async {
    final db = _requireDatabase();
    final total = await _count(db, 'SELECT COUNT(*) AS value FROM tasks');
    final completed = await _count(
      db,
      'SELECT COUNT(*) AS value FROM tasks WHERE is_done = 1',
    );

    return DashboardStats(
      totalTasks: total,
      completedTasks: completed,
      pendingTasks: total - completed,
    );
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  Future<void> _seedIfEmpty() async {
    final db = _requireDatabase();
    final total = await _count(db, 'SELECT COUNT(*) AS value FROM tasks');

    if (total > 0) {
      await _seedUsersIfNeeded(db);
      await _seedMessageQueueIfNeeded(db);
      await _seedDtnIfNeeded(db);
      return;
    }

    final batch = db.batch();
    batch.insert('tasks', {'title': 'Plan phase 2', 'is_done': 0});
    batch.insert('tasks', {'title': 'Wire auth flow', 'is_done': 0});
    batch.insert('tasks', {'title': 'Review dashboard layout', 'is_done': 1});
    await batch.commit(noResult: true);
    await _seedUsersIfNeeded(db);
    await _seedMessageQueueIfNeeded(db);
    await _seedDtnIfNeeded(db);
  }

  Future<List<UserAccount>> readUsers() async {
    final db = _requireDatabase();
    final rows = await db.query(
      'users',
      orderBy: 'full_name COLLATE NOCASE ASC',
    );
    return rows.map(UserAccount.fromMap).toList(growable: false);
  }

  Future<UserAccount> insertUser(UserAccount user) async {
    final db = _requireDatabase();
    final id = await db.insert('users', user.toInsertMap());
    return user.copyWith(id: id);
  }

  Future<UserAccount> updateUser(UserAccount user) async {
    final userId = user.id;
    if (userId == null) {
      throw ArgumentError('User id is required for update.');
    }
    final db = _requireDatabase();
    await db.update(
      'users',
      user.toUpdateMap(),
      where: 'id = ?',
      whereArgs: [userId],
    );
    return user;
  }

  Future<void> deleteUser(int id) async {
    final db = _requireDatabase();
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MessageBundle>> readMessageBundles() async {
    final db = _requireDatabase();
    final bundleRows = await db.rawQuery('''
      SELECT
        b.id,
        b.name,
        b.destination_address,
        b.created_at,
        COUNT(m.id) AS message_count,
        SUM(CASE WHEN m.status = 'queued' THEN 1 ELSE 0 END) AS queued_count,
        SUM(CASE WHEN m.status = 'sent' THEN 1 ELSE 0 END) AS sent_count,
        SUM(CASE WHEN m.status = 'failed' THEN 1 ELSE 0 END) AS failed_count
      FROM message_bundles b
      LEFT JOIN queue_messages m ON m.bundle_id = b.id
      GROUP BY b.id, b.name, b.destination_address, b.created_at
      ORDER BY b.created_at DESC
    ''');

    final bundlesByDestination = <String, MessageBundle>{};
    for (final row in bundleRows) {
      final bundleId = row['id'] as int;
      final messages = await _readBundleMessages(db, bundleId);
      final bundle = MessageBundle(
        id: bundleId,
        name: row['name'] as String,
        destinationAddress:
            row['destination_address'] as String? ?? row['name'] as String,
        createdAt: DateTime.parse(row['created_at'] as String),
        messageCount: (row['message_count'] as int?) ?? 0,
        queuedCount: (row['queued_count'] as int?) ?? 0,
        sentCount: (row['sent_count'] as int?) ?? 0,
        failedCount: (row['failed_count'] as int?) ?? 0,
        messages: messages,
      );
      final existing = bundlesByDestination[bundle.destinationAddress];
      bundlesByDestination[bundle.destinationAddress] = existing == null
          ? bundle
          : MessageBundle(
              id: existing.id,
              name: existing.name,
              destinationAddress: existing.destinationAddress,
              createdAt: existing.createdAt.isBefore(bundle.createdAt)
                  ? existing.createdAt
                  : bundle.createdAt,
              messageCount: existing.messageCount + bundle.messageCount,
              queuedCount: existing.queuedCount + bundle.queuedCount,
              sentCount: existing.sentCount + bundle.sentCount,
              failedCount: existing.failedCount + bundle.failedCount,
              messages: [...existing.messages, ...bundle.messages],
            );
    }
    return bundlesByDestination.values.toList(growable: false);
  }

  Future<void> createMessageBundle(
    String destinationAddress,
    List<String> messages,
  ) async {
    final db = _requireDatabase();
    final now = DateTime.now().toIso8601String();
    final existing = await db.query(
      'message_bundles',
      columns: ['id'],
      where: 'destination_address = ?',
      whereArgs: [destinationAddress],
      limit: 1,
    );
    final bundleId = existing.isEmpty
        ? await db.insert('message_bundles', {
            'name': destinationAddress,
            'destination_address': destinationAddress,
            'created_at': now,
          })
        : existing.first['id'] as int;

    final messageBatch = db.batch();
    for (final message in messages) {
      final encrypted = await _messageCrypto.encrypt(message);
      messageBatch.insert('queue_messages', {
        'bundle_id': bundleId,
        'destination_address': destinationAddress,
        'encrypted_body': encrypted,
        'status': MessageStatus.queued.name,
        'created_at': now,
        'updated_at': now,
      });
    }
    await messageBatch.commit(noResult: true);
  }

  Future<void> updateMessageStatus(int messageId, MessageStatus status) async {
    final db = _requireDatabase();
    await db.update(
      'queue_messages',
      {'status': status.name, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [messageId],
    );
  }

  Future<void> deleteMessageBundle(int bundleId) async {
    final db = _requireDatabase();
    await db.transaction((txn) async {
      await txn.delete(
        'queue_messages',
        where: 'bundle_id = ?',
        whereArgs: [bundleId],
      );
      await txn.delete(
        'message_bundles',
        where: 'id = ?',
        whereArgs: [bundleId],
      );
    });
  }

  Future<DtnSimulatorSnapshot> readDtnSnapshot() async {
    final db = _requireDatabase();
    final hubs = await _readDtnHubs(db);
    final buses = await _readDtnBuses(db);
    final bundles = await _readDtnBundles(db);
    return DtnSimulatorSnapshot(hubs: hubs, buses: buses, bundles: bundles);
  }

  Future<DtnBundle> createDtnBundle({
    required String label,
    required int originHubId,
    required int destinationHubId,
  }) async {
    final db = _requireDatabase();
    final now = DateTime.now().toIso8601String();
    final id = await db.insert('dtn_bundles', {
      'label': label,
      'origin_hub_id': originHubId,
      'destination_hub_id': destinationHubId,
      'current_hub_id': originHubId,
      'status': DtnBundleStatus.queued.name,
      'created_at': now,
      'updated_at': now,
    });
    return DtnBundle(
      id: id,
      label: label,
      originHubId: originHubId,
      destinationHubId: destinationHubId,
      currentHubId: originHubId,
      status: DtnBundleStatus.queued,
      createdAt: DateTime.parse(now),
      updatedAt: DateTime.parse(now),
    );
  }

  Future<DtnBus> createDtnBus({
    required String name,
    required int originHubId,
    required int destinationHubId,
  }) async {
    final db = _requireDatabase();
    final now = DateTime.now().toIso8601String();
    final id = await db.insert('dtn_buses', {
      'name': name,
      'origin_hub_id': originHubId,
      'destination_hub_id': destinationHubId,
      'current_hub_id': originHubId,
      'status': 'idle',
      'last_updated_at': now,
    });
    return DtnBus(
      id: id,
      name: name,
      originHubId: originHubId,
      destinationHubId: destinationHubId,
      currentHubId: originHubId,
      status: 'idle',
      lastUpdatedAt: DateTime.parse(now),
    );
  }

  Future<void> dispatchDtnBus(int busId) async {
    final db = _requireDatabase();
    final busRows = await db.query(
      'dtn_buses',
      where: 'id = ?',
      whereArgs: [busId],
      limit: 1,
    );
    if (busRows.isEmpty) {
      throw StateError('Bus not found.');
    }

    final bus = busRows.first;
    final currentHubId = bus['current_hub_id'] as int;
    final originHubId = bus['origin_hub_id'] as int;
    final destinationHubId = bus['destination_hub_id'] as int;
    final nextHubId = currentHubId == originHubId
        ? destinationHubId
        : originHubId;
    final now = DateTime.now().toIso8601String();
    final transferStatus = nextHubId == destinationHubId
        ? DtnBundleStatus.delivered
        : DtnBundleStatus.queued;

    final bundlesToMove = await db.query(
      'dtn_bundles',
      where: 'current_hub_id = ?',
      whereArgs: [currentHubId],
    );
    final batch = db.batch();
    for (final row in bundlesToMove) {
      batch.update(
        'dtn_bundles',
        {
          'current_hub_id': nextHubId,
          'status': transferStatus.name,
          'updated_at': now,
        },
        where: 'id = ?',
        whereArgs: [row['id']],
      );
    }
    batch.update(
      'dtn_buses',
      {'current_hub_id': nextHubId, 'status': 'idle', 'last_updated_at': now},
      where: 'id = ?',
      whereArgs: [busId],
    );
    await batch.commit(noResult: true);
  }

  Database _requireDatabase() {
    final database = _database;
    if (database == null) {
      throw StateError('Database is not open.');
    }
    return database;
  }

  Future<int> _count(Database db, String sql) async {
    final rows = await db.rawQuery(sql);
    return (rows.first['value'] as int?) ?? 0;
  }

  Future<void> _createSchema(Database db) async {
    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        is_done INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await _createUsersTable(db);
    await _createMessageQueueTables(db);
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _seedUsersIfNeeded(Database db) async {
    final now = DateTime.now().toIso8601String();
    final seedUsers = <Map<String, Object?>>[
      {
        'full_name': 'Vedh Pokharkar',
        'email': 'vedh.pokharkar@gmail.com',
        'phone': '+91 98765 43210',
      },
      {
        'full_name': 'Nihal Mishra',
        'email': 'nihal.mishra@gmail.com',
        'phone': '+91 98765 43211',
      },
      {
        'full_name': 'Disha Mohite',
        'email': 'disha.mohite@gmail.com',
        'phone': '+91 98765 43212',
      },
      {
        'full_name': 'Hemant Thakur',
        'email': 'hemant.thakur@gmail.com',
        'phone': '+91 98765 43213',
      },
      {
        'full_name': 'Aarav Deshmukh',
        'email': 'aarav.deshmukh@gmail.com',
        'phone': '+91 98765 43214',
      },
      {
        'full_name': 'Sara Patil',
        'email': 'sara.patil@gmail.com',
        'phone': '+91 98765 43215',
      },
    ];

    final existingRows = await db.query('users', columns: ['email']);
    final existingEmails = existingRows
        .map((row) => row['email'] as String? ?? '')
        .where((email) => email.isNotEmpty)
        .toSet();

    final batch = db.batch();
    for (final user in seedUsers) {
      final email = user['email'] as String;
      if (existingEmails.contains(email)) {
        continue;
      }

      batch.insert('users', {...user, 'created_at': now, 'updated_at': now});
    }

    await batch.commit(noResult: true);
  }

  Future<void> _createMessageQueueTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS message_bundles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        destination_address TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS queue_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        bundle_id INTEGER NOT NULL,
        destination_address TEXT NOT NULL,
        encrypted_body TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(bundle_id) REFERENCES message_bundles(id) ON DELETE CASCADE
      )
    ''');
    await _ensureMessageQueueColumns(db);
  }

  Future<void> _createDtnTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS dtn_hubs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS dtn_buses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        origin_hub_id INTEGER NOT NULL,
        destination_hub_id INTEGER NOT NULL,
        current_hub_id INTEGER NOT NULL,
        status TEXT NOT NULL,
        last_updated_at TEXT NOT NULL,
        FOREIGN KEY(origin_hub_id) REFERENCES dtn_hubs(id),
        FOREIGN KEY(destination_hub_id) REFERENCES dtn_hubs(id),
        FOREIGN KEY(current_hub_id) REFERENCES dtn_hubs(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS dtn_bundles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label TEXT NOT NULL,
        origin_hub_id INTEGER NOT NULL,
        destination_hub_id INTEGER NOT NULL,
        current_hub_id INTEGER NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(origin_hub_id) REFERENCES dtn_hubs(id),
        FOREIGN KEY(destination_hub_id) REFERENCES dtn_hubs(id),
        FOREIGN KEY(current_hub_id) REFERENCES dtn_hubs(id)
      )
    ''');
  }

  Future<List<MessageQueueRow>> _readBundleMessages(
    Database db,
    int bundleId,
  ) async {
    final rows = await db.query(
      'queue_messages',
      where: 'bundle_id = ?',
      whereArgs: [bundleId],
      orderBy: 'id ASC',
    );
    final messages = <MessageQueueRow>[];
    for (final row in rows) {
      final encryptedBody = row['encrypted_body'] as String;
      messages.add(
        MessageQueueRow(
          id: row['id'] as int,
          bundleId: row['bundle_id'] as int,
          destinationAddress: row['destination_address'] as String? ?? '',
          body: await _messageCrypto.decrypt(encryptedBody),
          status: MessageStatus.fromName(row['status'] as String),
          createdAt: DateTime.parse(row['created_at'] as String),
          updatedAt: DateTime.parse(row['updated_at'] as String),
        ),
      );
    }
    return messages;
  }

  Future<void> _seedDtnIfNeeded(Database db) async {
    await _seedDtnHubsIfNeeded(db);
    await _seedDtnFleetIfNeeded(db);
  }

  Future<void> _normalizeLegacyDemoData(Database db) async {
    await db.execute('''
      UPDATE message_bundles
      SET name = 'North Hub',
          destination_address = 'North Hub'
      WHERE name = 'North Dock' OR destination_address = 'North Dock'
    ''');
    await db.execute('''
      UPDATE queue_messages
      SET destination_address = 'North Hub'
      WHERE destination_address = 'North Dock'
    ''');
    await db.execute('''
      UPDATE dtn_bundles
      SET label = 'North Hub'
      WHERE label = 'North Dock'
    ''');
  }

  Future<void> _normalizeSeededUsers(Database db) async {
    final normalizedUsers = <Map<String, Object?>>[
      {
        'full_name': 'Vedh Pokharkar',
        'email': 'vedh.pokharkar@gmail.com',
        'phone': '+91 98765 43210',
        'aliases': ['asha.khan@example.com', 'Asha Khan'],
      },
      {
        'full_name': 'Nihal Mishra',
        'email': 'nihal.mishra@gmail.com',
        'phone': '+91 98765 43211',
        'aliases': ['marco.silva@example.com', 'Marco Silva'],
      },
      {
        'full_name': 'Disha Mohite',
        'email': 'disha.mohite@gmail.com',
        'phone': '+91 98765 43212',
        'aliases': ['priya.nair@example.com', 'Priya Nair'],
      },
      {
        'full_name': 'Hemant Thakur',
        'email': 'hemant.thakur@gmail.com',
        'phone': '+91 98765 43213',
        'aliases': [
          'jonah.reed@example.com',
          'Jonah Reed',
          'hemant@gmail.com',
          'Hemant',
        ],
      },
    ];

    for (final user in normalizedUsers) {
      final aliases = (user['aliases'] as List<String>);
      for (final alias in aliases) {
        await db.update(
          'users',
          {
            'full_name': user['full_name'],
            'email': user['email'],
            'phone': user['phone'],
          },
          where: 'LOWER(email) = LOWER(?) OR LOWER(full_name) = LOWER(?)',
          whereArgs: [alias, alias],
        );
      }
    }

    await db.delete(
      'users',
      where: 'LOWER(email) IN (?, ?) OR LOWER(full_name) IN (?, ?)',
      whereArgs: [
        'lina.torres@gmail.com',
        'ethan.cole@gmail.com',
        'Lina Torres',
        'Ethan Cole',
      ],
    );
  }

  Future<void> _seedDtnHubsIfNeeded(Database db) async {
    final count = await _count(db, 'SELECT COUNT(*) AS value FROM dtn_hubs');
    if (count > 0) {
      return;
    }

    final batch = db.batch();
    batch.insert('dtn_hubs', {'name': 'North Hub'});
    batch.insert('dtn_hubs', {'name': 'Central Hub'});
    batch.insert('dtn_hubs', {'name': 'South Hub'});
    await batch.commit(noResult: true);
  }

  Future<void> _seedDtnFleetIfNeeded(Database db) async {
    final hubs = await db.query('dtn_hubs', orderBy: 'id ASC');
    if (hubs.length < 3) {
      return;
    }

    final existingBuses = await db.query('dtn_buses', columns: ['name']);
    final existingBusNames = existingBuses
        .map((row) => row['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toSet();

    final existingBundles = await db.query('dtn_bundles', columns: ['label']);
    final existingBundleLabels = existingBundles
        .map((row) => row['label'] as String? ?? '')
        .where((label) => label.isNotEmpty)
        .toSet();

    final now = DateTime.now();
    final seedBuses = <Map<String, Object?>>[
      {
        'name': 'North Relay 01',
        'origin_hub_id': 1,
        'destination_hub_id': 2,
        'current_hub_id': 1,
        'status': 'loading',
        'last_updated_at': now
            .subtract(const Duration(minutes: 4))
            .toIso8601String(),
      },
      {
        'name': 'Central Relay 02',
        'origin_hub_id': 2,
        'destination_hub_id': 3,
        'current_hub_id': 2,
        'status': 'in-transit',
        'last_updated_at': now
            .subtract(const Duration(minutes: 9))
            .toIso8601String(),
      },
      {
        'name': 'South Relay 03',
        'origin_hub_id': 3,
        'destination_hub_id': 1,
        'current_hub_id': 3,
        'status': 'waiting',
        'last_updated_at': now
            .subtract(const Duration(minutes: 2))
            .toIso8601String(),
      },
    ];

    final seedBundles = <Map<String, Object?>>[
      {
        'label': 'North Hub',
        'origin_hub_id': 1,
        'destination_hub_id': 2,
        'current_hub_id': 1,
        'status': DtnBundleStatus.queued.name,
        'created_at': now
            .subtract(const Duration(minutes: 15))
            .toIso8601String(),
        'updated_at': now
            .subtract(const Duration(minutes: 4))
            .toIso8601String(),
      },
      {
        'label': 'Central Hub',
        'origin_hub_id': 2,
        'destination_hub_id': 3,
        'current_hub_id': 2,
        'status': DtnBundleStatus.queued.name,
        'created_at': now
            .subtract(const Duration(minutes: 13))
            .toIso8601String(),
        'updated_at': now
            .subtract(const Duration(minutes: 9))
            .toIso8601String(),
      },
      {
        'label': 'South Hub',
        'origin_hub_id': 3,
        'destination_hub_id': 1,
        'current_hub_id': 3,
        'status': DtnBundleStatus.queued.name,
        'created_at': now
            .subtract(const Duration(minutes: 10))
            .toIso8601String(),
        'updated_at': now
            .subtract(const Duration(minutes: 2))
            .toIso8601String(),
      },
    ];

    final batch = db.batch();
    for (final bus in seedBuses) {
      final name = bus['name'] as String;
      if (existingBusNames.contains(name)) {
        continue;
      }
      batch.insert('dtn_buses', bus);
    }
    for (final bundle in seedBundles) {
      final label = bundle['label'] as String;
      if (existingBundleLabels.contains(label)) {
        continue;
      }
      batch.insert('dtn_bundles', bundle);
    }
    await batch.commit(noResult: true);
  }

  Future<void> _seedMessageQueueIfNeeded(Database db) async {
    final now = DateTime.now().toIso8601String();
    final seedData = <String, List<String>>{
      'North Hub': ['Delivered 101', 'Delivered 102'],
      'Central Hub': ['Status report', 'Maintenance request'],
      'South Hub': ['Return label', 'Customs note'],
    };

    final existingBundles = await db.query(
      'message_bundles',
      columns: ['destination_address'],
    );
    final existingDestinations = existingBundles
        .map((row) => row['destination_address'] as String? ?? '')
        .where((destination) => destination.isNotEmpty)
        .toSet();

    await db.transaction((txn) async {
      for (final entry in seedData.entries) {
        if (existingDestinations.contains(entry.key)) {
          continue;
        }

        final bundleId = await txn.insert('message_bundles', {
          'name': entry.key,
          'destination_address': entry.key,
          'created_at': now,
        });

        for (final message in entry.value) {
          final encrypted = await _messageCrypto.encrypt(message);
          await txn.insert('queue_messages', {
            'bundle_id': bundleId,
            'destination_address': entry.key,
            'encrypted_body': encrypted,
            'status': MessageStatus.queued.name,
            'created_at': now,
            'updated_at': now,
          });
        }
      }
    });
  }

  Future<void> _ensureMessageQueueColumns(Database db) async {
    final bundleColumns = await db.rawQuery(
      'PRAGMA table_info(message_bundles)',
    );
    final bundleColumnNames = bundleColumns
        .map((row) => row['name'] as String)
        .toSet();
    if (!bundleColumnNames.contains('destination_address')) {
      await db.execute(
        "ALTER TABLE message_bundles ADD COLUMN destination_address TEXT",
      );
      await db.execute(
        'UPDATE message_bundles SET destination_address = name WHERE destination_address IS NULL',
      );
    }

    final messageColumns = await db.rawQuery(
      'PRAGMA table_info(queue_messages)',
    );
    final messageColumnNames = messageColumns
        .map((row) => row['name'] as String)
        .toSet();
    if (!messageColumnNames.contains('destination_address')) {
      await db.execute(
        "ALTER TABLE queue_messages ADD COLUMN destination_address TEXT",
      );
      await db.execute('''
        UPDATE queue_messages
        SET destination_address = (
          SELECT destination_address
          FROM message_bundles
          WHERE message_bundles.id = queue_messages.bundle_id
        )
        WHERE destination_address IS NULL
      ''');
    }
  }

  Future<List<DtnHub>> _readDtnHubs(Database db) async {
    final rows = await db.rawQuery('''
      SELECT
        h.id,
        h.name,
        COUNT(DISTINCT b.id) AS bus_count,
        COUNT(DISTINCT k.id) AS bundle_count
      FROM dtn_hubs h
      LEFT JOIN dtn_buses b ON b.current_hub_id = h.id
      LEFT JOIN dtn_bundles k ON k.current_hub_id = h.id
      GROUP BY h.id, h.name
      ORDER BY h.id ASC
    ''');
    return rows
        .map(
          (row) => DtnHub(
            id: row['id'] as int,
            name: row['name'] as String,
            bundleCount: row['bundle_count'] as int? ?? 0,
            busCount: row['bus_count'] as int? ?? 0,
          ),
        )
        .toList(growable: false);
  }

  Future<List<DtnBus>> _readDtnBuses(Database db) async {
    final rows = await db.query('dtn_buses', orderBy: 'id ASC');
    return rows
        .map(
          (row) => DtnBus(
            id: row['id'] as int,
            name: row['name'] as String,
            originHubId: row['origin_hub_id'] as int,
            destinationHubId: row['destination_hub_id'] as int,
            currentHubId: row['current_hub_id'] as int,
            status: row['status'] as String,
            lastUpdatedAt: DateTime.parse(row['last_updated_at'] as String),
          ),
        )
        .toList(growable: false);
  }

  Future<List<DtnBundle>> _readDtnBundles(Database db) async {
    final rows = await db.query('dtn_bundles', orderBy: 'id ASC');
    return rows
        .map(
          (row) => DtnBundle(
            id: row['id'] as int,
            label: row['label'] as String,
            originHubId: row['origin_hub_id'] as int,
            destinationHubId: row['destination_hub_id'] as int,
            currentHubId: row['current_hub_id'] as int,
            status: DtnBundleStatus.fromName(row['status'] as String),
            createdAt: DateTime.parse(row['created_at'] as String),
            updatedAt: DateTime.parse(row['updated_at'] as String),
          ),
        )
        .toList(growable: false);
  }
}
