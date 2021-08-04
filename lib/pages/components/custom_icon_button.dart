import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  final Color color;
  final Color textColor;
  final ImageProvider image;
  final String text;
  final VoidCallback onPressed;

  CustomIconButton(
      {required this.color,
      required this.textColor,
      required this.image,
      required this.text,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: color,
          ),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Row(
            children: [
              const SizedBox(width: 5),
              Image(image: image, width: 25),
              const SizedBox(width: 10),
              Expanded(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(width: 35)
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}

class CustomAppBarButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color checkedColor;
  final Color uncheckedColor;
  final bool isChecked;

  CustomAppBarButton(
      {required this.icon,
      required this.onTap,
      required this.uncheckedColor,
      required this.checkedColor,
      required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 20.0),
      child: GestureDetector(
        onTap: onTap,
        child: Icon(icon, size: 26.0, color: isChecked ? checkedColor : uncheckedColor),
      ),
    );
  }
}
