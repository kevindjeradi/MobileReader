// novel_url_field.dart
import 'package:flutter/material.dart';

class NovelUrlField extends StatelessWidget {
  final Function(String) onSaved;

  const NovelUrlField({Key? key, required this.onSaved}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'URL du novel'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Entrez l'URL du novel";
        }
        return null;
      },
      onSaved: (value) => onSaved(value!),
    );
  }
}
