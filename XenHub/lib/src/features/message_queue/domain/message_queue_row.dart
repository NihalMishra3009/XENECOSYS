import 'message_status.dart';

class MessageQueueRow {
  const MessageQueueRow({
    required this.id,
    required this.bundleId,
    required this.destinationAddress,
    required this.body,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int bundleId;
  final String destinationAddress;
  final String body;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
}
