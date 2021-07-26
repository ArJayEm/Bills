import 'package:bills/models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../mpin/mpin.dart';

class EmailSignInPage extends StatefulWidget {
  EmailSignInPage({Key? key}) : super(key: key);

  @override
  _EmailSignInPageState createState() => _EmailSignInPageState();
}

enum EmailVerificationState { SHOW_SIGN_IN_STATE, SHOW_SIGN_UP_STATE }

class _EmailSignInPageState extends State<EmailSignInPage> {
  EmailVerificationState emailState = EmailVerificationState.SHOW_SIGN_IN_STATE;
  bool _showLoading = false;

  late final UserProfile _userProfile;

  final emailController = TextEditingController();
  final emailPassController = TextEditingController();
  final emailConfirmPassController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPassFocusNode = FocusNode();
  
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
              //? showAlertDialog(context)
              : emailState == EmailVerificationState.SHOW_SIGN_IN_STATE
                  ? getEmailSignInPageWidget()
                  : getEmailSignUpPageWidget(),
        ),
      ),
    );
  }

  Widget getEmailSignUpPageWidget() {
    return Column(children: [
      TextButton(
        child: Row(
          children: [Icon(Icons.chevron_left), Text('Back')],
        ),
        onPressed: () {
          //Go back sign_in_page.dart
        },
      ),
      SizedBox(),
      Row(children: [
        Text('Alreaedy have an account?'),
        TextButton(
          child: Text('Log In'),
          onPressed: () {
            setState(() {
              emailState = EmailVerificationState.SHOW_SIGN_IN_STATE;
            });
          },
        ),
        Text('here.')
      ]),
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
        onChanged: (value) {},
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
        controller: emailPassController,
        onChanged: (value) {},
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
        controller: emailConfirmPassController,
        onChanged: (value) {},
      ),
      SizedBox(height: 30),
      TextButton(
        child: Text('Sign Up'),
        style: TextButton.styleFrom(
            //shape: StadiumBorder(),
            minimumSize: Size(double.infinity, 50),
            primary: Colors.white,
            backgroundColor: Color.fromARGB(255, 242, 163, 38)),
        onPressed: () {
          _signUp();
        },
      ),
    ]);
  }

  Widget getEmailSignInPageWidget() {
    return Column(children: [
      TextButton(
        child: Row(children: [Icon(Icons.chevron_left), Text('Back')]),
        onPressed: () {
          //Go back sign_in_page.dart
        },
      ),
      SizedBox(),
      Row(children: [
        Text('No account yet?'),
        TextButton(
          child: Text('Sign Up'),
          onPressed: () {
            setState(() {
              emailState = EmailVerificationState.SHOW_SIGN_UP_STATE;
            });
          },
        ),
        Text('here.')
      ]),
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
        onChanged: (value) {},
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
        controller: emailPassController,
        onChanged: (value) {},
      ),
      SizedBox(height: 30),
      TextButton(
        child: Text('Log In'),
        style: TextButton.styleFrom(
            //shape: StadiumBorder(),
            minimumSize: Size(double.infinity, 40),
            primary: Colors.white,
            backgroundColor: Color.fromARGB(255, 242, 163, 38)),
        onPressed: _signIn,
      ),
    ]);
  }

  _signUp() async {
    setState(() => _showLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: emailPassController.text);

      //send otp
      //verify otp

      _userProfile = UserProfile(
          id: userCredential.user!.uid,
          displayName: userCredential.user!.email ?? '',
          email: userCredential.user!.email ?? '');

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MpinSignInPage(userProfile: _userProfile)));
    } on FirebaseAuthException catch (e) {
      late String msg;

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
      Fluttertoast.showToast(msg: msg);
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  void _signIn() async {
    setState(() => _showLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: emailPassController.text);

      _userProfile = UserProfile(
          id: userCredential.user!.uid,
          displayName: userCredential.user!.email ?? '',
          email: userCredential.user!.email ?? '');

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MpinSignInPage(userProfile: _userProfile)));
    } on FirebaseAuthException catch (e) {
      setState(() {
        _showLoading = false;
      });
      late String msg;
      FocusScope.of(context).requestFocus(_passwordFocusNode);

      if (e.code == 'user-not-found') {
        msg = 'User not found.';
        FocusScope.of(context).requestFocus(_emailFocusNode);
      } else if (e.code == 'wrong-password') {
        msg = 'Invalid password';
      } else if (e.code == "unknown") {
        msg = e.message.toString();
      } else {
        msg = e.message.toString();
      }

      Fluttertoast.showToast(msg: msg);
    }
  }
}
