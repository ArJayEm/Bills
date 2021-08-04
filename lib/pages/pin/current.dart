import 'package:bills/pages/pin/enter.dart';
import 'package:bills/pages/settings/settings_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  String _errorMsg = "";

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
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SettingsHome(auth: _auth)),
            );
          },
          child: Icon(Icons.arrow_back),
        ),
        iconTheme: IconThemeData(color: Colors.grey.shade300),
        textTheme:
            TextTheme(headline6: TextStyle(color: Colors.white, fontSize: 25)),
        title: Text('Change PIN'),
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _getPinWidget(),
    );
  }

  Widget _getPinWidget() {
    return SafeArea(
      child: Container(
        color: Colors.grey.shade800,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Center(
                child: Text('Enter your current PIN',
                    style: TextStyle(fontSize: 20, color: Colors.white))),
            SizedBox(height: 10),
            Row(
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
                    // onTap: () {
                    //   FocusScope.of(context).requestFocus(_pinFocusNode1);
                    // },
                    onChanged: (value) {
                      if (value.length == 0) {
                        _pinController1.text = "";
                        _pinControllerFull.text = "";
                        FocusScope.of(context).unfocus();
                        //FocusScope.of(context).requestFocus(_pinFocusNode1);
                      } else if (value.length == 1) {
                        _pinController1.text = value;
                        _pinControllerFull.text =
                            '${_pinControllerFull.text}$value';
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
                            _nominate();
                          }
                        }
                      }
                      print('nom pin: ${_pinControllerFull.text}');
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
                        _pinControllerFull.text =
                            '${_pinControllerFull.text}$value';
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
                      print('nom pin: ${_pinControllerFull.text}');
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
                        _pinControllerFull.text =
                            '${_pinControllerFull.text}$value';
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

                      print('nom pin: ${_pinControllerFull.text}');
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
                        _pinControllerFull.text =
                            '${_pinControllerFull.text}$value';
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
                      print('nom pin: ${_pinControllerFull.text}');
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
                        _pinControllerFull.text =
                            '${_pinControllerFull.text}$value';
                        FocusScope.of(context).requestFocus(_pinFocusNode6);
                      } else {
                        String overValue = value.substring(1, 2);
                        value = value.substring(0, 1);
                        _pinController5.text = value;
                        _pinController6.text = overValue;
                        _pinControllerFull.text =
                            '${_pinControllerFull.text}$overValue';
                        FocusScope.of(context).requestFocus(_pinFocusNode6);
                        _nominate();
                      }

                      print('nom pin: ${_pinControllerFull.text}');
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
                        _pinControllerFull.text =
                            '${_pinControllerFull.text}$value';
                        FocusScope.of(context).unfocus();
                        _nominate();
                      } else {
                        value = value.substring(0, 1);
                        _pinController6.text = value;
                        FocusScope.of(context).unfocus();
                        _nominate();
                      }
                      print('nom pin: ${_pinControllerFull.text}');
                    },
                  ),
                ),
                Spacer(),
              ],
            )
          ],
        ),
      ),
    );
  }

  _nominate() async {
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
          _errorMsg = "Incorrect pin.";
        }
      });
    } on FirebaseAuthException catch (e) {
      _errorMsg = e.message.toString();
    } catch (error) {
      _errorMsg = error.toString();
    }

    setState(() => _isLoading = false);
    if (_errorMsg.length > 0) {
      Fluttertoast.showToast(msg: _errorMsg);
    }
  }
}
