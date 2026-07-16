import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto_pkg;
import 'package:encrypt/encrypt.dart' as encrypt;

class CryptoService {
  static final CryptoService _instance = CryptoService._internal();
  factory CryptoService() => _instance;
  CryptoService._internal();

  String encryptAES(String plaintext, String keyString) {
    final keyBytes = utf8.encode(keyString.padRight(32).substring(0, 32));
    final key = encrypt.Key(keyBytes);
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  String decryptAES(String encrypted, String keyString) {
    final parts = encrypted.split(':');
    if (parts.length != 2) throw Exception('Invalid encrypted format');
    final iv = encrypt.IV.fromBase64(parts[0]);
    final keyBytes = utf8.encode(keyString.padRight(32).substring(0, 32));
    final key = encrypt.Key(keyBytes);
    return encrypt.Encrypter(encrypt.AES(key)).decrypt64(parts[1], iv: iv);
  }

  Map<String, String> generateRSAKeyPair() => {
        'publicKey': 'mock_public_key_${DateTime.now().millisecondsSinceEpoch}',
        'privateKey': 'mock_private_key_${DateTime.now().millisecondsSinceEpoch}',
      };

  String generateChecksum(List<String> data) =>
      crypto_pkg.sha256.convert(utf8.encode(data.join('|'))).toString();

  String generateUniqueUserID() {
    final hex = DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase();
    return 'HX-${hex.substring(0, 8).padLeft(8, '0')}';
  }

  String generateMessageID() => 'MSG-${_generateRandomHex(8)}';
  String generateBundleID() => 'BDL-${_generateRandomHex(8)}';
  String generateDeviceID() => 'DEV-${_generateRandomHex(8)}';

  String _generateRandomHex(int length) {
    final value = DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase();
    return value.padRight(length, '0').substring(0, length);
  }
}
