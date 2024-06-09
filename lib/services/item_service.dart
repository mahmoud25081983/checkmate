import 'package:checkmate/schemas/account.dart';
import 'package:checkmate/schemas/item.dart';
import 'package:realm/realm.dart';

class ItemService {
   User user;
  late final Realm realm;

  ItemService(this.user) {
    realm = openRealm();
  }

  Realm openRealm() {
    var realmConfig = Configuration.flexibleSync(user, [Item.schema, Account.schema]);
    var realm = Realm(realmConfig);
    realm.subscriptions.update((mutableSubscriptions) {
            mutableSubscriptions.clear();

      mutableSubscriptions.add(realm.all<Item>());
      mutableSubscriptions.add(realm.all<Account>());
    });
        realm.subscriptions.waitForSynchronization();

    return realm;
  }

  RealmResults<Item> getItems() {
    return realm.query<Item>(
        "userId == '${user.id}' || sharedWith contains '${user.id}'");
  }

  RealmResults<Account> getUsers() {
    return realm.all<Account>(); // Get all users
  }

  add(String text) {
    realm
        .write(() => {realm.add<Item>(Item(ObjectId(), text, user.id ))});
  }

  toggleStatus(Item item) {
    realm.write(() => {item.isDone = !item.isDone});
  }

  delete(Item item) {
    realm.write(() => {realm.delete(item)});
  }

     shareItemWithUser(Item item, Account user) {
    // Share the item with another user
    realm.write(() {
      if (!item.sharedWith.contains(user.userId)) {
        item.sharedWith.add(user.userId);
      }
    });
  }
    removeSharedUser(Item item, Account user) {
    // Remove the user from the sharedWith list
    realm.write(() {
      item.sharedWith.remove(user.userId);
    });
  }   

   List<Account> getUsersSharedWith(Item item) {
    List<Account> sharedUsers = [];
    for (var userId in item.sharedWith) {
      var user = realm.query<Account>("userId == '$userId'").firstOrNull;
      if (user != null) {
        sharedUsers.add(user);
      }
    }
    return sharedUsers;
  }

    Account? getCreatedByUser(Item item) {
    // Find the account of the user who created the item
    return realm.query<Account>("userId == '${item.userId}'").firstOrNull;
  }

  bool isSharedWithCurrentUser(Item item) {
    // Check if the item is shared with the current user
    return item.sharedWith.contains(user.id);
  }
   

  Account getCurrentUser() {
    // Find the current user's account based on the provided user object
    var currentUserAccount = getUsers().where((e) => e.userId == user.id).firstOrNull;
    if (currentUserAccount != null) {
      return currentUserAccount;
    } else {
      throw Exception('Current user not found.');
    }
  }   

    Future<void> updateItem(Item item, String? text) async {
    realm.write(() {
      if (text != null) {
        item.text = text;
      }

    });
  }

    Future<void> deleteAccount(Account account) async {
    try {
      realm.write(() {
        realm.delete(account);
      });
    } catch (e) {
      print('Error deleting account: $e');
      // Handle any errors that occur during deletion
    }
  }

    Future<void> close() async {
    await user.logOut();
      realm.close();
  }                     
}
