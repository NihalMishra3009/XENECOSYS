import '../../models/user_model.dart';
import '../../services/crypto/crypto_service.dart';
import '../../services/database/database_service.dart';
import '../user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final DatabaseService _dbService = DatabaseService();
  final CryptoService _crypto = CryptoService();

  @override
  Future<User> createUser(String name, String homeHubID) async {
    final keys = _crypto.generateRSAKeyPair();
    final user = User(
      uniqueID: _crypto.generateUniqueUserID(),
      name: name,
      photo: null,
      homeHubID: homeHubID,
      currentHubID: homeHubID,
      publicKey: keys['publicKey']!,
      privateKey: keys['privateKey']!,
      deviceID: _crypto.generateDeviceID(),
      createdAt: DateTime.now(),
    );
    await _dbService.insert('users', user.toJson());
    return user;
  }

  @override
  Future<User?> getUserByID(String uniqueID) async {
    final result = await _dbService.query('users', where: 'uniqueID = ?', whereArgs: [uniqueID]);
    if (result.isEmpty) return null;
    return User.fromJson(result.first);
  }

  @override
  Future<List<User>> getAllUsers() async {
    final result = await _dbService.query('users');
    return result.map(User.fromJson).toList();
  }

  @override
  Future<void> updateUser(User user) async {
    await _dbService.update(
      'users',
      user.toJson(),
      where: 'uniqueID = ?',
      whereArgs: [user.uniqueID],
    );
  }

  @override
  Future<void> deleteUser(String uniqueID) async {
    await _dbService.delete('users', where: 'uniqueID = ?', whereArgs: [uniqueID]);
  }

  @override
  Future<User?> getUserByDeviceID(String deviceID) async {
    final result = await _dbService.query('users', where: 'deviceID = ?', whereArgs: [deviceID]);
    if (result.isEmpty) return null;
    return User.fromJson(result.first);
  }
}
