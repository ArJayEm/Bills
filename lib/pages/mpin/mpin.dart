import 'package:bills/pages/dashboard.dart';
import 'package:bills/pages/mpin/enter.dart';
import 'package:bills/pages/signin/home.dart';
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

enum MpinVerificationState { ENTER_MPIN, NOMINATE_MPIN }

class MpinSignInPage extends StatefulWidget {
  MpinSignInPage({Key? key, required this.auth, required this.displayName})
      : super(key: key);

  final FirebaseAuth auth;
  final String displayName;

  @override
  _MpinSignInPageState createState() => _MpinSignInPageState();
}

class _MpinSignInPageState extends State<MpinSignInPage> {
  late FirebaseAuth _auth;
  late String _displayName;

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

  final _mPinController = TextEditingController();
  bool _mPinControllerLen1 = false;
  bool _mPinControllerLen2 = false;
  bool _mPinControllerLen3 = false;
  bool _mPinControllerLen4 = false;
  bool _mPinControllerLen5 = false;
  bool _mPinControllerLen6 = false;
  bool _showBackSpace = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _auth = widget.auth;
      _displayName = widget.displayName;
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
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : getEnterMpinWidget(),
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
                _auth.currentUser!.photoURL.toString().length > 0
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
                    : SizedBox(
                        child: Image(
                            height: 20,
                            image: AssetImage('assets/icons/google.png'))),
                Text(
                  '  $_displayName',
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
            _mPinControllerLen1 || _mPinController.text.length >= 1
                ? Icon(Icons.circle, color: Colors.grey.shade800, size: 15)
                : Icon(Icons.circle_outlined,
                    color: Colors.grey.shade800, size: 15),
            _mPinControllerLen2 || _mPinController.text.length >= 2
                ? Icon(Icons.circle, color: Colors.grey.shade800, size: 15)
                : Icon(Icons.circle_outlined,
                    color: Colors.grey.shade800, size: 15),
            _mPinControllerLen3 || _mPinController.text.length >= 3
                ? Icon(Icons.circle, color: Colors.grey.shade800, size: 15)
                : Icon(Icons.circle_outlined,
                    color: Colors.grey.shade800, size: 15),
            _mPinControllerLen4 || _mPinController.text.length >= 4
                ? Icon(Icons.circle, color: Colors.grey.shade800, size: 15)
                : Icon(Icons.circle_outlined,
                    color: Colors.grey.shade800, size: 15),
            _mPinControllerLen5 || _mPinController.text.length >= 5
                ? Icon(Icons.circle, color: Colors.grey.shade800, size: 15)
                : Icon(Icons.circle_outlined,
                    color: Colors.grey.shade800, size: 15),
            _mPinControllerLen6 || _mPinController.text.length >= 6
                ? Icon(Icons.circle, color: Colors.grey.shade800, size: 15)
                : Icon(Icons.circle_outlined,
                    color: Colors.grey.shade800, size: 15),
          ],
        ),
        SizedBox(height: 20),
        Center(
          child: Text(
            'Enter your MPIN',
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
                ? GestureDetector(
                    onTap: () {
                      if (_mPinController.text.length < 6) {
                        _mPinController.text =
                            '${_mPinController.text}${_mpinButtons[index]}';
                        _setBoolean();
                        if (_mPinController.text.length == 6) {
                          _verifyMpin();
                        }
                      } else if (_mPinController.text.length == 6) {
                        _verifyMpin();
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade500, width: 1.5),
                        borderRadius: BorderRadius.circular(35),
                        color: Colors.grey.shade300,
                      ),
                      child: Center(
                        child: Text(
                          '${_mpinButtons[index]}',
                          style: TextStyle(
                            fontSize: 30,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  )
                : _mpinButtons[index].toString() == '<'
                    ? _showBackSpace == true
                        ? GestureDetector(
                            onTap: () {
                              if (_mPinController.text.isNotEmpty) {
                                _mPinController.text = _mPinController.text
                                    .substring(
                                        0, _mPinController.text.length - 1);
                                _setBoolean();
                              }
                            },
                            onLongPress: () {
                              if (_mPinController.text.isNotEmpty) {
                                for (var i = 0;
                                    i < _mPinController.text.length + 1;
                                    i++) {
                                  _mPinController.text = _mPinController.text
                                      .substring(
                                          0, _mPinController.text.length - 1);
                                }
                                _setBoolean();
                              }
                            },
                            child: Container(
                              child: Center(
                                child: Icon(
                                  Icons.backspace,
                                  color: Colors.grey.shade800,
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

  _setBoolean() {
    print('mpin: ${_mPinController.text}');
    setState(() {
      _mPinControllerLen1 = _mPinController.text.length == 1;
      _mPinControllerLen2 = _mPinController.text.length == 2;
      _mPinControllerLen3 = _mPinController.text.length == 3;
      _mPinControllerLen4 = _mPinController.text.length == 4;
      _mPinControllerLen5 = _mPinController.text.length == 5;
      _mPinControllerLen6 = _mPinController.text.length == 6;
      if (_mPinController.text.length == 0) {
        _showBackSpace = false;
      } else {
        _showBackSpace = true;
      }
    });
  }

  Future<void> _verifyMpin() async {
    setState(() => _isLoading = true);
    String msg = '';
    bool mpinMatched = false;
    DocumentReference _document = FirebaseFirestore.instance
        .collection('users')
        .doc(_auth.currentUser!.uid);

    try {
      _document.get().then((snapshot) {
        mpinMatched = snapshot.get('mpin') == _mPinController.text;
      }).whenComplete(() {
        if (mpinMatched == true) {
          _document.update({'logged_in': true});
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => Dashboard(auth: _auth)));
        } else {
          Fluttertoast.showToast(msg: 'Incorrect pin.');
        }
      });
    } on FirebaseAuthException catch (e) {
      msg = '${e.message}';
    } catch (error) {
      msg = error.toString();
    }
    setState(() => _isLoading = false);
    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
  }

  Future<void> _checkIfExistingUser() async {
    setState(() => _isLoading = true);
    String msg = '';
    bool hasMpin = false;

    try {
      DocumentReference _document = FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid);

      _document.get().then((snapshot) {
        if (snapshot.exists) {
          hasMpin = snapshot.get('mpin').toString().isNotEmpty;
        }
      }).whenComplete(() {
        if (!hasMpin) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => EnterMpin(auth: _auth)));
        }
      });
    } on FirebaseAuthException catch (e) {
      msg = e.message.toString();
    } catch (e) {
      msg = e.toString();
    }

    setState(() => _isLoading = false);
    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
  }

  _handleSignOut() async {
    setState(() => _isLoading = true);
    try {
      _auth.signOut();
      _googleSignIn.disconnect();
      FacebookLogin().logOut();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignInPage(auth: _auth),
        ),
      );
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
      Navigator.pop(context);
    }
  }
}
