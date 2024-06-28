import 'package:checkmate/schemas/item.dart';
import 'package:flutter/material.dart';
import 'package:realm/realm.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../schemas/account.dart';

class UserService with ChangeNotifier {
  String id;

  App atlasApp;
  User? currentUser;

  UserService(this.id) : atlasApp = App(AppConfiguration(id));

  Future<User> registerUserEmailPassword(
      String email, String password, String name) async {
    EmailPasswordAuthProvider authProvider =
        EmailPasswordAuthProvider(atlasApp);
    await authProvider.registerUser(email, password);
    User loggedInUser =
        await atlasApp.logIn(Credentials.emailPassword(email, password));

    await setRole(loggedInUser, email, name);
    await loggedInUser.refreshCustomData();
    currentUser = loggedInUser;
    notifyListeners();

    return loggedInUser;
  }

  Future<User> logInUserEmailPassword(String email, String password) async {
    Credentials credentials = Credentials.emailPassword(email, password);
    final loggedInUser = await atlasApp.logIn(credentials);
    currentUser = loggedInUser;
    notifyListeners();

    return loggedInUser;
  }

  Future<void> setRole(User loggedInUser, String email, String name) async {
    final realm = Realm(Configuration.flexibleSync(
        loggedInUser, [Account.schema, Item.schema]));
    String subscriptionName = "rolesSubscription";
    realm.subscriptions.update((mutableSubscriptions) =>
        mutableSubscriptions.add(realm.all<Account>(), name: subscriptionName));
    await realm.subscriptions.waitForSynchronization();
    realm.write(
        () => realm.add(Account(ObjectId(), email, name, loggedInUser.id)));
    await realm.syncSession.waitForUpload();
    realm.subscriptions.update((mutableSubscriptions) =>
        mutableSubscriptions.removeByName(subscriptionName));
    await realm.subscriptions.waitForSynchronization();
    await realm.syncSession.waitForDownload();
    realm.close();
  }

  Future<void> logoutUser() async {
    if (atlasApp.currentUser != null) {
      await atlasApp.currentUser!.logOut();
    }
  }

  Future<List<User>> getUsers() async {
    final arrUsers = atlasApp.users.toList();
    return arrUsers;
  }

  Future<void> deleteUserFromAppService() async {
    try {
      if (atlasApp.currentUser == null) {
        throw Exception('User is not logged in');
      }
      final currentUserData = atlasApp.currentUser!;
      await atlasApp.deleteUser(currentUserData);
    } catch (e) {
      print('Error deleting user: $e');
    }
  }
}
