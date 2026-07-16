import '../../models/user_model.dart';
import '../../services/database/database_service.dart';
import '../contact_repository.dart';
import 'user_repository_impl.dart';

class ContactRepositoryImpl implements ContactRepository {
  final DatabaseService _dbService = DatabaseService();
  final UserRepositoryImpl _userRepo = UserRepositoryImpl();

  @override
  Future<void> addContact(String userID, String contactUserID, String contactName) async {
    final existing = await _dbService.query(
      'contacts',
      where: 'userID = ? AND contactUserID = ?',
      whereArgs: [userID, contactUserID],
    );
    final values = {
      'contactID': existing.isNotEmpty
          ? existing.first['contactID']
          : 'CONT-${DateTime.now().microsecondsSinceEpoch}',
      'userID': userID,
      'contactUserID': contactUserID,
      'name': contactName,
      'addedAt': DateTime.now().toIso8601String(),
    };
    if (existing.isEmpty) {
      await _dbService.insert('contacts', values);
    } else {
      await _dbService.update(
        'contacts',
        values,
        where: 'userID = ? AND contactUserID = ?',
        whereArgs: [userID, contactUserID],
      );
    }
  }

  @override
  Future<void> removeContact(String userID, String contactUserID) async {
    await _dbService.delete(
      'contacts',
      where: 'userID = ? AND contactUserID = ?',
      whereArgs: [userID, contactUserID],
    );
  }

  @override
  Future<List<User>> getUserContacts(String userID) async {
    final contacts = await _dbService.query('contacts', where: 'userID = ?', whereArgs: [userID]);
    final users = <User>[];
    for (final contact in contacts) {
      final user = await _userRepo.getUserByID(contact['contactUserID'] as String);
      if (user != null) users.add(user);
    }
    return users;
  }

  @override
  Future<User?> searchContactByID(String userID, String contactID) async {
    final contact = await _dbService.query(
      'contacts',
      where: 'userID = ? AND contactUserID = ?',
      whereArgs: [userID, contactID],
    );
    if (contact.isEmpty) return null;
    return _userRepo.getUserByID(contactID);
  }

  @override
  Future<List<User>> searchContactsByName(String userID, String name) async {
    final contacts = await _dbService.query(
      'contacts',
      where: 'userID = ? AND name LIKE ?',
      whereArgs: [userID, '%$name%'],
    );
    final users = <User>[];
    for (final contact in contacts) {
      final user = await _userRepo.getUserByID(contact['contactUserID'] as String);
      if (user != null) users.add(user);
    }
    return users;
  }
}
