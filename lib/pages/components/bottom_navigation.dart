import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      clipBehavior: Clip.hardEdge,
      elevation: 9.0,
      shape: CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 22, 0, 19),
          ),
        ],
      ),
    );
  }
}

class CustomFloatingActionButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color color;
  //final bool isLoading;
  final Function()? onTap;

  const CustomFloatingActionButton({required this.title, required this.color, this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        backgroundColor: color,
        onPressed: onTap,
        tooltip: title,
        child: Icon(icon, color: Colors.white),
      );
  }
}
