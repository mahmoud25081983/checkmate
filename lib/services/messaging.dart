part of "realm_service.dart";

extension Messaging on ItemService {
  Future<void> FCMToken(Account user) async {
    FirebaseMessaging.instance.getToken().then((token) {
      if (token != null) {
        print('FCM registration token: $token');
        realm.write(() {
               if (!user.tokens.contains(token)) {
        user.tokens.add(token);
      }
        });
      } else {
        print('Error fetching FCM registration token');
      }
    }).catchError((error) {
      print('Error fetching FCM registration token: $error');
    });
  }

  void onCustomDataUpdated(result, realmError) {
    // Handle the result of updating the FCM user token
  }

  // Define updateFCMUserToken method in the User class
  Future<void> updateFCMUserToken() async {
    // Add the token to the tokens list

    // Save the updated account to the database
  }
}
