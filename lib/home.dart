import 'package:checkmate/schemas/account.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:realm/realm.dart';
import 'package:checkmate/services/item_service.dart';
import 'package:checkmate/services/user_service.dart';
import 'package:checkmate/splash.dart';
import 'package:checkmate/schemas/item.dart';

class HomeScreen extends StatefulWidget {
  final ItemService itemService;
  final UserService userService;

  const HomeScreen(
      {Key? key, required this.itemService, required this.userService})
      : super(key: key);

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

  @override
  void initState() {
    super.initState();
    allItems = widget.itemService.getItems();
    users = widget.itemService.getUsers();
    // currentUser = widget.itemService.getCurrentUser();
    //  print("${currentUser.email}");

    //currentAccount = widget.itemService.getCurrentUser();
    //_fetchUsers();
  }

  Future<void> _fetchUsers() async {
    users = await widget.itemService.getUsers();
    setState(() {});
  }

  void _fetchSharedUsers(Item item) {
    sharedUsersIds = widget.itemService.getUsersSharedWith(item);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("${widget.userService.atlasApp.currentUser!.profile.email}"),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                final navigator = Navigator.of(context);
                await widget.userService.logoutUser();
                //  await widget.itemService .deleteAccount(currentUser);
                await widget.userService.deleteUserFromAppService();

                // widget.itemService.close(); // Close the Realm instance

                navigator.pushReplacement(
                  MaterialPageRoute(builder: (BuildContext context) {
                    return SplashScreen(userService: widget.userService);
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
                await widget.userService.logoutUser();
                // widget.itemService.close(); // Close the Realm instance

                navigator.pushReplacement(
                  MaterialPageRoute(builder: (BuildContext context) {
                    return SplashScreen(userService: widget.userService);
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
              final createdByUser = widget.itemService.getCreatedByUser(item);
              final sharedWithCurrentUser =
                  widget.itemService.isSharedWithCurrentUser(item);
              /*            final isMine =
                  item.userId != currentUser.userId
                      ? ""
                      : "(Mine)"; */

              final isMine = (item.userId == widget.userService.currentUser?.id);

              return Card(
                margin: EdgeInsets.all(8.0),
                color: item.isDone ? Colors.green.shade50 : Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
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
                              widget.itemService.toggleStatus(item);
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
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      _buildUserDropdown(item),
                      _buildSelectedUsers(item),
                      if (!sharedWithCurrentUser)
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
                              icon: Icon(Icons.edit),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red.shade500,
                                semanticLabel: "Delete item",
                              ),
                              onPressed: () {
                                widget.itemService.delete(item);
                              },
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
                            widget.itemService.add(itemName);
                          } else if (isEdit == true) {
                            widget.itemService
                                .updateItem(currentItem, itemName);
                          }
                          setState(() {});
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        isEdit == true ? "Edit" : "Add",
                        style: TextStyle(fontSize: 20),
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
     List<Account> otherUsers =
        users.where((user) => user.userId != widget.userService.currentUser?.id).toList(); 

    return DropdownButton<Account>(
      hint: Text("Share with..."), // Display hint
      value: null, // Set the current user as the initial selected value
      items: otherUsers.map((Account user) {
        return DropdownMenuItem<Account>(
          value: user,
          child: Text(
              "${user.name} ${user.email}"), // Assuming email is used to display user
        );
      }).toList(),
      onChanged: (Account? user) {
        if (user != null) {
          widget.itemService.shareItemWithUser(item, user);
          if (selectedUsers[item.id] == null) {
            selectedUsers[item.id] = [];
          }
          setState(() {
            selectedUsers[item.id]!
                .add(user); // Add the selected user to the list for this item
          });
        }
      },
    );
  }

  Widget _buildSelectedUsers(Item item) {
    // Check if the item is shared with the current user
    bool sharedWithCurrentUser =
        item.sharedWith.contains(widget.userService.currentUser!.id);

    // If the item is shared with the current user, display the users it is shared with
    if (sharedWithCurrentUser) {
      return SizedBox();
    } else {
      // If the item is not shared with the current user, return an empty widget
      return Wrap(
        direction: Axis.vertical,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: widget.itemService
            .getUsersSharedWith(item)
            .map((user) => Chip(
                  padding: EdgeInsets.zero,
                  label: Text("${user.name + " " + user.email}"),
                  onDeleted: () {
                    widget.itemService.removeSharedUser(item, user);
                    selectedUsers[item.id]?.remove(user);
                    // Remove user from the database
                  },
                ))
            .toList(),
      );
    }
  }
}
