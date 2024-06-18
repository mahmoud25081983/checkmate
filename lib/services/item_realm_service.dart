part of "realm_service.dart";

extension ItemRealmService on ItemService {
  RealmResults<Item> getItems() {
    return realm.query<Item>(
        "userId == '${user!.id}' || sharedWith contains '${user!.id}'");
  }

  add(String text) async {
    realm.write(() => {
          realm.add<Item>(
              Item(ObjectId(), text, user!.id, DateTime.now().toString()))
        });
    notifyListeners();
  }

  toggleStatus(Item item) {
    realm.write(() => {item.isDone = !item.isDone});
    notifyListeners();
  }

  shareItemWithUser(Item item, Account user) async {
    // Share the item with another user
    realm.write(() {
      if (!item.sharedWith.contains(user.userId)) {
        item.sharedWith.add(user.userId);
      }
    });
    _startListeningForAccountChanges();
    notifyListeners();
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

  bool isSharedWithCurrentUser(Item item) {
    // Check if the item is shared with the current user
    return item.sharedWith.contains(user!.id);
  }

  Future<void> updateItem(Item item, String? text) async {
    realm.write(() {
      if (text != null) {
        item.text = text;
      }
    });
    notifyListeners();
  }

  deleteItem(Item item) {
    realm.write(() => {realm.delete(item)});
    notifyListeners();
  }



  // New method to get items shared with a specific user
  RealmResults<Item> getItemsSharedWithUser(Account selectedUser) {
    return realm.query<Item>("sharedWith contains '${selectedUser.userId}'");
  }

  Item? getItemById(String itemId) {
  return realm.find<Item>(itemId);
}
}
