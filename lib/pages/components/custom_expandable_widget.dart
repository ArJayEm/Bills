import 'package:bills/pages/styles/style.dart';
import 'package:flutter/material.dart';

class CustomExpandableWidget extends StatefulWidget {
  final String title;
  final Widget body;
  final bool isExpanded;

  const CustomExpandableWidget(
      {required this.title, required this.body, required this.isExpanded});

  @override
  _CustomExpandableWidgetState createState() => _CustomExpandableWidgetState();
}

class _CustomExpandableWidgetState extends State<CustomExpandableWidget> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isExpanded = widget.isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Theme.of(context).cardColor),
      child: ConstrainedBox(
        constraints: new BoxConstraints(
          minHeight: _isExpanded ? 100 : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              child: Container(
                margin:
                    EdgeInsets.only(top: 12, left: 15, right: 15, bottom: 12),
                child: Text(
                  widget.title,
                  style: cardTitleStyle3,
                ),
              ),
              onTap: () => setState(() {
                _isExpanded = !_isExpanded;
              }),
            ),
            ..._isExpanded
                ? <Widget>[Divider(thickness: 1, height: 0), widget.body]
                : <Widget>[]
          ],
        ),
      ),
    );
  }
}
