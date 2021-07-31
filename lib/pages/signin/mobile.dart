import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../mpin/mpin.dart';

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

  String? _verificationId;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  String _code = "";
  String signature = "{{ app signature }}";

  @override
  void initState() {
    super.initState();
    setState(() {
      _auth = widget.auth;
      //_user = _auth.currentUser!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
        // TextButton(
        //   child: Row(
        //     children: [Icon(Icons.chevron_left), Text('Back')],
        //   ),
        //   onPressed: () {
        //     FocusManager.instance.primaryFocus?.unfocus();
        //     Navigator.push(
        //         context,
        //         MaterialPageRoute(
        //             builder: (context) => SignInPage(auth: _auth)));
        //   },
        // ),
        // SizedBox(height: 100),
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
                  ? Colors.grey.shade500
                  : Colors.grey.shade800),
          onPressed: () {
            if (_sendOtpEnabled) {
              _verifyOTP();
            }
          },
        ),
      ],
    );
  }

  getAutoFillHomeWidget(context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        PhoneFieldHint(),
        Spacer(),
        PinFieldAutoFill(
          decoration: UnderlineDecoration(
            textStyle: TextStyle(fontSize: 20, color: Colors.black),
            colorBuilder: FixedColorBuilder(Colors.black.withOpacity(0.3)),
          ),
          currentCode: _code,
          onCodeSubmitted: (code) {},
          onCodeChanged: (code) {
            if (code!.length == 6) {
              FocusScope.of(context).requestFocus(FocusNode());
            }
          },
        ),
        Spacer(),
        TextFieldPinAutoFill(
          currentCode: _code,
        ),
        Spacer(),
        ElevatedButton(
          child: Text('Listen for sms code'),
          onPressed: () async {
            await SmsAutoFill().listenForCode;
          },
        ),
        ElevatedButton(
          child: Text('Set code to 123456'),
          onPressed: () async {
            setState(() {
              _code = '123456';
            });
          },
        ),
        SizedBox(height: 8.0),
        Divider(height: 1.0),
        SizedBox(height: 4.0),
        Text("App Signature : $signature"),
        SizedBox(height: 4.0),
        ElevatedButton(
          child: Text('Get app signature'),
          onPressed: () async {
            signature = await SmsAutoFill().getAppSignature;
            setState(() {});
          },
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => CodeAutoFillTestPage()));
          },
          child: Text("Test CodeAutoFill mixin"),
        )
      ],
    );
  }

  _sendOTP() async {
    setState(() => _isLoading = true);
    String msg = '';

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+63${_phoneController.text}',
        verificationCompleted: (phoneAuthCredential) async {
          //signInWithPhoneAuthCredential(phoneAuthCredential);
        },
        verificationFailed: (verificationFailed) async {
          msg = verificationFailed.message.toString();
        },
        codeSent: (verificationId, resendingToken) async {
          setState(() {
            _sendOtpEnabled = false;
            _mobileVerificationState =
                MobileVerificationState.SHOW_OTP_FORM_STATE;
            _otpController.clear();
            this._verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (verificationId) async {
          msg = 'Code auto retrieval timed out';
        },
      );
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

  _verifyOTP() async {
    setState(() => _isLoading = true);
    String msg = '';

    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: _verificationId!, smsCode: _otpController.text);
      UserCredential userCredential =
          await _auth.signInWithCredential(phoneAuthCredential);
      late String displayName;

      if (userCredential.user != null) {
        setState(() {
          _user = userCredential.user!;
        });
        var _document =
            FirebaseFirestore.instance.collection('users').doc(_user.uid);
        displayName = _user.displayName ?? _user.phoneNumber ?? 'User';

        _document.get().then((snapshot) {
          if (!snapshot.exists) {
            _document.set({
              'display_name': displayName,
              'phone_number': _user.phoneNumber,
              'logged_in': false
            }).then((value) {
              msg = "User added";
            }).catchError((error) {
              msg = "Failed to add user: $error";
            });
          } else {}
        }).whenComplete(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MpinSignInPage(auth: _auth, displayName: displayName)));
        });
      }
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
}

class CodeAutoFillTestPage extends StatefulWidget {
  @override
  _CodeAutoFillTestPageState createState() => _CodeAutoFillTestPageState();
}

class _CodeAutoFillTestPageState extends State<CodeAutoFillTestPage>
    with CodeAutoFill {
  String? appSignature;
  String? otpCode;

  @override
  void codeUpdated() {
    setState(() {
      otpCode = code!;
    });
  }

  @override
  void initState() {
    super.initState();
    listenForCode();

    SmsAutoFill().getAppSignature.then((signature) {
      setState(() {
        appSignature = signature;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    cancel();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: 18);

    return Scaffold(
      appBar: AppBar(
        title: Text("Listening for code"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
            child: Text(
              "This is the current app signature: $appSignature",
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Builder(
              builder: (_) {
                if (otpCode == null) {
                  return Text("Listening for code...", style: textStyle);
                }
                return Text("Code Received: $otpCode", style: textStyle);
              },
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
