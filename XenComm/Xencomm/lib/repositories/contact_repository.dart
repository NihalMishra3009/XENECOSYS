import '../models/user_model.dart';

abstract class ContactRepository {
  Future<void> addContact(String userID, String contactUserID, String contactName);
  Future<void> removeContact(String userID, String contactUserID);
  Future<List<User>> getUserContacts(String userID);
  Future<User?> searchContactByID(String userID, String contactID);
  Future<List<User>> searchContactsByName(String userID, String name);
}
