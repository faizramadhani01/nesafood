import 'package:flutter/foundation.dart'; // Untuk kIsWeb
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:universal_html/html.dart' as html; // Khusus Web

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) {
      // --- SETUP KHUSUS WEB ---
      // Minta izin langsung saat init di Web
      html.Notification.requestPermission().then((permission) {
        if (permission == 'granted') {
          print("Izin Notifikasi Web Diberikan");
        }
      });
      return;
    }

    // --- SETUP UNTUK HP (ANDROID/IOS APP) ---
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

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

  Future<void> showOrderReadyNotification(
    String orderId,
    String menuName,
  ) async {
    final title = 'Pesanan Siap! 🍽️';
    final body =
        'Hore! Pesananmu $menuName sudah selesai dimasak. Yuk ambil sekarang!';

    if (kIsWeb) {
      // --- TAMPILKAN NOTIFIKASI DI WEB ---
      if (html.Notification.permission == 'granted') {
        html.Notification(title, body: body, icon: 'icons/Icon-192.png');
      } else {
        // Coba minta izin lagi jika belum ada
        html.Notification.requestPermission();
      }
      return;
    }

    // --- TAMPILKAN NOTIFIKASI DI HP (ANDROID/IOS APP) ---
    final BigTextStyleInformation
    bigTextStyleInformation = BigTextStyleInformation(
      'Hore! Pesananmu <b>$menuName</b> sudah selesai dimasak dan siap diambil. Yuk segera ke kantin dan tunjukkan pesananmu sebelum dingin! 🍜',
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: 'Status Update',
      htmlFormatSummaryText: true,
    );

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'order_status_channel_id',
          'Status Pesanan',
          channelDescription: 'Notifikasi update status pesanan makanan',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          styleInformation: bigTextStyleInformation,
        );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      orderId.hashCode,
      title,
      body,
      platformChannelSpecifics,
    );
  }
}
