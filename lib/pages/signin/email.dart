import 'package:bills/pages/pin/pin_home.dart';
import 'package:bills/pages/signin/signin_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_auth/email_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EmailSignInPage extends StatefulWidget {
  EmailSignInPage({Key? key, required this.auth, required this.isSignin})
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

  CollectionReference _collection =
      FirebaseFirestore.instance.collection("users");

  bool _isLoading = false;
  RegExp _emailRegex = RegExp(
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
  String _errorMsg = "";
  bool _verifyOtpEnabled = false;

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
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Icon(Icons.arrow_back),
          ),
        ),
        iconTheme: IconThemeData(color: Colors.grey.shade300),
        textTheme:
            TextTheme(headline6: TextStyle(color: Colors.white, fontSize: 25)),
        title: Text(_title),
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey.shade800,
          padding: EdgeInsets.all(20),
          alignment: Alignment.center,
          child: Center(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
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
        decoration: InputDecoration(
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
      SizedBox(),
      TextFormField(
        obscureText: true,
        textInputAction: TextInputAction.next,
        focusNode: _passwordFocusNode,
        decoration: InputDecoration(
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
      SizedBox(height: 30),
      TextButton(
        child: Text("Sign In", style: TextStyle(fontSize: 18)),
        style: TextButton.styleFrom(
            //shape: StadiumBorder(),
            minimumSize: Size(double.infinity, 50),
            primary: Colors.grey.shade800,
            backgroundColor: _proceed ? Colors.grey.shade300 : Colors.white38),
        onPressed: _proceed ? _signIn : null,
      ),
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
          decoration: InputDecoration(
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
        SizedBox(),
        TextFormField(
          obscureText: true,
          textInputAction: TextInputAction.next,
          focusNode: _passwordFocusNode,
          decoration: InputDecoration(
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
        SizedBox(),
        TextFormField(
          obscureText: true,
          textInputAction: TextInputAction.go,
          focusNode: _confirmPassFocusNode,
          decoration: InputDecoration(
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
        SizedBox(height: 30),
        TextButton(
          child: Text("Sign Up", style: TextStyle(fontSize: 18)),
          style: TextButton.styleFrom(
              //shape: StadiumBorder(),
              minimumSize: Size(double.infinity, 50),
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
    setState(() {
      _errorMsg = "";
      _isLoading = true;
    });

    try {
      if (!_emailRegex.hasMatch(_email.toString())) {
        _errorMsg = "Invalid email format.";
      }
      if (_password.toString().length == 0) {
        _errorMsg = "Password is required.";
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _email!, password: _password!);
      late String displayName;
      User? user = userCredential.user;

      if (user != null) {
        DocumentReference document = _collection.doc(user.uid);
        document.get().then((snapshot) {
          if (snapshot.exists) {
            displayName = snapshot.get("display_name");
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
        _errorMsg = 'User not found.';
        FocusScope.of(context).requestFocus(_emailFocusNode);
      } else if (e.code == 'wrong-password') {
        _errorMsg = 'Invalid password';
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      } else if (e.code == "unknown") {
        _errorMsg = e.toString();
      } else {
        _errorMsg = e.toString();
      }
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
    }

    setState(() => _isLoading = false);
    if (_errorMsg.length > 0) {
      Fluttertoast.showToast(msg: _errorMsg);
    }
  }

  _signUp() async {
    setState(() {
      _errorMsg = "";
      _isLoading = true;
    });

    if (!_emailRegex.hasMatch(_email.toString())) {
      _errorMsg = "Invalid email format.";
    } else if (_password.toString().length == 0) {
      _errorMsg = "Password is required.";
    } else if (_confirmPassword.toString().length == 0) {
      _errorMsg = "Confirm password is required.";
    } else if (_password.toString() != _confirmPassword.toString()) {
      _errorMsg = "Password and confirm password doesn't match.";
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
          _errorMsg = "The password provided is too weak.";
          FocusScope.of(context).requestFocus(_passwordFocusNode);
        } else if (e.code == 'email-already-in-use') {
          _errorMsg = "Email already used";
          FocusScope.of(context).requestFocus(_emailFocusNode);
        } else if (e.code == "unknown") {
          _errorMsg = e.toString();
          FocusScope.of(context).requestFocus(_confirmPassFocusNode);
        }
      } catch (e) {
        _errorMsg = e.toString();
      }
    }

    setState(() => _isLoading = false);
    if (_errorMsg.length > 0) {
      Fluttertoast.showToast(msg: _errorMsg);
    }
  }

  Widget getVerifyOtpWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
              "An otp has been sent to your email\n${_emailController.text}",
              style: TextStyle(fontSize: 15, color: Colors.white),
              textAlign: TextAlign.center),
        ),
        SizedBox(height: 20),
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
              _verifyOtpEnabled = value.length == 6;
            });
          },
        ),
        SizedBox(height: 16),
        TextButton(
          child: Text("Verify"),
          style: TextButton.styleFrom(
              //shape: StadiumBorder(),
              minimumSize: Size(double.infinity, 40),
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

  void _sendOtp() async {
    setState(() {
      _errorMsg = "";
      _isLoading = true;
    });

    try {
      EmailAuth.sessionName = "Bills App";
      bool optSent =
          await EmailAuth.sendOtp(receiverMail: _emailController.value.text);

      if (optSent) {
        setState(() {
          _title = "Verify OTP";
          _emailState = EmailVerificationState.SHOW_OTP_SENT;
        });
      }
    } catch (e) {
      _errorMsg = e.toString();
    }

    setState(() => _isLoading = false);
    if (_errorMsg.length > 0) {
      Fluttertoast.showToast(msg: _errorMsg);
    }
  }

  void _verifyOtp() async {
    setState(() {
      _errorMsg = "";
      _isLoading = true;
    });

    bool verified = EmailAuth.validate(
        receiverMail: _emailController.text, userOTP: _otpController.text);

    if (verified) {
      try {
        // UserCredential userCredential =
        //     await _auth.createUserWithEmailAndPassword(
        //         email: _email!, password: _password!);
        late String displayName;
        User? user = _userCredential?.user;

        if (user != null) {
          DocumentReference document = _collection.doc(user.uid);
          displayName = user.displayName ?? user.email ?? 'User';

          document.get().then((snapshot) {
            if (!snapshot.exists) {
              document.set({
                'display_name': displayName,
                'email': user.email,
                'photo_url': user.photoURL,
                'logged_in': false
              }).then((value) {
                _errorMsg = "User added";
              }).catchError((error) {
                _errorMsg = "Failed to add user: $error";
              });
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
        if (e.code == 'weak-password') {
          _errorMsg = 'The password provided is too weak.';
          FocusScope.of(context).requestFocus(_passwordFocusNode);
        } else if (e.code == 'email-already-in-use') {
          _errorMsg = 'Email already used';
          FocusScope.of(context).requestFocus(_emailFocusNode);
        } else if (e.code == "unknown") {
          _errorMsg = e.message.toString();
          FocusScope.of(context).requestFocus(_confirmPassFocusNode);
        }
      } catch (e) {
        _errorMsg = e.toString();
      }
    } else {
      _errorMsg = "Invalid OTP.";
    }

    setState(() => _isLoading = false);
    if (_errorMsg.length > 0) {
      Fluttertoast.showToast(msg: _errorMsg);
    }
  }
}
