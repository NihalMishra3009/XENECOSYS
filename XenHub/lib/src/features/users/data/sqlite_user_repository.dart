import '../../../core/database/app_database.dart';
import '../domain/user_account.dart';
import '../domain/user_repository.dart';

class SqliteUserRepository implements UserRepository {
  SqliteUserRepository(this._database);

  final AppDatabase _database;

  @override
  Future<UserAccount> createUser(UserAccount user) => _database.insertUser(user);

  @override
  Future<void> deleteUser(int id) => _database.deleteUser(id);

  @override
  Future<List<UserAccount>> listUsers() => _database.readUsers();

  @override
  Future<UserAccount> updateUser(UserAccount user) => _database.updateUser(user);
}
