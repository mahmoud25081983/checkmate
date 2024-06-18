part of "realm_service.dart";

extension UserRealMService on ItemService {
  RealmResults<Account> getUsers() {
    return realm.all<Account>(); // Get all users
  }

  // New method to search for accounts by email or name
  List<Account> searchAccounts(String query) {
    return realm.all<Account>().where((account) {
      return account.email.contains(query) || account.name.contains(query);
    }).toList();
  }

  addUserToFreinds(Account userToAdd, Account currentUser) {
    // Share the item with another user
    realm.write(() {
      if (!currentUser.friends.contains(userToAdd.userId)) {
        currentUser.friends.add(userToAdd.userId);
      }
    });
    notifyListeners();
  }

  removeFreind(Account addedUser, Account currentUser) {
    // Remove the user from the sharedWith list
    realm.write(() {
      currentUser.friends.remove(addedUser.userId);
    });
    notifyListeners();
  }

  itemsSharesWithThisUser(Account currentUser, Item item) {
    // Share the item with another user
    realm.write(() {
      if (!currentUser.itemsId.contains(item.itemId)) {
        currentUser.itemsId.add(item.itemId);
      }
    });
    notifyListeners();
  }

  removeItemFromUser(Account currentUser, Item item) {
    // Remove the user from the sharedWith list
    realm.write(() {
      currentUser.itemsId.remove(item.itemId);
    });
    notifyListeners();
  }

  removeSharedUser(Item item, Account user) {
    // Remove the user from the sharedWith list
    realm.write(() {
      item.sharedWith.remove(user.userId);
    });
    notifyListeners();
  }

  List<Account> getFriends() {
    final currentUser = getCurrentUser();
    return currentUser.friends.map((userId) {
      return realm
          .all<Account>()
          .firstWhere((account) => account.userId == userId);
    }).toList();
  }

  Account? getCreatedByUser(Item item) {
    // Find the account of the user who created the item
    return realm.query<Account>("userId == '${item.userId}'").firstOrNull;
  }

  Account getCurrentUser() {
    // Find the current user's account based on the provided user object
    var currentUserAccount =
        getUsers().where((e) => e.userId == user!.id).firstOrNull;
    if (currentUserAccount != null) {
      return currentUserAccount;
    } else {
      throw Exception('Current user not found.');
    }
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
    notifyListeners();
  }
}
