import 'package:flutter/widgets.dart';

/// Hand-written localization table for the off-grid solar app.
///
/// All static UI copy lives in [_values]. Each supported language has its own
/// map; any key missing from a language gracefully falls back to English so a
/// partially translated language never shows a blank string.
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Languages the app ships with. English is the guaranteed fallback.
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('th'),
    Locale('vi'),
    Locale('id'),
    Locale('zh'),
    Locale('ja'),
    Locale('ko'),
  ];

  static AppLocalizations of(BuildContext context) {
    final localizations =
        Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(localizations != null, 'AppLocalizations not found in context.');
    return localizations!;
  }

  static bool isSupported(Locale locale) {
    return supportedLocales
        .any((supported) => supported.languageCode == locale.languageCode);
  }

  /// Native display name for a language code, used in the language picker so
  /// every option is readable regardless of the active language.
  static String nativeName(String languageCode) {
    return switch (languageCode) {
      'en' => 'English',
      'th' => 'ไทย',
      'vi' => 'Tiếng Việt',
      'id' => 'Bahasa Indonesia',
      'zh' => '中文',
      'ja' => '日本語',
      'ko' => '한국어',
      _ => languageCode,
    };
  }

  String _t(String key) {
    final table = _values[locale.languageCode] ?? _values['en']!;
    return table[key] ?? _values['en']![key] ?? key;
  }

  // Navigation -------------------------------------------------------------
  String get navHome => _t('navHome');
  String get navData => _t('navData');
  String get navAlerts => _t('navAlerts');
  String get navMine => _t('navMine');

  // Shared -----------------------------------------------------------------
  String get retry => _t('retry');
  String get refresh => _t('refresh');

  // Dashboard --------------------------------------------------------------
  String get dashboardTitle => _t('dashboardTitle');
  String get dashboardSubtitle => _t('dashboardSubtitle');
  String get demoScenario => _t('demoScenario');
  String get weakNetworkTitle => _t('weakNetworkTitle');
  String get weakNetworkMessage => _t('weakNetworkMessage');
  String remainingHours(String hours) =>
      _t('remainingHours').replaceAll('{hours}', hours);
  String get deviceOfflineHint => _t('deviceOfflineHint');
  String get metricPvPower => _t('metricPvPower');
  String get metricPvPowerCaption => _t('metricPvPowerCaption');
  String get metricLoadPower => _t('metricLoadPower');
  String get metricLoadPowerCaption => _t('metricLoadPowerCaption');
  String get metricBatterySoc => _t('metricBatterySoc');
  String get metricBatterySocCaption => _t('metricBatterySocCaption');
  String get metricTodayGenerated => _t('metricTodayGenerated');
  String todayUsedCaption(String value) =>
      _t('todayUsedCaption').replaceAll('{value}', value);
  String lastUpdated(String time) =>
      _t('lastUpdated').replaceAll('{time}', time);

  // Status labels ----------------------------------------------------------
  String get statusNormal => _t('statusNormal');
  String get statusCharging => _t('statusCharging');
  String get statusDischarging => _t('statusDischarging');
  String get statusLowBattery => _t('statusLowBattery');
  String get statusActionNeeded => _t('statusActionNeeded');
  String get statusOffline => _t('statusOffline');

  // Data page --------------------------------------------------------------
  String get dataTitle => _t('dataTitle');
  String get dataSubtitle => _t('dataSubtitle');
  String get savedDataTitle => _t('savedDataTitle');
  String get savedDataMessage => _t('savedDataMessage');
  String get metricTodayUsed => _t('metricTodayUsed');
  String get metricTotalGenerated => _t('metricTotalGenerated');
  String get metricTotalUsed => _t('metricTotalUsed');
  String monthCaption(String value) =>
      _t('monthCaption').replaceAll('{value}', value);
  String get todayTrend => _t('todayTrend');
  String get todayTrendSubtitle => _t('todayTrendSubtitle');
  String get legendGeneration => _t('legendGeneration');
  String get legendConsumption => _t('legendConsumption');

  // Alerts page ------------------------------------------------------------
  String get alertsTitle => _t('alertsTitle');
  String get alertsSubtitle => _t('alertsSubtitle');
  String get segmentCurrent => _t('segmentCurrent');
  String get segmentHistory => _t('segmentHistory');
  String get noAlertsTitle => _t('noAlertsTitle');
  String get noAlertsMessage => _t('noAlertsMessage');
  String get resolved => _t('resolved');
  String get severityWarning => _t('severityWarning');
  String get severityCritical => _t('severityCritical');
  String get severityInfo => _t('severityInfo');
  String actionPrefix(String action) =>
      _t('actionPrefix').replaceAll('{action}', action);
  String daysAgo(int count) =>
      _t('daysAgo').replaceAll('{count}', count.toString());
  String hoursAgo(int count) =>
      _t('hoursAgo').replaceAll('{count}', count.toString());
  String minutesAgo(int count) =>
      _t('minutesAgo').replaceAll('{count}', count.toString());

  // Profile page -----------------------------------------------------------
  String get profileTitle => _t('profileTitle');
  String get profileSubtitle => _t('profileSubtitle');
  String get accountSignedIn => _t('accountSignedIn');
  String get accountNotSignedIn => _t('accountNotSignedIn');
  String get otpPlaceholder => _t('otpPlaceholder');
  String get signOut => _t('signOut');
  String get signIn => _t('signIn');
  String get bindDevice => _t('bindDevice');
  String get bindDeviceHintEmpty => _t('bindDeviceHintEmpty');
  String bindDeviceHintSerial(String serial) =>
      _t('bindDeviceHintSerial').replaceAll('{serial}', serial);
  String get bindingReserved => _t('bindingReserved');
  String get pvCapacity => _t('pvCapacity');
  String get batteryCapacity => _t('batteryCapacity');
  String get firmware => _t('firmware');
  String get language => _t('language');
  String get languageSystemDefault => _t('languageSystemDefault');
  String get alertNotifications => _t('alertNotifications');
  String get alertNotificationsSubtitle => _t('alertNotificationsSubtitle');
  String get privacyTitle => _t('privacyTitle');
  String get privacySubtitle => _t('privacySubtitle');
  String get privacyPlaceholder => _t('privacyPlaceholder');

  // Detail pages -----------------------------------------------------------
  String get granularityDay => _t('granularityDay');
  String get granularityWeek => _t('granularityWeek');
  String get granularityMonth => _t('granularityMonth');
  String get detailEnergyTitle => _t('detailEnergyTitle');
  String get detailPowerTitle => _t('detailPowerTitle');
  String get detailBatteryTitle => _t('detailBatteryTitle');
  String get detailPvPowerTitle => _t('detailPvPowerTitle');
  String get detailLoadPowerTitle => _t('detailLoadPowerTitle');
  String get detailGenerationTitle => _t('detailGenerationTitle');
  String get detailConsumptionTitle => _t('detailConsumptionTitle');
  String get detailPeak => _t('detailPeak');
  String get detailAvg => _t('detailAvg');
  String get detailBatteryRange => _t('detailBatteryRange');
  String get detailBatteryLowThreshold => _t('detailBatteryLowThreshold');
  String get errorLoadingData => _t('errorLoadingData');

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'navHome': 'Home',
      'navData': 'Data',
      'navAlerts': 'Alerts',
      'navMine': 'Mine',
      'retry': 'Retry',
      'refresh': 'Refresh',
      'dashboardTitle': 'Off-grid solar',
      'dashboardSubtitle':
          'Clear power, battery and alert status for daily decisions.',
      'demoScenario': 'Demo scenario',
      'weakNetworkTitle': 'Weak network',
      'weakNetworkMessage':
          'Showing the latest successful data. Pull down to retry.',
      'remainingHours':
          'System can supply power for about {hours} hours at the current load.',
      'deviceOfflineHint':
          'Device is offline. Check the gateway power and signal.',
      'metricPvPower': 'PV power',
      'metricPvPowerCaption': 'Current solar output',
      'metricLoadPower': 'Load power',
      'metricLoadPowerCaption': 'Current home demand',
      'metricBatterySoc': 'Battery SOC',
      'metricBatterySocCaption': 'Remaining battery level',
      'metricTodayGenerated': 'Today generated',
      'todayUsedCaption': 'Used {value} kWh today',
      'lastUpdated': 'Last updated {time}',
      'statusNormal': 'Normal',
      'statusCharging': 'Charging',
      'statusDischarging': 'Discharging',
      'statusLowBattery': 'Low battery',
      'statusActionNeeded': 'Action needed',
      'statusOffline': 'Offline',
      'dataTitle': 'Energy data',
      'dataSubtitle':
          'Generation and consumption trends for daily energy planning.',
      'savedDataTitle': 'Latest saved data',
      'savedDataMessage':
          'The app kept your previous chart because the refresh failed.',
      'metricTodayUsed': 'Today used',
      'metricTotalGenerated': 'Total generated',
      'metricTotalUsed': 'Total used',
      'monthCaption': 'Month {value} kWh',
      'todayTrend': 'Today trend',
      'todayTrendSubtitle': 'Solar generation vs. home consumption',
      'legendGeneration': 'Generation',
      'legendConsumption': 'Consumption',
      'alertsTitle': 'Alerts',
      'alertsSubtitle': 'Clear actions for low battery, faults and overload.',
      'segmentCurrent': 'Current',
      'segmentHistory': 'History',
      'noAlertsTitle': 'No alerts',
      'noAlertsMessage':
          'The system is running normally. Keep monitoring the battery before night.',
      'resolved': 'Resolved',
      'severityWarning': 'Warning',
      'severityCritical': 'Critical',
      'severityInfo': 'Info',
      'actionPrefix': 'Action: {action}',
      'daysAgo': '{count}d ago',
      'hoursAgo': '{count}h ago',
      'minutesAgo': '{count}m ago',
      'profileTitle': 'My system',
      'profileSubtitle': 'Account, device, language and alert preferences.',
      'accountSignedIn': 'Demo account signed in',
      'accountNotSignedIn': 'Not signed in',
      'otpPlaceholder': 'Phone/email OTP placeholder for demo',
      'signOut': 'Sign out',
      'signIn': 'Sign in',
      'bindDevice': 'Bind device',
      'bindDeviceHintEmpty': 'Scan QR code or enter SN',
      'bindDeviceHintSerial': 'SN {serial}',
      'bindingReserved': 'Device binding flow is reserved for API integration.',
      'pvCapacity': 'PV capacity',
      'batteryCapacity': 'Battery capacity',
      'firmware': 'Firmware',
      'language': 'Language',
      'languageSystemDefault': 'System default',
      'alertNotifications': 'Alert notifications',
      'alertNotificationsSubtitle': 'Low battery, faults and overload',
      'privacyTitle': 'Privacy and user agreement',
      'privacySubtitle': 'Reserved page for launch preparation',
      'privacyPlaceholder': 'Agreement page placeholder.',
      'granularityDay': 'Day',
      'granularityWeek': 'Week',
      'granularityMonth': 'Month',
      'detailEnergyTitle': 'Energy detail',
      'detailPowerTitle': 'Power flow detail',
      'detailBatteryTitle': 'Battery detail',
      'detailPvPowerTitle': 'PV Power',
      'detailLoadPowerTitle': 'Load Power',
      'detailGenerationTitle': 'Generation',
      'detailConsumptionTitle': 'Consumption',
      'detailPeak': 'Peak',
      'detailAvg': 'Avg',
      'detailBatteryRange': 'SOC range',
      'detailBatteryLowThreshold': 'Low battery threshold (20%)',
      'errorLoadingData': 'Failed to load data.',
    },
    'th': {
      'navHome': 'หน้าหลัก',
      'navData': 'ข้อมูล',
      'navAlerts': 'การแจ้งเตือน',
      'navMine': 'ของฉัน',
      'retry': 'ลองอีกครั้ง',
      'refresh': 'รีเฟรช',
      'dashboardTitle': 'โซลาร์นอกระบบ',
      'dashboardSubtitle':
          'ดูสถานะพลังงาน แบตเตอรี่ และการแจ้งเตือนได้ชัดเจนทุกวัน',
      'demoScenario': 'สถานการณ์ตัวอย่าง',
      'weakNetworkTitle': 'สัญญาณอ่อน',
      'weakNetworkMessage': 'กำลังแสดงข้อมูลล่าสุดที่สำเร็จ ดึงลงเพื่อลองใหม่',
      'remainingHours': 'ระบบจ่ายไฟได้อีกประมาณ {hours} ชั่วโมงที่โหลดปัจจุบัน',
      'deviceOfflineHint': 'อุปกรณ์ออฟไลน์ ตรวจสอบไฟและสัญญาณของเกตเวย์',
      'metricPvPower': 'กำลังผลิตไฟ',
      'metricPvPowerCaption': 'กำลังผลิตจากแสงอาทิตย์ปัจจุบัน',
      'metricLoadPower': 'กำลังโหลด',
      'metricLoadPowerCaption': 'ความต้องการใช้ไฟในบ้านปัจจุบัน',
      'metricBatterySoc': 'ระดับแบตเตอรี่',
      'metricBatterySocCaption': 'ระดับพลังงานคงเหลือ',
      'metricTodayGenerated': 'ผลิตได้วันนี้',
      'todayUsedCaption': 'ใช้ไป {value} kWh วันนี้',
      'lastUpdated': 'อัปเดตล่าสุด {time}',
      'statusNormal': 'ปกติ',
      'statusCharging': 'กำลังชาร์จ',
      'statusDischarging': 'กำลังจ่ายไฟ',
      'statusLowBattery': 'แบตเตอรี่ต่ำ',
      'statusActionNeeded': 'ต้องดำเนินการ',
      'statusOffline': 'ออฟไลน์',
      'dataTitle': 'ข้อมูลพลังงาน',
      'dataSubtitle': 'แนวโน้มการผลิตและการใช้พลังงานสำหรับวางแผนรายวัน',
      'savedDataTitle': 'ข้อมูลที่บันทึกล่าสุด',
      'savedDataMessage': 'แอปยังคงแสดงกราฟก่อนหน้าเนื่องจากรีเฟรชไม่สำเร็จ',
      'metricTodayUsed': 'ใช้วันนี้',
      'metricTotalGenerated': 'ผลิตสะสม',
      'metricTotalUsed': 'ใช้สะสม',
      'monthCaption': 'เดือนนี้ {value} kWh',
      'todayTrend': 'แนวโน้มวันนี้',
      'todayTrendSubtitle': 'การผลิตจากแสงอาทิตย์เทียบกับการใช้ในบ้าน',
      'legendGeneration': 'การผลิต',
      'legendConsumption': 'การใช้',
      'alertsTitle': 'การแจ้งเตือน',
      'alertsSubtitle': 'แนวทางจัดการแบตต่ำ ความผิดปกติ และโหลดเกิน',
      'segmentCurrent': 'ปัจจุบัน',
      'segmentHistory': 'ประวัติ',
      'noAlertsTitle': 'ไม่มีการแจ้งเตือน',
      'noAlertsMessage': 'ระบบทำงานปกติ ติดตามแบตเตอรี่ก่อนค่ำ',
      'resolved': 'แก้ไขแล้ว',
      'severityWarning': 'คำเตือน',
      'severityCritical': 'วิกฤต',
      'severityInfo': 'ข้อมูล',
      'actionPrefix': 'การจัดการ: {action}',
      'daysAgo': '{count} วันที่แล้ว',
      'hoursAgo': '{count} ชม.ที่แล้ว',
      'minutesAgo': '{count} นาทีที่แล้ว',
      'profileTitle': 'ระบบของฉัน',
      'profileSubtitle': 'บัญชี อุปกรณ์ ภาษา และการแจ้งเตือน',
      'accountSignedIn': 'เข้าสู่ระบบบัญชีตัวอย่างแล้ว',
      'accountNotSignedIn': 'ยังไม่ได้เข้าสู่ระบบ',
      'otpPlaceholder': 'ตัวอย่าง OTP ทางโทรศัพท์/อีเมล',
      'signOut': 'ออกจากระบบ',
      'signIn': 'เข้าสู่ระบบ',
      'bindDevice': 'ผูกอุปกรณ์',
      'bindDeviceHintEmpty': 'สแกน QR หรือกรอกหมายเลข SN',
      'bindDeviceHintSerial': 'SN {serial}',
      'bindingReserved': 'ขั้นตอนผูกอุปกรณ์สงวนไว้สำหรับการเชื่อมต่อ API',
      'pvCapacity': 'กำลังการผลิต PV',
      'batteryCapacity': 'ความจุแบตเตอรี่',
      'firmware': 'เฟิร์มแวร์',
      'language': 'ภาษา',
      'languageSystemDefault': 'ค่าเริ่มต้นของระบบ',
      'alertNotifications': 'การแจ้งเตือน',
      'alertNotificationsSubtitle': 'แบตต่ำ ความผิดปกติ และโหลดเกิน',
      'privacyTitle': 'ความเป็นส่วนตัวและข้อตกลงผู้ใช้',
      'privacySubtitle': 'หน้าที่สงวนไว้สำหรับเตรียมเปิดตัว',
      'privacyPlaceholder': 'หน้าข้อตกลง (ตัวอย่าง)',
      'granularityDay': 'วัน',
      'granularityWeek': 'สัปดาห์',
      'granularityMonth': 'เดือน',
      'detailEnergyTitle': 'รายละเอียดพลังงาน',
      'detailPowerTitle': 'รายละเอียดกำลังไฟ',
      'detailBatteryTitle': 'รายละเอียดแบตเตอรี่',
      'detailPvPowerTitle': 'กำลังผลิตไฟ',
      'detailLoadPowerTitle': 'กำลังโหลด',
      'detailGenerationTitle': 'การผลิต',
      'detailConsumptionTitle': 'การใช้',
      'detailPeak': 'สูงสุด',
      'detailAvg': 'เฉลี่ย',
      'detailBatteryRange': 'ช่วง SOC',
      'detailBatteryLowThreshold': 'เกณฑ์แบตต่ำ (20%)',
      'errorLoadingData': 'โหลดข้อมูลล้มเหลว',
    },
    'vi': {
      'navHome': 'Trang chủ',
      'navData': 'Dữ liệu',
      'navAlerts': 'Cảnh báo',
      'navMine': 'Của tôi',
      'retry': 'Thử lại',
      'refresh': 'Làm mới',
      'dashboardTitle': 'Điện mặt trời độc lập',
      'dashboardSubtitle':
          'Trạng thái điện, pin và cảnh báo rõ ràng cho quyết định hằng ngày.',
      'demoScenario': 'Kịch bản demo',
      'weakNetworkTitle': 'Mạng yếu',
      'weakNetworkMessage':
          'Đang hiển thị dữ liệu thành công gần nhất. Kéo xuống để thử lại.',
      'remainingHours':
          'Hệ thống có thể cấp điện khoảng {hours} giờ ở mức tải hiện tại.',
      'deviceOfflineHint':
          'Thiết bị ngoại tuyến. Kiểm tra nguồn và tín hiệu của gateway.',
      'metricPvPower': 'Công suất PV',
      'metricPvPowerCaption': 'Sản lượng mặt trời hiện tại',
      'metricLoadPower': 'Công suất tải',
      'metricLoadPowerCaption': 'Nhu cầu điện trong nhà hiện tại',
      'metricBatterySoc': 'Dung lượng pin',
      'metricBatterySocCaption': 'Mức pin còn lại',
      'metricTodayGenerated': 'Hôm nay sản xuất',
      'todayUsedCaption': 'Đã dùng {value} kWh hôm nay',
      'lastUpdated': 'Cập nhật lúc {time}',
      'statusNormal': 'Bình thường',
      'statusCharging': 'Đang sạc',
      'statusDischarging': 'Đang xả',
      'statusLowBattery': 'Pin yếu',
      'statusActionNeeded': 'Cần xử lý',
      'statusOffline': 'Ngoại tuyến',
      'dataTitle': 'Dữ liệu năng lượng',
      'dataSubtitle':
          'Xu hướng sản xuất và tiêu thụ để lập kế hoạch năng lượng hằng ngày.',
      'savedDataTitle': 'Dữ liệu đã lưu gần nhất',
      'savedDataMessage':
          'Ứng dụng giữ biểu đồ trước đó vì làm mới không thành công.',
      'metricTodayUsed': 'Hôm nay đã dùng',
      'metricTotalGenerated': 'Tổng sản xuất',
      'metricTotalUsed': 'Tổng tiêu thụ',
      'monthCaption': 'Tháng {value} kWh',
      'todayTrend': 'Xu hướng hôm nay',
      'todayTrendSubtitle': 'Sản xuất mặt trời so với tiêu thụ trong nhà',
      'legendGeneration': 'Sản xuất',
      'legendConsumption': 'Tiêu thụ',
      'alertsTitle': 'Cảnh báo',
      'alertsSubtitle': 'Hành động rõ ràng cho pin yếu, lỗi và quá tải.',
      'segmentCurrent': 'Hiện tại',
      'segmentHistory': 'Lịch sử',
      'noAlertsTitle': 'Không có cảnh báo',
      'noAlertsMessage':
          'Hệ thống đang chạy bình thường. Theo dõi pin trước khi trời tối.',
      'resolved': 'Đã xử lý',
      'severityWarning': 'Cảnh báo',
      'severityCritical': 'Nghiêm trọng',
      'severityInfo': 'Thông tin',
      'actionPrefix': 'Hành động: {action}',
      'daysAgo': '{count} ngày trước',
      'hoursAgo': '{count} giờ trước',
      'minutesAgo': '{count} phút trước',
      'profileTitle': 'Hệ thống của tôi',
      'profileSubtitle': 'Tài khoản, thiết bị, ngôn ngữ và tùy chọn cảnh báo.',
      'accountSignedIn': 'Đã đăng nhập tài khoản demo',
      'accountNotSignedIn': 'Chưa đăng nhập',
      'otpPlaceholder': 'OTP qua điện thoại/email (demo)',
      'signOut': 'Đăng xuất',
      'signIn': 'Đăng nhập',
      'bindDevice': 'Liên kết thiết bị',
      'bindDeviceHintEmpty': 'Quét mã QR hoặc nhập SN',
      'bindDeviceHintSerial': 'SN {serial}',
      'bindingReserved': 'Luồng liên kết thiết bị dành cho tích hợp API.',
      'pvCapacity': 'Công suất PV',
      'batteryCapacity': 'Dung lượng pin',
      'firmware': 'Phần mềm',
      'language': 'Ngôn ngữ',
      'languageSystemDefault': 'Theo hệ thống',
      'alertNotifications': 'Thông báo cảnh báo',
      'alertNotificationsSubtitle': 'Pin yếu, lỗi và quá tải',
      'privacyTitle': 'Quyền riêng tư và thỏa thuận người dùng',
      'privacySubtitle': 'Trang dành riêng cho chuẩn bị ra mắt',
      'privacyPlaceholder': 'Trang thỏa thuận (mẫu).',
      'granularityDay': 'Ngày',
      'granularityWeek': 'Tuần',
      'granularityMonth': 'Tháng',
      'detailEnergyTitle': 'Chi tiết năng lượng',
      'detailPowerTitle': 'Chi tiết công suất',
      'detailBatteryTitle': 'Chi tiết pin',
      'detailPvPowerTitle': 'Công suất PV',
      'detailLoadPowerTitle': 'Công suất tải',
      'detailGenerationTitle': 'Sản xuất',
      'detailConsumptionTitle': 'Tiêu thụ',
      'detailPeak': 'Đỉnh',
      'detailAvg': 'TB',
      'detailBatteryRange': 'Phạm vi SOC',
      'detailBatteryLowThreshold': 'Ngưỡng pin yếu (20%)',
      'errorLoadingData': 'Không tải được dữ liệu.',
    },
    'id': {
      'navHome': 'Beranda',
      'navData': 'Data',
      'navAlerts': 'Peringatan',
      'navMine': 'Saya',
      'retry': 'Coba lagi',
      'refresh': 'Segarkan',
      'dashboardTitle': 'Surya off-grid',
      'dashboardSubtitle':
          'Status daya, baterai, dan peringatan yang jelas untuk keputusan harian.',
      'demoScenario': 'Skenario demo',
      'weakNetworkTitle': 'Jaringan lemah',
      'weakNetworkMessage':
          'Menampilkan data berhasil terakhir. Tarik ke bawah untuk mencoba lagi.',
      'remainingHours':
          'Sistem dapat memasok daya sekitar {hours} jam pada beban saat ini.',
      'deviceOfflineHint':
          'Perangkat offline. Periksa daya dan sinyal gateway.',
      'metricPvPower': 'Daya PV',
      'metricPvPowerCaption': 'Keluaran surya saat ini',
      'metricLoadPower': 'Daya beban',
      'metricLoadPowerCaption': 'Kebutuhan rumah saat ini',
      'metricBatterySoc': 'SOC baterai',
      'metricBatterySocCaption': 'Sisa level baterai',
      'metricTodayGenerated': 'Produksi hari ini',
      'todayUsedCaption': 'Terpakai {value} kWh hari ini',
      'lastUpdated': 'Diperbarui {time}',
      'statusNormal': 'Normal',
      'statusCharging': 'Mengisi',
      'statusDischarging': 'Melepas',
      'statusLowBattery': 'Baterai lemah',
      'statusActionNeeded': 'Perlu tindakan',
      'statusOffline': 'Offline',
      'dataTitle': 'Data energi',
      'dataSubtitle':
          'Tren produksi dan konsumsi untuk perencanaan energi harian.',
      'savedDataTitle': 'Data tersimpan terakhir',
      'savedDataMessage':
          'Aplikasi mempertahankan grafik sebelumnya karena penyegaran gagal.',
      'metricTodayUsed': 'Terpakai hari ini',
      'metricTotalGenerated': 'Total produksi',
      'metricTotalUsed': 'Total konsumsi',
      'monthCaption': 'Bulan {value} kWh',
      'todayTrend': 'Tren hari ini',
      'todayTrendSubtitle': 'Produksi surya vs konsumsi rumah',
      'legendGeneration': 'Produksi',
      'legendConsumption': 'Konsumsi',
      'alertsTitle': 'Peringatan',
      'alertsSubtitle':
          'Tindakan jelas untuk baterai lemah, gangguan, dan beban berlebih.',
      'segmentCurrent': 'Saat ini',
      'segmentHistory': 'Riwayat',
      'noAlertsTitle': 'Tidak ada peringatan',
      'noAlertsMessage':
          'Sistem berjalan normal. Pantau baterai sebelum malam.',
      'resolved': 'Teratasi',
      'severityWarning': 'Peringatan',
      'severityCritical': 'Kritis',
      'severityInfo': 'Info',
      'actionPrefix': 'Tindakan: {action}',
      'daysAgo': '{count} hari lalu',
      'hoursAgo': '{count} jam lalu',
      'minutesAgo': '{count} mnt lalu',
      'profileTitle': 'Sistem saya',
      'profileSubtitle': 'Akun, perangkat, bahasa, dan preferensi peringatan.',
      'accountSignedIn': 'Akun demo masuk',
      'accountNotSignedIn': 'Belum masuk',
      'otpPlaceholder': 'Placeholder OTP telepon/email untuk demo',
      'signOut': 'Keluar',
      'signIn': 'Masuk',
      'bindDevice': 'Tautkan perangkat',
      'bindDeviceHintEmpty': 'Pindai QR atau masukkan SN',
      'bindDeviceHintSerial': 'SN {serial}',
      'bindingReserved': 'Alur penautan perangkat disiapkan untuk integrasi API.',
      'pvCapacity': 'Kapasitas PV',
      'batteryCapacity': 'Kapasitas baterai',
      'firmware': 'Firmware',
      'language': 'Bahasa',
      'languageSystemDefault': 'Bawaan sistem',
      'alertNotifications': 'Notifikasi peringatan',
      'alertNotificationsSubtitle': 'Baterai lemah, gangguan, dan beban berlebih',
      'privacyTitle': 'Privasi dan perjanjian pengguna',
      'privacySubtitle': 'Halaman cadangan untuk persiapan peluncuran',
      'privacyPlaceholder': 'Placeholder halaman perjanjian.',
      'granularityDay': 'Hari',
      'granularityWeek': 'Minggu',
      'granularityMonth': 'Bulan',
      'detailEnergyTitle': 'Detail energi',
      'detailPowerTitle': 'Detail daya',
      'detailBatteryTitle': 'Detail baterai',
      'detailPvPowerTitle': 'Daya PV',
      'detailLoadPowerTitle': 'Daya beban',
      'detailGenerationTitle': 'Produksi',
      'detailConsumptionTitle': 'Konsumsi',
      'detailPeak': 'Puncak',
      'detailAvg': 'Rata-rata',
      'detailBatteryRange': 'Rentang SOC',
      'detailBatteryLowThreshold': 'Batas baterai lemah (20%)',
      'errorLoadingData': 'Gagal memuat data.',
    },
    'zh': {
      'navHome': '首页',
      'navData': '数据',
      'navAlerts': '告警',
      'navMine': '我的',
      'retry': '重试',
      'refresh': '刷新',
      'dashboardTitle': '离网光伏',
      'dashboardSubtitle': '清晰呈现发电、电池与告警状态，辅助日常决策。',
      'demoScenario': '演示场景',
      'weakNetworkTitle': '网络较弱',
      'weakNetworkMessage': '正在显示最近一次成功的数据，下拉可重试。',
      'remainingHours': '按当前负载，系统约可供电 {hours} 小时。',
      'deviceOfflineHint': '设备已离线，请检查网关电源与信号。',
      'metricPvPower': '光伏功率',
      'metricPvPowerCaption': '当前太阳能输出',
      'metricLoadPower': '负载功率',
      'metricLoadPowerCaption': '当前家庭用电需求',
      'metricBatterySoc': '电池电量',
      'metricBatterySocCaption': '剩余电量',
      'metricTodayGenerated': '今日发电',
      'todayUsedCaption': '今日已用 {value} kWh',
      'lastUpdated': '最后更新 {time}',
      'statusNormal': '正常',
      'statusCharging': '充电中',
      'statusDischarging': '放电中',
      'statusLowBattery': '电量低',
      'statusActionNeeded': '需要处理',
      'statusOffline': '离线',
      'dataTitle': '能源数据',
      'dataSubtitle': '发电与用电趋势，便于日常能源规划。',
      'savedDataTitle': '最近保存的数据',
      'savedDataMessage': '刷新失败，已保留上一次的图表。',
      'metricTodayUsed': '今日用电',
      'metricTotalGenerated': '累计发电',
      'metricTotalUsed': '累计用电',
      'monthCaption': '本月 {value} kWh',
      'todayTrend': '今日趋势',
      'todayTrendSubtitle': '太阳能发电 vs 家庭用电',
      'legendGeneration': '发电',
      'legendConsumption': '用电',
      'alertsTitle': '告警',
      'alertsSubtitle': '针对低电量、故障与过载的清晰处理建议。',
      'segmentCurrent': '当前',
      'segmentHistory': '历史',
      'noAlertsTitle': '暂无告警',
      'noAlertsMessage': '系统运行正常，入夜前请留意电池电量。',
      'resolved': '已解决',
      'severityWarning': '警告',
      'severityCritical': '严重',
      'severityInfo': '提示',
      'actionPrefix': '处理：{action}',
      'daysAgo': '{count} 天前',
      'hoursAgo': '{count} 小时前',
      'minutesAgo': '{count} 分钟前',
      'profileTitle': '我的系统',
      'profileSubtitle': '账号、设备、语言与告警设置。',
      'accountSignedIn': '已登录演示账号',
      'accountNotSignedIn': '未登录',
      'otpPlaceholder': '演示用手机/邮箱 OTP 占位',
      'signOut': '退出登录',
      'signIn': '登录',
      'bindDevice': '绑定设备',
      'bindDeviceHintEmpty': '扫描二维码或输入 SN',
      'bindDeviceHintSerial': 'SN {serial}',
      'bindingReserved': '设备绑定流程预留给 API 接入。',
      'pvCapacity': '光伏容量',
      'batteryCapacity': '电池容量',
      'firmware': '固件',
      'language': '语言',
      'languageSystemDefault': '跟随系统',
      'alertNotifications': '告警通知',
      'alertNotificationsSubtitle': '低电量、故障与过载',
      'privacyTitle': '隐私与用户协议',
      'privacySubtitle': '为上线准备预留的页面',
      'privacyPlaceholder': '协议页占位。',
      'granularityDay': '日',
      'granularityWeek': '周',
      'granularityMonth': '月',
      'detailEnergyTitle': '能源详情',
      'detailPowerTitle': '功率详情',
      'detailBatteryTitle': '电池详情',
      'detailPvPowerTitle': '光伏功率',
      'detailLoadPowerTitle': '负载功率',
      'detailGenerationTitle': '发电量',
      'detailConsumptionTitle': '用电量',
      'detailPeak': '峰值',
      'detailAvg': '均值',
      'detailBatteryRange': 'SOC 范围',
      'detailBatteryLowThreshold': '低电量阈值（20%）',
      'errorLoadingData': '数据加载失败。',
    },
    'ja': {
      'navHome': 'ホーム',
      'navData': 'データ',
      'navAlerts': 'アラート',
      'navMine': 'マイページ',
      'retry': '再試行',
      'refresh': '更新',
      'dashboardTitle': 'オフグリッド太陽光',
      'dashboardSubtitle': '電力・バッテリー・アラートの状態を日々の判断に役立てましょう。',
      'demoScenario': 'デモシナリオ',
      'weakNetworkTitle': 'ネットワーク弱い',
      'weakNetworkMessage': '最後に成功したデータを表示しています。下に引いて再試行してください。',
      'remainingHours': '現在の負荷で約 {hours} 時間給電できます。',
      'deviceOfflineHint': 'デバイスがオフラインです。ゲートウェイの電源と信号を確認してください。',
      'metricPvPower': 'PV出力',
      'metricPvPowerCaption': '現在の太陽光出力',
      'metricLoadPower': '負荷電力',
      'metricLoadPowerCaption': '現在の家庭消費',
      'metricBatterySoc': 'バッテリー残量',
      'metricBatterySocCaption': '残りバッテリーレベル',
      'metricTodayGenerated': '本日発電量',
      'todayUsedCaption': '本日 {value} kWh 消費',
      'lastUpdated': '最終更新 {time}',
      'statusNormal': '正常',
      'statusCharging': '充電中',
      'statusDischarging': '放電中',
      'statusLowBattery': 'バッテリー低下',
      'statusActionNeeded': '対応が必要',
      'statusOffline': 'オフライン',
      'dataTitle': 'エネルギーデータ',
      'dataSubtitle': '日々のエネルギー計画のための発電・消費傾向。',
      'savedDataTitle': '最後に保存したデータ',
      'savedDataMessage': '更新に失敗したため、前回のグラフを保持しています。',
      'metricTodayUsed': '本日消費量',
      'metricTotalGenerated': '累計発電量',
      'metricTotalUsed': '累計消費量',
      'monthCaption': '今月 {value} kWh',
      'todayTrend': '本日の推移',
      'todayTrendSubtitle': '太陽光発電 vs 家庭消費',
      'legendGeneration': '発電',
      'legendConsumption': '消費',
      'alertsTitle': 'アラート',
      'alertsSubtitle': '低バッテリー・故障・過負荷への明確な対処。',
      'segmentCurrent': '現在',
      'segmentHistory': '履歴',
      'noAlertsTitle': 'アラートなし',
      'noAlertsMessage': 'システムは正常稼働中。夜間前にバッテリーを確認してください。',
      'resolved': '解決済み',
      'severityWarning': '警告',
      'severityCritical': '重大',
      'severityInfo': '情報',
      'actionPrefix': '対処: {action}',
      'daysAgo': '{count}日前',
      'hoursAgo': '{count}時間前',
      'minutesAgo': '{count}分前',
      'profileTitle': 'マイシステム',
      'profileSubtitle': 'アカウント・デバイス・言語・アラート設定。',
      'accountSignedIn': 'デモアカウントでログイン中',
      'accountNotSignedIn': '未ログイン',
      'otpPlaceholder': '電話/メール OTP デモ用プレースホルダー',
      'signOut': 'ログアウト',
      'signIn': 'ログイン',
      'bindDevice': 'デバイス登録',
      'bindDeviceHintEmpty': 'QRコードをスキャンまたはSNを入力',
      'bindDeviceHintSerial': 'SN {serial}',
      'bindingReserved': 'デバイス登録はAPI連携のために予約されています。',
      'pvCapacity': 'PV容量',
      'batteryCapacity': 'バッテリー容量',
      'firmware': 'ファームウェア',
      'language': '言語',
      'languageSystemDefault': 'システム設定に従う',
      'alertNotifications': 'アラート通知',
      'alertNotificationsSubtitle': '低バッテリー・故障・過負荷',
      'privacyTitle': 'プライバシーとユーザー契約',
      'privacySubtitle': '公開準備のための予約ページ',
      'privacyPlaceholder': '契約ページのプレースホルダー。',
      'granularityDay': '日',
      'granularityWeek': '週',
      'granularityMonth': '月',
      'detailEnergyTitle': 'エネルギー詳細',
      'detailPowerTitle': '電力フロー詳細',
      'detailBatteryTitle': 'バッテリー詳細',
      'detailPvPowerTitle': 'PV電力',
      'detailLoadPowerTitle': '負荷電力',
      'detailGenerationTitle': '発電量',
      'detailConsumptionTitle': '消費量',
      'detailPeak': 'ピーク',
      'detailAvg': '平均',
      'detailBatteryRange': 'SOC範囲',
      'detailBatteryLowThreshold': '低バッテリー閾値（20%）',
      'errorLoadingData': 'データの読み込みに失敗しました。',
    },
    'ko': {
      'navHome': '홈',
      'navData': '데이터',
      'navAlerts': '알림',
      'navMine': '내 정보',
      'retry': '재시도',
      'refresh': '새로 고침',
      'dashboardTitle': '독립형 태양광',
      'dashboardSubtitle': '전력, 배터리, 알림 상태를 한눈에 파악하여 매일의 결정에 활용하세요.',
      'demoScenario': '데모 시나리오',
      'weakNetworkTitle': '네트워크 약함',
      'weakNetworkMessage': '마지막으로 성공한 데이터를 표시 중입니다. 아래로 당겨 재시도하세요.',
      'remainingHours': '현재 부하 기준으로 약 {hours}시간 공급 가능합니다.',
      'deviceOfflineHint': '기기가 오프라인입니다. 게이트웨이 전원과 신호를 확인하세요.',
      'metricPvPower': 'PV 전력',
      'metricPvPowerCaption': '현재 태양광 출력',
      'metricLoadPower': '부하 전력',
      'metricLoadPowerCaption': '현재 가정 수요',
      'metricBatterySoc': '배터리 잔량',
      'metricBatterySocCaption': '남은 배터리 수준',
      'metricTodayGenerated': '오늘 발전량',
      'todayUsedCaption': '오늘 {value} kWh 사용',
      'lastUpdated': '마지막 업데이트 {time}',
      'statusNormal': '정상',
      'statusCharging': '충전 중',
      'statusDischarging': '방전 중',
      'statusLowBattery': '배터리 부족',
      'statusActionNeeded': '조치 필요',
      'statusOffline': '오프라인',
      'dataTitle': '에너지 데이터',
      'dataSubtitle': '일일 에너지 계획을 위한 발전 및 소비 추세.',
      'savedDataTitle': '최근 저장된 데이터',
      'savedDataMessage': '새로 고침에 실패하여 이전 차트를 유지했습니다.',
      'metricTodayUsed': '오늘 사용량',
      'metricTotalGenerated': '총 발전량',
      'metricTotalUsed': '총 사용량',
      'monthCaption': '이번 달 {value} kWh',
      'todayTrend': '오늘 추세',
      'todayTrendSubtitle': '태양광 발전 vs 가정 소비',
      'legendGeneration': '발전',
      'legendConsumption': '소비',
      'alertsTitle': '알림',
      'alertsSubtitle': '배터리 부족, 고장, 과부하에 대한 명확한 조치.',
      'segmentCurrent': '현재',
      'segmentHistory': '기록',
      'noAlertsTitle': '알림 없음',
      'noAlertsMessage': '시스템이 정상 작동 중입니다. 밤이 되기 전에 배터리를 확인하세요.',
      'resolved': '해결됨',
      'severityWarning': '경고',
      'severityCritical': '심각',
      'severityInfo': '정보',
      'actionPrefix': '조치: {action}',
      'daysAgo': '{count}일 전',
      'hoursAgo': '{count}시간 전',
      'minutesAgo': '{count}분 전',
      'profileTitle': '내 시스템',
      'profileSubtitle': '계정, 기기, 언어 및 알림 기본 설정.',
      'accountSignedIn': '데모 계정으로 로그인됨',
      'accountNotSignedIn': '로그인 안 됨',
      'otpPlaceholder': '데모용 전화/이메일 OTP 자리 표시자',
      'signOut': '로그아웃',
      'signIn': '로그인',
      'bindDevice': '기기 등록',
      'bindDeviceHintEmpty': 'QR 코드 스캔 또는 SN 입력',
      'bindDeviceHintSerial': 'SN {serial}',
      'bindingReserved': '기기 등록 흐름은 API 연동을 위해 예약되어 있습니다.',
      'pvCapacity': 'PV 용량',
      'batteryCapacity': '배터리 용량',
      'firmware': '펌웨어',
      'language': '언어',
      'languageSystemDefault': '시스템 기본값',
      'alertNotifications': '알림',
      'alertNotificationsSubtitle': '배터리 부족, 고장, 과부하',
      'privacyTitle': '개인정보 및 사용자 계약',
      'privacySubtitle': '출시 준비를 위한 예약 페이지',
      'privacyPlaceholder': '계약 페이지 자리 표시자.',
      'granularityDay': '일',
      'granularityWeek': '주',
      'granularityMonth': '월',
      'detailEnergyTitle': '에너지 상세',
      'detailPowerTitle': '전력 흐름 상세',
      'detailBatteryTitle': '배터리 상세',
      'detailPvPowerTitle': 'PV 전력',
      'detailLoadPowerTitle': '부하 전력',
      'detailGenerationTitle': '발전량',
      'detailConsumptionTitle': '소비량',
      'detailPeak': '최대값',
      'detailAvg': '평균',
      'detailBatteryRange': 'SOC 범위',
      'detailBatteryLowThreshold': '낮은 배터리 임계값 (20%)',
      'errorLoadingData': '데이터를 불러오지 못했습니다.',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
