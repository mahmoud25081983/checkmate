import 'package:checkmate/schemas/account.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:checkmate/services/realm_service.dart';
import 'package:checkmate/services/user_service.dart';
import 'package:checkmate/schemas/item.dart';

import 'profile_screen.dart';
import 'splash.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  late RealmResults<Item> allItems;
  late RealmResults<Account> users;
  User? selectedUser;
  Map<ObjectId, List<Account>> selectedUsers = {};
  List<Account> sharedUsersIds = [];
  bool isEdit = false;
  late Item currentItem;
  // late Account currentUser;
  late UserService userService;
  late ItemService itemService;

  @override
  void initState() {
    super.initState();
    userService = Provider.of<UserService>(context, listen: false);
    itemService = Provider.of<ItemService>(context, listen: false);
    allItems = itemService.getItems();
    users = itemService.getUsers();
    // currentUser = widget.itemService.getCurrentUser();
    //  print("${currentUser.email}");

    //currentAccount = widget.itemService.getCurrentUser();
    //_fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${userService.atlasApp.currentUser!.profile.email}"),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                final navigator = Navigator.of(context);
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (BuildContext context) {
                    return ProfileScreen();
                  }),
                );
              } on RealmException catch (error) {
                if (kDebugMode) {
                  print("Error during logout ${error.message}");
                }
              }
            },
            icon: const Icon(
              Icons.delete_forever,
              size: 30,
            ),
          ),
          IconButton(
            onPressed: () async {
              try {
                final navigator = Navigator.of(context);
                userService.logoutUser();
                await itemService.close(); // Close the Realm instance

                navigator.pushReplacement(
                  MaterialPageRoute(builder: (BuildContext context) {
                    return const SplashScreen();
                  }),
                );
              } on RealmException catch (error) {
                if (kDebugMode) {
                  print("Error during logout ${error.message}");
                }
              }
            },
            icon: const Icon(
              Icons.logout,
              size: 30,
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: allItems.changes,
        builder: (BuildContext context,
            AsyncSnapshot<RealmResultsChanges<Item>> snapshot) {
          List<Item> items = [];
          if (snapshot.hasData) {
            items = snapshot.data!.results.toList();
          }

          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              final item = items[index];

              //  final isCurrentUserItem = item.userId == currentUser.userId;
              final createdByUser = itemService.getCreatedByUser(item);
              final sharedWithCurrentUser =
                  itemService.isSharedWithCurrentUser(item);
              /*            final isMine =
                  item.userId != currentUser.userId
                      ? ""
                      : "(Mine)"; */

              final isMine = (item.userId == userService.currentUser?.id);

              return Card(
                margin: const EdgeInsets.all(8.0),
                color: item.isDone ? Colors.green.shade50 : Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              item.isDone
                                  ? Icons.check_outlined
                                  : Icons.close_outlined,
                              color: item.isDone
                                  ? Colors.green.shade500
                                  : Colors.grey.shade500,
                              semanticLabel: "Mark done",
                            ),
                            onPressed: () {
                              itemService.toggleStatus(item);
                            },
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isMine
                                      ? "Mine"
                                      : "Shared by: ${createdByUser?.name ?? 'Unknown'}", // Display the current user's name
                                  style: TextStyle(
                                    color: isMine ? Colors.blue : Colors.black,
                                  ),
                                ),
                                Text(
                                  item.text,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (!sharedWithCurrentUser)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildUserDropdown(item),
                            _buildSelectedUsers(item),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    isEdit = true;
                                    currentItem = item;
                                    showDialog(
                                      context: context,
                                      builder: dialogBuilder,
                                    );
                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red.shade500,
                                    semanticLabel: "Delete item",
                                  ),
                                  onPressed: () {
                                    itemService.deleteItem(item);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
            itemCount: items.length,
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          isEdit = false;
          showDialog(context: context, builder: dialogBuilder);
        },
        tooltip: "Add item",
        child: const Icon(
          Icons.add,
          size: 50,
        ),
      ),
    );
  }

  Widget dialogBuilder(BuildContext context) {
    late String itemName;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(10),
        child: Wrap(
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...createTextFormField(
                    "Item name",
                    placeholder:
                        isEdit == true ? currentItem.text : "Enter item name",
                    isRequired: true,
                    onSaved: (value) {
                      itemName = value!;
                    },
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(10)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          if (kDebugMode) {
                            print(itemName);
                          }
                          if (isEdit == false) {
                            itemService.add(itemName);
                          } else if (isEdit == true) {
                            itemService.updateItem(currentItem, itemName);
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        isEdit == true ? "Edit" : "Add",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> createTextFormField(String label,
      {String? placeholder,
      bool isRequired = false,
      Function(String?)? onSaved}) {
    return [
      Text(label, style: const TextStyle(fontSize: 20)),
      const SizedBox(height: 5),
      TextFormField(
        onSaved: onSaved,
        validator: (value) {
          return isRequired && (value == null || value.isEmpty)
              ? "$label is required"
              : null;
        },
        decoration: InputDecoration(hintText: placeholder),
      ),
    ];
  }

  Widget _buildUserDropdown(Item item) {
/*     List<Account> otherUsers = users
        .where((user) => user.userId != userService.currentUser?.id)
        .toList();
 */
    return DropdownButton<Account>(
      hint: const Text("Share with..."), // Display hint
      value: null, // Set the current user as the initial selected value
      items: itemService.getFriends().map((Account user) {
        return DropdownMenuItem<Account>(
          value: user,
          child: Text(
              "${user.name} ${user.email}"), // Assuming email is used to display user
        );
      }).toList(),
      onChanged: (Account? user) {
        if (user != null) {
          itemService.shareItemWithUser(item, user);
          if (selectedUsers[item.id] == null) {
            selectedUsers[item.id] = [];
          }

          selectedUsers[item.id]!
              .add(user); // Add the selected user to the list for this item
        }
      },
    );
  }

  Widget _buildSelectedUsers(Item item) {
    // Check if the item is shared with the current user
    bool sharedWithCurrentUser =
        item.sharedWith.contains(userService.currentUser!.id);

    // If the item is shared with the current user, display the users it is shared with
    if (sharedWithCurrentUser) {
      return const SizedBox();
    } else {
      // If the item is not shared with the current user, return an empty widget
      return Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.start,
        spacing: 2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: itemService
            .getUsersSharedWith(item)
            .map((user) => Chip(
                  padding: EdgeInsets.zero,
                  label: Text("${user.name} ${user.email}"),
                  onDeleted: () {
                    itemService.removeSharedUser(item, user);
                    selectedUsers[item.id]?.remove(user);
                    // Remove user from the database
                  },
                ))
            .toList(),
      );
    }
  }
}
