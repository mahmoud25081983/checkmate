import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../schemas/account.dart';
import '../../schemas/item.dart';
import '../../services/realm_service.dart';
import 'package:realm/realm.dart';





class UserDropDown extends StatelessWidget {
  const UserDropDown({
    super.key,
    required this.selectedUsers,
    required this.item,
  });

  final Map<ObjectId, List<Account>> selectedUsers;
  final Item item;

  @override
  Widget build(BuildContext context) {
/*     List<Account> otherUsers = users
        .where((user) => user.userId != userService.currentUser?.id)
        .toList();
 */
   final itemService = Provider.of<ItemService>(context, listen: false);

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
          itemService.newItemsSharesWithThisUser(user, item);
          if (selectedUsers[item.id] == null) {
            selectedUsers[item.id] = [];
          }

          selectedUsers[item.id]!
              .add(user); // Add the selected user to the list for this item
        }
      },
    );
  }
}