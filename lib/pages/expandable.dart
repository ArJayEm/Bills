import 'dart:math' as math;

import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

class ExpandableSample extends StatefulWidget {
  @override
  State createState() {
    return ExpandableSampleState();
  }
}

class ExpandableSampleState extends State<ExpandableSample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Expandable Demo"),
      ),
      body: ExpandableTheme(
        data: const ExpandableThemeData(
          iconColor: Colors.blue,
          useInkWell: true,
        ),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            _card1(context),
            _card2(context),
            _card3(context),
          ],
        ),
      ),
    );
  }
}

const loremIpsum =
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.";

Widget _card1(context) {
  return ExpandableNotifier(
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 150,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.rectangle,
                ),
              ),
            ),
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: const ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToCollapse: true,
                ),
                header: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "ExpandablePanel",
                      style: Theme.of(context).textTheme.bodyText1,
                    )),
                collapsed: Text(
                  loremIpsum,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                expanded: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (var _ in Iterable.generate(5))
                      Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          loremIpsum,
                          softWrap: true,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                  ],
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildImg(Color color, double height) {
  return SizedBox(
    height: height,
    child: Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.rectangle,
      ),
    ),
  );
}

Widget buildCollapsed1(context) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Expandable",
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ],
          ),
        ),
      ]);
}

Widget buildCollapsed2() {
  return buildImg(Colors.lightGreenAccent, 150);
}

Widget buildCollapsed3() {
  return Container();
}

Widget buildExpanded1(context) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Expandable",
                style: Theme.of(context).textTheme.bodyText2,
              ),
              Text(
                "3 Expandable widgets",
                style: Theme.of(context).textTheme.caption,
              ),
            ],
          ),
        ),
      ]);
}

Widget buildExpanded2() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(child: buildImg(Colors.lightGreenAccent, 100)),
          Expanded(child: buildImg(Colors.orange, 100)),
        ],
      ),
      Row(
        children: <Widget>[
          Expanded(child: buildImg(Colors.lightBlue, 100)),
          Expanded(child: buildImg(Colors.cyan, 100)),
        ],
      ),
    ],
  );
}

Widget buildExpanded3() {
  return Padding(
    padding: EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          loremIpsum,
          softWrap: true,
        ),
      ],
    ),
  );
}

Widget _card2(context) {
  return ExpandableNotifier(
    child: Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      child: ScrollOnExpand(
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expandable(
                collapsed: buildCollapsed1(context),
                expanded: buildExpanded1(context),
              ),
              Expandable(
                collapsed: buildCollapsed2(),
                expanded: buildExpanded2(),
              ),
              Expandable(
                collapsed: buildCollapsed3(),
                expanded: buildExpanded3(),
              ),
              Divider(
                height: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Builder(
                    builder: (context) {
                      var controller =
                          ExpandableController.of(context, required: true)!;
                      return TextButton(
                        child: Text(
                          controller.expanded ? "COLLAPSE" : "EXPAND",
                          style: Theme.of(context)
                              .textTheme
                              .button!
                              .copyWith(color: Colors.deepPurple),
                        ),
                        onPressed: () {
                          controller.toggle();
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget buildItem(String label) {
  return Padding(
    padding: const EdgeInsets.all(10.0),
    child: Text(label),
  );
}

Widget buildList() {
  return Column(
    children: <Widget>[
      for (var i in [1, 2, 3, 4]) buildItem("Item $i"),
    ],
  );
}

Widget _card3(context) {
  return ExpandableNotifier(
      child: Padding(
    padding: const EdgeInsets.all(10),
    child: ScrollOnExpand(
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: <Widget>[
            ExpandablePanel(
              theme: const ExpandableThemeData(
                headerAlignment: ExpandablePanelHeaderAlignment.center,
                tapBodyToExpand: true,
                tapBodyToCollapse: true,
                hasIcon: false,
              ),
              header: Container(
                color: Colors.indigoAccent,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      ExpandableIcon(
                        theme: const ExpandableThemeData(
                          expandIcon: Icons.arrow_right,
                          collapseIcon: Icons.arrow_drop_down,
                          iconColor: Colors.white,
                          iconSize: 28.0,
                          iconRotationAngle: math.pi / 2,
                          iconPadding: EdgeInsets.only(right: 5),
                          hasIcon: false,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Items",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              collapsed: Container(),
              expanded: buildList(),
            ),
          ],
        ),
      ),
    ),
  ));
}
