import 'dart:convert';
import 'dart:io';

class HubApiClient {
  HubApiClient(this.baseUri) : _client = HttpClient();

  final Uri baseUri;
  final HttpClient _client;

  Future<Map<String, dynamic>> getObject(String path) async {
    final response = await _request('GET', path);
    return _expectObject(response);
  }

  Future<Map<String, dynamic>> postObject(
    String path, {
    Map<String, Object?>? body,
  }) async {
    final response = await _request('POST', path, body: body);
    return _expectObject(response);
  }

  Future<Map<String, dynamic>> putObject(
    String path, {
    Map<String, Object?>? body,
  }) async {
    final response = await _request('PUT', path, body: body);
    return _expectObject(response);
  }

  Future<Map<String, dynamic>> patchObject(
    String path, {
    Map<String, Object?>? body,
  }) async {
    final response = await _request('PATCH', path, body: body);
    return _expectObject(response);
  }

  Future<void> delete(String path) async {
    final response = await _request('DELETE', path);
    if (response.statusCode != HttpStatus.noContent) {
      _throwHttpError(response);
    }
  }

  Future<_ApiResponse> _request(
    String method,
    String path, {
    Map<String, Object?>? body,
  }) async {
    final uri = _resolve(path);
    final request = await _client.openUrl(method, uri);
    request.headers.contentType = ContentType.json;
    if (body != null) {
      request.write(jsonEncode(body));
    }
    final response = await request.close();
    final text = response.statusCode == HttpStatus.noContent
        ? ''
        : await utf8.decodeStream(response);
    if (response.statusCode >= 400) {
      throw HttpException(
        'HTTP ${response.statusCode} for $method $uri: $text',
        uri: uri,
      );
    }
    return _ApiResponse(statusCode: response.statusCode, body: text);
  }

  Uri _resolve(String path) {
    final base = baseUri.toString().endsWith('/') ? baseUri.toString() : '${baseUri.toString()}/';
    final cleaned = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('$base$cleaned');
  }

  Map<String, dynamic> _expectObject(_ApiResponse response) {
    if (response.body.isEmpty) {
      return const <String, dynamic>{};
    }
    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const FormatException('Expected a JSON object');
  }

  Never _throwHttpError(_ApiResponse response) {
    throw HttpException('HTTP ${response.statusCode}: ${response.body}');
  }

  void close() {
    _client.close(force: true);
  }
}

class _ApiResponse {
  const _ApiResponse({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final String body;
}
