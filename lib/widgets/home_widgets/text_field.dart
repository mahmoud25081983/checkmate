import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final String label;
  final String? placeholder;
  final bool isRequired;
  final Function(String?)? onSaved;

  const CustomTextFormField({
    Key? key,
    required this.label,
    this.placeholder,
    this.isRequired = false,
    this.onSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }
}
