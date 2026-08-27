import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _currentUser != null;
  String? get errorMessage => _errorMessage;

  String get role => _currentUser?.role.toUpperCase() ?? '';
  bool get isAdmin => role == 'ADMIN';
  bool get isInvestigator => role == 'INVESTIGATOR';
  bool get isCustomer => role == 'USER' || role == 'CUSTOMER';

  AuthProvider() {
    initAuth();
  }

  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonStr = prefs.getString('user');
      final token = prefs.getString(ApiClient.keyAccessToken);

      if (userJsonStr != null && token != null) {
        _currentUser = UserModel.fromJson(jsonDecode(userJsonStr));
      }
    } catch (e) {
      _currentUser = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiClient.post('/auth/login', body: {
        'email': email,
        'password': password,
      });

      if (data != null) {
        final prefs = await SharedPreferences.getInstance();
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        final userData = data['user'];

        if (accessToken != null) {
          await prefs.setString(ApiClient.keyAccessToken, accessToken);
        }
        if (refreshToken != null) {
          await prefs.setString(ApiClient.keyRefreshToken, refreshToken);
        }
        if (userData != null) {
          await prefs.setString('user', jsonEncode(userData));
          _currentUser = UserModel.fromJson(userData);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? phoneNumber,
    String? role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiClient.post('/auth/register', body: {
        'fullName': fullName,
        'email': email,
        'password': password,
        if (phoneNumber != null && phoneNumber.isNotEmpty) 'phoneNumber': phoneNumber,
        if (role != null && role.isNotEmpty) 'role': role,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiClient.post('/auth/forgot-password', body: {'email': email});
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(ApiClient.keyRefreshToken);
      if (refreshToken != null) {
        await _apiClient.post('/auth/logout', body: {'refreshToken': refreshToken});
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
    notifyListeners();
  }
}
