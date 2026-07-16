import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/data/communication_mock_data.dart';
import '../models/user_model.dart';
import '../repositories/impl/contact_repository_impl.dart';
import '../repositories/impl/hub_repository_impl.dart';
import '../repositories/impl/user_repository_impl.dart';
import '../services/auth_service.dart';
import '../services/database/database_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final userRepositoryProvider = Provider<UserRepositoryImpl>((ref) => UserRepositoryImpl());
final hubRepositoryProvider = Provider<HubRepositoryImpl>((ref) => HubRepositoryImpl());
final contactRepositoryProvider = Provider<ContactRepositoryImpl>((ref) => ContactRepositoryImpl());
final contactCountProvider = FutureProvider<int>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return contactSeeds.length;

  final rows = await DatabaseService().query('contacts', where: 'userID = ?', whereArgs: [user.uniqueID]);
  final seedIds = contactSeeds.map((contact) => contact.$2).toSet();
  return seedIds.length + rows.length;
});

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, User?>((ref) {
  return CurrentUserNotifier(ref.read(authServiceProvider));
});

class CurrentUserNotifier extends StateNotifier<User?> {
  CurrentUserNotifier(this._authService) : super(null) {
    _init();
  }

  final AuthService _authService;

  Future<void> _init() async {
    state = await _authService.getStoredUser();
  }

  Future<void> login(String userID) async {
    if (await _authService.login(userID)) {
      state = _authService.currentUser;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = null;
  }

  Future<void> updateName(String name) async {
    final user = state;
    if (user == null) return;
    final updated = user.copyWith(name: name.trim());
    state = await _authService.updateCurrentUser(updated);
  }
}
