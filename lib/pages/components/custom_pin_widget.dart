import 'package:flutter/material.dart';

class CustomPinWidget extends StatelessWidget {
  final TextEditingController controllerSingle;
  final TextEditingController controllerAll;
  final FocusNode focusNode;
  final FocusNode focusNodeNext;
  final bool isFirst;
  final bool isLast;
  //final VoidCallback onTap;
  final VoidCallback onChanged;

  CustomPinWidget(
      {required this.controllerSingle,
      required this.controllerAll,
      required this.focusNode,
      required this.focusNodeNext,
      //required this.onTap,
      required this.onChanged,
      required this.isFirst,
      required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: TextFormField(
        obscureText: true,
        controller: controllerSingle,
        focusNode: focusNode,
        autofocus: controllerAll.text.length == 0,
        style: TextStyle(fontSize: 25),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        onChanged: (value) {
          if (value.length == 0) {
            controllerSingle.text = "";
            controllerAll.text = "";
            if (isFirst) {
              FocusScope.of(context).unfocus();
            } else {
              FocusScope.of(context).requestFocus(focusNodeNext);
            }
          } else if (value.length == 1) {
            controllerSingle.text = value;
            controllerAll.text = '${controllerAll.text}$value';
            if (isLast) {
              FocusScope.of(context).unfocus();
              onChanged();
            } else {
              FocusScope.of(context).requestFocus(focusNodeNext);
            }
          } else {
            if (isLast) {
              value = value.substring(0, 1);
              controllerSingle.text = value;
              FocusScope.of(context).unfocus();
              onChanged();
            } else {
              FocusScope.of(context).requestFocus(focusNodeNext);
            }
            //_splitPin(value.split(""));
          }
        },
        onTap: () {
          controllerSingle.selection = TextSelection(
              baseOffset: 1, extentOffset: controllerSingle.text.length);
        },
      ),
    );
  }
}
