import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:print_color/print_color.dart';

extension FunctionsGlobal on bool {
  bool updateProgressStatus({String? errMsg, String? msg}) {
    //if ((msg?.isNotEmpty ?? false) && (errMsg?.isNotEmpty ?? false)) {
    if (msg?.isNotEmpty ?? false) {
      Fluttertoast.showToast(msg: msg!);
    }
    if (errMsg?.isNotEmpty ?? false) {
      Fluttertoast.showToast(msg: "Something went wrong.");

      if (kDebugMode) {
        Print.red("errMsg: $errMsg");
      }
    }
    //}

    return !this;
  }
}

class FirebaseStorageErrorMessageForUser {
  static String getMessage(FirebaseException e) {
    String msg = e.message.toString();
    Print.red("File error: $msg");
    if (e.code == "unknown" ||
        e.code == "bucket-not-found" ||
        e.code == "project-not-found" ||
        e.code == "canceled" ||
        e.code == "unauthenticated") {
      msg = e.message.toString();
    }
    if (e.code == 'object-not-found') {
      msg = "File not found.";
    }
    if (e.code == "unauthenticated") {
      msg = "User is unauthenticated.";
    }
    if (e.code == "unauthorized") {
      msg = "User not authorized.";
    }
    if (e.code == "quota-exceeded") {
      msg = "Quota on Cloud Storage has been exceeded.";
    }
    return msg;
  }
}
