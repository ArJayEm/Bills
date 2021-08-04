import 'package:bills/pages/pin/pin_home.dart';
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
  late User _user;
  MobileVerificationState _mobileVerificationState =
      MobileVerificationState.SHOW_MOBILE_FORM_STATE;

  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _sendOtpEnabled = false;
  bool _isLoading = false;
  String _errorMsg = '';

  String? _verificationId;

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
              : _mobileVerificationState ==
                      MobileVerificationState.SHOW_MOBILE_FORM_STATE
                  ? getMobileFormWidget(context)
                  : getOtpFormWidget(context),
        ),
      ),
    );
  }

  getMobileFormWidget(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        ),
      ],
    );
  }

  getOtpFormWidget(context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          keyboardType: TextInputType.number,
          //textInputAction: TextInputAction.continueAction,
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
        ),
      ],
    );
  }

  _sendOTP() async {
    setState(() {
      _errorMsg = "";
      _isLoading = true;
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+63${_phoneController.text}',
        verificationCompleted: (phoneAuthCredential) async {
          //signInWithPhoneAuthCredential(phoneAuthCredential);
        },
        verificationFailed: (verificationFailed) async {
          _errorMsg = verificationFailed.message.toString();
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
          _errorMsg = 'Code auto retrieval timed out';
        },
      );
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }

    if (_errorMsg.length > 0) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: _errorMsg);
    }
  }

  _verifyOTP() async {
    setState(() {
      _errorMsg = "";
      _isLoading = true;
    });

    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: _verificationId!, smsCode: _otpController.text);
      UserCredential userCredential =
          await _auth.signInWithCredential(phoneAuthCredential);

      if (userCredential.user != null) {
        setState(() {
          _user = userCredential.user!;
        });
        DocumentReference _document =
            FirebaseFirestore.instance.collection('users').doc(_user.uid);
        String displayName = _user.phoneNumber ?? '';

        _document.get().then((snapshot) {
          if (!snapshot.exists) {
            _document.set({
              'display_name': displayName,
              'phone_number': _user.phoneNumber,
              'logged_in': false
            }).then((value) {
              _errorMsg = "User added";
            }).catchError((error) {
              _errorMsg = "Failed to add user: $error";
            });
          } else {}
        }).whenComplete(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PinHome(auth: _auth, displayName: displayName)));
        });
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }

    if (_errorMsg.length > 0) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: _errorMsg);
    }
  }
}
