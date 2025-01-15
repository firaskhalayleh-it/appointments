import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotifications =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';
  static const String _channelDesc = 'Important notifications channel';

  Future<void> init() async {
    try {
      await _initializeLocalNotifications();
      await _requestPermissions();
      await _setupMessageHandling();
      await _subscribeToTopics();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    final androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.max,
      playSound: true,
    );

    await _flutterLocalNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _setupMessageHandling() async {
    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background messages when app is opened
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Check for initial message (app opened from terminated state)
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  Future<void> _subscribeToTopics() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        final userData = userDoc.data();

        if (userData != null && userData['role'] == 'admin') {
          final cities = List<String>.from(userData['cities'] ?? []);
          for (final city in cities) {
            await _fcm.subscribeToTopic('appointments_${city.toLowerCase()}');
            debugPrint(
                'Subscribed to topic: appointments_${city.toLowerCase()}');
          }
        }
      }
    } catch (e) {
      debugPrint('Error subscribing to topics: $e');
    }
  }

  void _handleNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      final route = response.payload;
      Get.toNamed(route!);
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Got foreground message: ${message.messageId}');

    if (message.notification != null) {
      final androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.max,
        priority: Priority.high,
      );

      final iosDetails = const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotifications.show(
        message.hashCode,
        message.notification!.title,
        message.notification!.body,
        details,
        payload: message.data['route'],
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    if (message.data['route'] != null) {
      Get.toNamed(message.data['route']);
    }
  }

  Future<void> _requestPermissions() async {
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  // Send notification to specific city topic
  Future<void> sendAppointmentNotification({
    required String city,
    required String customerName,
    String? appointmentId,
    String notificationType = 'new',
  }) async {
    try {
      final topicName = 'appointments_${city.toLowerCase()}';

      String title = 'حجز جديد في $city';
      String body = 'تم إضافة حجز جديد للعميل $customerName';

      switch (notificationType) {
        case 'new':
          break;
        case 'updated':
          title = 'تحديث حجز في $city';
          body = 'تم تحديث حجز العميل $customerName';
          break;
        case 'cancelled':
          title = 'إلغاء حجز في $city';
          body = 'تم إلغاء حجز العميل $customerName';
          break;
        default:
          title = 'إشعار حجز في $city';
          body = 'تحديث لحجز العميل $customerName';
      }

      // Create the notification message
      final message = RemoteMessage(
          data: {
            'type': 'appointment',
            'appointmentId': appointmentId ?? '',
            'city': city,
            'route': appointmentId != null
                ? '/appointments/$appointmentId'
                : '/appointments',
            'notificationType': notificationType,
          },
          notification: RemoteNotification(
            title: title,
            body: body,
            android: const AndroidNotification(
              channelId: _channelId,
              priority: AndroidNotificationPriority.highPriority,
            ),
          ));

      // If we're sending to our own device, show it immediately
      _handleForegroundMessage(message);
    } catch (e) {
      debugPrint('Error sending notification: $e');
      rethrow;
    }
  }
}
