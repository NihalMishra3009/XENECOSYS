import '../core/constants/app_constants.dart';
import '../models/bundle_model.dart';
import '../models/data_mule_model.dart';
import '../repositories/impl/bundle_repository_impl.dart';
import '../repositories/impl/data_mule_repository_impl.dart';
import '../repositories/impl/message_repository_impl.dart';
import '../services/crypto/crypto_service.dart';

class DTNSimulator {
  static final DTNSimulator _instance = DTNSimulator._internal();
  factory DTNSimulator() => _instance;
  DTNSimulator._internal();

  final _bundleRepo = BundleRepositoryImpl();
  final _muleRepo = DataMuleRepositoryImpl();
  final _msgRepo = MessageRepositoryImpl();
  final _crypto = CryptoService();

  Future<Bundle> createBundleFromMessages(
    String sourceHubID,
    String destHubID,
    List<String> messageIDs,
  ) async {
    var totalSize = 0;
    for (final msgID in messageIDs) {
      final msg = await _msgRepo.getMessageByID(msgID);
      if (msg != null) totalSize += msg.encryptedContent.length;
    }
    final bundle = Bundle(
      bundleID: _crypto.generateBundleID(),
      sourceHub: sourceHubID,
      destinationHub: destHubID,
      messageIDs: messageIDs,
      createdAt: DateTime.now(),
      checksum: _crypto.generateChecksum(messageIDs),
      status: AppConstants.bundleStatusCreated,
      sizeBytes: totalSize,
    );
    return _bundleRepo.createBundle(bundle);
  }

  Future<bool> verifyBundleChecksum(String bundleID) async {
    final bundle = await _bundleRepo.getBundleByID(bundleID);
    if (bundle == null) return false;
    return bundle.checksum == _crypto.generateChecksum(bundle.messageIDs);
  }

  Future<DataMule?> findBestMuleForBundle(String sourceHubID, String destHubID) async {
    final mules = await _muleRepo.getAllDataMules();
    final active = mules.where((m) => m.status == AppConstants.muleStatusActive).toList();
    for (final mule in active) {
      if (mule.currentHub == sourceHubID) return mule;
    }
    for (final mule in active) {
      if (mule.nextHub == sourceHubID) return mule;
    }
    return active.isNotEmpty ? active.first : null;
  }

  Future<void> assignBundleToMule(String bundleID, String muleID) async {
    final bundle = await _bundleRepo.getBundleByID(bundleID);
    final mule = await _muleRepo.getDataMuleByID(muleID);
    if (bundle == null) throw Exception('Bundle not found');
    if (mule == null) throw Exception('Mule not found');
    if (bundle.sizeBytes > mule.capacity) {
      throw Exception(AppConstants.capacityExceeded);
    }
    await _muleRepo.addBundleToMule(muleID, bundleID);
    await _bundleRepo.updateBundleStatus(bundleID, AppConstants.bundleStatusInTransit);
  }

  Future<void> moveMuleToHub(String muleID, String nextHubID) async {
    final mule = await _muleRepo.getDataMuleByID(muleID);
    if (mule == null) throw Exception('Mule not found');
    await _muleRepo.updateDataMule(
      mule.copyWith(
        currentHub: mule.nextHub,
        nextHub: nextHubID,
        status: AppConstants.muleStatusInTransit,
      ),
    );
  }

  Future<void> deliverBundleAtHub(String bundleID, String hubID) async {
    final bundle = await _bundleRepo.getBundleByID(bundleID);
    if (bundle == null) throw Exception('Bundle not found');
    if (bundle.destinationHub != hubID) return;
    await _bundleRepo.updateBundleStatus(bundleID, AppConstants.bundleStatusDelivered);
    for (final msgID in bundle.messageIDs) {
      await _msgRepo.updateMessageStatus(msgID, AppConstants.statusDelivered);
    }
  }

  Future<void> simulateEndToEndDelivery(
    String sourceHubID,
    String destHubID,
    List<String> messageIDs,
  ) async {
    final bundle = await createBundleFromMessages(sourceHubID, destHubID, messageIDs);
    final checksumOk = await verifyBundleChecksum(bundle.bundleID);
    if (!checksumOk) throw Exception(AppConstants.checksumMismatch);
    final mule = await findBestMuleForBundle(sourceHubID, destHubID);
    if (mule == null) throw Exception('No mule available');
    await assignBundleToMule(bundle.bundleID, mule.vehicleID);
    await moveMuleToHub(mule.vehicleID, destHubID);
    await deliverBundleAtHub(bundle.bundleID, destHubID);
  }

  List<String> getRoutingPath(String sourceHub, String destHub) {
    const routes = {
      'HUB-001|HUB-002': ['HUB-001', 'HUB-002'],
      'HUB-001|HUB-003': ['HUB-001', 'HUB-002', 'HUB-003'],
      'HUB-002|HUB-003': ['HUB-002', 'HUB-003'],
      'HUB-002|HUB-001': ['HUB-002', 'HUB-001'],
      'HUB-003|HUB-001': ['HUB-003', 'HUB-002', 'HUB-001'],
      'HUB-003|HUB-002': ['HUB-003', 'HUB-002'],
    };
    return routes['$sourceHub|$destHub'] ?? const [];
  }
}
