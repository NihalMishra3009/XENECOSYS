import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/message_bundle.dart';
import '../domain/message_queue_repository.dart';

final messageQueueRepositoryProvider = Provider<MessageQueueRepository>((ref) {
  throw UnimplementedError(
    'messageQueueRepositoryProvider must be overridden in main or tests.',
  );
});

final messageBundlesProvider = FutureProvider<List<MessageBundle>>((ref) {
  return ref.watch(messageQueueRepositoryProvider).listBundles();
});
