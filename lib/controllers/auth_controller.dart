import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/dummy_data.dart';
import '../models/user.dart';

class AuthController extends ChangeNotifier {
  AuthController({bool isGuest = true, User? user})
      : _isGuest = isGuest,
        _user = user;

  static const String setupCompleteKey = 'authSetupComplete';

  bool _isGuest;
  User? _user;

  bool get isGuest => _isGuest;
  User? get user => _user;

  Future<void> signIn(String email, String password) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _user = DummyData.user;
    _isGuest = false;
    notifyListeners();
    await _markSetupComplete();
  }

  Future<void> signUp(String email, String password, String name) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    _user = DummyData.user;
    _isGuest = false;
    notifyListeners();
    await _markSetupComplete();
  }

  Future<void> continueAsGuest() async {
    _isGuest = true;
    _user = null;
    notifyListeners();
    await _markSetupComplete();
  }

  Future<void> signOut() async {
    _isGuest = true;
    _user = null;
    notifyListeners();
  }

  static Future<AuthController> load() async {
    return AuthController();
  }

  static Future<void> _markSetupComplete() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(setupCompleteKey, true);
  }
}
