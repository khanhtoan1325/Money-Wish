import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin? _notifications =
      kIsWeb ? null : FlutterLocalNotificationsPlugin();
  
  bool _initialized = false;

  /// Khởi tạo notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Không hỗ trợ trên web
    if (kIsWeb || _notifications == null) {
      _initialized = true;
      return;
    }

    // Khởi tạo timezone database
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

    // Cấu hình Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Cấu hình iOS
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications!.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  /// Xử lý khi user tap vào notification
  void _onNotificationTapped(NotificationResponse response) {
    // Có thể navigate đến screen tương ứng dựa vào payload
    // TODO: Implement navigation logic
  }

  /// Kiểm tra notification có được bật không
  Future<bool> isNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notification_enabled') ?? true; // Mặc định là true
  }

  /// Bật/tắt notifications
  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_enabled', enabled);
  }

  /// Gửi notification ngay lập tức
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb || _notifications == null) return;
    final plugin = _notifications;
    if (plugin == null) return;
    
    final enabled = await isNotificationEnabled();
    if (!enabled) return;

    const androidDetails = AndroidNotificationDetails(
      'budget_channel',
      'Budget Notifications',
      channelDescription: 'Thông báo về ngân sách và chi tiêu',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await plugin.show(id, title, body, details, payload: payload);
  }

  /// Lên lịch notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (kIsWeb || _notifications == null) return;
    final plugin = _notifications;
    if (plugin == null) return;
    
    final enabled = await isNotificationEnabled();
    if (!enabled) return;

    if (scheduledDate.isBefore(DateTime.now())) {
      return; // Không lên lịch cho thời gian đã qua
    }

    const androidDetails = AndroidNotificationDetails(
      'budget_channel',
      'Budget Notifications',
      channelDescription: 'Thông báo về ngân sách và chi tiêu',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Lên lịch notification lặp lại hàng ngày
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required Time time,
    String? payload,
  }) async {
    if (kIsWeb || _notifications == null) return;
    final plugin = _notifications;
    if (plugin == null) return;
    
    final enabled = await isNotificationEnabled();
    if (!enabled) return;

    const androidDetails = AndroidNotificationDetails(
      'daily_reminder_channel',
      'Daily Reminders',
      channelDescription: 'Nhắc nhở hàng ngày về chi tiêu',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(time.hour, time.minute),
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Lên lịch notification lặp lại hàng tuần
  Future<void> scheduleWeeklyNotification({
    required int id,
    required String title,
    required String body,
    required Day day,
    required Time time,
    String? payload,
  }) async {
    if (kIsWeb || _notifications == null) return;
    final plugin = _notifications;
    if (plugin == null) return;
    
    final enabled = await isNotificationEnabled();
    if (!enabled) return;

    const androidDetails = AndroidNotificationDetails(
      'weekly_summary_channel',
      'Weekly Summary',
      channelDescription: 'Tổng kết chi tiêu hàng tuần',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfDayOfWeek(day, time.hour, time.minute),
      details,
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  /// Hủy notification theo ID
  Future<void> cancelNotification(int id) async {
    if (kIsWeb || _notifications == null) return;
    final plugin = _notifications;
    if (plugin == null) return;
    await plugin.cancel(id);
  }

  /// Hủy tất cả notifications
  Future<void> cancelAllNotifications() async {
    if (kIsWeb || _notifications == null) return;
    final plugin = _notifications;
    if (plugin == null) return;
    await plugin.cancelAll();
  }

  /// Hủy tất cả notifications trước khi đăng xuất hoặc tắt notification
  Future<void> clearAllScheduledNotifications() async {
    if (kIsWeb || _notifications == null) return;
    final plugin = _notifications;
    if (plugin == null) return;
    await plugin.cancelAll();
  }

  /// Helper: Tính thời gian kế tiếp của một giờ cụ thể
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Helper: Tính thời gian kế tiếp của một ngày trong tuần
  tz.TZDateTime _nextInstanceOfDayOfWeek(Day day, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Tìm ngày trong tuần tiếp theo
    while (scheduledDate.weekday != day.value || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Notification ID constants
  static const int dailyReminderId = 1;
  static const int weeklySummaryId = 2;
  static const int budgetWarning80Id = 100;
  static const int budgetWarning90Id = 101;
  static const int budgetWarning100Id = 102;
  static const int budgetExpiredId = 200;
}

/// Enum cho các ngày trong tuần
enum Day {
  monday(DateTime.monday),
  tuesday(DateTime.tuesday),
  wednesday(DateTime.wednesday),
  thursday(DateTime.thursday),
  friday(DateTime.friday),
  saturday(DateTime.saturday),
  sunday(DateTime.sunday);

  const Day(this.value);
  final int value;
}

/// Class đại diện cho thời gian (giờ, phút)
class Time {
  final int hour;
  final int minute;

  Time(this.hour, this.minute);

  factory Time.fromDateTime(DateTime dateTime) {
    return Time(dateTime.hour, dateTime.minute);
  }

  @override
  String toString() => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

