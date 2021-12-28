//import 'package:bills/pages/components/custom_pin_widget.dart';
import 'package:bills/pages/signin/pin/enter.dart';
import 'package:bills/pages/settings/settings_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EnterCurrent extends StatefulWidget {
  const EnterCurrent({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _EnterCurrentState createState() => _EnterCurrentState();
}

class _EnterCurrentState extends State<EnterCurrent> {
  late FirebaseAuth _auth;

  final _pinControllerFull = TextEditingController();
  final _pinController1 = TextEditingController();
  final _pinController2 = TextEditingController();
  final _pinController3 = TextEditingController();
  final _pinController4 = TextEditingController();
  final _pinController5 = TextEditingController();
  final _pinController6 = TextEditingController();

  final _pinFocusNode1 = FocusNode();
  final _pinFocusNode2 = FocusNode();
  final _pinFocusNode3 = FocusNode();
  final _pinFocusNode4 = FocusNode();
  final _pinFocusNode5 = FocusNode();
  final _pinFocusNode6 = FocusNode();

  bool _isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    setState(() {
      _auth = widget.auth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SettingsHome(auth: _auth, scaffoldKey: _scaffoldKey)),
            );
          },
          child: const Icon(Icons.arrow_back),
        ),
        iconTheme: IconThemeData(color: Colors.grey.shade300),
        //titleTextStyle: TextTheme(headline6: TextStyle(color: Colors.white, fontSize: 25)),
        title: const Text('Change PIN'),
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Center(
                    child: Text('Enter your current PIN',
                        style: TextStyle(fontSize: 20, color: Colors.white))),
                const SizedBox(height: 10),
                _getPinWidget(),
              ],
            ),
    );
  }

  Widget _getPinWidget() {
    return Row(
      children: [
        const Spacer(),
        Flexible(
          child: TextFormField(
            obscureText: true,
            controller: _pinController1,
            focusNode: _pinFocusNode1,
            autofocus: _pinControllerFull.text.isEmpty,
            style: const TextStyle(fontSize: 25),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            // onTap: () {
            //   FocusScope.of(context).requestFocus(_pinFocusNode1);
            // },
            onChanged: (value) {
              if (value.isEmpty) {
                _pinController1.text = "";
                _pinControllerFull.text = "";
                FocusScope.of(context).unfocus();
                //FocusScope.of(context).requestFocus(_pinFocusNode1);
              } else if (value.length == 1) {
                _pinController1.text = value;
                _pinControllerFull.text = '${_pinControllerFull.text}$value';
                FocusScope.of(context).requestFocus(_pinFocusNode2);
              } else {
                // String overValue = value.substring(1, 2);
                // value = value.substring(0, 1);
                // _pinController1.text = value;
                // _pinController2.text = overValue;
                // FocusScope.of(context).requestFocus(_pinFocusNode3);

                var splittedPin = value.split("");
                for (var i = 0; i < splittedPin.length; i++) {
                  if (i == 0) {
                    _pinController1.text = splittedPin[i];
                    FocusScope.of(context).requestFocus(_pinFocusNode2);
                  }
                  if (i == 1) {
                    _pinController2.text = splittedPin[i];
                    FocusScope.of(context).requestFocus(_pinFocusNode3);
                  }
                  if (i == 2) {
                    _pinController3.text = splittedPin[i];
                    FocusScope.of(context).requestFocus(_pinFocusNode4);
                  }
                  if (i == 3) {
                    _pinController4.text = splittedPin[i];
                    FocusScope.of(context).requestFocus(_pinFocusNode5);
                  }
                  if (i == 4) {
                    _pinController5.text = splittedPin[i];
                    FocusScope.of(context).requestFocus(_pinFocusNode6);
                  }
                  if (i == 5) {
                    _pinController6.text = splittedPin[i];
                    _pinControllerFull.text = splittedPin.join();
                    _verify();
                  }
                }
              }
              if (kDebugMode) {
                print('nom pin: ${_pinControllerFull.text}');
              }
            },
          ),
        ),
        const Spacer(),
        Flexible(
          child: TextFormField(
            obscureText: true,
            controller: _pinController2,
            focusNode: _pinFocusNode2,
            style: const TextStyle(fontSize: 25),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isEmpty) {
                _pinController2.text = "";
                _pinControllerFull.text =
                    _pinControllerFull.text.substring(0, 1);
                FocusScope.of(context).requestFocus(_pinFocusNode1);
              } else if (value.length == 1) {
                _pinController2.text = value;
                _pinControllerFull.text = '${_pinControllerFull.text}$value';
                FocusScope.of(context).requestFocus(_pinFocusNode3);
              } else {
                String overValue = value.substring(1, 2);
                value = value.substring(0, 1);
                _pinController2.text = value;
                _pinController3.text = overValue;
                _pinControllerFull.text =
                    '${_pinControllerFull.text}$overValue';
                FocusScope.of(context).requestFocus(_pinFocusNode4);
              }
              if (kDebugMode) {
                print('nom pin: ${_pinControllerFull.text}');
              }
            },
          ),
        ),
        const Spacer(),
        Flexible(
          child: TextFormField(
            obscureText: true,
            controller: _pinController3,
            focusNode: _pinFocusNode3,
            style: const TextStyle(fontSize: 25),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isEmpty) {
                _pinController3.text = "";
                _pinControllerFull.text =
                    _pinControllerFull.text.substring(0, 2);
                FocusScope.of(context).requestFocus(_pinFocusNode2);
              } else if (value.length == 1) {
                _pinController3.text = value;
                _pinControllerFull.text = '${_pinControllerFull.text}$value';
                FocusScope.of(context).requestFocus(_pinFocusNode4);
              } else {
                String overValue = value.substring(1, 2);
                value = value.substring(0, 1);
                _pinController3.text = value;
                _pinController4.text = overValue;
                _pinControllerFull.text =
                    '${_pinControllerFull.text}$overValue';
                FocusScope.of(context).requestFocus(_pinFocusNode5);
              }

              if (kDebugMode) {
                print('nom pin: ${_pinControllerFull.text}');
              }
            },
          ),
        ),
        const Spacer(),
        Flexible(
          child: TextFormField(
            obscureText: true,
            controller: _pinController4,
            focusNode: _pinFocusNode4,
            style: const TextStyle(fontSize: 25),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isEmpty) {
                _pinController4.text = "";
                _pinControllerFull.text =
                    _pinControllerFull.text.substring(0, 3);
                FocusScope.of(context).requestFocus(_pinFocusNode3);
              } else if (value.length == 1) {
                _pinController4.text = value;
                _pinControllerFull.text = '${_pinControllerFull.text}$value';
                FocusScope.of(context).requestFocus(_pinFocusNode5);
              } else {
                String overValue = value.substring(1, 2);
                value = value.substring(0, 1);
                _pinController4.text = value;
                _pinController5.text = overValue;
                _pinControllerFull.text =
                    '${_pinControllerFull.text}$overValue';
                FocusScope.of(context).requestFocus(_pinFocusNode6);
              }
              if (kDebugMode) {
                print('nom pin: ${_pinControllerFull.text}');
              }
            },
          ),
        ),
        const Spacer(),
        Flexible(
          child: TextFormField(
            obscureText: true,
            controller: _pinController5,
            focusNode: _pinFocusNode5,
            style: const TextStyle(fontSize: 25),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isEmpty) {
                _pinController5.text = "";
                _pinControllerFull.text =
                    _pinControllerFull.text.substring(0, 4);
                FocusScope.of(context).requestFocus(_pinFocusNode4);
              } else if (value.length == 1) {
                _pinController5.text = value;
                _pinControllerFull.text = '${_pinControllerFull.text}$value';
                FocusScope.of(context).requestFocus(_pinFocusNode6);
              } else {
                String overValue = value.substring(1, 2);
                value = value.substring(0, 1);
                _pinController5.text = value;
                _pinController6.text = overValue;
                _pinControllerFull.text =
                    '${_pinControllerFull.text}$overValue';
                FocusScope.of(context).requestFocus(_pinFocusNode6);
                _verify();
              }

              if (kDebugMode) {
                print('nom pin: ${_pinControllerFull.text}');
              }
            },
          ),
        ),
        const Spacer(),
        Flexible(
          child: TextFormField(
            obscureText: true,
            controller: _pinController6,
            focusNode: _pinFocusNode6,
            style: const TextStyle(fontSize: 25),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.isEmpty) {
                _pinController6.text = "";
                _pinControllerFull.text =
                    _pinControllerFull.text.substring(0, 5);
                FocusScope.of(context).requestFocus(_pinFocusNode5);
              } else if (value.length == 1) {
                _pinController6.text = value;
                _pinControllerFull.text = '${_pinControllerFull.text}$value';
                FocusScope.of(context).unfocus();
                _verify();
              } else {
                value = value.substring(0, 1);
                _pinController6.text = value;
                FocusScope.of(context).unfocus();
                _verify();
              }
              if (kDebugMode) {
                print('nom pin: ${_pinControllerFull.text}');
              }
            },
          ),
        ),
        const Spacer(),
      ],
    );
  }

  // Widget _getPinFormWidget() {
  //   return Row(
  //     children: [
  //       Spacer(),
  //       CustomPinWidget(
  //         controllerSingle: _pinController1,
  //         controllerAll: _pinControllerFull,
  //         focusNode: _pinFocusNode1,
  //         focusNodeNext: _pinFocusNode2,
  //         isFirst: true,
  //         isLast: false,
  //         onChanged: _verify(),
  //       ),
  //       Spacer(),
  //       CustomPinWidget(
  //         controllerSingle: _pinController2,
  //         controllerAll: _pinControllerFull,
  //         focusNode: _pinFocusNode2,
  //         focusNodeNext: _pinFocusNode3,
  //         isFirst: false,
  //         isLast: false,
  //         onChanged: _verify(),
  //       ),
  //       Spacer(),
  //       CustomPinWidget(
  //         controllerSingle: _pinController3,
  //         controllerAll: _pinControllerFull,
  //         focusNode: _pinFocusNode3,
  //         focusNodeNext: _pinFocusNode4,
  //         isFirst: false,
  //         isLast: false,
  //         onChanged: _verify(),
  //       ),
  //       Spacer(),
  //       CustomPinWidget(
  //         controllerSingle: _pinController4,
  //         controllerAll: _pinControllerFull,
  //         focusNode: _pinFocusNode4,
  //         focusNodeNext: _pinFocusNode5,
  //         isFirst: false,
  //         isLast: false,
  //         onChanged: _verify(),
  //       ),
  //       Spacer(),
  //       CustomPinWidget(
  //         controllerSingle: _pinController5,
  //         controllerAll: _pinControllerFull,
  //         focusNode: _pinFocusNode5,
  //         focusNodeNext: _pinFocusNode6,
  //         isFirst: false,
  //         isLast: false,
  //         onChanged: _verify(),
  //       ),
  //       Spacer(),
  //       CustomPinWidget(
  //         controllerSingle: _pinController6,
  //         controllerAll: _pinControllerFull,
  //         focusNode: _pinFocusNode6,
  //         focusNodeNext: _pinFocusNode6,
  //         isFirst: false,
  //         isLast: true,
  //         onChanged: _verify(),
  //       ),
  //       Spacer(),
  //     ],
  //   );
  // }

  _verify() async {
    _showProgressUi(true, "");

    try {
      DocumentReference _document = FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid);
      String? pin;

      _document.get().then((snapshot) {
        if (snapshot.exists) {
          pin = snapshot.get("pin") as String?;
        }
      }).whenComplete(() {
        if (pin == _pinControllerFull.text) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EnterMpin(
                      auth: _auth, isChange: true, nominatedPin: '')));
        } else {
          // setState(() {
          //   _pinControllerFull.clear();
          //   _pinController1.clear();
          //   _pinController2.clear();
          //   _pinController3.clear();
          //   _pinController4.clear();
          //   _pinController5.clear();
          //   _pinController6.clear();
          //   FocusScope.of(context).requestFocus(_pinFocusNode1);
          // });
          FocusScope.of(context).requestFocus(_pinFocusNode6);
          _showProgressUi(false, "Incorrect pin.");
        }
      });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  _showProgressUi(bool isLoading, String msg) {
    if (msg.isNotEmpty) {
      Fluttertoast.showToast(msg: msg);
    }
    setState(() => _isLoading = isLoading);
  }
}
