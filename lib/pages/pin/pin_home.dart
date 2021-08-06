import 'package:bills/pages/dashboard.dart';
import 'package:bills/pages/pin/enter.dart';
//import 'package:bills/pages/signin/email.dart';
import 'package:bills/pages/signin/signin_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class PinHome extends StatefulWidget {
  PinHome({Key? key, required this.auth, required this.displayName})
      : super(key: key);

  final FirebaseAuth auth;
  final String displayName;

  @override
  _PinHomeState createState() => _PinHomeState();
}

class _PinHomeState extends State<PinHome> {
  late FirebaseAuth _auth;
  late String _name;

  List _mpinButtons = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '',
    '0',
    '<'
  ];

  final _pinController = TextEditingController();
  bool _pinControllerLen1 = false;
  bool _pinControllerLen2 = false;
  bool _pinControllerLen3 = false;
  bool _pinControllerLen4 = false;
  bool _pinControllerLen5 = false;
  bool _pinControllerLen6 = false;
  bool _showBackSpace = false;

  bool _isLoading = false;
  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _auth = widget.auth;
      _name = widget.displayName;
    });
    _checkIfExistingUser();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor:
            Colors.grey.shade300, // Color.fromARGB(255, 0, 125, 253),
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.all(20),
          color: Colors.grey.shade300, // Color.fromARGB(255, 0, 125, 253),
          child: getEnterMpinWidget(),
        ),
      ),
    );
  }

  Widget getEnterMpinWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Spacer(),
            Row(
              children: [
                _auth.currentUser!.photoURL != null
                    ? Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(
                              _auth.currentUser!.photoURL.toString(),
                            ),
                          ),
                        ),
                      )
                    : SizedBox(),
                Text(
                  '  $_name',
                  style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                ),
              ],
            ),
            Spacer(),
            TextButton(
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Are you sure you want to logout?'),
                  content: const Text(
                      'Your account will be removed from the device.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () async {
                        _handleSignOut();
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              ),
              child: Text(
                'Switch Account',
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.grey.shade800, fontSize: 15),
              ),
            ),
            Spacer(),
          ],
        ),
        SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _pinControllerLen1 || _pinController.text.length >= 1
                ? Icon(Icons.circle, color: Colors.grey.shade800, size: 15)
                : Icon(Icons.circle_outlined,
                    color: Colors.grey.shade800, size: 15),
            _pinControllerLen2 || _pinController.text.length >= 2
                ? Icon(Icons.circle, color: Colors.grey.shade800, size: 15)
                : Icon(Icons.circle_outlined,
                    color: Colors.grey.shade800, size: 15),
            _pinControllerLen3 || _pinController.text.length >= 3
                ? Icon(Icons.circle, color: Colors.grey.shade800, size: 15)
                : Icon(Icons.circle_outlined,
                    color: Colors.grey.shade800, size: 15),
            _pinControllerLen4 || _pinController.text.length >= 4
                ? Icon(Icons.circle, color: Colors.grey.shade800, size: 15)
                : Icon(Icons.circle_outlined,
                    color: Colors.grey.shade800, size: 15),
            _pinControllerLen5 || _pinController.text.length >= 5
                ? Icon(Icons.circle, color: Colors.grey.shade800, size: 15)
                : Icon(Icons.circle_outlined,
                    color: Colors.grey.shade800, size: 15),
            _pinControllerLen6 || _pinController.text.length >= 6
                ? Icon(Icons.circle, color: Colors.grey.shade800, size: 15)
                : Icon(Icons.circle_outlined,
                    color: Colors.grey.shade800, size: 15),
          ],
        ),
        SizedBox(height: 20),
        Center(
          child: Text(
            'Enter your PIN',
            style: TextStyle(color: Colors.grey.shade800),
          ),
        ),
        SizedBox(height: 20),
        GridView.builder(
          padding: EdgeInsets.fromLTRB(50, 10, 50, 10),
          shrinkWrap: true,
          //physics: BouncingScrollPhysics(),
          itemCount: _mpinButtons.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 1.5,
              crossAxisCount: 3,
              mainAxisExtent: 80,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10),
          itemBuilder: (BuildContext context, int index) {
            return _mpinButtons[index].length > 0 && _mpinButtons[index] != '<'
                ? FloatingActionButton(
                    onPressed: () {
                      if (!_isLoading) {
                        if (_pinController.text.length < 6) {
                          _pinController.text =
                              '${_pinController.text}${_mpinButtons[index]}';
                          _setBoolean();
                          if (_pinController.text.length == 6) {
                            _verifyMpin();
                          }
                        } else if (_pinController.text.length == 6) {
                          _verifyMpin();
                        }
                        _buttonPressed(index);
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade700, width: 1.5),
                        borderRadius: BorderRadius.circular(35),
                        color: _isLoading
                            ? Colors.grey.shade700
                            : Colors.grey.shade800,
                      ),
                      child: Center(
                        child: Text(
                          '${_mpinButtons[index]}',
                          style: TextStyle(
                            fontSize: 30,
                            color: _isButtonPressed
                                ? Colors.grey.shade700
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                  )
                : _mpinButtons[index].toString() == '<'
                    ? _showBackSpace == true
                        ? GestureDetector(
                            onTap: () {
                              if (!_isLoading) {
                                if (_pinController.text.isNotEmpty) {
                                  _pinController.text = _pinController.text
                                      .substring(
                                          0, _pinController.text.length - 1);
                                  _setBoolean();
                                }
                              }
                            },
                            onLongPress: () {
                              if (_pinController.text.isNotEmpty) {
                                for (var i = 0;
                                    i < _pinController.text.length + 1;
                                    i++) {
                                  _pinController.text = _pinController.text
                                      .substring(
                                          0, _pinController.text.length - 1);
                                }
                                _setBoolean();
                              }
                            },
                            child: Container(
                              child: Center(
                                child: Icon(
                                  Icons.backspace,
                                  color: _isLoading
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade800,
                                  size: 35,
                                ),
                              ),
                            ),
                          )
                        : SizedBox()
                    : SizedBox();
          },
        )
      ],
    );
  }

  _buttonPressed(index) {
    // setState(() {
    //   //_isButtonPressed = true;
    // });
    // Future.delayed(const Duration(milliseconds: 100), () {
    //   setState(() {
    //     _isButtonPressed = false;
    //   });
    // });
  }

  _setBoolean() {
    setState(() {
      _pinControllerLen1 = _pinController.text.length == 1;
      _pinControllerLen2 = _pinController.text.length == 2;
      _pinControllerLen3 = _pinController.text.length == 3;
      _pinControllerLen4 = _pinController.text.length == 4;
      _pinControllerLen5 = _pinController.text.length == 5;
      _pinControllerLen6 = _pinController.text.length == 6;

      _showBackSpace = _pinController.text.length > 0;
    });
  }

  Future<void> _verifyMpin() async {
    _showProgressUi(true, "");
    try {
      DocumentReference _document = FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid);
      String mpin = '';

      _document.get().then((snapshot) {
        if (snapshot.exists) {
          mpin = snapshot.get('mpin');
        }
      }).whenComplete(() {
        if (mpin == _pinController.text) {
          _document.update({'logged_in': true});
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => Dashboard(auth: _auth)));
        } else {
          _showProgressUi(false, "Incorrect pin.");
        }
      });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, e.message.toString());
    } catch (e) {
      _showProgressUi(false, e.toString());
    }
  }

  Future<void> _checkIfExistingUser() async {
    _showProgressUi(true, "");
    try {
      DocumentReference _document = FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid);
      bool loggedIn = false;
      String? pin;

      _document.get().then((snapshot) {
        if (snapshot.exists) {
          loggedIn = snapshot.get('logged_in');
          pin = snapshot.get('mpin');
        } else {
          _auth.signOut();
          _showProgressUi(false, "User not found.");
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SignInHome(auth: _auth)));
        }
      }).whenComplete(() {
        if (loggedIn) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => Dashboard(auth: _auth)));
        } else {
          if (pin == null) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EnterMpin(
                        auth: _auth, isChange: false, nominatedPin: '')));
          } else {}
        }
        _showProgressUi(false, "");
      });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  _handleSignOut() async {
    _showProgressUi(true, "");

    try {
      _auth.signOut();
      _googleSignIn.disconnect();
      FacebookLogin().logOut();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignInHome(auth: _auth),
          //builder: (context) => EmailSignInPage(auth: _auth, isSignin: true),
        ),
      );
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  _showProgressUi(bool isLoading, String msg) {
    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
    setState(() => _isLoading = isLoading);
  }

  // _showProgressDialog() {
  //   return _isLoading
  //       ? showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return Center(
  //               child: CircularProgressIndicator(),
  //             );
  //           },
  //         ).whenComplete(
  //           () {
  //             Navigator.pop(context);
  //           },
  //         )
  //       : null;
  // }
}
