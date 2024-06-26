import 'package:realm/realm.dart';
part 'item.g.dart';

@RealmModel()
@MapTo("Items")
class _Item {
  @PrimaryKey()
  @MapTo("_id")
  late ObjectId id;

  late String text;
  bool isDone = false;
  @MapTo("user_id")
  late String userId;
  late String itemId;
  @MapTo("shared_with")
  late List<String> sharedWith;
  
  late String? doneByUser;
}
