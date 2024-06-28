// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class Account extends _Account with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Account(
    ObjectId id,
    String email,
    String name,
    String userId, {
    bool isAdmin = false,
    Iterable<String> tokens = const [],
    Iterable<String> friends = const [],
    Iterable<String> itemsId = const [],
    Iterable<String> newItemsId = const [],
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Account>({
        'isAdmin': false,
      });
    }
    RealmObjectBase.set(this, '_id', id);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'isAdmin', isAdmin);
    RealmObjectBase.set(this, 'user_id', userId);
    RealmObjectBase.set<RealmList<String>>(
        this, 'tokens', RealmList<String>(tokens));
    RealmObjectBase.set<RealmList<String>>(
        this, 'friends', RealmList<String>(friends));
    RealmObjectBase.set<RealmList<String>>(
        this, 'itemsId', RealmList<String>(itemsId));
    RealmObjectBase.set<RealmList<String>>(
        this, 'newItemsId', RealmList<String>(newItemsId));
  }

  Account._();

  @override
  ObjectId get id => RealmObjectBase.get<ObjectId>(this, '_id') as ObjectId;
  @override
  set id(ObjectId value) => RealmObjectBase.set(this, '_id', value);

  @override
  String get email => RealmObjectBase.get<String>(this, 'email') as String;
  @override
  set email(String value) => RealmObjectBase.set(this, 'email', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  bool get isAdmin => RealmObjectBase.get<bool>(this, 'isAdmin') as bool;
  @override
  set isAdmin(bool value) => RealmObjectBase.set(this, 'isAdmin', value);

  @override
  String get userId => RealmObjectBase.get<String>(this, 'user_id') as String;
  @override
  set userId(String value) => RealmObjectBase.set(this, 'user_id', value);

  @override
  RealmList<String> get tokens =>
      RealmObjectBase.get<String>(this, 'tokens') as RealmList<String>;
  @override
  set tokens(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<String> get friends =>
      RealmObjectBase.get<String>(this, 'friends') as RealmList<String>;
  @override
  set friends(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<String> get itemsId =>
      RealmObjectBase.get<String>(this, 'itemsId') as RealmList<String>;
  @override
  set itemsId(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  RealmList<String> get newItemsId =>
      RealmObjectBase.get<String>(this, 'newItemsId') as RealmList<String>;
  @override
  set newItemsId(covariant RealmList<String> value) =>
      throw RealmUnsupportedSetError();

  @override
  Stream<RealmObjectChanges<Account>> get changes =>
      RealmObjectBase.getChanges<Account>(this);

  @override
  Account freeze() => RealmObjectBase.freezeObject<Account>(this);

  static SchemaObject get schema => _schema ??= _initSchema();
  static SchemaObject? _schema;
  static SchemaObject _initSchema() {
    RealmObjectBase.registerFactory(Account._);
    return const SchemaObject(ObjectType.realmObject, Account, 'Users', [
      SchemaProperty('id', RealmPropertyType.objectid,
          mapTo: '_id', primaryKey: true),
      SchemaProperty('email', RealmPropertyType.string),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('isAdmin', RealmPropertyType.bool),
      SchemaProperty('userId', RealmPropertyType.string, mapTo: 'user_id'),
      SchemaProperty('tokens', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
      SchemaProperty('friends', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
      SchemaProperty('itemsId', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
      SchemaProperty('newItemsId', RealmPropertyType.string,
          collectionType: RealmCollectionType.list),
    ]);
  }
}
