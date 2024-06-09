import 'package:realm/realm.dart';

import '../schemas/item.dart';

class RealmHelper {
  static Realm openRealm(User user) {
    var realmConfig = Configuration.flexibleSync(user, [Item.schema]);
    var realm = Realm(realmConfig);
    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.all<Item>());
    });
    return realm;
  }
}
