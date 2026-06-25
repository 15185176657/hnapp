class AuthSession {
  String? _token;

  String? get token => _token;
  bool get isSignedIn => _token != null && _token!.isNotEmpty;

  void signInWithDemoToken() {
    _token = 'demo-session-token';
  }

  void signOut() {
    _token = null;
  }
}