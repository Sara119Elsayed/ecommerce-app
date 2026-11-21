import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';

class AuthService {
  AuthService({
    http.Client? client,
    String baseUrl = ApiConstance.baseUrl,
  }) : _client = client ?? http.Client(),
       _baseUrl = baseUrl;

  final http.Client _client;
  final String _baseUrl;

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final base = Uri.parse(_baseUrl);
    final uri = base.replace(path: '${base.path}/auth/login');
    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({
        'username': username,
        'password': password,
        'expiresInMins': 30,
      });

    final streamedResponse = await _client.send(request);
    final response = await http.Response.fromStream(streamedResponse);
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('The login response is invalid.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          decoded['message']?.toString() ?? response.reasonPhrase ?? 'Login failed';
      throw Exception(message);
    }
    return decoded;
  }

  void close() => _client.close();
}
