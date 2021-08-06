import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/pin/pin_home.dart';
import 'package:bills/pages/signin/signin_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

enum MobileVerificationState { SHOW_MOBILE_FORM_STATE, SHOW_OTP_FORM_STATE }

class MobileSignInPage extends StatefulWidget {
  MobileSignInPage({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _MobileSignInPageState createState() => _MobileSignInPageState();
}

class _MobileSignInPageState extends State<MobileSignInPage> {
  late FirebaseAuth _auth;
  late User _firebaseAuthUser;
  MobileVerificationState _mobileVerificationState =
      MobileVerificationState.SHOW_MOBILE_FORM_STATE;

  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _sendOtpEnabled = false;
  bool _isLoading = false;

  String? _verificationId;

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

  String signature = "{{ app signature }}";

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
            if (_mobileVerificationState ==
                MobileVerificationState.SHOW_OTP_FORM_STATE) {
              setState(() {
                _mobileVerificationState =
                    MobileVerificationState.SHOW_MOBILE_FORM_STATE;
              });
            } else {
              //Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SignInHome(auth: _auth)),
              );
            }
          },
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Icon(Icons.arrow_back),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.grey.shade300),
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey.shade800,
          padding: EdgeInsets.all(20),
          alignment: Alignment.center,
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._mobileVerificationState ==
                            MobileVerificationState.SHOW_MOBILE_FORM_STATE
                        ? getMobileFormWidget(context)
                        : getOtpFormWidget2(context)
                  ],
                ),
        ),
      ),
    );
  }

  List<Widget> getMobileFormWidget(context) {
    return <Widget>[
      Text('Enter your mobile number'),
      TextFormField(
        keyboardType: TextInputType.number,
        autofocus: true,
        decoration: InputDecoration(
            //labelText: '••••••••••',
            //hintText: '••••••••••',
            prefixText: '+63 '),
        controller: _phoneController,
        onChanged: (value) {
          if (value == "0") {
            value = "";
            _phoneController.clear();
          }
          if (value.length > 10) {
            value = value.substring(0, 10);
            _phoneController.value = TextEditingValue(
              text: value,
              selection: TextSelection.collapsed(offset: value.length),
            );
          }
          setState(() {
            _sendOtpEnabled = value.length == 10;
          });
        },
      ),
      SizedBox(height: 40),
      TextButton(
        child: Text('Next'),
        style: TextButton.styleFrom(
            //shape: StadiumBorder(),
            minimumSize: Size(double.infinity, 40),
            primary: Colors.grey.shade800,
            backgroundColor:
                _sendOtpEnabled ? Colors.grey.shade300 : Colors.white38),
        onPressed: () {
          if (_sendOtpEnabled) {
            _sendOTP();
          }
        },
      )
    ];
  }

  List<Widget> getOtpFormWidget(context) {
    return <Widget>[
      TextFormField(
        keyboardType: TextInputType.number,
        autofocus: true,
        controller: _otpController,
        decoration: InputDecoration(hintText: "Enter OTP"),
        onChanged: (value) {
          if (value.length > 6) {
            value = value.substring(0, 6);
            _otpController.value = TextEditingValue(
              text: value,
              selection: TextSelection.collapsed(offset: value.length),
            );
          }
          setState(() {
            _sendOtpEnabled = value.length == 6;
          });
        },
      ),
      SizedBox(
        height: 16,
      ),
      TextButton(
        child: Text('Verify'),
        style: TextButton.styleFrom(
            //shape: StadiumBorder(),
            minimumSize: Size(double.infinity, 40),
            primary: Colors.grey.shade800,
            backgroundColor:
                _sendOtpEnabled ? Colors.grey.shade300 : Colors.white38),
        onPressed: () {
          if (_sendOtpEnabled) {
            _verifyOTP();
          }
        },
      )
    ];
  }

  List<Widget> getOtpFormWidget2(context) {
    return <Widget>[
      Center(
        child: Text(
            "An OTP has been sent to your mobile\n+63${_phoneController.text}",
            style: TextStyle(fontSize: 15, color: Colors.white),
            textAlign: TextAlign.center),
      ),
      SizedBox(height: 20),
      Row(
        children: [
          Spacer(),
          Flexible(
            child: TextFormField(
              obscureText: true,
              controller: _pinController1,
              focusNode: _pinFocusNode1,
              autofocus: true,
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
                  _autoValidate();
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
                  _autoValidate();
                } else {
                  value = value.substring(0, 1);
                  _pinController6.text = value;
                  FocusScope.of(context).unfocus();
                  _autoValidate();
                }
              },
            ),
          ),
          Spacer(),
        ],
      )
    ];
  }

  _sendOTP() async {
    _showProgressUi(true, "");

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+63${_phoneController.text}',
        verificationCompleted: (phoneAuthCredential) async {
          //signInWithPhoneAuthCredential(phoneAuthCredential);
        },
        verificationFailed: (verificationFailed) async {
          _showProgressUi(false, verificationFailed.message.toString());
        },
        codeSent: (verificationId, resendingToken) async {
          setState(() {
            _sendOtpEnabled = false;
            _mobileVerificationState =
                MobileVerificationState.SHOW_OTP_FORM_STATE;
            _otpController.clear();
            this._verificationId = verificationId;
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (verificationId) async {
          _showProgressUi(false, "Code auto retrieval timed out");
        },
      );
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  _verifyOTP() async {
    _showProgressUi(true, "");

    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: _verificationId!, smsCode: _pinControllerFull.text);
      UserCredential userCredential =
          await _auth.signInWithCredential(phoneAuthCredential);

      if (userCredential.user != null) {
        setState(() {
          _firebaseAuthUser = userCredential.user!;
        });
        CollectionReference _collection =
            FirebaseFirestore.instance.collection('users');
        DocumentReference _document = _collection.doc(_firebaseAuthUser.uid);
        UserProfile userProfile = UserProfile();
        // String? name = _firebaseAuthUser.phoneNumber;
        // var count = 0;
        // if (name == null) {
        //   _collection.get().then((querySnapshot) {
        //     querySnapshot.docs.forEach((doc) {
        //       count++;
        //     });
        //   }).whenComplete(() {
        //     name = 'User $count';
        //   });
        // }

        _document.get().then((snapshot) {
          if (!snapshot.exists) {
            userProfile.displayName = _firebaseAuthUser.phoneNumber;
            userProfile.phoneNumber = _firebaseAuthUser.phoneNumber;
            userProfile.registeredUsing = 'mobile';

            _document.set(userProfile.toJson()).then((value) {
              _showProgressUi(false, "User added.");
            }).catchError((error) {
              _showProgressUi(false, "Failed to add user: $error.");
            });
          } else {}
        }).whenComplete(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PinHome(
                      auth: _auth, displayName: userProfile.displayName!)));
        });
      }
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
        _autoValidate();
      }
    }
  }

  _autoValidate() {
    _verifyOTP();
  }

  _showProgressUi(bool isLoading, String msg) {
    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
    setState(() => _isLoading = isLoading);
  }
}
