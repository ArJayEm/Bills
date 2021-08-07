//import 'package:bills/pages/components/custom_pin_widget.dart';
import 'package:bills/pages/pin/reenter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum PinVerificationState { ENTER_OTP, NOMINATE_PIN, CHANGE_PIN }

class EnterMpin extends StatefulWidget {
  EnterMpin(
      {Key? key,
      required this.auth,
      required this.isChange,
      required this.nominatedPin})
      : super(key: key);

  final FirebaseAuth auth;
  final bool isChange;
  final String nominatedPin;

  @override
  _EnterMpinState createState() => _EnterMpinState();
}

class _EnterMpinState extends State<EnterMpin> {
  late FirebaseAuth _auth;
  late bool _isChange;
  PinVerificationState _pinVerificationState =
      PinVerificationState.NOMINATE_PIN;

  String _title = '';
  String _text = '';

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
      _isChange = widget.isChange;
      _pinVerificationState =
          _isChange ? PinVerificationState.CHANGE_PIN : _pinVerificationState;

      if (_pinVerificationState == PinVerificationState.CHANGE_PIN) {
        _title = 'Change PIN';
        _text = 'Nominate new PIN';
      } else {
        _title = 'Nominate PIN';
        _text = 'Nominate your PIN';
      }

      if (widget.nominatedPin.length > 0) {
        //FocusScope.of(context).requestFocus(_pinFocusNode1);
        //_pinController1.value = widget.nominatedPin;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          // leading: GestureDetector(
          //   onTap: () {
          //     Navigator.pop(context);
          //     if (_pinVerificationState == PinVerificationState.CHANGE_PIN) {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => SettingsPage(auth: _auth)),
          //       );
          //     } else {
          //       // _errorMsg = "'Unable to navigate back');
          //     }
          //   },
          //   child: Icon(Icons.arrow_back),
          // ),
          iconTheme: IconThemeData(color: Colors.grey.shade300),
          textTheme: TextTheme(
              headline6: TextStyle(color: Colors.white, fontSize: 25)),
          title: Text(_title),
          titleSpacing: 0,
          centerTitle: false,
          backgroundColor: Colors.grey.shade800,
          elevation: 0,
        ),
        body: SafeArea(
          child: Container(
            color: Colors.grey.shade800,
            padding: EdgeInsets.all(20),
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 20),
                      Center(
                          child: Text(_text,
                              style: TextStyle(
                                  fontSize: 20, color: Colors.white))),
                      SizedBox(height: 10),
                      _getPinWidget(),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          if (_pinControllerFull.text.length >= 6) {
                            _reEnter();
                          }
                        },
                        child: Text('Next'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 40),
                          textStyle: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
          ),
        ),
      ),
      onWillPop: () async => _isChange,
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
  //         onChanged: _reEnter(),
  //       ),
  //       Spacer(),
  //       CustomPinWidget(
  //         controllerSingle: _pinController2,
  //         controllerAll: _pinControllerFull,
  //         focusNode: _pinFocusNode2,
  //         focusNodeNext: _pinFocusNode3,
  //         isFirst: false,
  //         isLast: false,
  //         onChanged: _reEnter(),
  //       ),
  //       Spacer(),
  //       CustomPinWidget(
  //         controllerSingle: _pinController3,
  //         controllerAll: _pinControllerFull,
  //         focusNode: _pinFocusNode3,
  //         focusNodeNext: _pinFocusNode4,
  //         isFirst: false,
  //         isLast: false,
  //         onChanged: _reEnter(),
  //       ),
  //       Spacer(),
  //       CustomPinWidget(
  //         controllerSingle: _pinController4,
  //         controllerAll: _pinControllerFull,
  //         focusNode: _pinFocusNode4,
  //         focusNodeNext: _pinFocusNode5,
  //         isFirst: false,
  //         isLast: false,
  //         onChanged: _reEnter(),
  //       ),
  //       Spacer(),
  //       CustomPinWidget(
  //         controllerSingle: _pinController5,
  //         controllerAll: _pinControllerFull,
  //         focusNode: _pinFocusNode5,
  //         focusNodeNext: _pinFocusNode6,
  //         isFirst: false,
  //         isLast: false,
  //         onChanged: _reEnter(),
  //       ),
  //       Spacer(),
  //       CustomPinWidget(
  //         controllerSingle: _pinController6,
  //         controllerAll: _pinControllerFull,
  //         focusNode: _pinFocusNode6,
  //         focusNodeNext: _pinFocusNode6,
  //         isFirst: false,
  //         isLast: true,
  //         onChanged: _reEnter(),
  //       ),
  //       Spacer(),
  //     ],
  //   );
  // }

  Widget _getPinWidget() {
    return Row(
      children: [
        Spacer(),
        Flexible(
          child: TextFormField(
            obscureText: true,
            controller: _pinController1,
            focusNode: _pinFocusNode1,
            autofocus: _pinControllerFull.text.length == 0,
            style: TextStyle(fontSize: 25),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.length == 0) {
                _pinController1.text = "";
                _pinControllerFull.text = "";
                FocusScope.of(context).unfocus();
                //FocusScope.of(context).requestFocus(_pinFocusNode1);
              } else if (value.length == 1) {
                _pinController1.text = value;
                _pinControllerFull.text = '${_pinControllerFull.text}$value';
                FocusScope.of(context).requestFocus(_pinFocusNode2);
              } else {
                _splitPin(value.split(""));
              }
            },
            onTap: () {
              _pinController1.selection = TextSelection(
                  baseOffset: 1, extentOffset: _pinController1.text.length);
            },
          ),
        ),
        Spacer(),
        Flexible(
          child: TextFormField(
            obscureText: true,
            controller: _pinController2,
            focusNode: _pinFocusNode2,
            style: TextStyle(fontSize: 25),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.length == 0) {
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
                _pinControllerFull.text += value;
                FocusScope.of(context).requestFocus(_pinFocusNode4);
              }
            },
            onTap: () {
              _pinController2.selection = TextSelection(
                  baseOffset: 1, extentOffset: _pinController2.text.length);
            },
          ),
        ),
        Spacer(),
        Flexible(
          child: TextFormField(
            obscureText: true,
            controller: _pinController3,
            focusNode: _pinFocusNode3,
            style: TextStyle(fontSize: 25),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.length == 0) {
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
                _pinControllerFull.text += value;
                FocusScope.of(context).requestFocus(_pinFocusNode5);
              }
            },
            onTap: () {
              _pinController3.selection = TextSelection(
                  baseOffset: 1, extentOffset: _pinController3.text.length);
            },
          ),
        ),
        Spacer(),
        Flexible(
          child: TextFormField(
            obscureText: true,
            controller: _pinController4,
            focusNode: _pinFocusNode4,
            style: TextStyle(fontSize: 25),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.length == 0) {
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
                _pinControllerFull.text += value;
                FocusScope.of(context).requestFocus(_pinFocusNode6);
              }
            },
            onTap: () {
              _pinController4.selection = TextSelection(
                  baseOffset: 1, extentOffset: _pinController4.text.length);
            },
          ),
        ),
        Spacer(),
        Flexible(
          child: TextFormField(
            obscureText: true,
            controller: _pinController5,
            focusNode: _pinFocusNode5,
            style: TextStyle(fontSize: 25),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.length == 0) {
                _pinController5.text = "";
                _pinControllerFull.text =
                    _pinControllerFull.text.substring(0, 4);
                FocusScope.of(context).requestFocus(_pinFocusNode4);
              } else if (value.length == 1) {
                _pinController5.text = value;
                _pinControllerFull.text += value;
                FocusScope.of(context).requestFocus(_pinFocusNode6);
              } else {
                String overValue = value.substring(1, 2);
                value = value.substring(0, 1);
                _pinController5.text = value;
                _pinController6.text = overValue;
                _pinControllerFull.text += value;
                FocusScope.of(context).requestFocus(_pinFocusNode6);
                //_autoValidate();
              }
            },
            onTap: () {
              _pinController5.selection = TextSelection(
                  baseOffset: 1, extentOffset: _pinController5.text.length);
            },
          ),
        ),
        Spacer(),
        Flexible(
          child: TextFormField(
            obscureText: true,
            controller: _pinController6,
            focusNode: _pinFocusNode6,
            style: TextStyle(fontSize: 25),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              if (value.length == 0) {
                _pinController6.text = "";
                _pinControllerFull.text =
                    _pinControllerFull.text.substring(0, 5);
                FocusScope.of(context).requestFocus(_pinFocusNode5);
              } else if (value.length == 1) {
                _pinController6.text = value;
                _pinControllerFull.text = '${_pinControllerFull.text}$value';
                FocusScope.of(context).unfocus();
                //_autoValidate();
              } else {
                value = value.substring(0, 1);
                _pinController6.text = value;
                FocusScope.of(context).unfocus();
                //_autoValidate();
              }
            },
            onTap: () {
              _pinController6.selection = TextSelection(
                  baseOffset: 1, extentOffset: _pinController6.text.length);
            },
          ),
        ),
        Spacer(),
      ],
    );
  }

  _reEnter() async {
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
          _showProgressUi(
              false, "Your new PIN must not be the same as your current PIN");
        } else {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReenterMpin(
                      auth: _auth,
                      isChange: _isChange,
                      nominatedPin: _pinControllerFull.text)));
        }
      });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  void _splitPin(List<String> splittedPin) {
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
        //_autoValidate();
      }
    }
  }

  _showProgressUi(bool isLoading, String msg) {
    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
    setState(() => _isLoading = isLoading);
  }
}
