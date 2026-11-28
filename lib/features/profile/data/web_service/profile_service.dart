import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';

class ProfileService {
  ProfileService({
    http.Client? client,
    String? accessToken,
    String baseUrl = ApiConstance.baseUrl,
  }) : _client = client ?? http.Client(),
       _accessToken = accessToken,
       _baseUrl = baseUrl;

  final http.Client _client;
  final String? _accessToken;
  final String _baseUrl;

  Future<Map<String, dynamic>> getProfile(int userId) async {
    final base = Uri.parse(_baseUrl);
    final uri = base.replace(path: '${base.path}/users/$userId');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_accessToken != null && _accessToken.trim().isNotEmpty)
        'Authorization': 'Bearer ${_accessToken.trim()}',
    };
    final response = await _client.get(uri, headers: headers);
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('The profile response is invalid.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message =
          decoded['message']?.toString() ??
          response.reasonPhrase ??
          'Unable to load profile';
      throw Exception(
        'Profile request failed (${response.statusCode}): $message',
      );
    }
    return decoded;
  }

  void close() => _client.close();
}