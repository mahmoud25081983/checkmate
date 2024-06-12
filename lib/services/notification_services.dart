import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



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
          importance: NotificationImportance.Default,
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
    final context = Jamia.navigatorKey.currentContext;
    if (payload["navigate"] == "true") {
      final tableId = int.tryParse(payload["tableId"] ?? "");
      if (tableId != null) {
        final provider =
            Provider.of<DataTableProvider>(context!, listen: false);
        final selectedTable = provider.getTableById(tableId);
        if (selectedTable != null) {
          provider.setSelectedTable(selectedTable);
        //  AdMobservices.creatInterstitialAd();
          Navigator.of(context).pushNamedAndRemoveUntil(
              GeneratedTableScreen.routeName, (route) => route.isFirst);
        } else {}
      }
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
        id: -1,
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

  static Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }

  static List<NotificationModel> notifications = [];

  static Future<List<NotificationModel>> loadNotifications(
      MyTable table) async {
    final fetchedNotifications =
        await AwesomeNotifications().listScheduledNotifications();

    final notificationsForTable = fetchedNotifications.where((notification) {
      final payload = notification.content?.payload ?? {};
      final tableId = int.tryParse(payload["tableId"] ?? "");
      return tableId == table.id;
    }).toList();

    notifications = notificationsForTable;

    return notifications;
  }

  static Future<void> cancelSpecificDateNotifications(MyTable table) async {
    await loadNotifications(table);
    if (notifications.isNotEmpty) {
      await AwesomeNotifications().cancel(notifications.last.content!.id!);
    }
  }

  static Future<void> cancelSpecificTableNotifications(MyTable table) async {
    await loadNotifications(table);
    for (int i = 0; i < notifications.length; i++) {
      debugPrint("${notifications[i].content!.id}");

      await AwesomeNotifications().cancel(notifications[i].content!.id!);
    }
  }

  static Future<bool> isDateScheduled(DateTime date, MyTable table) async {
   await loadNotifications(table);
    return notifications.any((notification) {
      final content = notification.content;
      if (content != null) {
        final displayedDate = content.displayedDate;
        if (displayedDate != null) {
          final notificationDate = DateTime(
            displayedDate.year,
            displayedDate.month,
            displayedDate.day,
          );
          return notificationDate.isAtSameMomentAs(date);
        }
      }
      return true;
    });
  }
}
