import 'package:bills/pages/signin/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../mpin/mpin.dart';

class EmailSignInPage extends StatefulWidget {
  EmailSignInPage({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

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
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      key: _scaffoldKey,
      child: Scaffold(
        body: Container(
          padding: EdgeInsets.all(20),
          alignment: Alignment.center,
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : _emailState == EmailVerificationState.SHOW_SIGN_IN_STATE
                  ? getEmailSignInPageWidget()
                  : getEmailSignUpPageWidget(),
        ),
      ),
    );
  }

  Widget getEmailSignInPageWidget() {
    return Column(children: [
      TextButton(
        child: Row(children: [Icon(Icons.chevron_left), Text('Back')]),
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SignInPage(auth: _auth)));
        },
      ),
      SizedBox(),
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
          backgroundColor: Colors.grey.shade300,
        ),
        onPressed: _signIn,
      ),
      SizedBox(height: 10),
      TextButton(
        child: Text('Sign Up', style: TextStyle(fontSize: 18)),
        style: TextButton.styleFrom(
          //shape: StadiumBorder(),
          minimumSize: Size(double.infinity, 50),
          primary: Colors.grey.shade300,
          backgroundColor: Colors.grey.shade800,
        ),
        onPressed: () {
          setState(() {
            _emailState = EmailVerificationState.SHOW_SIGN_UP_STATE;
          });
        },
      ),
    ]);
  }

  Widget getEmailSignUpPageWidget() {
    return Column(children: [
      TextButton(
        child: Row(
          children: [Icon(Icons.chevron_left), Text('Back')],
        ),
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SignInPage(auth: _auth)));
        },
      ),
      SizedBox(),
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
          });
        },
      ),
      SizedBox(height: 30),
      TextButton(
        child: Text('Sign Up', style: TextStyle(fontSize: 18)),
        style: TextButton.styleFrom(
          //shape: StadiumBorder(),
          minimumSize: Size(double.infinity, 50),
          primary: Colors.grey.shade300,
          backgroundColor: Colors.grey.shade800,
        ),
        onPressed: _signUp,
      ),
      SizedBox(height: 10),
      TextButton(
        child: Text('Sign In', style: TextStyle(fontSize: 18)),
        style: TextButton.styleFrom(
          //shape: StadiumBorder(),
          minimumSize: Size(double.infinity, 50),
          primary: Colors.grey.shade800,
          backgroundColor: Colors.grey.shade300,
        ),
        onPressed: () {
          setState(() {
            _emailState = EmailVerificationState.SHOW_SIGN_IN_STATE;
          });
        },
      ),
    ]);
  }

  _signUp() async {
    setState(() => _isLoading = true);
    String msg = '';

    if (_password?.isNotEmpty == true && _password == _confirmPassword) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
                email: _email!, password: _password!);
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
    } else {
      msg = "email and password required.";
    }

    setState(() => _isLoading = false);
    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
  }

  _signIn() async {
    setState(() => _isLoading = true);
    String? msg;

    if (_email != null && _password != null) {
      try {
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
      }
    } else {
      msg = "email and password required.";
    }

    setState(() => _isLoading = false);
    if (msg != null) {
      Fluttertoast.showToast(msg: msg);
    }
  }
}
