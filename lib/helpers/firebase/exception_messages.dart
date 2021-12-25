import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/foundation.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:print_color/print_color.dart';

class ExceptionMessages {
  String authExceptionMessage(FirebaseAuthException e) {
    String msg = e.message.toString();
    Print.red("Authentication error: $msg");
    if (e.code == "user-not-found" || e.code == "email-already-in-use") {
      msg = e.message.toString();
    } else {
      msg = "Something went wrong.";
    }
    return msg;
  }
}
