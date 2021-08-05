import 'package:flutter/material.dart';

Widget generateModalBody(Widget body, List<Widget> footer,
    {Widget? headWidget, String? header}) {
  return SafeArea(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          headWidget == null
              ? Container(
                  child: Text(
                    header ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                )
              : headWidget,
          Divider(),
          Container(margin: EdgeInsets.only(left: 20, right: 20), child: body),
          Container(
            margin: EdgeInsets.fromLTRB(20, 10, 20, 5),
            child: Row(
              children: footer.toList(),
            ),
          ),
        ],
      ),
    ),
  );
}
