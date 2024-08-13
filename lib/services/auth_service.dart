import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../pages/mock_service.dart';

class AuthService with ChangeNotifier {
  final MockService _mockService = MockService();
  String? _token;
  String? _userId;
  String? _userType;

  bool get isAuth {
    return token != null;
  }

  String? get token => _token;
  String? get userId => _userId;
  String? get userType => _userType;

  Future<void> login(String id, String password) async {
    final url = Uri.parse('http://34.22.110.59:8082/auth/sign-in?id=$id&password=$password');
    try {
      final response = await http.post(
        url,
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['resultCode'] == 'SUCCESS') {
        final data = responseData['data'];
        if (data['success']) {
          _token = data['token'];
          _userId = id;
          _userType = 'helper';  // 서버에서 userType을 제공하지 않아 임의로 설정

          final prefs = await SharedPreferences.getInstance();
          prefs.setString('token', _token!);
          prefs.setString('userId', _userId!);
          prefs.setString('userType', _userType!);

          notifyListeners();
        } else {
          throw Exception(data['msg'] ?? '로그인에 실패했습니다.');
        }
      } else {
        throw Exception(responseData['msg'] ?? '로그인에 실패했습니다.');
      }
    } catch (error) {
      throw error;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) {
      return false;
    }
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _userType = prefs.getString('userType');
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _userType = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }

  Future<void> signup(String phoneNumber, String password, String name) async {
    final url = Uri.parse('https://your-backend-url.com/api/signup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phoneNumber': phoneNumber,
          'password': password,
          'name': name,
          'userType': 'helper',
        }),
      );

      final responseData = json.decode(response.body);
      if (response.statusCode == 201) {  // 일반적으로 회원가입 성공은 201 Created 상태 코드를 사용합니다.
        _token = responseData['token'];
        _userId = responseData['userId'];
        _userType = 'helper';

        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', _token!);
        prefs.setString('userId', _userId!);
        prefs.setString('userType', _userType!);

        notifyListeners();
      } else {
        throw Exception('회원가입에 실패했습니다.');
      }
    } catch (error) {
      throw error;
    }
  }
}
