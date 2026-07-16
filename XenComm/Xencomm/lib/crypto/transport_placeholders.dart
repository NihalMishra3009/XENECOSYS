abstract class BluetoothTransport {
  Future<void> send(String payload);
}

abstract class WifiDirectTransport {
  Future<void> send(String payload);
}

abstract class QRExchange {
  Future<void> exchange(String payload);
}

abstract class MeshTransport {
  Future<void> relay(String payload);
}
