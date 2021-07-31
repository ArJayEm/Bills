import 'package:bills/pages/mpin/mpin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileHome extends StatefulWidget {
  const ProfileHome({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _ProfileHomeState createState() => _ProfileHomeState();
}

class _ProfileHomeState extends State<ProfileHome> {
  late FirebaseAuth _auth;
  late String _displayName;

  CollectionReference _collection =
      FirebaseFirestore.instance.collection('users');

  @override
  void initState() {
    super.initState();
    setState(() {
      _auth = widget.auth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.chevron_left),
        ),
        iconTheme: IconThemeData(color: Colors.grey.shade300),
        textTheme:
            TextTheme(headline6: TextStyle(color: Colors.white, fontSize: 25)),
        title: Text('Profile'),
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              minLeadingWidth: 0,
              title: Text('Log Out'),
              onTap: _logoutDialog,
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  Future<String?> _logoutDialog() {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Are you sure you want to logout?'),
        content: const Text('Your account will be removed from the device.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              _collection
                  .doc(_auth.currentUser!.uid)
                  .update({'logged_in': false});
              setState(() {
                _displayName = _auth.currentUser!.displayName!;
              });
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MpinSignInPage(
                          auth: _auth, displayName: _displayName)));
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
