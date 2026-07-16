import '../core/constants/app_constants.dart';
import '../models/message_model.dart';
import '../repositories/impl/message_repository_impl.dart';
import 'crypto/crypto_service.dart';

class MessageService {
  static final MessageService _instance = MessageService._internal();
  factory MessageService() => _instance;
  MessageService._internal();

  final MessageRepositoryImpl _msgRepo = MessageRepositoryImpl();
  final CryptoService _crypto = CryptoService();

  Future<Message> sendMessage({
    required String senderID,
    required String receiverID,
    required String content,
    required String priority,
  }) async {
    final encryptionKey = _generateMessageKey(senderID, receiverID);
    final message = Message(
      messageID: _crypto.generateMessageID(),
      senderID: senderID,
      receiverID: receiverID,
      timestamp: DateTime.now(),
      priority: priority,
      status: AppConstants.statusDraft,
      encryptedContent: _crypto.encryptAES(content, encryptionKey),
    );
    return _msgRepo.createMessage(message);
  }

  Future<void> queueMessageForUpload(String messageID) async {
    await _msgRepo.updateMessageStatus(messageID, AppConstants.statusQueued);
  }

  Future<void> markMessageAsSent(String messageID) async {
    await _msgRepo.updateMessageStatus(messageID, AppConstants.statusSent);
  }

  Future<void> markMessageAsDelivered(String messageID) async {
    await _msgRepo.updateMessageStatus(messageID, AppConstants.statusDelivered);
  }

  Future<String> decryptMessage(Message message, String senderID, String receiverID) async {
    final encryptionKey = _generateMessageKey(senderID, receiverID);
    return _crypto.decryptAES(message.encryptedContent, encryptionKey);
  }

  Future<List<Message>> getConversation(String userID, String contactID) async {
    final allMessages = await _msgRepo.getMessagesByUser(userID);
    return allMessages
        .where(
          (msg) =>
              (msg.senderID == userID && msg.receiverID == contactID) ||
              (msg.senderID == contactID && msg.receiverID == userID),
        )
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  String _generateMessageKey(String userA, String userB) {
    final combined = userA.compareTo(userB) < 0 ? '$userA:$userB' : '$userB:$userA';
    return combined.padRight(32).substring(0, 32);
  }

  Future<void> simulateHubSync(String hubID, List<String> userIDsAtHub) async {
    for (final userID in userIDsAtHub) {
      final pending = await _msgRepo.getPendingMessages(userID);
      for (final msg in pending) {
        await _msgRepo.updateMessageStatus(msg.messageID, AppConstants.statusSent);
      }
    }
  }
}
