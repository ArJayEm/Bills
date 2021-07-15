import 'package:flutter/material.dart';

class Menu {
  String? location;
  String? route;
  Widget? view;
  Icon? icon;
  bool? isSelected;
  Menu(
      {this.location,
      this.route,
      this.view,
      this.icon,
      this.isSelected = false});
}
