import 'dart:convert';

String encodeJson(Object? value) => jsonEncode(value);

dynamic decodeJson(String value) => jsonDecode(value);
