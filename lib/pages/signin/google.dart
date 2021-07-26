import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/mpin/mpin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInPage extends StatefulWidget {
  GoogleSignInPage({Key? key}) : super(key: key);

  @override
  _GoogleSignInPageState createState() => _GoogleSignInPageState();
}

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

enum EmailVerificationState { SHOW_SIGN_IN_STATE, SHOW_SIGN_UP_STATE }

class _GoogleSignInPageState extends State<GoogleSignInPage> {
  EmailVerificationState emailState = EmailVerificationState.SHOW_SIGN_IN_STATE;

  UserProfile _userProfile = UserProfile();

  @override
  void initState() {
    super.initState();
    _handleSignIn();
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Google'));
  }

  Future<void> _handleSignIn() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        setState(() {
          _userProfile.id = googleSignInAccount.id;
          _userProfile.displayName =
              googleSignInAccount.displayName ?? googleSignInAccount.email;
          _userProfile.photoUrl = googleSignInAccount.photoUrl;
        });

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MpinSignInPage(userProfile: _userProfile)));
      } else {
        Fluttertoast.showToast(msg: "Invalid user!");
      }
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
