import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:print_color/print_color.dart';

extension FunctionsGlobal on bool {
  bool updateProgressStatus({String? errMsg, String? msg}) {
    if (msg?.isNotEmpty ?? false) {
      Fluttertoast.showToast(msg: msg!);
    }
    if (errMsg?.isNotEmpty ?? false) {
      Fluttertoast.showToast(msg: "Something went wrong.");
      printError(errMsg!);
    }

    return !this;
  }
}

void printIfDebug(dynamic msg, {String desc = "message: "}) {
  if (kDebugMode) {
    Print.green("$desc$msg");
  }
}

void printError(String errMsg) {
  if (kDebugMode) {
    Print.red("errMsg: $errMsg");
  }
}

void printMessage(String msg, {String desc = "message: "}) {
  if (kDebugMode) {
    Print.green("$desc$msg");
  }
}

class ExceptionHandler {
  static Future<void> writeLogs(String errMsg) async {
    //Write to logs.txt
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final file = File('${appDocDir.path}/logs.txt');
      String text = await file.readAsString();
      text += "\n" + errMsg;
      await file.writeAsString(text);
    } catch (e) {
      printError("Couldn't read file. $e.");
    }
  }

  static Future<String> readLogs() async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/logs.txt');
      return await file.readAsString();
    } catch (e) {
      String errMsg = "Couldn't read file. $e.";
      printError(errMsg);
      return errMsg;
    }
  }
}

String getFirebaseStorageErrorMessage(FirebaseException e) {
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
