import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:print_color/print_color.dart';

extension FunctionsGlobal on bool {
  bool updateProgressStatus({String? errMsg, String? msg}) {
    bool status = false;

    if (msg?.isNotEmpty == false) {
      Fluttertoast.showToast(msg: msg!);
      status = !this;
    }
    if (errMsg?.isNotEmpty == false) {
      Fluttertoast.showToast(msg: "Something went wrong.");

      if (kDebugMode) {
        Print.red("msg: $errMsg");
      }
      status = !this;
    }

    return status;
  }
}
