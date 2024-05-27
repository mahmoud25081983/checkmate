import 'package:checkmate/schemas/item.dart';
import 'package:realm/realm.dart';

class ItemService {
  final User user;
  late final Realm realm;

  ItemService(this.user) {
    realm = openRealm();
  }

  Realm openRealm() {
    var realmConfig = Configuration.flexibleSync(user, [Item.schema]);
    var realm = Realm(realmConfig);
    realm.subscriptions.update((mutableSubscriptions) {
      mutableSubscriptions.add(realm.all<Item>());
    });
    return realm;
  }

  RealmResults<Item> getItems() {
    return realm.query<Item>(
        "userId == '${user.id}' || sharedWith contains '${user.id}'");
  }

  add(String text) {
    realm
        .write(() => {realm.add<Item>(Item(ObjectId(), text, false, user.id))});
  }

  toggleStatus(Item item) {
    realm.write(() => {item.done = !item.done});
  }

  delete(Item item) {
    realm.write(() => {realm.delete(item)});
  }

  shareItemWithUser(Item item, User user) {
    realm.write(() => {
          if (!item.sharedWith.contains(user.id))
            {
              item.sharedWith.add(user.id),
            }
        });
  }
}



/* checkmate

exports = function(changeEvent) {
  const mongodb = context.services.get("mongodb-atlas");
  const appServiceUsersCollection = mongodb.db("checkmate").collection("AppServiceUsers");
  const usersCollection = mongodb.db("checkmate").collection("Users");

  if (changeEvent.operationType === "insert") {
    const newUser = changeEvent.fullDocument;

    // Check if user already exists in Users collection
    return usersCollection.findOne({ email: newUser.email })
      .then(existingUser => {
        if (existingUser) {
          console.log(`User with email ${newUser.email} already exists.`);
          return null;
        }

        // Add the new user to the Users collection
        return usersCollection.insertOne({
          _id: newUser._id,
          email: newUser.email,
          // Add other user fields as needed
        })
        .then(result => {
          console.log(`User added with _id: ${result.insertedId}`);
          return result;
        });
      })
      .catch(err => {
        console.error("Error checking or adding user:", err);
        throw new Error("Error checking or adding user");
      });
  }

  return Promise.resolve();
}; */