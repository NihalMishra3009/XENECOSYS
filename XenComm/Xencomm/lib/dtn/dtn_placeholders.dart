abstract class DTNNetwork {
  Future<void> queue(String bundleId);
  Future<void> route(String bundleId);
}
