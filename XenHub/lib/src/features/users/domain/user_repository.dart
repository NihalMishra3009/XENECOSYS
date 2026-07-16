import 'user_account.dart';

abstract class UserRepository {
  Future<List<UserAccount>> listUsers();
  Future<UserAccount> createUser(UserAccount user);
  Future<UserAccount> updateUser(UserAccount user);
  Future<void> deleteUser(int id);
}
