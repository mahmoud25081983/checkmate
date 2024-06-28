import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../../schemas/account.dart';
import '../../schemas/item.dart';
import '../../services/realm_service.dart';
class SelectedUsers extends StatelessWidget {
  const SelectedUsers({
    super.key,
    required this.selectedUsers,
    required this.item,
  });

  final Map<ObjectId, List<Account>> selectedUsers;
  final Item item;

  @override
  Widget build(BuildContext context) {
    final itemService = Provider.of<ItemService>(context, listen: false);
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
                  itemService.removeItemFromUser(user, item);
                  selectedUsers[item.id]?.remove(user);
                  // Remove user from the database
                },
              ))
          .toList(),
    );
  }
}
