import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';

import 'package:checkmate/schemas/account.dart';
import 'package:checkmate/schemas/item.dart';

import 'notification_services.dart';

part 'item_realm_service.dart';
part 'user_realm_service.dart';

class ItemService with ChangeNotifier {
  User? user;
  late Realm realm;
  App app;
  Account? currentAccount;
  List<StreamSubscription<RealmObjectChanges<Account>>> _itemSubscriptions = [];

  ItemService(this.app) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (app.currentUser == null) {
      throw Exception("User is not authenticated");
    }
    user = app.currentUser;
    realm = await _openRealm();
    await _fetchCurrentUserAccount();
    _startListeningForAccountChanges();
  }

  Future<Realm> _openRealm() async {
    var realmConfig =
        Configuration.flexibleSync(user!, [Item.schema, Account.schema]);
    realm = Realm(realmConfig);
    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.clear();
      mutableSubscriptions.add(realm.all<Item>());
      mutableSubscriptions.add(realm.all<Account>());
    });
    await realm.subscriptions.waitForSynchronization();
    return realm;
  }

  Future<void> _fetchCurrentUserAccount() async {
    final userId = user!.id;
    currentAccount =
        realm.all<Account>().firstWhere((account) => account.userId == userId);
    if (currentAccount == null) {
      throw Exception('Current user account not found.');
    }
  }

  void _startListeningForAccountChanges() {
    if (currentAccount == null) return;

    final subscription = currentAccount!.changes.listen((change) {
      if (change.isDeleted) return;

      var newItemsIds = change.object.newItemsId.toList();
      newItemsIds.forEach((itemId) async {
        final item =
            realm.all<Item>().where((item) => item.itemId == itemId).first;
        await schedulNotifications(item);
        newRemoveItemFromUser(currentAccount!, item);
        itemsSharesWithThisUser(currentAccount!, item);
      });
    });
    _itemSubscriptions.add(subscription);
  }

  @override
  void dispose() {
    realm.close();
    _itemSubscriptions.forEach((subscription) => subscription.cancel());
    super.dispose();
  }

  Future<void> close() async {
    // await _itemSubscription.cancel();
    //  await _accountSubscription.cancel();
    _itemSubscriptions.clear();
    if (user != null) {
      await user?.logOut();
      user = null;
    }
    realm.close();
  }

/*   void _startListeningForItemChanges() {
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
  } */

  Future<void> schedulNotifications(Item item) async {
    DateTime notificationDate = DateTime.now();

//final item = getItems().firstWhere((element) => element.userId == itemId);
// final itemName = "Reminder for ${item.text}";
// final title = "${senderUser!.name} sent you new Mission";
// final notificationBody =
    // '${Emojis.activites_reminder_ribbon} ${DateFormat('d MMM yyyy').format(notificationDate)}';
    NotificationService.showNotification(
      title: "{senderAccount.name} Sent a New Mission",
      body: "${item.text} - Click Here to see Your Mission",
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
}
