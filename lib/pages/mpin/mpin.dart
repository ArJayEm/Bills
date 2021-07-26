import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/landing_page.dart';
import 'package:bills/pages/mpin/enter.dart';
import 'package:bills/pages/sign_in_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  MpinSignInPage({Key? key, required this.userProfile}) : super(key: key);

  final UserProfile userProfile;

  @override
  _MpinSignInPageState createState() => _MpinSignInPageState();
}

class _MpinSignInPageState extends State<MpinSignInPage> {
  late UserProfile _userProfile;

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

  late DocumentReference _document;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _userProfile = widget.userProfile;
      _document =
          FirebaseFirestore.instance.collection('users').doc(_userProfile.id);
    });
    _checkIfExistingUser();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: _scaffoldKey,
      child: Scaffold(
        body: Container(
          color: Color.fromARGB(255, 2, 125, 253),
          padding: EdgeInsets.all(20),
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
            Text(
              '${_userProfile.displayName}',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 15, color: Colors.white70),
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
                        await FirebaseAuth.instance.signOut();
                        _googleSignIn.disconnect();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInPage(),
                          ),
                        );
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              ),
              child: Text(
                'Switch Account',
                textAlign: TextAlign.left,
                style: TextStyle(color: Colors.white, fontSize: 15),
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
                  ? Icon(Icons.circle, color: Colors.white, size: 15)
                  : Icon(Icons.circle_outlined, color: Colors.white, size: 15),
              _mPinControllerLen2 || _mPinController.text.length >= 2
                  ? Icon(Icons.circle, color: Colors.white, size: 15)
                  : Icon(Icons.circle_outlined, color: Colors.white, size: 15),
              _mPinControllerLen3 || _mPinController.text.length >= 3
                  ? Icon(Icons.circle, color: Colors.white, size: 15)
                  : Icon(Icons.circle_outlined, color: Colors.white, size: 15),
              _mPinControllerLen4 || _mPinController.text.length >= 4
                  ? Icon(Icons.circle, color: Colors.white, size: 15)
                  : Icon(Icons.circle_outlined, color: Colors.white, size: 15),
              _mPinControllerLen5 || _mPinController.text.length >= 5
                  ? Icon(Icons.circle, color: Colors.white, size: 15)
                  : Icon(Icons.circle_outlined, color: Colors.white, size: 15),
              _mPinControllerLen6 || _mPinController.text.length >= 6
                  ? Icon(Icons.circle, color: Colors.white, size: 15)
                  : Icon(Icons.circle_outlined, color: Colors.white, size: 15),
            ]),
        SizedBox(height: 20),
        Center(child: Text('Enter your MPIN')),
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
                ? MaterialButton(
                    onPressed: () {
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
                    color: Color.fromARGB(255, 0, 84, 203),
                    textColor: Colors.white,
                    child: Text(
                      '${_mpinButtons[index]}',
                      style: TextStyle(fontSize: 30),
                    ),
                    //padding: EdgeInsets.all(16),
                    shape: CircleBorder(),
                  )
                : _mpinButtons[index].toString() == '<'
                    ? _showBackSpace == true
                        ? MaterialButton(
                            onPressed: () {
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
                            textColor: Colors.white,
                            child: Icon(
                              Icons.backspace,
                              color: Colors.white,
                              size: 35,
                            ),
                            //padding: EdgeInsets.all(16),
                            shape: CircleBorder(),
                          )
                        : SizedBox()
                    : SizedBox();
          },
        ),
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
    setState(() {
      _isLoading = true;
    });
    bool mpinMatched = false;
    try {
      _document.get().then((snapshot) {
        mpinMatched = snapshot.get('mpin') == _mPinController.text;
      }).whenComplete(() {
        if (mpinMatched == true) {
          _document.update({'logged_in': true});
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      LandingPage(userProfile: _userProfile)));
        } else {
          Fluttertoast.showToast(msg: 'Incorrect pin.');
        }
      });
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: '${e.message}');
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkIfExistingUser() async {
    setState(() {
      _isLoading = true;
    });
    String msg = '';
    bool hasMpin = false;
    UserProfile userProfile = UserProfile();

    _document.get().then((snapshot) {
      if (snapshot.exists) {
        _document.update({'logged_in': false});
        hasMpin = snapshot.get('mpin').toString().isNotEmpty;
        userProfile = UserProfile(
            id: snapshot.id,
            displayName: snapshot.get('display_name'),
            loggedIn: snapshot.get('logged_in'));
      } else {
        _document.set(
            {'display_name': _userProfile.displayName, 'logged_in': false});
        if (_userProfile.email!.isNotEmpty) {
          _document
              .set({
                'display_name': _userProfile.email,
                'email': _userProfile.email
              })
              .then((value) => {msg = "Email added"})
              .catchError((error) => {msg = "Failed to add email: $error"});
        } else if (_userProfile.phoneNumber!.isNotEmpty) {
          _document
              .set({
                'display_name': _userProfile.phoneNumber,
                'phone_number': _userProfile.phoneNumber
              })
              .then((value) => {msg = "Phone number added"})
              .catchError(
                  (error) => {msg = "Failed to add phone number: $error"});
        } else if (_userProfile.displayName!.isNotEmpty) {
          _document
              .set({
                'display_name': _userProfile.displayName,
              })
              .then((value) => {msg = "User added"})
              .catchError((error) => {msg = "Failed to add user: $error"});
        }
      }
    }).whenComplete(() {
      setState(() {
        _userProfile = userProfile;
      });

      if (hasMpin) {
        setState(() {
          _isLoading = false;
        });
      } else {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => EnterMpin(userProfile: _userProfile)));
      }

      if (msg.length > 0) {
        Fluttertoast.showToast(msg: msg);
      }
    });
  }
}
