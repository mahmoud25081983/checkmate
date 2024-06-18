import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:checkmate/main.dart';
import 'package:checkmate/services/realm_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/home.dart';

class NotificationService extends ChangeNotifier {
  static Future<void> initializeNotification() async {
    debugPrint("created");
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'high',
          channelKey: 'high',
          channelName: 'channel Name',
          channelDescription: 'channel Description test',
          defaultColor: Colors.blue,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: 'high', channelGroupName: 'channel Name'),
      ],
      debug: true,
    );
    await AwesomeNotifications()
        .isNotificationAllowed()
        .then((isAllowed) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );
  }

  static void disposeNotifications() {
    AwesomeNotifications().dispose();
  }

  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint("onNotificationCreatedMethod");
  }

  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint("onNotificationDisplayedMethod");
  }

  static Future<void> onDismissActionReceivedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint("onDismissActionReceivedMethod");
  }

  static Future<void> onActionReceivedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint("onActionReceivedMethod");
    final payload = receivedNotification.payload ?? {};
    final context = MyApp.navigatorKey.currentContext;
    if (payload["navigate"] == "true") {
      final tableId = int.tryParse(payload["itemId"] ?? "");

      final provider = Provider.of<ItemService>(context!, listen: false);

      //  AdMobservices.creatInterstitialAd();
      Navigator.of(context).pushNamedAndRemoveUntil(
          HomeScreen.routeName, (route) => route.isFirst);
    }
  }

  static Future<void> showNotification({
    required final String title,
    required final String body,
    final String? summary,
    final Map<String, String>? payload,
    final ActionType actionType = ActionType.Default,
    final NotificationLayout notificationLayout = NotificationLayout.Default,
    final NotificationCategory? category,
    final String? bigPicture,
    final List<NotificationActionButton>? actionButtons,
    final bool scheduled = false,
    final int? interval,
    final int? day,
    final int? month,
    final int? year,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: 'high',
        title: title,
        body: body,
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
        wakeUpScreen: true,
      ),
      actionButtons: actionButtons,
      schedule: scheduled
          ? NotificationCalendar(
              day: day,
              month: month,
              year: year,
              timeZone:
                  await AwesomeNotifications().getLocalTimeZoneIdentifier(),
              preciseAlarm: true,
            )
          : null,
    );
  }

    static  int createUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }



  }

