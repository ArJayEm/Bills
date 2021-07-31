import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:bills/pages/mpin/mpin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:bills/pages/signin/email.dart';
import 'package:bills/pages/signin/mobile.dart';
//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../components/button.dart';

// GoogleSignIn _googleSignIn = GoogleSignIn(
//   // Optional clientId
//   // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
//   scopes: <String>[
//     'email',
//     'https://www.googleapis.com/auth/contacts.readonly',
//   ],
// );

enum LoginType { MOBILE_NUMBER, GOOGLE, MPIN }

class SignInPage extends StatefulWidget {
  SignInPage({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late FirebaseAuth _auth;
  late User _user;
  var facebookProfile;

  CollectionReference _collection =
      FirebaseFirestore.instance.collection('users');

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _auth = widget.auth;
      //_user = _auth.currentUser!;
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext ctxt) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
        //toolbarHeight: 0,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.grey.shade800,
          padding: EdgeInsets.all(20),
          alignment: Alignment.center,
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : getWelcomeWidget(),
        ),
      ),
    );
  }

  Widget getWelcomeWidget() {
    return ListView(
      children: [
        ListTile(
          title: Text('Welcome back!\nLogin to your account',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
        SizedBox(height: 20),
        CustomIconButton(
          color: Colors.deepOrange.shade400,
          textColor: Colors.grey.shade300,
          image: const AssetImage('assets/icons/google.png'),
          text: 'Google',
          onPressed: _signInWithGoogle,
        ),
        CustomIconButton(
          color: Colors.blue,
          textColor: Colors.grey.shade300,
          image: const AssetImage('assets/icons/facebook-256.png'),
          text: 'Facebook',
          onPressed: initiateFacebookLogin,
        ),
        CustomIconButton(
          color: Colors.grey.shade300,
          textColor: Colors.grey.shade800,
          image: const AssetImage('assets/icons/email.png'),
          text: 'Email',
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EmailSignInPage(auth: _auth, isSignin: false)));
          },
        ),
        CustomIconButton(
          color: Colors.grey.shade300,
          textColor: Colors.grey.shade800,
          image: const AssetImage('assets/icons/mobile.png'),
          text: 'Mobile Number',
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MobileSignInPage(auth: _auth)));
          },
        ),
        SizedBox(height: 20),
        Row(
          children: [
            Spacer(),
            Text(
              'Already registered?',
              style: TextStyle(color: Colors.grey.shade300, fontSize: 15),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EmailSignInPage(auth: _auth, isSignin: true)));
              },
              child: Text(
                'Sign In',
                style: TextStyle(color: Colors.grey.shade300, fontSize: 15),
              ),
            ),
            Spacer(),
          ],
        ),
        // GestureDetector(
        //   child: Container(
        //     width: 120,
        //     height: 55,
        //     decoration: BoxDecoration(
        //       //color: Colors.black,
        //       image: DecorationImage(
        //           image: AssetImage("assets/buttons/google_login.png"),
        //           fit: BoxFit.cover),
        //     ),
        //   ),
        //   onTap: _handleSignIn,
        // )
      ],
    );
  }

  Future<void> _signInWithGoogle() async {
    String msg = '';
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        if (userCredential.user != null) {
          setState(() {
            _user = userCredential.user!;
          });
          msg = await _createLoginAccount();
        }
      }
    } on FirebaseAuthException catch (e) {
      msg = '${e.message}';
    } catch (error) {
      msg = error.toString();
    }

    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
  }

  void initiateFacebookLogin() async {
    setState(() => _isLoading = true);
    String msg = '';
    try {
      final FacebookLoginResult result = await FacebookLogin().logIn();
      switch (result.status) {
        case FacebookLoginStatus.error:
          // var values = FacebookLoginStatus.values;
          // print('values: $values');
          msg = FacebookLoginStatus.error.toString();
          break;
        case FacebookLoginStatus.cancel:
          msg = FacebookLoginStatus.cancel.toString();
          break;
        case FacebookLoginStatus.success:
          msg = FacebookLoginStatus.success.toString();

          final facebookAuthCredential =
              FacebookAuthProvider.credential(result.accessToken!.token);
          UserCredential userCredential =
              await _auth.signInWithCredential(facebookAuthCredential);
          if (userCredential.user != null) {
            setState(() {
              _user = userCredential.user!;
            });
            msg = await _createLoginAccount();
          }

          if (result.accessToken != null) {
            Uri uri = Uri.parse(
                'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=${result.accessToken!.token}');
            var graphResponse = await http.get(uri);
            var profile = json.decode(graphResponse.body);
            setState(() {
              _user = userCredential.user!;
            });
            msg = await _createLoginAccount();
            print(profile.toString());
          }
          break;
      }
    } on FirebaseAuthException catch (e) {
      msg = '${e.message}';
    } catch (error) {
      msg = error.toString();
    }

    if (msg.length > 0) {
      print(msg);
      Fluttertoast.showToast(msg: msg);
    }
  }

  Future<String> _createLoginAccount() async {
    String msg = '';
    var _document = _collection.doc(_user.uid);
    _document.get().then((snapshot) {
      if (!snapshot.exists) {
        _document.set({
          'display_name': _user.displayName ?? _user.email,
          'email': _user.email,
          'photo_url': _user.photoURL,
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
          builder: (context) => MpinSignInPage(
            auth: _auth,
            displayName: _user.displayName ?? 'User',
          ),
        ),
      );
    });
    return msg;
  }
}
