import '../models/hub_model.dart';

abstract class HubRepository {
  Future<Hub> createHub(String hubName, Map<String, dynamic> location);
  Future<Hub?> getHubByID(String hubID);
  Future<List<Hub>> getAllHubs();
  Future<void> updateHub(Hub hub);
  Future<void> deleteHub(String hubID);
  Future<void> registerUserToHub(String hubID, String userID);
  Future<void> removeUserFromHub(String hubID, String userID);
}
