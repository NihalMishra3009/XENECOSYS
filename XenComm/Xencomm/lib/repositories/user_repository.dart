import '../models/user_model.dart';

abstract class UserRepository {
  Future<User> createUser(String name, String homeHubID);
  Future<User?> getUserByID(String uniqueID);
  Future<List<User>> getAllUsers();
  Future<void> updateUser(User user);
  Future<void> deleteUser(String uniqueID);
  Future<User?> getUserByDeviceID(String deviceID);
}
