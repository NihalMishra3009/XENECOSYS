import 'message_bundle.dart';
import 'message_status.dart';

abstract class MessageQueueRepository {
  Future<List<MessageBundle>> listBundles();
  Future<void> createBundle(String destinationAddress, List<String> messages);
  Future<void> updateMessageStatus(int messageId, MessageStatus status);
  Future<void> deleteBundle(int bundleId);
}
