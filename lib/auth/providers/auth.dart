import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../home/models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  String _particularId;
  Timer _authTimer;

  String _url_link = "https://codearistos.io/clients/telerad-2/";
  // String _url_link = "https://digisofthms.com/";
  // Example:
  // String _url_link = "https://codearistos.net/demo/multi-hms/";

  bool get isAuth {
    return _token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  String get particularId {
    return _particularId;
  }

  String get linkURL {
    return _url_link;
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    String gtype = "Doctor";
    final url = _url_link + 'api/authenticate';
    try {
      final response = await http.post(
        url,
        body: {
          'email': email,
          'password': password,
          'group': gtype,
        },
      );

      final responseData = json.decode(response.body);

      responseData['error'] == null;
      if (responseData['message'] != 'successful') {
        throw HttpException(responseData['message']);
      }

      _token = responseData['idToken'].toString();
      _userId = responseData['ion_id'].toString();

      _particularId = responseData['user_id'].toString();

      _expiryDate = DateTime.now().add(
        Duration(
          seconds: int.parse(
            82000.toString(),
          ),
        ),
      );
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode(
        {
          'token': _token,
          'userId': _userId,
          'particularId': _particularId,
          'expiryDate': _expiryDate.toIso8601String(),
        },
      );
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')) as Map<String, Object>;
    final expiryDate = DateTime.parse(extractedUserData['expiryDate']);

    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }

    _token = extractedUserData['token'];
    _userId = extractedUserData['userId'];
    _particularId = extractedUserData['particularId'];

    this._expiryDate = expiryDate;

    notifyListeners();
    _autoLogout();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
