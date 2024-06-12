import 'package:realm/realm.dart';

part 'account.g.dart';

@RealmModel()
@MapTo("Users")
class _Account {
  @MapTo("_id")
  @PrimaryKey()
  late ObjectId id;
  
  late String email;
  late String name;
  bool isAdmin = false;
  @MapTo('user_id')
  late String userId;
  late List<String> friends;

}
