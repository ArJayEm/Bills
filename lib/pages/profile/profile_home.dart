import 'package:bills/models/payer.dart';
//import 'package:bills/pages/pin/pin_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileHome extends StatefulWidget {
  const ProfileHome({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _ProfileHomeState createState() => _ProfileHomeState();
}

class _ProfileHomeState extends State<ProfileHome> {
  late FirebaseAuth _auth;
  //late String _displayName;

  Payer _payer = Payer();

  // final _displayNameController = TextEditingController();
  // final _emailController = TextEditingController();
  // final _phoneNumberController = TextEditingController();
  // final _membersController = TextEditingController();

  String _errorMsg = '';
  bool _isLoading = false;

  //final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      _auth = widget.auth;
    });
    _getPayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back),
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
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _getPayerDisplay(),
      ),
    );
  }

  Widget _getPayerDisplay() {
    return ListView(
      children: [
        Divider(),
        ListTile(
          leading: Icon(Icons.person),
          minLeadingWidth: 0,
          title: Text('Display Name'),
          trailing: Text("${_payer.displayName}"),
          //onTap: _logoutDialog,
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.email),
          minLeadingWidth: 0,
          title: Text('Email'),
          trailing: Text("${_payer.email}"),
          //onTap: _logoutDialog,
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.mobile_friendly),
          minLeadingWidth: 0,
          title: Text('Mobile Number'),
          trailing: Text("${_payer.phoneNumber}"),
          //onTap: _logoutDialog,
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.group),
          minLeadingWidth: 0,
          title: Text('Members'),
          trailing: Text("${_payer.members}"),
          //onTap: _logoutDialog,
        ),
        Divider(),
      ],
    );
  }

  _getPayer() {
    setState(() {
      _errorMsg = "";
      _isLoading = true;
    });

    try {
      DocumentReference _document = FirebaseFirestore.instance
          .collection('users')
          .doc(_auth.currentUser!.uid);
      Payer payer = Payer();

      _document.get().then((snapshot) {
        if (snapshot.exists) {
          //payer = Payer.fromJson(snapshot.data() as Map<String, dynamic>);
          payer.displayName = snapshot.get('display_name');
          payer.email = snapshot.get('email');
          payer.phoneNumber = snapshot.get('phone_number');
          payer.members = snapshot.get('members');
        } else {}
      }).whenComplete(() {
        setState(() {
          _payer = payer;
        });
      });
    } on FirebaseAuthException catch (e) {
      _errorMsg = '${e.message}';
    } catch (error) {
      _errorMsg = error.toString();
    }

    setState(() => _isLoading = false);
    if (_errorMsg.length > 0) {
      Fluttertoast.showToast(msg: _errorMsg);
    }
  }
}
