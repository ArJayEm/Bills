import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/sign_in_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../mpin/mpin.dart';

enum MobileVerificationState { SHOW_MOBILE_FORM_STATE, SHOW_OTP_FORM_STATE }

class MobileSignInPage extends StatefulWidget {
  MobileSignInPage({Key? key}) : super(key: key);

  @override
  _MobileSignInPageState createState() => _MobileSignInPageState();
}

class _MobileSignInPageState extends State<MobileSignInPage> {
  MobileVerificationState _mobileVerificationState =
      MobileVerificationState.SHOW_MOBILE_FORM_STATE;
  FirebaseAuth _auth = FirebaseAuth.instance;

  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _sendOtpEnabled = false;
  bool _showLoading = false;

  String? _verificationId;

  UserProfile _userProfile = UserProfile();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: _scaffoldKey,
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(20),
          alignment: Alignment.center,
          child: _showLoading
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
        TextButton(
          child: Row(
            children: [Icon(Icons.chevron_left), Text('Back')],
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => SignInPage()));
          },
        ),
        SizedBox(height: 100),
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
              primary: Colors.white,
              backgroundColor: _sendOtpEnabled
                  ? Color.fromARGB(255, 242, 163, 38)
                  : Color.fromARGB(150, 242, 163, 38)),
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
        TextButton(
          child: Row(
            children: [Icon(Icons.chevron_left), Text('Back')],
          ),
          onPressed: () {
            setState(() {
              _mobileVerificationState =
                  MobileVerificationState.SHOW_MOBILE_FORM_STATE;
            });
          },
        ),
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
              primary: Colors.white,
              backgroundColor: _sendOtpEnabled
                  ? Color.fromARGB(255, 242, 163, 38)
                  : Color.fromARGB(150, 242, 163, 38)),
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
      _showLoading = true;
    });
    await _auth.verifyPhoneNumber(
      phoneNumber: '+63${_phoneController.text}',
      verificationCompleted: (phoneAuthCredential) async {
        setState(() {
          _showLoading = false;
        });
        //signInWithPhoneAuthCredential(phoneAuthCredential);
      },
      verificationFailed: (verificationFailed) async {
        setState(() {
          _showLoading = false;
        });
        Fluttertoast.showToast(msg: verificationFailed.message.toString());
      },
      codeSent: (verificationId, resendingToken) async {
        setState(() {
          _showLoading = false;
          _sendOtpEnabled = false;
          _mobileVerificationState =
              MobileVerificationState.SHOW_OTP_FORM_STATE;
          _otpController.clear();
          this._verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (verificationId) async {
        setState(() {
          _showLoading = false;
        });
        Fluttertoast.showToast(msg: 'Code auto retrieval timed out');
      },
    );
  }

  _verifyOTP() async {
    PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: _verificationId!, smsCode: _otpController.text);
    setState(() {
      _showLoading = true;
    });

    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);

      if (authCredential.user != null) {
        setState(() {
          _userProfile.id = authCredential.user!.uid;
          _userProfile.displayName = authCredential.user!.phoneNumber ??
              authCredential.user!.displayName ??
              '';
          _userProfile.phoneNumber = authCredential.user!.phoneNumber;
          _showLoading = false;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MpinSignInPage(userProfile: _userProfile)));
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _showLoading = false;
      });
      Fluttertoast.showToast(msg: e.message.toString());
    }
  }
}
