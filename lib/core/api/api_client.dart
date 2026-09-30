import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiClient {
  final http.Client _httpClient;

  ApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  Map<String, String> _buildHeaders({String? token, bool isOctetStream = false, bool isGithub = false}) {
    final headers = <String, String>{
      'User-Agent': 'Auraliss-Industrial-App/0.0.1',
    };
    if (isOctetStream) {
      headers['Accept'] = 'application/octet-stream';
    } else if (isGithub) {
      headers['Accept'] = 'application/vnd.github+json';
    } else {
      headers['Accept'] = 'application/json';
      headers['Content-Type'] = 'application/json';
    }
    if (token != null && token.trim().isNotEmpty) {
      headers['Authorization'] = 'Bearer ${token.trim()}';
    }
    return headers;
  }

  Future<dynamic> getJson(String url, {String? token, bool isGithub = false}) async {
    try {
      final uri = Uri.parse(url);
      final response = await _httpClient.get(
        uri,
        headers: _buildHeaders(token: token, isGithub: isGithub),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        throw ApiException('Resource not found (404)', statusCode: 404);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw ApiException('Access forbidden or unauthorized', statusCode: response.statusCode);
      } else {
        throw ApiException('HTTP Error: ${response.statusCode} - ${response.reasonPhrase}', statusCode: response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network connection failed: $e');
    }
  }

  Future<dynamic> postJson(String url, {Map<String, dynamic>? body, String? token}) async {
    try {
      final uri = Uri.parse(url);
      final response = await _httpClient.post(
        uri,
        headers: _buildHeaders(token: token),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw ApiException('HTTP Error: ${response.statusCode} - ${response.reasonPhrase}', statusCode: response.statusCode);
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network connection failed: $e');
    }
  }

  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _httpClient.send(request);
  }

  void close() {
    _httpClient.close();
  }
}
