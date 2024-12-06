import 'package:flutter/material.dart';

import 'package:cai_gameengine/models/profile.model.dart';

import 'package:cai_gameengine/services/login_session.service.dart';

class LoginSessionModel extends ChangeNotifier {
  late LoginSessionService _preferences;

  late bool _sessionActive;
  late String _token;
  late ProfileModel? _user;
  late bool _complete;
  bool _pretestDone = false;

  bool get sessionActive => _sessionActive;
  String get token => _token;
  ProfileModel? get user => _user;
  bool get complete => _complete;
  bool get pretestDone => _pretestDone;

  LoginSessionModel() {
    _sessionActive = false;
    _token = '';
    _user = null;
    _complete = false;
    _preferences = LoginSessionService();
    isActive();
  }

  set sessionActive(bool value) {
    _sessionActive = value;
    notifyListeners();
  }

  set token(String value) {
    _preferences.setToken(value);
    _token = value;
    _sessionActive = true;
    // createSession();
    notifyListeners();
  }

  set pretestDone(bool value) {
    _pretestDone = value;
    notifyListeners();
  }

  set user(ProfileModel? value) {
    _user = value;
    checkComplete();
  }

  isActive() async {
    _token = await _preferences.getToken();
    if(_token.isNotEmpty) {
      _sessionActive = true;
      // createSession();
    } else {
      _sessionActive = false;
    }
    notifyListeners();
  }

  checkComplete() {
    if(_user != null) {
      _complete = true;
      notifyListeners();
    }
  }

  clearSession() async {
    _preferences.removeSession();
    _sessionActive = false;
    _token = '';
    _user = null;
    _complete = false;
    _pretestDone = false;
    notifyListeners();
  }

}