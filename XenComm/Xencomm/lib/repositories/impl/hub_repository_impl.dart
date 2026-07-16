import '../../models/hub_model.dart';
import '../../services/database/database_service.dart';
import '../hub_repository.dart';

class HubRepositoryImpl implements HubRepository {
  final DatabaseService _dbService = DatabaseService();

  @override
  Future<Hub> createHub(String hubName, Map<String, dynamic> location) async {
    final hub = Hub(
      hubID: 'HUB-${DateTime.now().millisecondsSinceEpoch}',
      hubName: hubName,
      location: location,
      registeredUsers: const [],
      pendingBundles: const [],
      receivedBundles: const [],
      connectedDataMules: const [],
      createdAt: DateTime.now(),
    );
    await _dbService.insert('hubs', hub.toJson());
    return hub;
  }

  @override
  Future<Hub?> getHubByID(String hubID) async {
    final result = await _dbService.query('hubs', where: 'hubID = ?', whereArgs: [hubID]);
    if (result.isEmpty) return null;
    return Hub.fromJson(result.first);
  }

  @override
  Future<List<Hub>> getAllHubs() async {
    final result = await _dbService.query('hubs');
    return result.map(Hub.fromJson).toList();
  }

  @override
  Future<void> updateHub(Hub hub) async {
    await _dbService.update('hubs', hub.toJson(), where: 'hubID = ?', whereArgs: [hub.hubID]);
  }

  @override
  Future<void> deleteHub(String hubID) async {
    await _dbService.delete('hubs', where: 'hubID = ?', whereArgs: [hubID]);
  }

  @override
  Future<void> registerUserToHub(String hubID, String userID) async {
    final hub = await getHubByID(hubID);
    if (hub == null) throw Exception('Hub not found');
    final users = List<String>.from(hub.registeredUsers);
    if (!users.contains(userID)) {
      users.add(userID);
      await updateHub(hub.copyWith(registeredUsers: users));
    }
  }

  @override
  Future<void> removeUserFromHub(String hubID, String userID) async {
    final hub = await getHubByID(hubID);
    if (hub == null) throw Exception('Hub not found');
    final users = List<String>.from(hub.registeredUsers)..remove(userID);
    await updateHub(hub.copyWith(registeredUsers: users));
  }
}
