import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/mpin/reenter.dart';
import 'package:bills/pages/sign_in_page.dart';
import 'package:flutter/material.dart';

class EnterMpin extends StatefulWidget {
  EnterMpin({Key? key, required this.userProfile}) : super(key: key);

  final UserProfile userProfile;

  @override
  _EnterMpinState createState() => _EnterMpinState();
}

class _EnterMpinState extends State<EnterMpin> {
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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: _scaffoldKey,
      child: Scaffold(
        body: Container(
          color: Color.fromARGB(255, 2, 125, 253),
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextButton(
                child: Row(
                  children: [
                    Icon(Icons.chevron_left, color: Colors.white),
                    Text('Back', style: TextStyle(color: Colors.white))
                  ],
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignInPage()));
                },
              ),
              SizedBox(height: 10),
              Center(
                child: Text('Nominate your 6-digit PIN',
                    style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Spacer(),
                  Flexible(
                    child: TextFormField(
                      obscureText: true,
                      controller: _pinController1,
                      focusNode: _pinFocusNode1,
                      //autofocus: _pinController1.text.length == 0,
                      style: TextStyle(fontSize: 25),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.length == 0) {
                          _pinController1.text = "";
                          _pinControllerFull.text = "";
                          FocusScope.of(context).requestFocus(_pinFocusNode1);
                          FocusScope.of(context).unfocus();
                        } else if (value.length == 1) {
                          _pinController1.text = value;
                          _pinControllerFull.text =
                              '${_pinControllerFull.text}$value';
                          FocusScope.of(context).requestFocus(_pinFocusNode2);
                        } else {
                          String overValue = value.substring(1, 2);
                          value = value.substring(0, 1);
                          _pinController1.text = value;
                          _pinController2.text = overValue;
                          FocusScope.of(context).requestFocus(_pinFocusNode3);
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
                        } else {
                          value = value.substring(0, 1);
                          _pinController6.text = value;
                          FocusScope.of(context).unfocus();
                        }
                        print('nom pin: ${_pinControllerFull.text}');
                      },
                    ),
                  ),
                  Spacer(),
                ],
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReenterMpin(
                          nominatedPin: _pinControllerFull.text,
                          userProfile: widget.userProfile),
                    ),
                  );
                },
                child: Text('Next'),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 40),
                    textStyle: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
