import 'package:bills/models/user_profile.dart';
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
  //late String _name;

  UserProfile _userProfile = UserProfile();
  String? _id;
  //var _widgetList = <Widget>[];
  //var p = _payer.

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _membersController = TextEditingController();

  final _nameFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isUpdate = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      _auth = widget.auth;
      _id = _auth.currentUser!.uid;
    });
    _getPayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: _isLoading
            ? null
            : [
                IconButton(
                  icon: Icon(
                    _isUpdate ? Icons.done : Icons.edit,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (_isUpdate) {
                      _updatePayer();
                    } else {}
                    setState(() {
                      _isUpdate = !_isUpdate;
                    });
                    FocusScope.of(context).requestFocus(_nameFocusNode);
                  },
                )
              ],
        leading: _isUpdate
            ? IconButton(
                onPressed: () => setState(() => _isUpdate = !_isUpdate),
                icon: Icon(Icons.close),
              )
            : IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back),
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
            : _getPayerForm(),
      ),
    );
  }

  Widget _getPayerForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        physics: BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(5),
                icon: Icon(Icons.person),
                labelText: 'Name',
                hintText: 'Name',
              ),
              keyboardType: TextInputType.name,
              focusNode: _isUpdate ? _nameFocusNode : null,
              enabled: _isUpdate,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              controller: _nameController,
              onChanged: (value) {
                setState(() {
                  _userProfile.displayName = value;
                });
              },
              onTap: () {
                if (_nameController.text.isEmpty) {
                  _nameController.selection = TextSelection(
                      baseOffset: _nameController.text.length,
                      extentOffset: _nameController.text.length);
                }
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(5),
                icon: Icon(Icons.people),
                labelText: 'Members',
                hintText: 'Members',
              ),
              keyboardType: TextInputType.number,
              enabled: _isUpdate,
              textInputAction: TextInputAction.done,
              controller: _membersController,
              onChanged: (value) {
                setState(() {
                  _userProfile.members = int.parse(value);
                });
              },
              onTap: () {
                if (_membersController.text.isEmpty) {
                  _membersController.selection = TextSelection(
                      baseOffset: _membersController.text.length,
                      extentOffset: _membersController.text.length);
                }
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // Widget _getPayerDisplay() {
  //   return ListView(
  //     children: [
  //       Divider(),
  //       ListTile(
  //         leading: Icon(Icons.person),
  //         minLeadingWidth: 0,
  //         title: Text('Display Name'),
  //         trailing: Text("${_userProfile.displayName}"),
  //         //onTap: _logoutDialog,
  //       ),
  //       Divider(),
  //       ListTile(
  //         leading: Icon(Icons.email),
  //         minLeadingWidth: 0,
  //         title: Text('Email'),
  //         trailing: Text("${_userProfile.email}"),
  //         //onTap: _logoutDialog,
  //       ),
  //       Divider(),
  //       ListTile(
  //         leading: Icon(Icons.mobile_friendly),
  //         minLeadingWidth: 0,
  //         title: Text('Mobile Number'),
  //         trailing: Text("${_userProfile.phoneNumber}"),
  //         //onTap: _logoutDialog,
  //       ),
  //       Divider(),
  //       ListTile(
  //         leading: Icon(Icons.group),
  //         minLeadingWidth: 0,
  //         title: Text('Members'),
  //         trailing: Text("${_userProfile.members}"),
  //         //onTap: _logoutDialog,
  //       ),
  //       Divider(),
  //     ],
  //   );
  // }

  _getPayer() {
    _showProgressUi(true, "");

    try {
      DocumentReference _document =
          FirebaseFirestore.instance.collection('users').doc(_id);
      UserProfile userprofile = UserProfile();

      _document.get().then((snapshot) {
        if (snapshot.exists) {
          userprofile =
              UserProfile.fromJson(snapshot.data() as Map<String, dynamic>);
          userprofile.id = snapshot.id;
        } else {}
      }).whenComplete(() {
        setState(() {
          _userProfile = userprofile;
          _nameController.text = _userProfile.displayName ?? "No Name";
          _emailController.text = _userProfile.email ?? "No Email";
          _phoneNumberController.text =
              _userProfile.phoneNumber ?? "No Mobile Number";
          _membersController.text = (_userProfile.members ?? 0).toString();
        });
        _showProgressUi(false, "");
      });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  _updatePayer() {
    _showProgressUi(true, "Saving");

    try {
      if (_id != null) {
        DocumentReference _document =
            FirebaseFirestore.instance.collection('users').doc(_id);
        _userProfile.modifiedOn = DateTime.now();
        _document.update(_userProfile.toJson()).whenComplete(() {
          _showProgressUi(false, "Update success.");
        });
      } else {
        _showProgressUi(false, "Invalid user.");
      }
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  _showProgressUi(bool isLoading, String msg) {
    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
    setState(() => _isLoading = isLoading);
  }
}
