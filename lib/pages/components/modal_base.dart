import 'package:flutter/material.dart';

Widget generateModalBody(Widget body, List<Widget> footer,
    {Widget? headWidget, String? header}) {
  return SafeArea(
    child: SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(top: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            headWidget == null
                ? Container(
                    margin: EdgeInsets.only(top: 10, bottom: 20),
                    child: Text(
                      header ?? '',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                    ),
                  )
                : headWidget,
            Container(
              child: Container(
                width: 30,
              ),
              alignment: Alignment.center,
            ),
            Container(
                margin: EdgeInsets.only(left: 20, right: 20), child: body),
            Container(
                margin: EdgeInsets.fromLTRB(20, 10, 20, 5),
                child: Row(children: footer.toList()))
          ],
        ),
      ),
    ),
  );
}
