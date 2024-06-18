import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import 'package:checkmate/schemas/account.dart';
import 'package:checkmate/schemas/item.dart';
import 'package:checkmate/services/user_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'notification_services.dart';

part "messaging.dart";
part 'item_realm_service.dart';
part 'user_realm_service.dart';

class ItemService with ChangeNotifier {
  User? user;
  late Realm realm;
  App app;
  Item? currentItem;
  late StreamSubscription<RealmResultsChanges<Item>> _itemSubscription;
  late StreamSubscription<RealmResultsChanges<Account>> _accountSubscription;
   List<StreamSubscription<RealmObjectChanges<Account>>> _itemSubscriptions = [];

  ItemService(this.app) {
    realm = openRealm();
  //  _startListeningForItemChanges();
   // _startListeningForAccountChanges();
  }

  Realm openRealm() {
    if (app.currentUser != null || user != app.currentUser) {
      user ??= app.currentUser;
      var realmConfig =
          Configuration.flexibleSync(user!, [Item.schema, Account.schema]);
      realm = Realm(realmConfig);
      realm.subscriptions.update((mutableSubscriptions) {
        mutableSubscriptions.clear();
        mutableSubscriptions.add(realm.all<Item>());
        mutableSubscriptions.add(realm.all<Account>());
      });
    }
    realm.subscriptions.waitForSynchronization();
    return realm;
  }

  @override
  Future<void> close() async {
    await _itemSubscription.cancel();
    await _accountSubscription.cancel();
    if (user != null) {
      await user?.logOut();
      user = null;
    }
    realm.close();
  }

  @override
  void dispose() {
    print("dispose");
    _itemSubscription.cancel();
    _accountSubscription.cancel();
    realm.close();
    super.dispose();
  }

  void _startListeningForItemChanges() {
    final items = realm.all<Item>();
    _itemSubscription = items.changes.listen((changes) {
      // Handle item changes
      changes.inserted.forEach((index) {
        final newItem = changes.results[index];
        // Handle new item insertion
      });
      changes.modified.forEach((index) {
        final modifiedItem = changes.results[index];
        // Handle item modification
      });
      changes.deleted.forEach((index) {
        // Handle item deletion
      });
      notifyListeners();
    });
  }

  void _startListeningForAccountChanges() {
    final account = getCurrentUser();
    _itemSubscriptions = [];

      final subscription = account.changes.listen((change) {
        // Handle changes for this specific item

        if (change.isDeleted) {
          return;
        }

        var itemsIds = change.object.itemsId.toList();
        

        itemsIds.forEach((itemId) {
          print(account.itemsId.map((e) => e == account.userId));
            print(account.name);
        });
      });
      _itemSubscriptions.add(subscription);
    }
  }

  Future<void> schedulNotifications() async {
    DateTime notificationDate = DateTime.now();
/* final senderUser = getUsers()
.where((user) => user.userId == currentItem!.userId)
.firstOrNull;
//final item = getItems().firstWhere((element) => element.userId == itemId);
// final itemName = "Reminder for ${item.text}";
final title = "${senderUser!.name} sent you new Mission"; /
/ final notificationBody =
'${Emojis.activites_reminder_ribbon} ${DateFormat('d MMM yyyy').format(notificationDate)}'; */
    NotificationService.showNotification(
      title: "title",
      body: "currentItem!.text",
      scheduled: true,
      day: notificationDate.day,
      month: notificationDate.month,
      year: notificationDate.year,
      category: NotificationCategory.Reminder,
      payload: {
        "navigate": "true",
//"itemId": item.id.toString(),
        "notificationDate": notificationDate.hashCode.toString(),
      },
      actionButtons: [
        NotificationActionButton(
            key: 'DISMISS',
            label: 'Dismiss',
            autoDismissible: true,
            actionType: ActionType.DisabledAction,
            isDangerousOption: true),
      ],
    );
  }

