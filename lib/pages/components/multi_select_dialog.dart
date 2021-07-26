import 'package:flutter/material.dart';

class MultiSelectDialog extends StatelessWidget {
  final Widget question;
  final List<dynamic> answers;

  final List<String> selectedItems = [];
  final List<String> selectedIds = [];
  static Map<String, bool> mappedItem = Map<String, bool>();

  MultiSelectDialog({required this.answers, required this.question});

  /// Function that converts the list answer to a map.
  Map<String, bool> initMap() {
    return mappedItem = Map.fromIterable(answers,
        key: (k) => k.toString(),
        value: (v) {
          if (v != true && v != false)
            return false;
          else
            return v as bool;
        });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unnecessary_null_comparison
    if (mappedItem.length == 0) {
      initMap();
    }
    return SimpleDialog(
      title: question,
      children: [
        ...mappedItem.keys.map(
          (String key) {
            return StatefulBuilder(
              builder: (_, StateSetter setState) => CheckboxListTile(
                  title: Text(key), // Displays the option
                  value: mappedItem[key], // Displays checked or unchecked value
                  controlAffinity: ListTileControlAffinity.platform,
                  onChanged: (value) {
                    setState(() {
                      mappedItem[key] = value!;
                    });
                  }),
            );
          },
        ).toList(),
        SizedBox(height: 10),
        Container(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: ElevatedButton(
            child: Text('Submit'),
            style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 40)),
            onPressed: () {
              selectedItems.clear();
              mappedItem.forEach((key, value) {
                if (value == true) {
                  selectedItems.add(key);
                }
              });
              Navigator.pop(context, selectedItems);
            },
          ),
        ),
      ],
    );
  }
}
