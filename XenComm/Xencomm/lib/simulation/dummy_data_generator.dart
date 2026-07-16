import '../core/constants/app_constants.dart';
import '../models/data_mule_model.dart';
import '../models/hub_model.dart';
import '../models/user_model.dart';
import '../services/crypto/crypto_service.dart';

class DummyDataGenerator {
  static final _crypto = CryptoService();

  static List<Hub> generateHubs() {
    final now = DateTime.now();
    return [
      Hub(
        hubID: 'HUB-001',
        hubName: 'Central Hub - Mumbai',
        location: {'lat': 19.0760, 'lng': 72.8777, 'address': 'Mumbai, Maharashtra, India'},
        registeredUsers: [],
        pendingBundles: [],
        receivedBundles: [],
        connectedDataMules: [],
        createdAt: now,
      ),
      Hub(
        hubID: 'HUB-002',
        hubName: 'Northern Hub - Delhi',
        location: {'lat': 28.7041, 'lng': 77.1025, 'address': 'Delhi, India'},
        registeredUsers: [],
        pendingBundles: [],
        receivedBundles: [],
        connectedDataMules: [],
        createdAt: now,
      ),
      Hub(
        hubID: 'HUB-003',
        hubName: 'Southern Hub - Bangalore',
        location: {'lat': 12.9716, 'lng': 77.5946, 'address': 'Bangalore, Karnataka, India'},
        registeredUsers: [],
        pendingBundles: [],
        receivedBundles: [],
        connectedDataMules: [],
        createdAt: now,
      ),
    ];
  }

  static List<DataMule> generateDataMules() {
    final now = DateTime.now();
    return [
      DataMule(
        vehicleID: 'MULE-BUS-001',
        type: 'Bus',
        capacity: 500,
        currentHub: 'HUB-001',
        nextHub: 'HUB-002',
        speed: 60.0,
        status: AppConstants.muleStatusActive,
        bundlesCarrying: [],
        createdAt: now,
      ),
      DataMule(
        vehicleID: 'MULE-TRAIN-001',
        type: 'Train',
        capacity: 2000,
        currentHub: 'HUB-002',
        nextHub: 'HUB-003',
        speed: 80.0,
        status: AppConstants.muleStatusActive,
        bundlesCarrying: [],
        createdAt: now,
      ),
    ];
  }

  static User generateUser(String name, String homeHubID) {
    final keys = _crypto.generateRSAKeyPair();
    return User(
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
  }

  static List<User> generateDummyUsers() => [
        generateUser('Alice', 'HUB-001'),
        generateUser('Bob', 'HUB-001'),
        generateUser('Charlie', 'HUB-002'),
        generateUser('Diana', 'HUB-002'),
        generateUser('Eve', 'HUB-003'),
      ];
}
