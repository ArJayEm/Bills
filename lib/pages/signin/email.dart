// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/signin/pin/pin_home.dart';
import 'package:bills/pages/signin/signin_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EmailSignInPage extends StatefulWidget {
  const EmailSignInPage({Key? key, required this.auth, required this.isSignin})
      : super(key: key);

  final FirebaseAuth auth;
  final bool isSignin;

  @override
  _EmailSignInPageState createState() => _EmailSignInPageState();
}

enum EmailVerificationState {
  SHOW_SIGN_IN_STATE,
  SHOW_SIGN_UP_STATE,
  SHOW_OTP_SENT
}

class _EmailSignInPageState extends State<EmailSignInPage> {
  late FirebaseAuth _auth;
  EmailVerificationState _emailState =
      EmailVerificationState.SHOW_SIGN_IN_STATE;

  final CollectionReference _collection =
      FirebaseFirestore.instance.collection("users");

  EmailAuth emailAuth = EmailAuth(sessionName: "Bills App");

  bool _isLoading = false;
  final RegExp _emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  bool _proceed = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  String? _email, _password, _confirmPassword;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPassFocusNode = FocusNode();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  String _title = "";

  bool _verifyOtpEnabled = false;
  bool _showSignUp = false;

  UserCredential? _userCredential;

  @override
  void initState() {
    super.initState();
    setState(() {
      _auth = widget.auth;
      _emailState = widget.isSignin
          ? EmailVerificationState.SHOW_SIGN_IN_STATE
          : EmailVerificationState.SHOW_SIGN_UP_STATE;
      _title = _emailState == EmailVerificationState.SHOW_SIGN_IN_STATE
          ? "Sign In with Email"
          : "Sign Up with Email";
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
            if (_emailState == EmailVerificationState.SHOW_OTP_SENT) {
              setState(() {
                _emailState = widget.isSignin
                    ? EmailVerificationState.SHOW_SIGN_IN_STATE
                    : EmailVerificationState.SHOW_SIGN_UP_STATE;
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
          child: const Padding(
            padding: EdgeInsets.all(10),
            child: Icon(Icons.arrow_back),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.grey.shade300),
        //titleTextStyle: TextTheme(headline6: TextStyle(color: Colors.white, fontSize: 25)),
        title: Text(_title),
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey.shade800,
          padding: const EdgeInsets.all(20),
          alignment: Alignment.center,
          child: Center(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _emailState == EmailVerificationState.SHOW_SIGN_IN_STATE
                      ? getEmailSignInPageWidget()
                      : _emailState == EmailVerificationState.SHOW_SIGN_UP_STATE
                          ? getEmailSignUpPageWidget()
                          : getVerifyOtpWidget()),
        ),
      ),
    );
  }

  Widget getEmailSignInPageWidget() {
    return Column(children: [
      TextFormField(
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofocus: true,
        focusNode: _emailFocusNode,
        decoration: const InputDecoration(
          labelText: "Email",
          hintText: "Email",
        ),
        controller: _emailController,
        onChanged: (value) {
          setState(() {
            _email = value.trim();
            _proceed =
                _emailRegex.hasMatch(_email.toString()) && _password != null;
          });
        },
      ),
      const SizedBox(),
      TextFormField(
        obscureText: true,
        textInputAction: TextInputAction.next,
        focusNode: _passwordFocusNode,
        decoration: const InputDecoration(
          labelText: "Password",
          hintText: "Password",
        ),
        controller: _passwordController,
        onChanged: (value) {
          setState(() {
            _password = value.trim();
            _proceed =
                _emailRegex.hasMatch(_email.toString()) && _password != null;
          });
        },
      ),
      const SizedBox(height: 30),
      TextButton(
        child: const Text("Sign In", style: TextStyle(fontSize: 18)),
        style: TextButton.styleFrom(
            //shape: StadiumBorder(),
            minimumSize: const Size(double.infinity, 50),
            primary: Colors.grey.shade800,
            backgroundColor: _proceed ? Colors.grey.shade300 : Colors.white38),
        onPressed: _proceed ? _signIn : null,
      ),
      _showSignUp ? const SizedBox(height: 10) : const SizedBox(),
      _showSignUp
          ? TextButton(
              child: const Text("Sign Up", style: TextStyle(fontSize: 18)),
              style: TextButton.styleFrom(
                  //shape: StadiumBorder(),
                  minimumSize: const Size(double.infinity, 50),
                  primary: Colors.grey.shade800,
                  backgroundColor:
                      _proceed ? Colors.grey.shade300 : Colors.white38),
              onPressed: () {
                setState(() {
                  _emailState = EmailVerificationState.SHOW_SIGN_UP_STATE;
                });
              },
            )
          : const SizedBox(),
    ]);
  }

  Widget getEmailSignUpPageWidget() {
    return Column(
      children: [
        TextFormField(
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofocus: true,
          focusNode: _emailFocusNode,
          decoration: const InputDecoration(
            labelText: "Email",
            hintText: "Email",
          ),
          controller: _emailController,
          onChanged: (value) {
            setState(() {
              _email = value.trim();
              _proceed = _emailRegex.hasMatch(_email.toString()) &&
                  _password != null &&
                  _confirmPassword != null;
            });
          },
        ),
        const SizedBox(),
        TextFormField(
          obscureText: true,
          textInputAction: TextInputAction.next,
          focusNode: _passwordFocusNode,
          decoration: const InputDecoration(
            labelText: "Password",
            hintText: "Password",
          ),
          controller: _passwordController,
          onChanged: (value) {
            setState(() {
              _password = value.trim();
              _proceed = _emailRegex.hasMatch(_email.toString()) &&
                  ((_password != null && _confirmPassword != null) &&
                      _password == _confirmPassword);
            });
          },
        ),
        const SizedBox(),
        TextFormField(
          obscureText: true,
          textInputAction: TextInputAction.go,
          focusNode: _confirmPassFocusNode,
          decoration: const InputDecoration(
            labelText: "Confirm Password",
            hintText: "Confirm Password",
          ),
          controller: _confirmPasswordController,
          onChanged: (value) {
            setState(() {
              _confirmPassword = value.trim();
              _proceed = _emailRegex.hasMatch(_email.toString()) &&
                  ((_password != null && _confirmPassword != null) &&
                      _password == _confirmPassword);
            });
          },
        ),
        const SizedBox(height: 30),
        TextButton(
          child: const Text("Sign Up", style: TextStyle(fontSize: 18)),
          style: TextButton.styleFrom(
              //shape: StadiumBorder(),
              minimumSize: const Size(double.infinity, 50),
              primary: Colors.grey.shade800,
              backgroundColor:
                  _proceed ? Colors.grey.shade300 : Colors.white38),
          onPressed: () {
            if (_proceed) {
              _signUp();
            }
          },
        ),
      ],
    );
  }

  _signIn() async {
    _showProgressUi(true, "");

    try {
      if (!_emailRegex.hasMatch(_email.toString())) {
        _showProgressUi(false, "Invalid email format.");
      }
      if (_password.toString().isEmpty) {
        _showProgressUi(false, "Password is required.");
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _email!, password: _password!);
      String displayName = "";
      User? user = userCredential.user;

      if (user != null) {
        DocumentReference document = _collection.doc(user.uid);
        document.get().then((document) {
          if (document.exists) {
            UserProfile up =
                UserProfile.fromJson(document.data() as Map<String, dynamic>);
            displayName = "${user.displayName ?? up.email ?? up.name}";
          }
        }).whenComplete(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      PinHome(auth: _auth, displayName: displayName)));
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showProgressUi(false, "User not found.");
        setState(() {
          _auth.signOut();
          _showSignUp = true;
        });
        FocusScope.of(context).requestFocus(_emailFocusNode);
      } else if (e.code == 'wrong-password') {
        _showProgressUi(false, "Invalid password.");
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      } else if (e.code == "unknown") {
        _showProgressUi(false, "${e.message}.");
      } else {
        _showProgressUi(false, "${e.message}.");
      }
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  _signUp() async {
    _showProgressUi(true, "");

    if (!_emailRegex.hasMatch(_email.toString())) {
      _showProgressUi(false, "Invalid email format.");
    } else if (_password.toString().isEmpty) {
      _showProgressUi(false, "Password is required.");
    } else if (_confirmPassword.toString().isEmpty) {
      _showProgressUi(false, "Confirm password is required.");
    } else if (_password.toString() != _confirmPassword.toString()) {
      _showProgressUi(false, "Password and confirm password doesn't match.");
    } else {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
                email: _email!, password: _password!);
        User? user = userCredential.user;

        if (user != null) {
          setState(() {
            _userCredential = userCredential;
          });
          _sendOtp();
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          _showProgressUi(false, "The password provided is too weak.");
          FocusScope.of(context).requestFocus(_passwordFocusNode);
        } else if (e.code == 'email-already-in-use') {
          _showProgressUi(false, "Email already used.");
          FocusScope.of(context).requestFocus(_emailFocusNode);
        } else if (e.code == "unknown") {
          _showProgressUi(false, "${e.message}.");
          FocusScope.of(context).requestFocus(_confirmPassFocusNode);
        }
      } catch (e) {
        _showProgressUi(false, "$e.");
      }
    }
  }

  Widget getVerifyOtpWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
              "An OTP has been sent to your email\n${_emailController.text}",
              style: const TextStyle(fontSize: 15, color: Colors.white),
              textAlign: TextAlign.center),
        ),
        const SizedBox(height: 20),
        TextFormField(
          keyboardType: TextInputType.number,
          //textInputAction: TextInputAction.continueAction,
          autofocus: true,
          controller: _otpController,
          decoration: const InputDecoration(hintText: "Enter OTP"),
          onChanged: (value) {
            if (value.length > 6) {
              value = value.substring(0, 6);
              _otpController.value = TextEditingValue(
                text: value,
                selection: TextSelection.collapsed(offset: value.length),
              );
            }
            setState(() {
              _verifyOtpEnabled = value.length == 6;
            });
          },
        ),
        const SizedBox(height: 16),
        TextButton(
          child: const Text("Verify"),
          style: TextButton.styleFrom(
              //shape: StadiumBorder(),
              minimumSize: const Size(double.infinity, 40),
              primary: Colors.grey.shade800,
              backgroundColor:
                  _verifyOtpEnabled ? Colors.grey.shade300 : Colors.white38),
          onPressed: () {
            if (_verifyOtpEnabled) {
              _verifyOtp();
            }
          },
        ),
      ],
    );
  }

  _sendOtp() async {
    _showProgressUi(true, "");

    try {
      bool optSent =
          await emailAuth.sendOtp(recipientMail: _emailController.value.text);

      if (optSent) {
        setState(() {
          _title = "Verify OTP";
          _emailState = EmailVerificationState.SHOW_OTP_SENT;
          _isLoading = false;
        });
      } else {
        _showProgressUi(false, "OTP not sent.");
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message.toString());
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  void _verifyOtp() async {
    _showProgressUi(true, "");

    bool verified = emailAuth.validateOtp(
        recipientMail: _emailController.text, userOtp: _otpController.text);

    if (verified) {
      try {
        // UserCredential userCredential =
        //     await _auth.createUserWithEmailAndPassword(
        //         email: _email!, password: _password!);
        User? _firebaseAuthUser = _userCredential?.user;

        if (_firebaseAuthUser != null) {
          DocumentReference document = _collection.doc(_firebaseAuthUser.uid);
          UserProfile userProfile = UserProfile();

          document.get().then((snapshot) {
            if (!snapshot.exists) {
              userProfile.name =
                  _firebaseAuthUser.displayName ?? _firebaseAuthUser.email;
              userProfile.nameseparated = userProfile.name?.split(" ");
              userProfile.email = _firebaseAuthUser.email;
              userProfile.userCode = _generateUserCode();
              userProfile.registeredUsing = 'email';
              userProfile.photoUrl = _firebaseAuthUser.photoURL;

              document.set(userProfile.toJson()).then((value) {
                _showProgressUi(false, "User added");
              }).catchError((error) {
                _showProgressUi(false, "Failed to add user: $error");
              });
            }
          }).whenComplete(() {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        PinHome(auth: _auth, displayName: userProfile.name!)));
          });
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          _showProgressUi(false, "The password provided is too weak.");
          FocusScope.of(context).requestFocus(_passwordFocusNode);
        } else if (e.code == 'email-already-in-use') {
          _showProgressUi(false, "Email already used.");
          FocusScope.of(context).requestFocus(_emailFocusNode);
        } else if (e.code == "unknown") {
          _showProgressUi(false, e.message.toString());
          FocusScope.of(context).requestFocus(_confirmPassFocusNode);
        }
      } catch (e) {
        _showProgressUi(false, "$e.");
      }
    } else {
      _showProgressUi(false, "Invalid OTP.");
    }
  }

  String _generateUserCode() {
    var rng = Random();
    var code1 = rng.nextInt(9000) + 1000;
    var code2 = rng.nextInt(9000) + 1000;
    var code3 = rng.nextInt(9000) + 1000;
    return "$code1 $code2 $code3";
  }

  _showProgressUi(bool isLoading, String msg) {
    if (msg.isNotEmpty) {
      Fluttertoast.showToast(msg: msg);
    }
    setState(() => _isLoading = isLoading);
  }
}
