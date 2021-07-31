import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../mpin/mpin.dart';

class EmailSignInPage extends StatefulWidget {
  EmailSignInPage({Key? key, required this.auth, required this.isSignin})
      : super(key: key);

  final FirebaseAuth auth;
  final bool isSignin;

  @override
  _EmailSignInPageState createState() => _EmailSignInPageState();
}

enum EmailVerificationState { SHOW_SIGN_IN_STATE, SHOW_SIGN_UP_STATE }

class _EmailSignInPageState extends State<EmailSignInPage> {
  late FirebaseAuth _auth;
  EmailVerificationState _emailState =
      EmailVerificationState.SHOW_SIGN_IN_STATE;

  CollectionReference _collection =
      FirebaseFirestore.instance.collection('users');

  bool _isLoading = false;
  RegExp _emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  bool _proceed = false;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? _email, _password, _confirmPassword;

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPassFocusNode = FocusNode();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    setState(() {
      _auth = widget.auth;
      _emailState = widget.isSignin
          ? EmailVerificationState.SHOW_SIGN_IN_STATE
          : EmailVerificationState.SHOW_SIGN_UP_STATE;
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
          child: Center(
              child: _isLoading
                  ? CircularProgressIndicator()
                  : _emailState == EmailVerificationState.SHOW_SIGN_IN_STATE
                      ? getEmailSignInPageWidget()
                      : getEmailSignUpPageWidget()),
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
          labelText: 'Email',
          hintText: 'Email',
        ),
        controller: emailController,
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
          labelText: 'Password',
          hintText: 'Password',
        ),
        controller: passwordController,
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
        child: Text('Sign In', style: TextStyle(fontSize: 18)),
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
    return Column(children: [
      TextFormField(
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofocus: true,
        focusNode: _emailFocusNode,
        decoration: InputDecoration(
          labelText: 'Email',
          hintText: 'Email',
        ),
        controller: emailController,
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
          labelText: 'Password',
          hintText: 'Password',
        ),
        controller: passwordController,
        onChanged: (value) {
          setState(() {
            _password = value.trim();
            _proceed = _emailRegex.hasMatch(_email.toString()) &&
                _password != null &&
                _confirmPassword != null;
          });
        },
      ),
      SizedBox(),
      TextFormField(
        obscureText: true,
        textInputAction: TextInputAction.go,
        focusNode: _confirmPassFocusNode,
        decoration: InputDecoration(
          labelText: 'Confirm Password',
          hintText: 'Confirm Password',
        ),
        controller: confirmPasswordController,
        onChanged: (value) {
          setState(() {
            _confirmPassword = value.trim();
            _proceed = _emailRegex.hasMatch(_email.toString()) &&
                _password != null &&
                _confirmPassword != null;
          });
        },
      ),
      SizedBox(height: 30),
      TextButton(
        child: Text('Sign Up', style: TextStyle(fontSize: 18)),
        style: TextButton.styleFrom(
            //shape: StadiumBorder(),
            minimumSize: Size(double.infinity, 50),
            primary: Colors.grey.shade800,
            backgroundColor: _proceed ? Colors.grey.shade300 : Colors.white38),
        onPressed: _proceed ? _signUp : null,
      ),
    ]);
  }

  _signIn() async {
    setState(() => _isLoading = true);
    String? msg;

    try {
      if (!_emailRegex.hasMatch(_email.toString())) {
        msg = "Invalid email format.";
        setState(() => _isLoading = false);
        return;
      }
      if (_password.toString().length == 0) {
        msg = "Password is required.";
        setState(() => _isLoading = false);
        return;
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _email!, password: _password!);
      late String displayName;
      User? user = userCredential.user;

      if (user != null) {
        DocumentReference document = _collection.doc(user.uid);
        document.get().then((snapshot) {
          if (snapshot.exists) {
            displayName = snapshot.get('display_name');
          }
        }).whenComplete(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MpinSignInPage(auth: _auth, displayName: displayName)));
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        msg = 'User not found.';
        FocusScope.of(context).requestFocus(_emailFocusNode);
      } else if (e.code == 'wrong-password') {
        msg = 'Invalid password';
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      } else if (e.code == "unknown") {
        msg = e.message.toString();
      } else {
        msg = e.message.toString();
      }
      setState(() => _isLoading = false);
    } catch (error) {
      setState(() => _isLoading = false);
      msg = error.toString();
    }

    if (msg != null) {
      Fluttertoast.showToast(msg: msg);
    }
  }

  _signUp() async {
    setState(() => _isLoading = true);
    String msg = '';

    try {
      if (!_emailRegex.hasMatch(_email.toString())) {
        msg = "Invalid email format.";
        setState(() => _isLoading = false);
        return;
      }
      if (_password.toString().length == 0) {
        msg = "Password is required.";
        setState(() => _isLoading = false);
        return;
      }
      if (_confirmPassword.toString().length == 0) {
        msg = "Confirm password is required.";
        setState(() => _isLoading = false);
        return;
      }
      if (_password.toString() != _confirmPassword.toString()) {
        msg = "Password and confirm password doesn't match.";
        setState(() => _isLoading = false);
        return;
      }

      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: _email!, password: _password!);
      late String displayName;
      User? user = userCredential.user;

      if (user != null) {
        DocumentReference document = _collection.doc(user.uid);
        displayName = user.displayName ?? user.email ?? 'User';

        document.get().then((snapshot) {
          if (!snapshot.exists) {
            document.set({
              'display_name': displayName,
              'email': user.email,
              'logged_in': false
            }).then((value) {
              msg = "User added";
            }).catchError((error) {
              msg = "Failed to add user: $error";
            });
          }
        }).whenComplete(() {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MpinSignInPage(auth: _auth, displayName: displayName)));
        });
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        msg = 'The password provided is too weak.';
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      } else if (e.code == 'email-already-in-use') {
        msg = 'The account already exists for that email.';
        FocusScope.of(context).requestFocus(_emailFocusNode);
      } else if (e.code == "unknown") {
        msg = e.message.toString();
        FocusScope.of(context).requestFocus(_confirmPassFocusNode);
      }
    } catch (e) {
      msg = e.toString();
    }

    setState(() => _isLoading = false);
    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
  }
}
