import 'dart:math';

import 'package:badges/badges.dart';
import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/dashboard.dart';
//import 'package:bills/pages/pin/pin_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

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
  List<dynamic> _selectedList = [];
  List<dynamic> _selectList = [];

  final _displayNameController = TextEditingController();
  final _userCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _membersController = TextEditingController();
  final _billGenDateController = TextEditingController();
  final _userTypeController = TextEditingController();

  final DateTime _firstdate = DateTime(DateTime.now().year - 2);
  final DateTime _lastdate = DateTime.now();

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
    _getUserTypes();
    _getPayer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // actions: _isLoading
        //     ? null
        //     : [
        //         IconButton(
        //           icon: Icon(
        //             _isUpdate ? Icons.done : Icons.edit,
        //             color: Colors.white,
        //           ),
        //           onPressed: () {
        //             if (_isUpdate) {
        //               _updatePayer();
        //             } else {}
        //             setState(() {
        //               _isUpdate = !_isUpdate;
        //             });
        //             FocusScope.of(context).requestFocus(_nameFocusNode);
        //           },
        //         )
        //       ],
        leading:
            // _isUpdate
            //     ? IconButton(
            //         onPressed: () => setState(() => _isUpdate = !_isUpdate),
            //         icon: Icon(Icons.close),
            //       )
            //     :
            IconButton(
          onPressed: () {
            if (_isUpdate) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text('Are you sure you want this Page?'),
                  content: const Text('There are changes that are not saved.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.pop(context, 'Cancel'),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isUpdate = false;
                          Navigator.pop(context);
                          Navigator.pop(context);
                        });
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          physics: BouncingScrollPhysics(),
          child: _getPayerDisplay(),
        ),
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
            ListTile(
              title: Text('Personal Details'),
              dense: true,
            ),
            Divider(indent: 15, endIndent: 15),
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
              controller: _displayNameController,
              onChanged: (value) {
                setState(() {
                  _userProfile.displayName = value;
                });
              },
              onTap: () {
                if (_displayNameController.text.isEmpty) {
                  _displayNameController.selection = TextSelection(
                      baseOffset: _displayNameController.text.length,
                      extentOffset: _displayNameController.text.length);
                }
              },
            ),
            CustomDivider(),
            ListTile(
              title: Text('Payer Details'),
              dense: true,
            ),
            Divider(indent: 15, endIndent: 15),
            TextFormField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(5),
                icon: Icon(Icons.people),
                labelText: 'Members',
                hintText: 'Members',
              ),
              keyboardType: TextInputType.number,
              //enabled: _isUpdate,
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
            TextFormField(
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(5),
                  icon: Icon(Icons.calendar_today),
                  labelText: 'Bill Generation Date',
                  hintText: 'Bill Generation Date'),
              controller: _billGenDateController,
              readOnly: true,
              //enabled: _isUpdate,
              onTap: () {
                _getDate();
              },
              validator: (value) {
                if (value == null || value.isEmpty || value == "0") {
                  return 'Invalid date.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _getPayerDisplay() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      children: [
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text("Personal"),
              ),
              CustomDivider(),
              ListTile(
                leading: _getUserImage(),
                minLeadingWidth: 0,
                title: Text(_displayNameController.text),
                subtitle: Text("Name"),
                trailing: Icon(Icons.edit),
                onTap: () => showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text('Enter Name'),
                    content: TextFormField(
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (value) {
                        //_displayNameController.text = value;
                      },
                      controller: _displayNameController,
                      //autofocus: true,
                      decoration: InputDecoration(hintText: "Name"),
                      validator: (value) {
                        if (value == null || value.isEmpty || value == "") {
                          return 'Invalid name.';
                        }
                        return null;
                      },
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel')),
                      TextButton(
                          onPressed: () {
                            if (_displayNameController.text.isNotEmpty) {
                              setState(() {
                                _userProfile.displayName =
                                    _displayNameController.text;
                              });
                              _isUpdate = true;
                              Navigator.pop(context);
                            } else {
                              Fluttertoast.showToast(msg: "Name required.");
                            }
                          },
                          child: Text('OK')),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text("Payer Details"),
              ),
              CustomDivider(),
              ListTile(
                leading: Icon(Icons.code),
                minLeadingWidth: 0,
                title: Text(_userCodeController.text),
                subtitle:
                    Text("${_userTypeController.text.split(' ')[0]} Code"),
                trailing: Icon(Icons.copy),
                onTap: () {
                  Clipboard.setData(
                          new ClipboardData(text: _userCodeController.text))
                      .then((_) {
                    Fluttertoast.showToast(
                        msg:
                            "${_userTypeController.text.split(' ')[0]} Code copied to clipboard");
                  });
                },
              ),
              Divider(indent: 15, endIndent: 15),
              ListTile(
                leading: _userProfile.userType?.isEmpty ?? true
                    ? Badge(
                        badgeContent: Text(''),
                        child: Icon(Icons.person),
                      )
                    : Icon(Icons.person),
                minLeadingWidth: 0,
                title: Text(_userTypeController.text),
                subtitle: Text("User Type"),
                trailing: Icon(Icons.edit),
                onTap: () => showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text("Select User Type"),
                    content: SafeArea(
                        child: SingleChildScrollView(
                            //padding: EdgeInsets.all(10),
                            physics: BouncingScrollPhysics(),
                            child: _userTypesSelectionWidget())),
                    // actions: [
                    //   TextButton(
                    //       onPressed: () => Navigator.pop(context),
                    //       child: Text('Cancel')),
                    //   TextButton(
                    //       onPressed: () {
                    //         if ((_userProfile.members ?? 0) > 0) {
                    //           Navigator.pop(context);
                    //           setState(() {
                    //             _isUpdate = true;
                    //           });
                    //         } else {
                    //           Fluttertoast.showToast(
                    //               msg: "User Type required.");
                    //         }
                    //       },
                    //       child: Text('OK')),
                    // ],
                  ),
                ),
              ),
              Divider(indent: 15, endIndent: 15),
              ListTile(
                leading: _userProfile.members == 0
                    ? Badge(
                        badgeContent: Text(''),
                        animationType: BadgeAnimationType.scale,
                        child: Icon(Icons.people_alt_outlined),
                      )
                    : Icon(Icons.people_alt_outlined),
                minLeadingWidth: 0,
                title: Text(_membersController.text),
                subtitle: Text("Members"),
                trailing: Icon(Icons.edit),
                onTap: () => showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text('Enter Member(s)'),
                    content: TextFormField(
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          //_userProfile.members = int.parse(value);
                          //_membersController.text = value;
                        });
                      },
                      controller: _membersController,
                      autofocus: true,
                      decoration: InputDecoration(hintText: "Member(s)"),
                      validator: (value) {
                        if (value == null || value.isEmpty || value == "0") {
                          return 'Must be geater than 0.';
                        }
                        return null;
                      },
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel')),
                      TextButton(
                          onPressed: () {
                            if ((_userProfile.members ?? 0) > 0) {
                              Navigator.pop(context);
                              setState(() {
                                _isUpdate = true;
                                _userProfile.members =
                                    int.parse(_membersController.text);
                              });
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Member(s) must be greater than 0.");
                            }
                          },
                          child: Text('OK')),
                    ],
                  ),
                ),
              ),
              Divider(indent: 15, endIndent: 15),
              ListTile(
                leading: _userProfile.billingGenDate == null
                    ? Badge(
                        badgeContent: Text(''),
                        animationType: BadgeAnimationType.scale,
                        child: Icon(Icons.calendar_today),
                      )
                    : Icon(Icons.calendar_today),
                minLeadingWidth: 0,
                title: Text(_billGenDateController.text),
                subtitle: Text("Bill Generation Date"),
                trailing: Icon(Icons.edit),
                onTap: () {
                  _getDate();
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isUpdate ? _updatePayer : null,
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Text('Submit Changes'),
          style: ElevatedButton.styleFrom(
            minimumSize: Size(double.infinity, 50),
            primary: _isUpdate ? Colors.white38 : Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _getUserImage() {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1.5),
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.fill,
          image: _auth.currentUser!.photoURL != null
              ? NetworkImage(_auth.currentUser!.photoURL.toString())
              : AssetImage('assets/icons/user.png') as ImageProvider,
        ),
      ),
    );
  }

  // Widget _getPayerDisplay() {
  //   return ListView(
  //     children: [
  //       Divider(indent: 15, endIndent: 15),
  //       ListTile(
  //         leading: Icon(Icons.person),
  //         minLeadingWidth: 0,
  //         title: Text('Display Name'),
  //         trailing: Text("${_userProfile.displayName}"),
  //         //onTap: _logoutDialog,
  //       ),
  //       Divider(indent: 15, endIndent: 15),
  //       ListTile(
  //         leading: Icon(Icons.email),
  //         minLeadingWidth: 0,
  //         title: Text('Email'),
  //         trailing: Text("${_userProfile.email}"),
  //         //onTap: _logoutDialog,
  //       ),
  //       Divider(indent: 15, endIndent: 15),
  //       ListTile(
  //         leading: Icon(Icons.mobile_friendly),
  //         minLeadingWidth: 0,
  //         title: Text('Mobile Number'),
  //         trailing: Text("${_userProfile.phoneNumber}"),
  //         //onTap: _logoutDialog,
  //       ),
  //       Divider(indent: 15, endIndent: 15),
  //       ListTile(
  //         leading: Icon(Icons.group),
  //         minLeadingWidth: 0,
  //         title: Text('Members'),
  //         trailing: Text("${_userProfile.members}"),
  //         //onTap: _logoutDialog,
  //       ),
  //       Divider(indent: 15, endIndent: 15),
  //     ],
  //   );
  // }

  _getPayer() {
    _showProgressUi(true, "");

    try {
      DocumentReference _document =
          FirebaseFirestore.instance.collection('users').doc(_id);
      UserProfile userProfile = UserProfile();

      _document.get().then((snapshot) {
        if (snapshot.exists) {
          // var aa = snapshot.data() as Map<String, dynamic>;
          // var bb = json.encode(aa);
          // var cc = UserProfile.fromJson(bb as Map<String, dynamic>);
          userProfile.displayName = snapshot.get('display_name') as String?;
          userProfile.userCode = snapshot.get('user_code') as String?;
          userProfile.userType = snapshot.get('user_type') as String?;
          userProfile.members = snapshot.get('members') as int?;
          userProfile.billingGenDate =
              DateTime.parse(snapshot.get('billing_generation_date') as String);
          userProfile.userCode = _userProfile.userCode?.isEmpty ?? true
              ? _generateUserCode()
              : _userProfile.userCode!;
          userProfile.id = snapshot.id;
        } else {}
      }).whenComplete(() {
        setState(() {
          _userProfile = userProfile;
          _displayNameController.text = _userProfile.displayName ?? "No Name";
          _userCodeController.text = _userProfile.userCode ?? "No User Code";
          _userTypeController.text =
              _getUserTypeDescription(_userProfile.userType ?? "No User Type");
          _emailController.text = _userProfile.email ?? "No Email";
          _phoneNumberController.text =
              _userProfile.phoneNumber ?? "No Mobile Number";
          _membersController.text = (_userProfile.members ?? 1).toString();
          _billGenDateController.text = _userProfile.billingGenDate != null
              ? DateFormat('MMM dd, yyyy')
                  .format(_userProfile.billingGenDate!)
                  .toString()
              : "No Billing Generation Date";
        });
        _showProgressUi(false, "");
      });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  String _generateUserCode() {
    var rng = new Random();
    var code1 = rng.nextInt(9000) + 1000;
    var code2 = rng.nextInt(9000) + 1000;
    var code3 = rng.nextInt(9000) + 1000;
    return "$code1 $code2 $code3";
  }

  _updatePayer() {
    _showProgressUi(true, "Saving");

    try {
      if (_id != null) {
        DocumentReference _document =
            FirebaseFirestore.instance.collection('users').doc(_id);
        _userProfile.modifiedOn = DateTime.now();
        _document.update({
          'display_name': _userProfile.displayName,
          'user_code': _userProfile.userCode,
          'user_type': _userProfile.userType,
          'members': _userProfile.members,
          'billing_generation_date': _userProfile.billingGenDate.toString()
        }).whenComplete(() {
          setState(() {
            _isUpdate = false;
          });
          _showProgressUi(false, "Update success.");
          _getPayer();
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

  _getDate() async {
    var date = await showDatePicker(
      context: context,
      initialDate: _userProfile.billingGenDate ?? _lastdate,
      firstDate: _firstdate,
      lastDate: _lastdate,
    );
    if (date != null) {
      setState(() {
        _billGenDateController.text = DateFormat('MMM dd, yyyy')
            .format(DateTime(date.year, date.month, date.day));
        _userProfile.billingGenDate = DateTime(date.year, date.month, date.day);
        _isUpdate = true;
      });
    }
  }

  Future<void> _getUserTypes() async {
    //_showProgressUi(true, "");

    try {
      List<dynamic> users = [];
      CollectionReference _collection =
          FirebaseFirestore.instance.collection("user_types");
      _collection.get().then((querySnapshot) {
        querySnapshot.docs.forEach((document) {
          users.add([document.id, document.get('description')]);
        });
      }).whenComplete(() {
        setState(() {
          _selectList.addAll(users);
        });
        //_showProgressUi(false, "");
      });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  Widget _userTypesSelectionWidget() {
    List<Widget> mList = <Widget>[];
    for (int b = 0; b < _selectList.length; b++) {
      String id = _selectList[b][0];
      String description = _selectList[b][1] ?? "User Type";
      mList.add(CheckboxListTile(
        selected: _selectedList.contains(id),
        onChanged: (bool? value) {
          setState(() {
            _selectedList.clear();
            if (value == true) {
              _selectedList.add(id);
              _userProfile.userType = id;
              _userTypeController.text = _getUserTypeDescription(id);
            } else {
              _selectedList.remove(id);
              _userProfile.userType = "";
              _userTypeController.text = "";
            }
            _selectedUserTypeDisplay();
          });
          print(_selectedList);

          Navigator.pop(context);
        },
        value: _selectedList.contains(id),
        title: new Text(description),
        subtitle: new Text(id),
        controlAffinity: ListTileControlAffinity.leading,
      ));
      mList.add(Divider());
    }
    return Container(
        height: 150.0, // Change as per your requirement
        width: 300.0, // Change as per your requirement
        child: ListView(shrinkWrap: true, children: mList));
  }

  _selectedUserTypeDisplay() {
    setState(() {
      // if (_selectedList.length == 1) {
      //   String? payer = _getUserTypeDescription(_selectedList[0]);
      //   _userTypeController.text = '$payer';
      // } else {
      //   _userTypeController.text = 'Select a Payer';
      // }
      //if (_userTypeController.text.isNotEmpty) {
      //_userProfile.userType = _userTypeController.text;
      //_isUpdate = true;
      //} else {
      //  _userProfile.userType = "";
      //}
    });
  }

  String _getUserTypeDescription(String id) {
    String desc = id;
    for (var p in _selectList) {
      if (p[0] == id) {
        desc = p[1] ?? "";
        break;
      }
    }
    return desc;
  }

  _showProgressUi(bool isLoading, String msg) {
    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
    setState(() => _isLoading = isLoading);
  }
}
