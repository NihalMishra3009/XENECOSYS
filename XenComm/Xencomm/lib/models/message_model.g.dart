part of 'message_model.dart';

// ignore_for_file: type=lint

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      messageID: json['messageID'] as String,
      senderID: json['senderID'] as String,
      receiverID: json['receiverID'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      priority: json['priority'] as String,
      status: json['status'] as String,
      encryptedContent: json['encryptedContent'] as String,
      attachmentHash: json['attachmentHash'] as String?,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'messageID': instance.messageID,
      'senderID': instance.senderID,
      'receiverID': instance.receiverID,
      'timestamp': instance.timestamp.toIso8601String(),
      'priority': instance.priority,
      'status': instance.status,
      'encryptedContent': instance.encryptedContent,
      'attachmentHash': instance.attachmentHash,
    };
