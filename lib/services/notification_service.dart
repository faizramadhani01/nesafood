import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:universal_html/html.dart' as html; // Khusus Web

class NotificationService {
  // Singleton Pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // --- INISIALISASI ---
  Future<void> init() async {
    if (kIsWeb) {
      // Minta izin langsung di Web
      html.Notification.requestPermission();
      return;
    }

    // Setup Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Setup iOS
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // --- 1. UNTUK USER: Notifikasi "Pesanan Siap" ---
  Future<void> showOrderReadyNotification(
    String orderId,
    String menuName,
  ) async {
    await _showNotification(
      id: orderId.hashCode,
      title: 'Pesanan Siap! 🍽️',
      body:
          'Hore! Pesananmu $menuName sudah selesai dimasak. Yuk ambil sekarang!',
      channelId: 'order_status_channel',
      channelName: 'Status Pesanan',
    );
  }

  // --- 2. UNTUK ADMIN: Notifikasi "Pesanan Baru Masuk" ---
  Future<void> showNewOrderNotification(
    String orderId,
    String tableNumber,
  ) async {
    await _showNotification(
      id: orderId.hashCode,
      title: 'Pesanan Baru Masuk! 🔔',
      body: 'Ada pelanggan baru di Meja $tableNumber. Cek pesanan sekarang!',
      channelId: 'admin_order_channel',
      channelName: 'Pesanan Masuk Admin',
    );
  }

  // --- HELPER: Logic Tampilan Web vs Native ---
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
  }) async {
    // A. JIKA DI WEB
    if (kIsWeb) {
      if (html.Notification.permission == 'granted') {
        // Tampilkan notifikasi browser standar
        html.Notification(title, body: body, icon: 'icons/Icon-192.png');
      } else {
        html.Notification.requestPermission();
      }
      return;
    }

    // B. JIKA DI HP (ANDROID/IOS)
    final BigTextStyleInformation bigTextStyleInformation =
        BigTextStyleInformation(
          body,
          htmlFormatBigText: false,
          contentTitle: title,
          htmlFormatContentTitle: false,
          summaryText: 'Nesafood Update',
          htmlFormatSummaryText: false,
        );

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: bigTextStyleInformation,
        );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
    );
  }
}
