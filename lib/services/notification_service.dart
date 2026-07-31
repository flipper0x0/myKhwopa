import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';

// Top-level / static background messaging handler for FCM.
// Must be top-level and have @pragma('vm:entry-point') so it runs natively in the background.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    // 1. Android & iOS Local Notifications settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.payload != null && details.payload!.isNotEmpty) {
          try {
            final Map<String, dynamic> data = jsonDecode(details.payload!);
            _handleNotificationClick(data);
          } catch (e) {
            debugPrint("FCM: Failed to parse notification response payload: $e");
          }
        }
      },
    );

    // 2. Initialize FCM Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Create high-importance Android channel for Foreground push notices
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important push notifications.',
      importance: Importance.max,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Setup foreground presentation options
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 3. FOREGROUND NOTIFICATIONS LISTENER
    // Shows a local notification banner when app is actively open
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _notifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });

    // 4. BACKGROUND CLICK LISTENER: When app is opened from a background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App opened from background via FCM: ${message.notification?.title}');
      _handleNotificationClick(message.data);
    });

    // 5. Initialize FCM background subscriptions asynchronously (does not block offline startup)
    _initFCMInBackground();
  }


  /// Handles clicking on a push or local notification.
  /// 1. If payload contains a 'url', launches it externally (PDF, notice links, website, etc.).
  /// 2. If payload contains 'section' or 'screen' set to 'articles'/'resources', brings user to Resources tab.
  /// Supports delayed execution when the app is booted from a terminated state to prevent null navigator errors.
  Future<void> _handleNotificationClick(Map<String, dynamic> data) async {
    debugPrint("FCM: Handling notification click with data: $data");

    final String? webUrl = data['url']?.toString();
    final String? targetSection = data['section']?.toString() ?? data['screen']?.toString();
    final String lowerSection = targetSection?.trim().toLowerCase() ?? '';

    // If there is no valid target action (no URL and no target section), do nothing
    if ((webUrl == null || webUrl.isEmpty) && lowerSection.isEmpty) {
      return;
    }

    if (navigatorKey.currentState == null) {
      debugPrint("FCM: Navigator state is null (app is still booting). Scheduling background check...");
      int checkCount = 0;
      Timer.periodic(const Duration(milliseconds: 200), (timer) {
        checkCount++;
        if (navigatorKey.currentState != null) {
          timer.cancel();
          _performNavigation(targetSection, webUrl);
        } else if (checkCount >= 25) { // Timeout after 5 seconds
          timer.cancel();
          debugPrint("FCM: Navigator initialization timed out.");
        }
      });
    } else {
      _performNavigation(targetSection, webUrl);
    }
  }

  /// Performs the actual redirect actions once the navigation stack is initialized.
  Future<void> _performNavigation(String? targetSection, String? webUrl) async {
    // A. Check if the payload contains a direct web URL (open in browser)
    if (webUrl != null && webUrl.isNotEmpty) {
      final Uri uri = Uri.parse(webUrl);
      try {
        // Direct launchUrl without canLaunchUrl bypasses Android 11+ package visibility restrictions!
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint("FCM: Failed to launch external URL: $e");
      }
      return;
    }

    // B. Dynamically map targetSection to its corresponding bottom navigation tab index!
    int? targetTabIndex;
    final String lowerSection = targetSection?.trim().toLowerCase() ?? '';

    if (lowerSection == 'home' || lowerSection == 'dashboard') {
      targetTabIndex = 0;
    } else if (lowerSection == 'report' || lowerSection == 'marks' || lowerSection == 'report_card') {
      targetTabIndex = 1;
    } else if (lowerSection == 'fees' || lowerSection == 'payments' || lowerSection == 'dues') {
      targetTabIndex = 2;
    } else if (lowerSection == 'resources' || lowerSection == 'articles' || lowerSection == 'notices' || lowerSection == 'news') {
      targetTabIndex = 3;
    } else if (lowerSection == 'profile' || lowerSection == 'settings' || lowerSection == 'account') {
      targetTabIndex = 4;
    }

    if (targetTabIndex != null) {
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/home', 
        (_) => false,
        arguments: targetTabIndex, // Passes the index to HomeScreen to select the correct tab!
      );
    }
  }

  /// Runs Firebase and FCM token and subscription calls asynchronously in the background.
  /// This guarantees that if the user is completely offline, the app startup main() function is
  /// never blocked, and the splash screen loads instantly.
  Future<void> _initFCMInBackground() async {
    // A. Terminated state launch handling in background
    try {
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        debugPrint('App launched from terminated state via FCM: ${initialMessage.notification?.title}');
        _handleNotificationClick(initialMessage.data);
      }
    } catch (e) {
      debugPrint("FCM: Failed to get initial message: $e");
    }

    // B. Fetch FCM Device token in background
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        debugPrint("=========================================");
        debugPrint("🔥 YOUR FCM DEVICE TOKEN: $token");
        debugPrint("=========================================");
      }
    } catch (e) {
      debugPrint("FCM: Failed to get Token: $e");
    }

    // C. Handle Automatic Topic Subscriptions in background
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String rawUsername = prefs.getString('username')?.trim().toLowerCase() ?? '';
      
      // These do not need to be awaited synchronously on startup. Firebase internally queues them offline.
      _fcm.subscribeToTopic('topic_all');
      debugPrint('FCM: Queued subscription to topic_all');

      // Check for first-time install / first launch to target new installs specifically
      bool isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
      if (isFirstLaunch) {
        final bool isAlreadyLoggedIn = prefs.getBool('isLoggedIn') ?? false;
        if (isAlreadyLoggedIn || rawUsername.isNotEmpty) {
          // This is an existing user updating their app — skip subscribing to welcome topic
          await prefs.setBool('is_first_launch', false);
        } else {
          _fcm.subscribeToTopic('topic_new_users');
          debugPrint('FCM: Queued subscription to topic_new_users (New Install)');
          await prefs.setBool('is_first_launch', false);
        }
      }

      if (rawUsername.isNotEmpty) {
        // They are now logged in! Unsubscribe them from the new-install welcome topic automatically
        _fcm.unsubscribeFromTopic('topic_new_users');
        debugPrint('FCM: Unsubscribed logged-in user from topic_new_users');

        _fcm.subscribeToTopic('student_$rawUsername');
        debugPrint('FCM: Queued subscription to student_$rawUsername');

        // Parse batch from 4th, 5th, and 6th characters (indices 3, 4, 5) (e.g. "079")
        if (rawUsername.length >= 6) {
          final String batch = rawUsername.substring(3, 6);
          _fcm.subscribeToTopic('batch_$batch');
          debugPrint('FCM: Queued subscription to batch_$batch');
        }

        // Parse department from 7th, 8th, and 9th characters (indices 6, 7, 8)
        if (rawUsername.length >= 9) {
          final String dept = rawUsername.substring(6, 9);
          if (dept == 'bct' || dept == 'bce' || dept == 'bel') {
            _fcm.subscribeToTopic('topic_$dept');
            debugPrint('FCM: Queued subscription to topic_$dept');
          }
        }
      }
    } catch (e) {
      debugPrint('FCM: Background topic subscription queuing failed: $e');
    }
  }

  /// Cleanly unsubscribe from topics on logout to prevent notification leakage
  Future<void> handleLogout() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String rawUsername = prefs.getString('username')?.trim().toLowerCase() ?? '';

      await _fcm.unsubscribeFromTopic('topic_all');
      debugPrint('FCM: Unsubscribed from topic_all');

      if (rawUsername.isNotEmpty) {
        await _fcm.unsubscribeFromTopic('student_$rawUsername');
        debugPrint('FCM: Unsubscribed from student_$rawUsername');

        if (rawUsername.length >= 6) {
          final String batch = rawUsername.substring(3, 6);
          await _fcm.unsubscribeFromTopic('batch_$batch');
          debugPrint('FCM: Unsubscribed from batch_$batch');
        }

        if (rawUsername.length >= 9) {
          final String dept = rawUsername.substring(6, 9);
          if (dept == 'bct' || dept == 'bce' || dept == 'bel') {
            await _fcm.unsubscribeFromTopic('topic_$dept');
            debugPrint('FCM: Unsubscribed from topic_$dept');
          }
        }
      }
    } catch (e) {
      debugPrint('FCM: Unsubscribe on logout failed: $e');
    }
  }

  Future<void> requestPermissions() async {
    // Request FCM permission first (required for iOS and Android 13+)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> scheduleMonthlyFeeReminder({
    required int id,
    required String title,
    required String body,
    required int day,
    required TimeOfDay time,
  }) async {
    await cancelNotification(id);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      day,
      time.hour,
      time.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = tz.TZDateTime(
        tz.local,
        now.month == 12 ? now.year + 1 : now.year,
        now.month == 12 ? 1 : now.month + 1,
        day,
        time.hour,
        time.minute,
      );
    }

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'fee_reminder_channel',
      'Fee Reminders',
      channelDescription: 'Monthly fee payment reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
    } catch (e) {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
      );
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
