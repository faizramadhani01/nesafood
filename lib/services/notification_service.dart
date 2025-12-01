import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // Singleton pattern agar service ini bisa dipanggil dari mana saja dengan satu instance
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // --- 1. Inisialisasi Service ---
  Future<void> init() async {
    // Pengaturan untuk Android
    // Pastikan icon 'ic_launcher' ada di folder android/app/src/main/res/mipmap-*/
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Pengaturan untuk iOS (Meminta izin dasar)
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

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Logika jika notifikasi diklik (opsional, bisa diarahkan ke halaman history)
        print("Notifikasi diklik: ${response.payload}");
      },
    );
  }

  // --- 2. Tampilkan Notifikasi "Pesanan Siap" ---
  Future<void> showOrderReadyNotification(
    String orderId,
    String menuName,
  ) async {
    // Gaya Teks Panjang (BigTextStyle) agar pesan tidak terpotong
    final BigTextStyleInformation
    bigTextStyleInformation = BigTextStyleInformation(
      'Hore! Pesananmu <b>$menuName</b> sudah selesai dimasak dan siap diambil. Yuk segera ke kantin dan tunjukkan pesananmu sebelum dingin! 🍜',
      htmlFormatBigText: true,
      contentTitle: 'Pesanan Siap Diambil! 🍽️',
      htmlFormatContentTitle: true,
      summaryText: 'Status Update',
      htmlFormatSummaryText: true,
    );

    // Detail Spesifik Android
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'order_status_channel_id', // ID Channel (harus unik)
          'Status Pesanan', // Nama Channel yang muncul di pengaturan HP
          channelDescription: 'Notifikasi update status pesanan makanan',
          importance: Importance.max, // MAX agar muncul pop-up (heads-up)
          priority: Priority.high, // HIGH agar bunyi dan getar
          playSound: true,
          enableVibration: true,
          styleInformation:
              bigTextStyleInformation, // Terapkan gaya teks panjang
        );

    // Detail Spesifik iOS
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    // Tampilkan Notifikasi
    // Gunakan hashCode dari orderId sebagai ID notifikasi agar setiap pesanan punya notif sendiri
    await flutterLocalNotificationsPlugin.show(
      orderId.hashCode,
      'Pesanan Siap!', // Judul default (akan tertimpa oleh contentTitle di atas untuk Android)
      'Pesanan $menuName sudah siap diambil.', // Body default
      platformChannelSpecifics,
      payload: orderId, // Data tambahan jika notif diklik
    );
  }
}
