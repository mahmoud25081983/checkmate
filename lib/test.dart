/* import 'package:realm/realm.dart';

import '../schemas/account.dart';

class UserService {
  final App atlasApp;
   Realm? realm;

   UserService(this.atlasApp);

   //////////////////////////////////////////

  Future<void> init() async {
    if (atlasApp.currentUser == null) {
      throw Exception("No user is currently logged in.");
    }
    realm = await openRealm();
  }

  Future<Realm> openRealm() async {
    var realmConfig = Configuration.flexibleSync(atlasApp.currentUser!, [Account.schema]);
    var realm = Realm(realmConfig);
    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.all<Account>());
    });
    await realm.subscriptions.waitForSynchronization(); // Ensure subscriptions are synchronized
    return realm;
  }

  searchUser({required String email}) {
    final users = realm!.query<Account>('email == ${atlasApp.currentUser!.profile.email}', [email]);
    return users.isNotEmpty ? users.first : null;
  }

  Future<User> createUser(String email, String password) async {
    EmailPasswordAuthProvider authProvider = EmailPasswordAuthProvider(atlasApp);
    await authProvider.registerUser(email, password);
    User user = await loginUser(email, password);
    await init(); // Initialize the realm after login
    await addUserToCollection(user.id.toString(), email);
    return user;
  }

  Future<User> loginUser(String email, String password) async {
    Credentials credentials = Credentials.emailPassword(email, password);
    User user = await atlasApp.logIn(credentials);
    await init(); // Initialize the realm after login
    return user;
  }

  Future<void> logoutUser() async {
    if (atlasApp.currentUser != null) {
      await atlasApp.currentUser!.logOut();
    }
    realm = null; // Reset realm on logout
  }

  getUsers() {
    print(atlasApp.users.map((e) => e.profile.email).toList());
  }

  Future<void> addUserToCollection(String userId, String email) async {
    if (realm == null) {
      throw Exception("Realm has not been initialized.");
    }
    await realm!.subscriptions.waitForSynchronization(); // Ensure subscriptions are synchronized
    realm!.write(() {
      realm!.add<Account>(Account(ObjectId(), email));
    });
  }
} */