import 'package:checkmate/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:checkmate/schemas/account.dart';
import '../services/realm_service.dart';
import 'package:checkmate/services/user_service.dart';
import 'package:realm/realm.dart';
import 'splash.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
 static const String routeName = 'profilescreen';
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Account> _searchResults = [];

  late UserService userService;
  late ItemService itemService;
  late Account currentUserAccount;

  @override
  void initState() {
    super.initState();
    itemService = Provider.of<ItemService>(context, listen: false);
    currentUserAccount = itemService.getCurrentUser();
  }

  void _search(String query) {
    var results = itemService.searchAccounts(query);
    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    itemService = Provider.of<ItemService>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                final navigator = Navigator.of(context);
                navigator.pushReplacement(
                  MaterialPageRoute(builder: (BuildContext context) {
                    return const HomeScreen();
                  }),
                );
              } on RealmException catch (error) {
                print("Error during logout ${error.message}");
              }
            },
            icon: const Icon(
              Icons.logout,
              size: 30,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search by email or name',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, size: 30),
                    onPressed: () => _search(_searchController.text),
                  ),
                ),
                onChanged: (value) => _search(value),
              ),
            ),
            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  var account = _searchResults[index];
                  return ListTile(
                    title: Text(account.email),
                    subtitle: Text(account.name),
                    trailing: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        itemService.addUserToFreinds(
                            account, currentUserAccount);
                      },
                    ),
                  );
                },
              ),
            ),
            Wrap(
              direction: Axis.horizontal,
              alignment: WrapAlignment.start,
              spacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: itemService
                  .getFriends()
                  .map((AddedUser) => Chip(
                        padding: EdgeInsets.zero,
                        label: Text("${AddedUser.name} ${AddedUser.email}"),
                        onDeleted: () {
                          itemService.removeFreind(
                              AddedUser, currentUserAccount);
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            if (currentUserAccount != null) ...[
              ListTile(
                title: Text('Email ${currentUserAccount!.email}'),
              ),
              ListTile(
                title: Text('Name ${currentUserAccount!.name}'),
              ),
            ] else ...[
              const Center(child: CircularProgressIndicator()),
            ],
            IconButton(
              onPressed: () async {
                try {
                  final navigator = Navigator.of(context);
                  await userService.logoutUser();
                  await userService.deleteUserFromAppService();
                  await itemService.close();
                  navigator.pushReplacement(
                    MaterialPageRoute(builder: (BuildContext context) {
                      return const SplashScreen();
                    }),
                  );
                } on RealmException catch (error) {
                  print("Error during logout ${error.message}");
                }
              },
              icon: const Icon(
                Icons.delete_forever,
                size: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
