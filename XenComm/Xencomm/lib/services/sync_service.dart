import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../repositories/impl/message_repository_impl.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final MessageRepositoryImpl _msgRepo = MessageRepositoryImpl();

  Future<void> syncWithHub(User user, String hubID) async {
    final pending = await _msgRepo.getPendingMessages(user.uniqueID);
    for (final msg in pending) {
      await _msgRepo.updateMessageStatus(msg.messageID, AppConstants.statusSent);
    }

    final received = await _msgRepo.getReceivedMessages(user.uniqueID);
    for (final msg in received) {
      if (msg.status != AppConstants.statusDelivered) {
        await _msgRepo.updateMessageStatus(msg.messageID, AppConstants.statusDelivered);
      }
    }
  }
}
