import 'api_endpoints.dart';

class AuthApi {
  const AuthApi();

  Future<void> sendOtp({required String account}) async {
    // 占位接口：后续接入真实后端时，改为调用 ApiEndpoints.authSendOtp。
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _debugEndpoint(ApiEndpoints.authSendOtp, account);
  }

  Future<String> verifyOtp({
    required String account,
    required String code,
  }) async {
    // 占位接口：后续接入真实后端时，改为调用 ApiEndpoints.authVerifyOtp 并返回真实 token。
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _debugEndpoint(ApiEndpoints.authVerifyOtp, '$account:$code');
    return 'demo-session-token';
  }

  void _debugEndpoint(String endpoint, String payload) {
    assert(() {
      // 保留 endpoint 引用，确保占位流程和统一 API 管理保持一致。
      endpoint.isNotEmpty && payload.isNotEmpty;
      return true;
    }());
  }
}
