import '../models/message_model.dart';

abstract class MessageRepository {
  Future<Message> createMessage(Message message);
  Future<Message?> getMessageByID(String messageID);
  Future<List<Message>> getMessagesByUser(String userID);
  Future<List<Message>> getPendingMessages(String senderID);
  Future<List<Message>> getReceivedMessages(String receiverID);
  Future<void> updateMessageStatus(String messageID, String status);
  Future<void> deleteMessage(String messageID);
}
