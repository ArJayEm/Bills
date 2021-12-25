import 'package:bills/models/icon_data.dart';
import 'package:flutter/material.dart';

class Menu {
  String location;
  String? route;
  Widget view;
  Icon? icon;
  bool? isSelected = false;
  Function? onPressed;
  CustomIconData iconData;

  Menu(
      {required this.location,
      required this.view,
      this.icon,
      required this.iconData});
}
