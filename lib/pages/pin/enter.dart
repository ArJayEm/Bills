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
  String _errorMsg = "";

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
                var splittedPin = value.split("");
                _splitPin(splittedPin);
              }
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
          ),
        ),
        Spacer(),
      ],
    );
  }

  _reEnter() async {
    setState(() {
      _errorMsg = "";
      _isLoading = true;
    });

    try {
      DocumentReference _document = FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid);
      String? pin;

      _document.get().then((snapshot) {
        if (snapshot.exists) {
          pin = snapshot.get('mpin');
        }
      }).whenComplete(() {
        if (pin == _pinControllerFull.text) {
          Fluttertoast.showToast(
              msg: "Your new PIN must not be the same as your current PIN");
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
      _errorMsg = e.toString();
    } catch (e) {
      _errorMsg = e.toString();
    }

    setState(() => _isLoading = false);
    if (_errorMsg.length > 0) {
      Fluttertoast.showToast(msg: _errorMsg);
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
}
