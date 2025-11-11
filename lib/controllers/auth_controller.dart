import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../data/dummy_data.dart';

class AuthController extends ChangeNotifier {
  AuthController({bool isGuest = true, User? user})
      : _isGuest = isGuest,
        _user = user;

  static const _authModeKey = 'authMode';

  bool _isGuest;
  User? _user;

  bool get isGuest => _isGuest;
  User? get user => _user;

  Future<void> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _user = DummyData.user;
    _isGuest = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authModeKey, 'user');
  }

  Future<void> signUp(String email, String password, String name) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _user = DummyData.user;
    _isGuest = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authModeKey, 'user');
  }

  Future<void> continueAsGuest() async {
    _isGuest = true;
    _user = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authModeKey, 'guest');
  }

  Future<void> signOut() async {
    _isGuest = true;
    _user = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authModeKey, 'guest');
  }

  static Future<AuthController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_authModeKey) ?? 'guest';
    if (mode == 'user') {
      return AuthController(isGuest: false, user: DummyData.user);
    }
    return AuthController();
  }
}
