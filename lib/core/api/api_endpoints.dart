abstract final class ApiEndpoints {
  static const authSendOtp = '/v1/auth/otp/send';
  static const authVerifyOtp = '/v1/auth/otp/verify';
  static const devicesBind = '/v1/devices/bind';
  static const devicesCurrent = '/v1/devices/current';
  static const stationOverview = '/v1/stations/current/overview';
  static const energyStatistics = '/v1/stations/current/energy-statistics';
  static const alerts = '/v1/stations/current/alerts';
  static const userSettings = '/v1/users/me/settings';
}