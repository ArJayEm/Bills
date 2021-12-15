import 'package:flutter/material.dart';

Widget generateModalBody(Widget body, List<Widget> footer,
    {Widget? headWidget, String? header}) {
  return SafeArea(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          headWidget ?? Text(
            header ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const Divider(),
          Container(margin: const EdgeInsets.only(left: 20, right: 20), child: body),
          Container(
            margin: const EdgeInsets.fromLTRB(20, 10, 20, 5),
            child: Row(
              children: footer.toList(),
            ),
          ),
        ],
      ),
    ),
  );
}
