import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotif = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'bachakhana_deals',
    'BachaKhana Deals',
    description: 'New deals aur order updates',
    importance: Importance.high,
  );

  /// Initialize — call in main()
  static Future<void> init() async {
    // Request permission
    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    // Local notifications setup
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _localNotif.initialize(
      const InitializationSettings(
        android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotifTap,
    );

    // Create Android channel
    await _localNotif
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_channel);

    // FCM foreground handler
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // Get FCM token (save to Firestore for targeted notifications)
    final token = await _messaging.getToken();
    print('FCM Token: $token');
  }

  static void _onForegroundMessage(RemoteMessage message) {
    final notif = message.notification;
    if (notif == null) return;

    _localNotif.show(
      notif.hashCode,
      notif.title,
      notif.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id, _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true, presentBadge: true, presentSound: true),
      ),
    );
  }

  static void _onNotifTap(NotificationResponse response) {
    // Handle notification tap — navigate to relevant screen
    print('Notification tapped: ${response.payload}');
  }

  /// Show local notification (for order confirmation)
  static Future<void> showOrderConfirmed(String restaurantName, String orderId) async {
    await _localNotif.show(
      orderId.hashCode,
      '✅ Order Confirm Ho Gayi!',
      '$restaurantName se aaj Surprise Bag pickup karein.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id, _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  /// Show deal alert
  static Future<void> showDealAlert(String restName, int bagsLeft) async {
    await _localNotif.show(
      restName.hashCode,
      '⚡ Jaldi Karein! Sirf $bagsLeft bags baki!',
      '$restName — Aaj raat tak available.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id, _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  /// Save FCM token to Firestore (for server-side push)
  static Future<void> saveToken(String userId) async {
    final token = await _messaging.getToken();
    if (token == null) return;
    // Save via Firestore
    // await FirebaseFirestore.instance
    //   .collection('users').doc(userId)
    //   .update({'fcmToken': token});
  }
}
