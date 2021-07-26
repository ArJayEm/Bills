//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//import 'package:bills/models/user_profile.dart';
import 'package:bills/models/menu.dart';

import 'package:bills/pages/signin/email.dart';
import 'package:bills/pages/signin/google.dart';
import 'package:bills/pages/signin/mobile.dart';
// import 'package:bills/pages/mpin/mpin.dart';
// import 'package:fluttertoast/fluttertoast.dart';

enum LoginType { MOBILE_NUMBER, GOOGLE, MPIN }

class SignInPage extends StatefulWidget {
  SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _showLoading = false;

  List<Menu> _signInOptions = [
    Menu(location: '  Email', view: EmailSignInPage(), icon: Icon(Icons.email)),
    Menu(
        location: '  Mobile Number',
        view: MobileSignInPage(),
        icon: Icon(Icons.mobile_friendly)),
    Menu(location: '  Google', view: GoogleSignInPage(), icon: Icon(Icons.web)),
  ];

  @override
  void initState() {
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext ctxt) {
    return SafeArea(
      key: _scaffoldKey,
      child: Scaffold(
        body: Container(
          color: Colors.white,
          padding: EdgeInsets.all(20),
          alignment: Alignment.center,
          child: _showLoading
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
                  color: Colors.black)),
        ),
        SizedBox(height: 30),
        ListView.builder(
          itemCount: _signInOptions.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => _signInOptions[index].view!));
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _signInOptions[index].icon!,
                      SizedBox(height: 20),
                      Text(_signInOptions[index].location!,
                          style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 40),
                    textStyle: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 10)
              ],
            );
          },
        ),
        // ElevatedButton(
        //   onPressed: () {
        //     String msg = '';
        //     var _document = FirebaseFirestore.instance
        //         .collection('users')
        //         .doc('dfdjgvaeifewucw87cwdsi');
        //     UserProfile userProfile = UserProfile();
        //     _document.get().then((snapshot) {
        //       if (snapshot.exists) {
        //         userProfile = UserProfile(
        //             id: snapshot.id,
        //             displayName: snapshot.get('display_name'),
        //             loggedIn: snapshot.get('logged_in'));
        //       } else {
        //         userProfile = UserProfile(
        //             id: 'dfdjgvaeifewucw87cwdsi',
        //             displayName: 'Anonymous',
        //             email: 'sample@gmail.com');
        //         _document
        //             .set({
        //               'display_name': userProfile.displayName,
        //             })
        //             .then((value) => {msg = "User added"})
        //             .catchError(
        //                 (error) => {msg = "Failed to add user: $error"});
        //       }
        //     }).whenComplete(() {
        //       Navigator.push(
        //           context,
        //           MaterialPageRoute(
        //               builder: (context) =>
        //                   MpinSignInPage(userProfile: userProfile)));
        //       // setState(() {
        //       //   _userProfile = userProfile;
        //       //   _isLoading = false;
        //       // });
        //     });

        //     if (msg.length > 0) {
        //       Fluttertoast.showToast(msg: msg);
        //     }
        //   },
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: <Widget>[
        //       Icon(Icons.person),
        //       SizedBox(height: 20),
        //       Text('  Anonymous', style: TextStyle(fontSize: 15)),
        //     ],
        //   ),
        //   style: ElevatedButton.styleFrom(
        //     minimumSize: Size(double.infinity, 40),
        //     //primary: Colors.orange,
        //     textStyle: TextStyle(color: Colors.white),
        //   ),
        // ),
      ],
    );
  }

  showAlertDialog(context) {
    return _showLoading
        ? showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                content: Row(children: [
                  CircularProgressIndicator(),
                  //Spacer(),
                  Text(
                    "  Processing...",
                    style: TextStyle(color: Colors.black),
                  )
                ]),
              );
            },
          )
        : null;
  }
}
