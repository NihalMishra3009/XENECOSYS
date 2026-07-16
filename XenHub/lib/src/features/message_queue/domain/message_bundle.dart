import 'message_queue_row.dart';

class MessageBundle {
  const MessageBundle({
    required this.id,
    required this.name,
    required this.destinationAddress,
    required this.createdAt,
    required this.messageCount,
    required this.queuedCount,
    required this.sentCount,
    required this.failedCount,
    required this.messages,
  });

  final int id;
  final String name;
  final String destinationAddress;
  final DateTime createdAt;
  final int messageCount;
  final int queuedCount;
  final int sentCount;
  final int failedCount;
  final List<MessageQueueRow> messages;
}
