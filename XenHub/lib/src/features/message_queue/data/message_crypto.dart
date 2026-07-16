import 'dart:convert';

import 'package:cryptography/cryptography.dart';

class MessageCrypto {
  MessageCrypto({String passphrase = 'xenhub-phase3-message-key'})
      : _keyBytes = _deriveKeyBytes(passphrase);

  final List<int> _keyBytes;
  final AesGcm _cipher = AesGcm.with256bits();

  Future<String> encrypt(String value) async {
    final box = await _cipher.encrypt(
      utf8.encode(value),
      secretKey: SecretKey(_keyBytes),
    );
    return base64Encode(box.concatenation());
  }

  Future<String> decrypt(String value) async {
    final box = SecretBox.fromConcatenation(
      base64Decode(value),
      nonceLength: _cipher.nonceLength,
      macLength: _cipher.macAlgorithm.macLength,
    );
    final clear = await _cipher.decrypt(
      box,
      secretKey: SecretKey(_keyBytes),
    );
    return utf8.decode(clear);
  }

  static List<int> _deriveKeyBytes(String passphrase) {
    final bytes = utf8.encode(passphrase);
    return List<int>.unmodifiable(
      List<int>.generate(32, (index) {
        final source = bytes[index % bytes.length];
        return source ^ ((index * 17) & 0xff);
      }),
    );
  }
}
