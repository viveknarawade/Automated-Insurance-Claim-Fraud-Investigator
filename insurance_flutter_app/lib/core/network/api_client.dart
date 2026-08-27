import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  static const String keyAccessToken = 'accessToken';
  static const String keyRefreshToken = 'refreshToken';

  Future<Map<String, String>> _getHeaders({bool isMultipart = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(keyAccessToken);

    final headers = <String, String>{};
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    final baseUrl = await ApiConstants.getBaseUrl();
    var uri = Uri.parse('$baseUrl$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    final headers = await _getHeaders();
    var response = await http.get(uri, headers: headers);

    if (response.statusCode == 401 && !endpoint.contains('/auth/')) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final newHeaders = await _getHeaders();
        response = await http.get(uri, headers: newHeaders);
      }
    }

    return _processResponse(response);
  }

  Future<dynamic> post(String endpoint, {dynamic body}) async {
    final baseUrl = await ApiConstants.getBaseUrl();
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    var response = await http.post(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 401 && !endpoint.contains('/auth/')) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final newHeaders = await _getHeaders();
        response = await http.post(
          uri,
          headers: newHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      }
    }

    return _processResponse(response);
  }

  Future<dynamic> patch(String endpoint, {dynamic body}) async {
    final baseUrl = await ApiConstants.getBaseUrl();
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    var response = await http.patch(
      uri,
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );

    if (response.statusCode == 401 && !endpoint.contains('/auth/')) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final newHeaders = await _getHeaders();
        response = await http.patch(
          uri,
          headers: newHeaders,
          body: body != null ? jsonEncode(body) : null,
        );
      }
    }

    return _processResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final baseUrl = await ApiConstants.getBaseUrl();
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    var response = await http.delete(uri, headers: headers);

    if (response.statusCode == 401 && !endpoint.contains('/auth/')) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final newHeaders = await _getHeaders();
        response = await http.delete(uri, headers: newHeaders);
      }
    }

    return _processResponse(response);
  }

  Future<dynamic> uploadMultipart(
    String endpoint, {
    required String filePath,
    required String fileParamName,
    Map<String, String>? fields,
  }) async {
    final baseUrl = await ApiConstants.getBaseUrl();
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders(isMultipart: true);

    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);

    if (fields != null) {
      request.fields.addAll(fields);
    }

    final multipartFile = await http.MultipartFile.fromPath(fileParamName, filePath);
    request.files.add(multipartFile);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    return _processResponse(response);
  }

  Future<bool> _tryRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(keyRefreshToken);
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final baseUrl = await ApiConstants.getBaseUrl();
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] != null) {
          final newAccessToken = json['data']['accessToken'];
          if (newAccessToken != null) {
            await prefs.setString(keyAccessToken, newAccessToken);
            return true;
          }
        }
      }
    } catch (_) {}
    return false;
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
        return decoded['data'];
      }
      return decoded;
    } else {
      String errorMessage = 'Request failed with status code ${response.statusCode}';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('message')) {
          errorMessage = decoded['message'];
        }
      } catch (_) {}
      throw Exception(errorMessage);
    }
  }
}
