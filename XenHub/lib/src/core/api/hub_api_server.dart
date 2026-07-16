import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

import '../../features/dashboard/domain/dashboard_repository.dart';
import '../../features/dtn/domain/dtn_bundle.dart';
import '../../features/dtn/domain/dtn_bus.dart';
import '../../features/dtn/domain/dtn_hub.dart';
import '../../features/dtn/domain/dtn_simulator_repository.dart';
import '../../features/message_queue/domain/message_bundle.dart';
import '../../features/message_queue/domain/message_queue_repository.dart';
import '../../features/message_queue/domain/message_status.dart';
import '../../features/users/domain/user_account.dart';
import '../../features/users/domain/user_repository.dart';

class HubApiServer {
  HubApiServer({
    required DashboardRepository dashboardRepository,
    required UserRepository userRepository,
    required MessageQueueRepository messageQueueRepository,
    required DtnSimulatorRepository dtnSimulatorRepository,
    this.port = 8080,
  })  : _dashboardRepository = dashboardRepository,
        _userRepository = userRepository,
        _messageQueueRepository = messageQueueRepository,
        _dtnSimulatorRepository = dtnSimulatorRepository;

  final DashboardRepository _dashboardRepository;
  final UserRepository _userRepository;
  final MessageQueueRepository _messageQueueRepository;
  final DtnSimulatorRepository _dtnSimulatorRepository;
  final int port;

  HttpServer? _server;

  int get boundPort => _server?.port ?? port;

  Future<void> start() async {
    if (_server != null) {
      return;
    }

    _server = await shelf_io.serve(_handleRequest, InternetAddress.loopbackIPv4, port);
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    await server?.close(force: true);
  }

  Future<shelf.Response> _handleRequest(shelf.Request request) async {
    final path = request.url.pathSegments;
    if (request.method == 'OPTIONS') {
      return _cors(_jsonResponse(HttpStatus.noContent, const {}));
    }

    if (path.isEmpty || path.first != 'api') {
      return _cors(_jsonResponse(HttpStatus.notFound, {'error': 'Not found'}));
    }

    if (path.length == 2 && path[1] == 'health' && request.method == 'GET') {
      return _cors(_jsonResponse(200, {'ok': true}));
    }

    if (path.length == 2 && path[1] == 'dashboard' && request.method == 'GET') {
      return _cors(await _handleDashboard());
    }

    if (path.length == 2 && path[1] == 'users') {
      return _cors(await _handleUsersCollection(request));
    }

    if (path.length == 3 && path[1] == 'users') {
      return _cors(await _handleUserItem(request, path[2]));
    }

    if (path.length == 3 && path[1] == 'queue' && path[2] == 'bundles') {
      return _cors(await _handleBundlesCollection(request));
    }

    if (path.length == 4 && path[1] == 'queue' && path[2] == 'bundles') {
      return _cors(await _handleBundleItem(request, path[3]));
    }

    if (path.length == 5 &&
        path[1] == 'queue' &&
        path[2] == 'messages' &&
        path[4] == 'status') {
      return _cors(await _handleMessageStatus(request, path[3]));
    }

    if (path.length == 2 && path[1] == 'dtn' && request.method == 'GET') {
      return _cors(await _handleDtnSnapshot());
    }

    if (path.length == 3 && path[1] == 'dtn' && path[2] == 'buses') {
      return _cors(await _handleDtnBusesCollection(request));
    }

    if (path.length == 3 && path[1] == 'dtn' && path[2] == 'bundles') {
      return _cors(await _handleDtnBundlesCollection(request));
    }

    if (path.length == 5 &&
        path[1] == 'dtn' &&
        path[2] == 'buses' &&
        path[4] == 'dispatch') {
      return _cors(await _handleDtnBusDispatch(request, path[3]));
    }

    return _cors(_jsonResponse(HttpStatus.notFound, {'error': 'Not found'}));
  }

  Future<shelf.Response> _handleDashboard() async {
    final stats = await _dashboardRepository.loadStats();
    return _jsonResponse(200, {
      'totalTasks': stats.totalTasks,
      'completedTasks': stats.completedTasks,
      'pendingTasks': stats.pendingTasks,
    });
  }

  Future<shelf.Response> _handleUsersCollection(shelf.Request request) async {
    switch (request.method) {
      case 'GET':
        final users = await _userRepository.listUsers();
        return _jsonResponse(
          200,
          {'items': users.map(_userToJson).toList(growable: false)},
        );
      case 'POST':
        final body = await _readJsonBody(request);
        final errors = _validateUserPayload(body);
        if (errors.isNotEmpty) {
          return _jsonResponse(400, {'errors': errors});
        }
        final now = DateTime.now();
        final created = await _userRepository.createUser(
          UserAccount(
            fullName: body['fullName'] as String,
            email: (body['email'] as String).toLowerCase(),
            phone: body['phone'] as String,
            createdAt: now,
            updatedAt: now,
          ),
        );
        return _jsonResponse(201, _userToJson(created));
      default:
        return _methodNotAllowed(['GET', 'POST']);
    }
  }

  Future<shelf.Response> _handleUserItem(shelf.Request request, String rawId) async {
    final id = int.tryParse(rawId);
    if (id == null) {
      return _jsonResponse(400, {'error': 'Invalid user id'});
    }

    final users = await _userRepository.listUsers();
    final existing = users.where((user) => user.id == id).toList(growable: false);
    if (existing.isEmpty && request.method != 'DELETE') {
      return _jsonResponse(404, {'error': 'User not found'});
    }

    switch (request.method) {
      case 'GET':
        return _jsonResponse(200, _userToJson(existing.first));
      case 'PUT':
      case 'PATCH':
        final body = await _readJsonBody(request);
        final merged = _mergeUserPayload(existing.first, body);
        final errors = _validateUserPayload(merged);
        if (errors.isNotEmpty) {
          return _jsonResponse(400, {'errors': errors});
        }
        final updated = await _userRepository.updateUser(
          UserAccount(
            id: id,
            fullName: merged['fullName'] as String,
            email: (merged['email'] as String).toLowerCase(),
            phone: merged['phone'] as String,
            createdAt: existing.first.createdAt,
            updatedAt: DateTime.now(),
          ),
        );
        return _jsonResponse(200, _userToJson(updated));
      case 'DELETE':
        await _userRepository.deleteUser(id);
        return shelf.Response(HttpStatus.noContent);
      default:
        return _methodNotAllowed(['GET', 'PUT', 'PATCH', 'DELETE']);
    }
  }

  Future<shelf.Response> _handleBundlesCollection(shelf.Request request) async {
    switch (request.method) {
      case 'GET':
        final bundles = await _messageQueueRepository.listBundles();
        return _jsonResponse(
          200,
          {'items': bundles.map(_bundleToJson).toList(growable: false)},
        );
      case 'POST':
        final body = await _readJsonBody(request);
        final errors = _validateBundlePayload(body);
        if (errors.isNotEmpty) {
          return _jsonResponse(400, {'errors': errors});
        }
        await _messageQueueRepository.createBundle(
          (body['destinationAddress'] ?? body['name']).toString(),
          (body['messages'] as List).cast<String>(),
        );
        return _jsonResponse(201, {'ok': true});
      default:
        return _methodNotAllowed(['GET', 'POST']);
    }
  }

  Future<shelf.Response> _handleBundleItem(shelf.Request request, String rawId) async {
    final id = int.tryParse(rawId);
    if (id == null) {
      return _jsonResponse(400, {'error': 'Invalid bundle id'});
    }

    if (request.method != 'DELETE') {
      return _methodNotAllowed(['DELETE']);
    }

    await _messageQueueRepository.deleteBundle(id);
    return shelf.Response(HttpStatus.noContent);
  }

  Future<shelf.Response> _handleMessageStatus(shelf.Request request, String rawId) async {
    if (request.method != 'PATCH') {
      return _methodNotAllowed(['PATCH']);
    }

    final id = int.tryParse(rawId);
    if (id == null) {
      return _jsonResponse(400, {'error': 'Invalid message id'});
    }

    final body = await _readJsonBody(request);
    final statusValue = body['status']?.toString();
    final status = MessageStatus.values.where((item) => item.name == statusValue).firstOrNull;
    if (status == null) {
      return _jsonResponse(
        400,
        {'error': 'status must be one of ${MessageStatus.values.map((value) => value.name).join(', ')}'},
      );
    }

    await _messageQueueRepository.updateMessageStatus(id, status);
    return shelf.Response(HttpStatus.noContent);
  }

  Future<shelf.Response> _handleDtnSnapshot() async {
    final snapshot = await _dtnSimulatorRepository.loadSnapshot();
    return _jsonResponse(
      200,
      {
        'hubs': snapshot.hubs.map(_hubToJson).toList(growable: false),
        'buses': snapshot.buses.map(_busToJson).toList(growable: false),
        'bundles': snapshot.bundles.map(_dtnBundleToJson).toList(growable: false),
      },
    );
  }

  Future<shelf.Response> _handleDtnBusesCollection(shelf.Request request) async {
    if (request.method != 'POST') {
      return _methodNotAllowed(['POST']);
    }

    final body = await _readJsonBody(request);
    final name = (body['name'] ?? '').toString().trim();
    final originHubId = body['originHubId'] as int?;
    final destinationHubId = body['destinationHubId'] as int?;
    if (name.isEmpty || originHubId == null || destinationHubId == null) {
      return _jsonResponse(
        400,
        {'error': 'name, originHubId, and destinationHubId are required'},
      );
    }

    final bus = await _dtnSimulatorRepository.createBus(
      name: name,
      originHubId: originHubId,
      destinationHubId: destinationHubId,
    );
    return _jsonResponse(201, _busToJson(bus));
  }

  Future<shelf.Response> _handleDtnBundlesCollection(shelf.Request request) async {
    if (request.method != 'POST') {
      return _methodNotAllowed(['POST']);
    }

    final body = await _readJsonBody(request);
    final label = (body['label'] ?? '').toString().trim();
    final originHubId = body['originHubId'] as int?;
    final destinationHubId = body['destinationHubId'] as int?;
    if (label.isEmpty || originHubId == null || destinationHubId == null) {
      return _jsonResponse(
        400,
        {'error': 'label, originHubId, and destinationHubId are required'},
      );
    }

    final bundle = await _dtnSimulatorRepository.createBundle(
      label: label,
      originHubId: originHubId,
      destinationHubId: destinationHubId,
    );
    return _jsonResponse(201, _dtnBundleToJson(bundle));
  }

  Future<shelf.Response> _handleDtnBusDispatch(shelf.Request request, String rawId) async {
    if (request.method != 'POST') {
      return _methodNotAllowed(['POST']);
    }

    final id = int.tryParse(rawId);
    if (id == null) {
      return _jsonResponse(400, {'error': 'Invalid bus id'});
    }

    await _dtnSimulatorRepository.dispatchBus(id);
    return shelf.Response(HttpStatus.noContent);
  }

  Map<String, Object?> _userToJson(UserAccount user) {
    return {
      'id': user.id,
      'fullName': user.fullName,
      'email': user.email,
      'phone': user.phone,
      'createdAt': user.createdAt.toIso8601String(),
      'updatedAt': user.updatedAt.toIso8601String(),
    };
  }

  Map<String, Object?> _bundleToJson(MessageBundle bundle) {
    return {
      'id': bundle.id,
      'name': bundle.name,
      'destinationAddress': bundle.destinationAddress,
      'createdAt': bundle.createdAt.toIso8601String(),
      'messageCount': bundle.messageCount,
      'queuedCount': bundle.queuedCount,
      'sentCount': bundle.sentCount,
      'failedCount': bundle.failedCount,
      'messages': bundle.messages
          .map(
            (message) => {
              'id': message.id,
              'bundleId': message.bundleId,
              'destinationAddress': message.destinationAddress,
              'body': message.body,
              'status': message.status.name,
              'createdAt': message.createdAt.toIso8601String(),
              'updatedAt': message.updatedAt.toIso8601String(),
            },
          )
          .toList(growable: false),
    };
  }

  Map<String, Object?> _hubToJson(DtnHub hub) {
    return {
      'id': hub.id,
      'name': hub.name,
      'bundleCount': hub.bundleCount,
      'busCount': hub.busCount,
    };
  }

  Map<String, Object?> _busToJson(DtnBus bus) {
    return {
      'id': bus.id,
      'name': bus.name,
      'originHubId': bus.originHubId,
      'destinationHubId': bus.destinationHubId,
      'currentHubId': bus.currentHubId,
      'status': bus.status,
      'lastUpdatedAt': bus.lastUpdatedAt.toIso8601String(),
    };
  }

  Map<String, Object?> _dtnBundleToJson(DtnBundle bundle) {
    return {
      'id': bundle.id,
      'label': bundle.label,
      'originHubId': bundle.originHubId,
      'destinationHubId': bundle.destinationHubId,
      'currentHubId': bundle.currentHubId,
      'status': bundle.status.name,
      'createdAt': bundle.createdAt.toIso8601String(),
      'updatedAt': bundle.updatedAt.toIso8601String(),
    };
  }

  Future<Map<String, Object?>> _readJsonBody(shelf.Request request) async {
    final body = await utf8.decoder.bind(request.read()).join();
    if (body.trim().isEmpty) {
      return <String, Object?>{};
    }
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded.cast<String, Object?>();
    }
    throw const FormatException('Expected a JSON object');
  }

  Map<String, Object?> _mergeUserPayload(
    UserAccount existing,
    Map<String, Object?> payload,
  ) {
    return {
      'fullName': payload['fullName'] ?? existing.fullName,
      'email': payload['email'] ?? existing.email,
      'phone': payload['phone'] ?? existing.phone,
    };
  }

  List<String> _validateUserPayload(Map<String, Object?> payload) {
    final errors = <String>[];
    final fullName = (payload['fullName'] ?? '').toString().trim();
    final email = (payload['email'] ?? '').toString().trim();
    final phone = (payload['phone'] ?? '').toString().trim();

    if (fullName.length < 2) {
      errors.add('fullName must be at least 2 characters');
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      errors.add('email must be valid');
    }
    if (!RegExp(r'^[0-9+\-\s]{7,20}$').hasMatch(phone)) {
      errors.add('phone must be valid');
    }
    return errors;
  }

  List<String> _validateBundlePayload(Map<String, Object?> payload) {
    final errors = <String>[];
    final destinationAddress = (payload['destinationAddress'] ?? payload['name'] ?? '').toString().trim();
    final messages = payload['messages'];

    if (destinationAddress.isEmpty) {
      errors.add('destinationAddress is required');
    }
    if (messages is! List || messages.isEmpty) {
      errors.add('messages must be a non-empty list');
    }
    return errors;
  }

  shelf.Response _methodNotAllowed(List<String> allowed) {
    return _jsonResponse(
      HttpStatus.methodNotAllowed,
      {'error': 'Method not allowed', 'allowed': allowed},
      headers: {HttpHeaders.allowHeader: allowed.join(', ')},
    );
  }

  shelf.Response _jsonResponse(
    int statusCode,
    Object body, {
    Map<String, String>? headers,
  }) {
    if (statusCode == HttpStatus.noContent) {
      return shelf.Response(
        statusCode,
        headers: {
          HttpHeaders.accessControlAllowOriginHeader: '*',
          ...?headers,
        },
      );
    }

    return shelf.Response(
      statusCode,
      body: jsonEncode(body),
      headers: {
        HttpHeaders.contentTypeHeader: ContentType.json.mimeType,
        HttpHeaders.accessControlAllowOriginHeader: '*',
        ...?headers,
      },
    );
  }

  shelf.Response _cors(shelf.Response response) {
    return response.change(
      headers: {
        HttpHeaders.accessControlAllowOriginHeader: '*',
        HttpHeaders.accessControlAllowMethodsHeader: 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
        HttpHeaders.accessControlAllowHeadersHeader: 'Content-Type, Authorization',
        ...response.headers,
      },
    );
  }
}

extension FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
