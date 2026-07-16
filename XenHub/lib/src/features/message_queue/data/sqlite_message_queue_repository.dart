import '../../../core/database/app_database.dart';
import '../domain/message_bundle.dart';
import '../domain/message_queue_repository.dart';
import '../domain/message_status.dart';

class SqliteMessageQueueRepository implements MessageQueueRepository {
  SqliteMessageQueueRepository(this._database);

  final AppDatabase _database;

  @override
  Future<void> createBundle(String destinationAddress, List<String> messages) =>
      _database.createMessageBundle(destinationAddress, messages);

  @override
  Future<void> deleteBundle(int bundleId) => _database.deleteMessageBundle(bundleId);

  @override
  Future<List<MessageBundle>> listBundles() => _database.readMessageBundles();

  @override
  Future<void> updateMessageStatus(int messageId, MessageStatus status) =>
      _database.updateMessageStatus(messageId, status);
}
