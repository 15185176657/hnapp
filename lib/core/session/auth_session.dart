import 'package:flutter/foundation.dart';

class AuthSession extends ChangeNotifier {
  String? _token;

  String? get token => _token;
  bool get isSignedIn => _token != null && _token!.isNotEmpty;

  void signInWithToken(String token) {
    _token = token;
    notifyListeners();
  }

  void signOut() {
    _token = null;
    notifyListeners();
  }
}
