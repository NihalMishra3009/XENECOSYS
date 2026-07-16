import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/user_account.dart';
import '../domain/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  throw UnimplementedError('userRepositoryProvider must be overridden in main.');
});

final usersProvider = FutureProvider<List<UserAccount>>((ref) {
  return ref.watch(userRepositoryProvider).listUsers();
});
