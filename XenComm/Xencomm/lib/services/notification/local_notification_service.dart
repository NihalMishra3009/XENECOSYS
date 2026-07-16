import 'package:flutter/material.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  Future<void> showMessageReceivedNotification({required String title, required String message}) async {
    // placeholder for native/local notifications later
    debugPrint('Notification: $title - $message');
  }

  Future<void> showEmergencyAlert({required String alertType, required String location}) async {
    debugPrint('Emergency Alert: $alertType at $location');
  }

  Future<void> showSyncCompleteNotification(int messageCount) async {
    debugPrint('Sync complete: $messageCount messages');
  }
}
