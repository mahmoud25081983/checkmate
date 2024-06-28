import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realm/realm.dart';

import '../../schemas/item.dart';
import '../../services/realm_service.dart';



class ItemDialog extends StatelessWidget {
  final bool isEdit;
  final Item? currentItem;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ItemDialog({
    Key? key,
    required this.isEdit,
    this.currentItem,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    late String itemName;
   final itemService = Provider.of<ItemService>(context, listen: false);

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
                    placeholder: isEdit ? currentItem!.text : "Enter item name",
                    isRequired: true,
                    onSaved: (value) {
                      itemName = value!;
                    },
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(10)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          if (kDebugMode) {
                            print(itemName);
                          }
                          if (!isEdit) {
                            itemService.add(itemName);
                          } else {
                            itemService.updateItem(currentItem!, itemName);
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        isEdit ? "Edit" : "Add",
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
      {String? placeholder, bool isRequired = false, Function(String?)? onSaved}) {
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
  
}

Future<void> showItemDialog(
    BuildContext context, bool isEdit, Item? currentItem) {
  return showDialog(
    context: context,
    builder: (context) {
      return ItemDialog(
        isEdit: isEdit,
        currentItem: currentItem,
      );
    },
  );
}
