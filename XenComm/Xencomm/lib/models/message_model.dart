import 'package:json_annotation/json_annotation.dart';

part 'message_model.g.dart';

@JsonSerializable()
class Message {
  final String messageID;
  final String senderID;
  final String receiverID;
  final DateTime timestamp;
  final String priority;
  final String status;
  final String encryptedContent;
  final String? attachmentHash;

  Message({
    required this.messageID,
    required this.senderID,
    required this.receiverID,
    required this.timestamp,
    required this.priority,
    required this.status,
    required this.encryptedContent,
    this.attachmentHash,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  Message copyWith({
    String? messageID,
    String? senderID,
    String? receiverID,
    DateTime? timestamp,
    String? priority,
    String? status,
    String? encryptedContent,
    String? attachmentHash,
  }) {
    return Message(
      messageID: messageID ?? this.messageID,
      senderID: senderID ?? this.senderID,
      receiverID: receiverID ?? this.receiverID,
      timestamp: timestamp ?? this.timestamp,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      encryptedContent: encryptedContent ?? this.encryptedContent,
      attachmentHash: attachmentHash ?? this.attachmentHash,
    );
  }
}
