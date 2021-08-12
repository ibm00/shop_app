import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/http_exception.dart';

class AuthProvider extends ChangeNotifier {
  String _token;
  DateTime _expireDate;
  String _userId;
  Timer _autoLogoutTimer;

  bool get isAuth {
    return _token != null;
  }

  String get token {
    if (_expireDate != null &&
        _expireDate.isAfter(DateTime.now()) &&
        _token != null) return _token;
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> signUp(String email, String pass) async {
    await _authMe(email, pass, "signUp");
  }

  Future<void> signIn(String email, String pass) async {
    await _authMe(email, pass, "signInWithPassword");
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expireDate = null;
    _autoLogoutTimer.cancel();
    _autoLogoutTimer = null;
    notifyListeners();
    final sharedP = await SharedPreferences.getInstance();
    sharedP.clear();
  }

  Future<bool> autoLogin() async {
    final sharedP = await SharedPreferences.getInstance();
    if (!sharedP.containsKey("userData")) return false;
    final userData =
        json.decode(sharedP.getString("userData")) as Map<String, dynamic>;
    final expireDate = DateTime.parse(userData["expireDate"]);
    if ((expireDate.isBefore(DateTime.now()))) return false;

    _token = userData["token"];
    _userId = userData["userId"];
    _expireDate = expireDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  void _autoLogout() {
    if (_autoLogoutTimer != null) _autoLogoutTimer.cancel();
    final int expireSeconds = _expireDate.difference(DateTime.now()).inSeconds;
    _autoLogoutTimer = Timer(Duration(seconds: expireSeconds), logout);
  }

  Future<void> _authMe(String email, String pass, String urlSegment) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyDrtQx8aKwBn-1Y1MemlRf1DDd5ByNv8xA");
    try {
      final res = await http.post(
        url,
        body: json.encode(
          {
            "email": email,
            "password": pass,
            "returnSecureToken": true,
          },
        ),
      );
      final authData = json.decode(res.body) as Map<String, dynamic>;

      if (authData["error"] != null)
        throw MyHttpException(authData["error"]["message"]);

      _token = authData["idToken"];
      _expireDate = DateTime.now()
          .add(Duration(seconds: int.parse(authData["expiresIn"])));
      _userId = authData["localId"];
      notifyListeners();
      _autoLogout();
      final sharedP = await SharedPreferences.getInstance();
      final userData = json.encode({
        "token": _token,
        "userId": _userId,
        "expireDate": _expireDate.toIso8601String(),
      });
      sharedP.setString("userData", userData);
    } catch (e) {
      print(e);
      throw e;
    }
  }
}
