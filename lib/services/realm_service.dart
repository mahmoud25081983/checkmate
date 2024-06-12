import 'package:checkmate/schemas/account.dart';
import 'package:checkmate/schemas/item.dart';
import 'package:realm/realm.dart';
import 'package:flutter/material.dart';

part 'item_realm_service.dart';
part 'user_realm_service.dart';

class ItemService with ChangeNotifier {
  User? user;
  late Realm realm;
  App app;

  ItemService(this.app) {
    realm = openRealm();
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

  Future<void> close() async {
    if (user != null) {
      await user?.logOut();
      user = null;
    }
    realm.close();
  }

  @override
  void dispose() {
    print("dispose");
    realm.close();
    super.dispose();
  }
}
