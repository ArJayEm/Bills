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
  bool _hasRequiredFields = false;
  //bool _mobileUser = false;

  TextStyle _hint = TextStyle(fontSize: 15, color: Colors.white30);

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      _auth = widget.auth;
      _id = _auth.currentUser!.uid;
    });
    _getUserTypes();
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
                title: Text("Payer Info"),
              ),
              CustomDivider(),
              ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _hasRequiredFields
                        ? Badge(
                            badgeContent: Text(''),
                            child: _getUserImage(),
                          )
                        : _getUserImage()
                  ],
                ),
                minLeadingWidth: 0,
                title: Text(_displayNameController.text),
                subtitle: Text("Name"),
                trailing: _hasRequiredFields &&
                        _isUpdate &&
                        (_userProfile.displayName?.isEmpty ?? true)
                    ? Icon(Icons.edit)
                    : Icon(Icons.info_outline),
                onTap: () => _hasRequiredFields &&
                        _isUpdate &&
                        (_userProfile.displayName?.isEmpty ?? true)
                    ? showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text('Enter Name'),
                          content: SafeArea(
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  Text(
                                      "Hint: This means you registered by mobile number, and that you must update this to you name for easier reference.",
                                      style: _hint),
                                  SizedBox(height: 10),
                                  TextFormField(
                                    keyboardType: TextInputType.name,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    onChanged: (value) {
                                      //_displayNameController.text = value;
                                    },
                                    controller: _displayNameController,
                                    //autofocus: true,
                                    decoration:
                                        InputDecoration(hintText: "Name"),
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          value == "") {
                                        return 'Invalid name.';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
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
                                    Navigator.pop(context);
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Name required.");
                                  }
                                },
                                child: Text("OK")),
                          ],
                        ),
                      )
                    : showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text('Name'),
                          content: Text(
                              "How your name will appear on your bills.",
                              style: _hint),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("OK")),
                          ],
                        ),
                      ),
              ),
              Divider(indent: 15, endIndent: 15),
              ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [Icon(Icons.qr_code)],
                ),
                minLeadingWidth: 0,
                title: Text(_userCodeController.text),
                subtitle: Text("User Code"),
                trailing: Icon(Icons.chevron_right),
                onTap: () => showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text("User Code"),
                    content: SafeArea(
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            Text(
                                "Hint: Let your Collector/Payee scan this QR Code or share your code through the following features:",
                                style: _hint),
                            SizedBox(height: 10),
                            TextButton(
                                onPressed: () {
                                  Clipboard.setData(new ClipboardData(
                                          text: _userCodeController.text))
                                      .then((_) {
                                    Fluttertoast.showToast(
                                        msg:
                                            "${_userCodeController.text} Code copied to clipboard");
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _userCodeController.text,
                                      style: TextStyle(
                                          fontSize: 25, color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(width: 5),
                                    Icon(Icons.copy, color: Colors.white)
                                  ],
                                )),
                            SizedBox(height: 15),
                            Container(
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                //border: Border.all(color: Colors.white, width: 1.5),
                                shape: BoxShape.rectangle,
                                image: DecorationImage(
                                  fit: BoxFit.fill,
                                  image: AssetImage('assets/icons/qr.png'),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          Fluttertoast.showToast(msg: "Feature not available.");
                        },
                        icon: Icon(Icons.share),
                      ),
                      IconButton(
                        onPressed: () {
                          Fluttertoast.showToast(msg: "Feature not available.");
                        },
                        icon: Icon(Icons.download),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.done),
                      ),
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
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _userProfile.userType?.isEmpty ?? true
                        ? Badge(
                            badgeContent: Text(''),
                            child: Icon(Icons.person),
                          )
                        : Icon(Icons.person),
                  ],
                ),
                minLeadingWidth: 0,
                title: Text(_userTypeController.text),
                subtitle: Text("User Type"),
                trailing: _hasRequiredFields &&
                        _isUpdate &&
                        (_userProfile.userType?.isEmpty ?? true)
                    ? Icon(Icons.edit)
                    : Icon(Icons.info_outline),
                onTap: () => _hasRequiredFields &&
                        _isUpdate &&
                        (_userProfile.userType?.isEmpty ?? true)
                    ? showDialog(
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
                          //       child: Text("OK")),
                          // ],
                        ),
                      )
                    : showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text('User Type'),
                          content:
                              Text("Hint: How you use this app.", style: _hint),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("OK")),
                          ],
                        ),
                      ),
              ),
              Divider(indent: 15, endIndent: 15),
              ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _userProfile.members == 0
                        ? Badge(
                            badgeContent: Text(''),
                            animationType: BadgeAnimationType.scale,
                            child: Icon(Icons.people_alt_outlined),
                          )
                        : Icon(Icons.people_alt_outlined),
                  ],
                ),
                minLeadingWidth: 0,
                title: Text(_membersController.text),
                subtitle: Text("Members"),
                trailing:
                    _hasRequiredFields && _isUpdate && _userProfile.members == 0
                        ? Icon(Icons.edit)
                        : Icon(Icons.info_outline),
                onTap: () => _hasRequiredFields &&
                        _isUpdate &&
                        _userProfile.members == 0
                    ? showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text('Enter Member(s)'),
                          content: SafeArea(
                            child: SingleChildScrollView(
                              physics: BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  Text(
                                      "Hint: 1 if you're solo or number of family members if you're in a household. (To be used for 'per head' computations).",
                                      style: _hint),
                                  SizedBox(height: 10),
                                  TextFormField(
                                    keyboardType: TextInputType.number,
                                    onChanged: (value) {
                                      setState(() {
                                        //_userProfile.members = int.parse(value);
                                        //_membersController.text = value;
                                      });
                                    },
                                    controller: _membersController,
                                    autofocus: true,
                                    decoration:
                                        InputDecoration(hintText: "Member(s)"),
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty ||
                                          value == "0") {
                                        return 'Must be geater than 0.';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancel')),
                            TextButton(
                                onPressed: () {
                                  if (_membersController.text
                                          .trim()
                                          .isNotEmpty &&
                                      _membersController.text.trim() != "0") {
                                    Navigator.pop(context);
                                    setState(() {
                                      _isUpdate = true;
                                      _userProfile.members =
                                          int.parse(_membersController.text);
                                    });
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            "Member(s) must be greater than 0.");
                                  }
                                },
                                child: Text("OK")),
                          ],
                        ),
                      )
                    : showDialog(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Text('Members'),
                          content: Text(
                              "You or your number of family members if you're in a household. (To be used for 'per head' computations).",
                              style: _hint),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text("OK")),
                          ],
                        ),
                      ),
              ),
              Divider(indent: 15, endIndent: 15),
              ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(Icons.calendar_today),
                  ],
                ),
                minLeadingWidth: 0,
                title: Text(_billGenDateController.text),
                subtitle: Text("Billing Date"),
                trailing: Icon(Icons.info_outline),
                onTap: () => showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: Text('Billing Date'),
                    content: Text(
                        "Your very first recorded bill's billing date.",
                        style: _hint),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("OK")),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        _hasRequiredFields
            ? ElevatedButton(
                onPressed: _confirmSubmit,
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Text('Submit Changes'),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  primary: _isUpdate ? Colors.white38 : Colors.grey.shade800,
                ),
              )
            : SizedBox(),
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

  _getPayer() {
    _showProgressUi(true, "");

    try {
      DocumentReference _document =
          FirebaseFirestore.instance.collection("users").doc(_id);
      UserProfile userProfile = UserProfile();

      _document.get().then((snapshot) {
        if (snapshot.exists) {
          userProfile =
              UserProfile.fromJson(snapshot.data() as Map<String, dynamic>);
          //userProfile.id = snapshot.id;
          _id = snapshot.id;

          // userProfile.displayName = snapshot.get('display_name') as String?;
          // userProfile.userType = snapshot.get('user_type') as String?;
          // userProfile.members = snapshot.get('members') as int?;
          // userProfile.billingDate =
          //     DateTime.parse(snapshot.get('billing_date') as String);
          //userProfile.userCode = snapshot.get('user_code') as String?;
          if (userProfile.userCode?.isEmpty ?? true) {
            String usercode = _generateUserCode();
            _document.update({"user_code": usercode}).whenComplete(() {
              userProfile.userCode = usercode;
            });
          }
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
          _billGenDateController.text = _userProfile.billingDate != null
              ? DateFormat('MMM dd, yyyy')
                  .format(_userProfile.billingDate!)
                  .toString()
              : "No Billing Generation Date";
          // _mobileUser =
          //     _userProfile.registeredUsing?.contains("mobile") == true &&
          //         _userProfile.phoneNumber?.trim() ==
          //             _userProfile.displayName?.trim();
          _hasRequiredFields = //_mobileUser ||
              (_userProfile.displayName?.isEmpty ?? true) ||
                  (_userProfile.userType?.isEmpty ?? true) ||
                  _userProfile.members == 0;

          _isUpdate = _hasRequiredFields;
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
            FirebaseFirestore.instance.collection("users").doc(_id);
        _userProfile.modifiedOn = DateTime.now();
        _userProfile.billingDate = _userProfile.billingDate ?? null;

        _document.set(_userProfile.toJson()).then((value) {
          setState(() {
            _isUpdate = false;
          });
          _showProgressUi(false, "Update success.");
          _getPayer();
        }).catchError((error) {
          _showProgressUi(false, error);
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
      initialDate: _userProfile.billingDate ?? _lastdate,
      firstDate: _firstdate,
      lastDate: _lastdate,
    );
    if (date != null) {
      setState(() {
        _billGenDateController.text = DateFormat('MMM dd, yyyy')
            .format(DateTime(date.year, date.month, date.day));
        _userProfile.billingDate = DateTime(date.year, date.month, date.day);
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

        _getPayer();
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

  String _getUserTypeDescription(String id) {
    for (var p in _selectList) {
      if (p[0] == id) {
        return p[1] ?? id;
      }
    }
    return id;
  }

  _showProgressUi(bool isLoading, String msg) {
    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
    setState(() => _isLoading = isLoading);
  }

  void _confirmSubmit() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Are you sure you want to save now?'),
        content: const Text(
            'Please check if all data are correct. This is a one time update only. All future updates will need to be requested.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              _updatePayer();
              Navigator.pop(context);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
