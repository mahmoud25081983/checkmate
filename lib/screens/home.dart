import 'package:checkmate/schemas/account.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';
import 'package:checkmate/services/realm_service.dart';
import 'package:checkmate/services/user_service.dart';
import 'package:checkmate/schemas/item.dart';

import '../widgets/home_widgets/add_edit_item_dialog.dart';
import '../widgets/home_widgets/toggle_status_dialog.dart';
import '../widgets/home_widgets/users_dropdown.dart';
import '../widgets/home_widgets/selected_users.dart';
import 'profile_screen.dart';
import 'splash.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String routeName = 'homescreen';

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
    // Listen for changes in the item service
    itemService.addListener(_handleItemServiceChanges);
  }

  @override
  void dispose() {
    // Remove the listener when the screen is disposed
    itemService.removeListener(_handleItemServiceChanges);
    super.dispose();
  }

  void _handleItemServiceChanges() {
    // Update the allItems whenever there are changes in the item service
    setState(() {
      allItems = itemService.getItems();
    });
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
                    return const ProfileScreen();
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
                              showToggleStatusDialog(context, item);
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
                          Text(item.isDone
                              ? "Done by ${item.doneByUser ?? 'Unknown'}"
                              : "Not done")
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (!sharedWithCurrentUser)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UserDropDown(
                                selectedUsers: selectedUsers, item: item),
                            sharedWithCurrentUser
                                ? const SizedBox()
                                : SelectedUsers(
                                    selectedUsers: selectedUsers, item: item),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    isEdit = true;
                                    currentItem = item;
                                    showItemDialog(
                                        context, isEdit, currentItem);
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
          showItemDialog(context, isEdit, null);
        },
        tooltip: "Add item",
        child: const Icon(
          Icons.add,
          size: 50,
        ),
      ),
    );
  }

  Future<void> toggleStatus(BuildContext context, Item item) async {
    bool? confirmRemoval = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Removal'),
          content: Text('Are you sure you Done ${item.text} Mission?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmRemoval == true) {
      itemService.toggleStatus(item, itemService.currentAccount!);
    }
  }
}
