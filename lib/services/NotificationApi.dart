import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:chat_app/main.dart'; // To access navigatorKey
import 'package:chat_app/Screen/AppScreen/ChatPage.dart'; // Your chat page

// Handle background push messages
@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('🔔 Background Chat Notification');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Payload: ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  // Android Notification Channel for chat messages
  final _androidChannel = const AndroidNotificationChannel(
    'chat_messages', // ID
    'Chat Messages', // Name
    description: 'This channel is used for chat message notifications',
    importance: Importance.high,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  // Handle notification tap - navigate to specific chat
  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    // Extract chat data from notification payload
    final data = message.data;
    if (data.containsKey('receiverID') &&
        data.containsKey('receiverName') &&
        data.containsKey('receiverImage') &&
        data.containsKey('receiverEmail')) {

      // Navigate to ChatPage with the sender's details
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => ChatPage(
            receiverName: data['receiverName'],
            receiverImage: data['receiverImage'],
            receiverID: data['receiverID'],
            receiverEmail: data['receiverEmail'],
          ),
        ),
      );
    }
  }

  // Initialize Push Notifications
  Future initPushNotifications() async {
    // Set foreground notification behavior
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle app opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    // Handle app opened from background
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;

      // Show local notification for chat messages
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });
  }

  // Setup Local Notifications
  Future initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null) {
          final message = RemoteMessage.fromMap(jsonDecode(details.payload!));
          handleMessage(message);
        }
      },
    );

    // Register Android notification channel
    final platform = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (platform != null) {
      await platform.createNotificationChannel(_androidChannel);
    }
  }

  // Get FCM Token for the current user
  Future<String?> getFCMToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      print('📱 FCM Token: $token');
      return token;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  // Initialize everything
  Future<void> initNotifications() async {
    try {
      // Request permission
      await _firebaseMessaging.requestPermission();

      // Initialize local notifications first
      await initLocalNotifications();

      // Then initialize push notifications
      await initPushNotifications();

      // Get FCM token
      await getFCMToken();

    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }
}