import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ── Notification channel IDs ──
  static const String _inquiryChannelId = 'inquiries';
  static const String _chatChannelId = 'chat_messages';
  static const String _generalChannelId = 'general';

  // ── Initialize ──
  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);

    await _createChannels();
  }

  Future<void> _createChannels() async {
    const inquiryChannel = AndroidNotificationChannel(
      _inquiryChannelId,
      'Inquiries',
      description: 'Notifications for new inquiries and status updates',
      importance: Importance.high,
      playSound: true,
    );

    const chatChannel = AndroidNotificationChannel(
      _chatChannelId,
      'Chat Messages',
      description: 'Notifications for new chat messages',
      importance: Importance.high,
      playSound: true,
    );

    const generalChannel = AndroidNotificationChannel(
      _generalChannelId,
      'General',
      description: 'General app notifications',
      importance: Importance.defaultImportance,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(inquiryChannel);
    await androidPlugin?.createNotificationChannel(chatChannel);
    await androidPlugin?.createNotificationChannel(generalChannel);
  }

  // ── Request permissions ──
  Future<bool> requestPermission() async {
    // Android 13+
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final androidResult = await androidPlugin?.requestNotificationsPermission();

    // iOS
    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final iosResult = await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    return androidResult ?? iosResult ?? true;
  }

  // ── Show a notification ──
  Future<void> _show({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, body, details);
  }

  // ────────────────────────────────────────────────────────────────
  // PUBLIC METHODS
  // ────────────────────────────────────────────────────────────────

  // ── New inquiry received (shown to owner) ──
  Future<void> showNewInquiry({
    required String customerName,
    required String listingTitle,
  }) async {
    await _show(
      id: 1001,
      title: 'New inquiry received',
      body: '$customerName is interested in "$listingTitle"',
      channelId: _inquiryChannelId,
      channelName: 'Inquiries',
    );
  }

  // ── Inquiry accepted (shown to customer) ──
  Future<void> showInquiryAccepted({required String listingTitle}) async {
    await _show(
      id: 1002,
      title: 'Inquiry accepted! 🎉',
      body:
          'Your inquiry for "$listingTitle" was accepted. Open the app to chat with the owner.',
      channelId: _inquiryChannelId,
      channelName: 'Inquiries',
    );
  }

  // ── Inquiry declined (shown to customer) ──
  Future<void> showInquiryDeclined({
    required String listingTitle,
    String? reason,
  }) async {
    await _show(
      id: 1003,
      title: 'Inquiry update',
      body: reason != null
          ? 'Your inquiry for "$listingTitle" was declined. Reason: $reason'
          : 'Your inquiry for "$listingTitle" was declined.',
      channelId: _inquiryChannelId,
      channelName: 'Inquiries',
    );
  }

  // ── New chat message ──
  Future<void> showNewMessage({
    required String senderName,
    required String message,
    required String listingTitle,
  }) async {
    await _show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: senderName,
      body: message.isEmpty ? '📷 Photo' : message,
      channelId: _chatChannelId,
      channelName: 'Chat Messages',
    );
  }

  // ── Cancel all notifications ──
  Future<void> cancelAll() async => await _plugin.cancelAll();

  // ── Cancel a specific notification ──
  Future<void> cancel(int id) async => await _plugin.cancel(id);
}
