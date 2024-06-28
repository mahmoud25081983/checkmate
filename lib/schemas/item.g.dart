// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Item extends _Item with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Item(
    ObjectId id,
    String text,
    String userId,
    String itemId, {
    bool isDone = false,
    String? doneByUser,
    Iterable<String> sharedWith = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Item>({
        'isDone': false,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'text', text);
    RealmObjectBase.set(this, 'isDone', isDone);
    RealmObjectBase.set(this, 'user_id', userId);
    RealmObjectBase.set(this, 'itemId', itemId);
    RealmObjectBase.set(this, 'doneByUser', doneByUser);
    RealmObjectBase.set<RealmList<String>>(
        this, 'shared_with', RealmList<String>(sharedWith));
  }

  Item._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get text => RealmObjectBase.get<String>(this, 'text') as String;
  @override
  set text(String value) => RealmObjectBase.set(this, 'text', value);

  @override
  bool get isDone => RealmObjectBase.get<bool>(this, 'isDone') as bool;
  @override
  set isDone(bool value) => RealmObjectBase.set(this, 'isDone', value);

  @override
  String get userId => RealmObjectBase.get<String>(this, 'user_id') as String;
  @override
  set userId(String value) => RealmObjectBase.set(this, 'user_id', value);

  @override
  String get itemId => RealmObjectBase.get<String>(this, 'itemId') as String;
  @override
  set itemId(String value) => RealmObjectBase.set(this, 'itemId', value);

  @override
  RealmList<String> get sharedWith =>
      RealmObjectBase.get<String>(this, 'shared_with') as RealmList<String>;
  @override
  set sharedWith(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  String? get doneByUser =>
      RealmObjectBase.get<String>(this, 'doneByUser') as String?;
  @override
  set doneByUser(String? value) =>
      RealmObjectBase.set(this, 'doneByUser', value);

  @override
  Stream<RealmObjectChanges<Item>> get changes =>
      RealmObjectBase.getChanges<Item>(this);

  @override
  Item freeze() => RealmObjectBase.freezeObject<Item>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Item._);
    return const SchemaObject(ObjectType.realmObject, Item, 'Items', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('text', RealmPropertyType.string),
      SchemaProperty('isDone', RealmPropertyType.bool),
      SchemaProperty('userId', RealmPropertyType.string, mapTo: 'user_id'),
      SchemaProperty('itemId', RealmPropertyType.string),
      SchemaProperty('sharedWith', RealmPropertyType.string,
          mapTo: 'shared_with', collectionType: RealmCollectionType.list),
      SchemaProperty('doneByUser', RealmPropertyType.string, optional: true),
    ]);
  }
}
