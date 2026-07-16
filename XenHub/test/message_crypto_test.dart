import 'package:flutter_test/flutter_test.dart';

import 'package:xenhub/src/features/message_queue/data/message_crypto.dart';

void main() {
  test('message crypto encrypts and decrypts round trip', () async {
    final crypto = MessageCrypto();
    final encrypted = await crypto.encrypt('hello queue');

    expect(encrypted, isNot('hello queue'));
    expect(await crypto.decrypt(encrypted), 'hello queue');
  });
}
