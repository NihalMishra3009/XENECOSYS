import '../../../core/api/hub_api_client.dart';
import '../domain/message_bundle.dart';
import '../domain/message_queue_repository.dart';
import '../domain/message_queue_row.dart';
import '../domain/message_status.dart';

class ApiMessageQueueRepository implements MessageQueueRepository {
  ApiMessageQueueRepository(this._client);

  final HubApiClient _client;

  @override
  Future<void> createBundle(String destinationAddress, List<String> messages) {
    return _client.postObject(
      'queue/bundles',
      body: {'destinationAddress': destinationAddress, 'messages': messages},
    );
  }

  @override
  Future<void> deleteBundle(int bundleId) => _client.delete('queue/bundles/$bundleId');

  @override
  Future<List<MessageBundle>> listBundles() async {
    final json = await _client.getObject('queue/bundles');
    final items = (json['items'] as List? ?? const []);
    return items
        .cast<Map<String, dynamic>>()
        .map(_bundleFromJson)
        .toList(growable: false);
  }

  @override
  Future<void> updateMessageStatus(int messageId, MessageStatus status) {
    return _client.patchObject(
      'queue/messages/$messageId/status',
      body: {'status': status.name},
    );
  }

  MessageBundle _bundleFromJson(Map<String, dynamic> json) {
    final messages = (json['messages'] as List? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(_messageFromJson)
        .toList(growable: false);

    return MessageBundle(
      id: json['id'] as int,
      name: json['name'] as String,
      destinationAddress: json['destinationAddress'] as String? ?? json['name'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      messageCount: json['messageCount'] as int? ?? messages.length,
      queuedCount: json['queuedCount'] as int? ?? 0,
      sentCount: json['sentCount'] as int? ?? 0,
      failedCount: json['failedCount'] as int? ?? 0,
      messages: messages,
    );
  }

  MessageQueueRow _messageFromJson(Map<String, dynamic> json) {
    return MessageQueueRow(
      id: json['id'] as int,
      bundleId: json['bundleId'] as int,
      destinationAddress: json['destinationAddress'] as String? ?? '',
      body: json['body'] as String,
      status: MessageStatus.fromName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
