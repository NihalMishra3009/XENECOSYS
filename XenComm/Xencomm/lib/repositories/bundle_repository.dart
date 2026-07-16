import '../models/bundle_model.dart';

abstract class BundleRepository {
  Future<Bundle> createBundle(Bundle bundle);
  Future<Bundle?> getBundleByID(String bundleID);
  Future<List<Bundle>> getBundlesByHub(String hubID);
  Future<List<Bundle>> getBundlesByStatus(String status);
  Future<void> updateBundleStatus(String bundleID, String status);
  Future<void> deleteBun(String bundleID);
}
