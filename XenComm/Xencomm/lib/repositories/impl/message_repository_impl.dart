import '../../core/constants/app_constants.dart';
import '../../models/message_model.dart';
import '../../services/database/database_service.dart';
import '../message_repository.dart';

class MessageRepositoryImpl implements MessageRepository {
  final DatabaseService _dbService = DatabaseService();

  @override
  Future<Message> createMessage(Message message) async {
    final data = message.toJson();
    data['timestamp'] = message.timestamp.toIso8601String();
    await _dbService.insert('messages', data);
    return message;
  }

  @override
  Future<Message?> getMessageByID(String messageID) async {
    final result = await _dbService.query('messages', where: 'messageID = ?', whereArgs: [messageID]);
    if (result.isEmpty) return null;
    final data = Map<String, dynamic>.from(result.first);
    data['timestamp'] = DateTime.parse(data['timestamp'] as String);
    return Message.fromJson(data);
  }

  @override
  Future<List<Message>> getMessagesByUser(String userID) async {
    final result = await _dbService.query(
      'messages',
      where: 'senderID = ? OR receiverID = ?',
      whereArgs: [userID, userID],
    );
    return result.map((json) {
      final data = Map<String, dynamic>.from(json);
      data['timestamp'] = DateTime.parse(data['timestamp'] as String);
      return Message.fromJson(data);
    }).toList();
  }

  @override
  Future<List<Message>> getPendingMessages(String senderID) async {
    final result = await _dbService.query(
      'messages',
      where: 'senderID = ? AND status = ?',
      whereArgs: [senderID, AppConstants.statusQueued],
    );
    return result.map((json) {
      final data = Map<String, dynamic>.from(json);
      data['timestamp'] = DateTime.parse(data['timestamp'] as String);
      return Message.fromJson(data);
    }).toList();
  }

  @override
  Future<List<Message>> getReceivedMessages(String receiverID) async {
    final result = await _dbService.query('messages', where: 'receiverID = ?', whereArgs: [receiverID]);
    return result.map((json) {
      final data = Map<String, dynamic>.from(json);
      data['timestamp'] = DateTime.parse(data['timestamp'] as String);
      return Message.fromJson(data);
    }).toList();
  }

  @override
  Future<void> updateMessageStatus(String messageID, String status) async {
    await _dbService.update(
      'messages',
      {'status': status},
      where: 'messageID = ?',
      whereArgs: [messageID],
    );
  }

  @override
  Future<void> deleteMessage(String messageID) async {
    await _dbService.delete('messages', where: 'messageID = ?', whereArgs: [messageID]);
  }
}
