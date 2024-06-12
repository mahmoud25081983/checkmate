

part of "realm_service.dart";



extension ItemRealmService on ItemService {

  RealmResults<Item> getItems() {
    return realm.query<Item>(
        "userId == '${user!.id}' || sharedWith contains '${user!.id}'");
  }

    add(String text) {
    realm.write(() => {realm.add<Item>(Item(ObjectId(), text, user!.id))});
    notifyListeners();
  }

    toggleStatus(Item item) {
    realm.write(() => {item.isDone = !item.isDone});
    notifyListeners();
  }

    shareItemWithUser(Item item, Account user) {
    // Share the item with another user
    realm.write(() {
      if (!item.sharedWith.contains(user.userId)) {
        item.sharedWith.add(user.userId);
      }
    });
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


}
