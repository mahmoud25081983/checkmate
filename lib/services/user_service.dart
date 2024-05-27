import 'package:checkmate/schemas/account.dart';
import 'package:realm/realm.dart';
import 'package:mongo_dart/mongo_dart.dart';

class UserService {
  final App atlasApp;
  final Db db;

  UserService(this.atlasApp, this.db);

  Future<List<User>> getData() async {
    final arrData = atlasApp.users.toList();
    return arrData;
  }

  Future<User> createUser(String email, String password) async {
    EmailPasswordAuthProvider authProvider =
        EmailPasswordAuthProvider(atlasApp);
    await authProvider.registerUser(email, password);
    
    // Find user by id
    var userId = atlasApp.currentUser!.id;
    await updateUserPassword(userId, password);
    
    // Return the logged-in user
    return loginUser(email, password);
  }

  Future<void> updateUserPassword(String userId, String password) async {
    // Get reference to the MongoDB collection
    var usersCollection = db.collection('users');

    // Update the user document with the password field
    await usersCollection.updateOne(
      {'_id': userId},
      {
        r'$set': {'password': password}
      },
    );
  }

  Future<User> loginUser(String email, String password) async {
    Credentials credentials = Credentials.emailPassword(email, password);
    return atlasApp.logIn(credentials);
  }

  Future<void> logoutUser() async {
    return atlasApp.currentUser!.logOut();
  }

}
