import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permissions for iOS and Android
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('User granted permission');
      }
    }

    // Handle messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Foreground message: ${message.data}');
      }
      handleNotificationRedirect(message);
    });

    // Handle messages when the app is in the background and opened by user
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Background message opened: ${message.data}');
      }
      handleNotificationRedirect(message);
    });

    // Handle initial message if the app was opened from a terminated state
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      handleNotificationRedirect(initialMessage);
    }
  }

  void handleNotificationRedirect(RemoteMessage message) async {
    final Map<String, dynamic> data = message.data;

    if (data['type'] == 'app_update') {
      String? url;
      if (Platform.isAndroid) {
        url = data['android_url'];
      } else if (Platform.isIOS) {
        url = data['ios_url'];
      }

      if (url != null && url.isNotEmpty) {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } else {
          if (kDebugMode) {
            print('Could not launch $url');
          }
        }
      }
    }
  }
}
