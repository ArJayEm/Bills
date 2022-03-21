//import 'dart:math';

import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:badges/badges.dart';
import 'package:bills/helpers/functions/functions_global.dart';
import 'package:bills/models/members.dart';
import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/components/custom_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
  final FirebaseFirestore _ffInstance = FirebaseFirestore.instance;

  UserProfile _userProfile = UserProfile();
  String? _loggedInId;
  final List<dynamic> _selectedList = [];
  final List<Map<String, dynamic>> _selectList = [];

  final _displayNameController = TextEditingController();
  final _userCodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _membersController = TextEditingController();
  final _billGenDateController = TextEditingController();
  final _userTypeController = TextEditingController();

  int _members = 0;
  final bool _isLoading = false;
  bool _isUpdate = false;

  final TextStyle _hint = const TextStyle(fontSize: 15, color: Colors.white30);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    setState(() {
      _auth = widget.auth;
      _loggedInId = _auth.currentUser!.uid;
    });
    _onLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
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
          icon: const Icon(Icons.arrow_back),
        ),
        iconTheme: IconThemeData(color: Colors.grey.shade300),
        //titleTextStyle: TextTheme(headline6: TextStyle(color: Colors.white, fontSize: 25)),
        title: const Text('Profile'),
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _getCurrentUser,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            physics: const BouncingScrollPhysics(),
            child: _getCurrentUserDisplay(),
          ),
        ),
      ),
    );
  }

  Widget _getCurrentUserDisplay() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      children: [
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // const ListTile(
              //   title: Text("Payer Info"),
              // ),
              // const CustomDivider(),
              CustomCenterExpanded(children: [_getUserImage(100)]),
              TextButton.icon(
                icon: const Icon(Icons.edit),
                label: Text("${_userProfile.name}",
                    style: const TextStyle(fontSize: 20, color: Colors.white)),
                onPressed: () {},
              ),
              ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [_getUserImage(40)],
                ),
                minLeadingWidth: 0,
                title: Text("${_userProfile.name}"),
                subtitle: const Text("Name"),
                trailing: const Icon(Icons.edit),
                onTap: () => _isUpdate && (_userProfile.name.isNullOrEmpty())
                    ? showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Enter Name'),
                          content: SafeArea(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  Text(
                                      "Hint: This means you registered by mobile number, and that you must update this to you name for easier reference.",
                                      style: _hint),
                                  const SizedBox(height: 10),
                                  TextFormField(
                                    keyboardType: TextInputType.name,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    onChanged: (value) {
                                      //_displayNameController.text = value;
                                    },
                                    controller: _displayNameController,
                                    //autofocus: true,
                                    decoration: const InputDecoration(
                                        hintText: "Name", labelText: "Name"),
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
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () {
                                  if (_displayNameController.text.isNotEmpty) {
                                    setState(() {
                                      _userProfile.name =
                                          _displayNameController.text;
                                    });
                                    Navigator.pop(context);
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: "Name required.");
                                  }
                                },
                                child: const Text("OK")),
                          ],
                        ),
                      )
                    : infoDialog(
                        'Name', "How your name will appear on your bills."),
              ),
              const Divider(indent: 15, endIndent: 15),
              ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [Icon(Icons.qr_code)],
                ),
                minLeadingWidth: 0,
                title: Text(_userCodeController.text),
                subtitle: const Text("User Code"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text("User Code"),
                    content: SafeArea(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            Text(
                                "Hint: Let your Collector/Payee scan this QR Code or share your code through the following features:",
                                style: _hint),
                            const SizedBox(height: 10),
                            Text(
                              _userCodeController.text,
                              style: const TextStyle(
                                  fontSize: 25, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            // TextButton(
                            //     onPressed: () {
                            //       Clipboard.setData(new ClipboardData(
                            //               text: _userCodeController.text))
                            //           .then((_) {
                            //         Fluttertoast.showToast(
                            //             msg:
                            //                 "${_userCodeController.text} Code copied to clipboard");
                            //       });
                            //     },
                            //     child: Row(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       crossAxisAlignment: CrossAxisAlignment.center,
                            //       children: [
                            //         Text(
                            //           _userCodeController.text,
                            //           style: TextStyle(
                            //               fontSize: 25, color: Colors.white),
                            //           textAlign: TextAlign.center,
                            //         ),
                            //         SizedBox(width: 5),
                            //         Icon(Icons.copy, color: Colors.white)
                            //       ],
                            //     )),
                            const SizedBox(height: 15),
                            Container(
                              height: 200,
                              width: 200,
                              decoration: const BoxDecoration(
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
                          Clipboard.setData(
                                  ClipboardData(text: _userCodeController.text))
                              .then((_) {
                            Fluttertoast.showToast(
                                msg:
                                    "${_userCodeController.text} Code copied to clipboard");
                          });
                        },
                        icon: const Icon(Icons.copy),
                      ),
                      IconButton(
                        onPressed: () {
                          Fluttertoast.showToast(msg: "Feature not available.");
                        },
                        icon: const Icon(Icons.share),
                      ),
                      IconButton(
                        onPressed: () {
                          Fluttertoast.showToast(msg: "Feature not available.");
                        },
                        icon: const Icon(Icons.download),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.done),
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
              const ListTile(
                title: Text("Members History"),
              ),
              const CustomDivider(),
              ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _members < 1
                        ? Badge(
                            badgeContent: const Text(''),
                            animationType: BadgeAnimationType.scale,
                            child: const Icon(Icons.people_alt_outlined),
                          )
                        : const Icon(Icons.people_alt_outlined),
                  ],
                ),
                minLeadingWidth: 0,
                title: Text(_membersController.text),
                subtitle: const Text("Members"),
                trailing: _isUpdate
                    ? const Icon(Icons.edit)
                    : const Icon(Icons.info_outline),
                onTap: () => _isUpdate
                    ? showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text('Enter Member(s)'),
                          content: SafeArea(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  Text(
                                      "Hint: 1 if you're solo or number of family members if you're in a household. (To be used for 'per head' computations).",
                                      style: _hint),
                                  const SizedBox(height: 10),
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
                                    decoration: const InputDecoration(
                                        hintText: "Member(s)"),
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
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () {
                                  if (_membersController.text
                                          .trim()
                                          .isNotEmpty &&
                                      _membersController.text.trim() != "0") {
                                    Navigator.pop(context);
                                    setState(() {
                                      _isUpdate = true;
                                      _members = int.tryParse(
                                          _membersController.text)!;

                                      for (var m in _userProfile.membersArr) {
                                        if (m.modifiedBy?.isEmpty ?? false) {
                                          m.modifiedBy = _userProfile.id;
                                          m.effectivityEnd = DateTime.now();
                                        }
                                      }

                                      if (_members !=
                                          _userProfile.membersArr.last.count) {
                                        Members m = Members();
                                        m.count = _members;
                                        m.createdBy = _userProfile.id;
                                        m.createdBy = _userProfile.id;
                                        _userProfile.membersArr.add(m);
                                      }
                                    });
                                  } else {
                                    Fluttertoast.showToast(
                                        msg:
                                            "Member(s) must be greater than 0.");
                                  }
                                },
                                child: const Text("OK")),
                          ],
                        ),
                      )
                    : infoDialog('Members',
                        "You or your number of family members if you're in a household. (To be used for 'per head' computations)."),
              ),
              const Divider(indent: 15, endIndent: 15),
              ListView(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                children: <Widget>[
                  ..._userProfile.membersArr.map((member) {
                    return ListTile(
                      minLeadingWidth: 0,
                      title: Text(
                          "From ${member.effectivityStart.formatDate(dateOnly: true)} ${member.modifiedOn == null ? "up to present" : "to ${member.effectivityEnd?.formatDate(dateOnly: true)}"}"),
                      subtitle: Text(
                          member.createdOn.lastModified(member.modifiedOn)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("${member.count} member(s)"),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.redAccent),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      onTap: () {},
                    );
                  }).toList(),
                ],
              ),
            ],
          ),
        ),
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ListTile(
                title: Text("Payer Details"),
              ),
              const CustomDivider(),
              ListTile(
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _userProfile.userType.isNullOrEmpty()
                        ? Badge(
                            badgeContent: const Text(''),
                            child: const Icon(Icons.person),
                          )
                        : const Icon(Icons.person),
                  ],
                ),
                minLeadingWidth: 0,
                title: Text(_userTypeController.text),
                subtitle: const Text("User Type"),
                trailing: _isUpdate && (_userProfile.userType.isNullOrEmpty())
                    ? const Icon(Icons.edit)
                    : const Icon(Icons.info_outline),
                onTap: () => _isUpdate &&
                        (_userProfile.userType.isNullOrEmpty())
                    ? showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) => AlertDialog(
                          title: const Text("Select User Type"),
                          content: SafeArea(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: _userTypesSelectionWidget(),
                            ),
                          ),
                        ),
                      )
                    : infoDialog('User Type', "Hint: How you use this app."),
              ),
              // const Divider(indent: 15, endIndent: 15),
              // ListTile(
              //   leading: Column(
              //     mainAxisAlignment: MainAxisAlignment.spaceAround,
              //     children: const [
              //       Icon(Icons.calendar_today),
              //     ],
              //   ),
              //   minLeadingWidth: 0,
              //   title: Text(_billGenDateController.text),
              //   subtitle: const Text("Billing Date"),
              //   trailing: const Icon(Icons.info_outline),
              //   onTap: () => showDialog(
              //     context: context,
              //     builder: (BuildContext context) => AlertDialog(
              //       title: const Text('Billing Date'),
              //       content: Text(
              //           "Your very first recorded bill's billing date.",
              //           style: _hint),
              //       actions: [
              //         TextButton(
              //             onPressed: () => Navigator.pop(context),
              //             child: const Text("OK")),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (_isUpdate)
          ElevatedButton(
            onPressed: _confirmSubmit,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : const Text('Submit Changes'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              primary: _isUpdate ? Colors.white38 : Colors.grey.shade800,
            ),
          ),
      ],
    );
  }

  Widget _getUserImage(double dimensions) {
    return GetUserImage(
        height: dimensions,
        width: dimensions,
        borderColor: Colors.white,
        borderWidth: 1.5,
        //shape: BoxShape.circle,
        image: _userProfile.userImage);
  }

  Future<void> _onLoad() async {
    await _getUserTypes();
    await _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    _isLoading.updateProgressStatus(msg: "");

    try {
      DocumentReference document =
          _ffInstance.collection('users').doc(_loggedInId);
      UserProfile up = UserProfile();

      document.get().then((snapshot) {
        if (snapshot.exists) {
          up = UserProfile.fromJson(snapshot.data() as Map<String, dynamic>);
          up.id = snapshot.id;
          up.mapMembers();
        }
      }).whenComplete(() {
        setState(() {
          _userProfile = up;
          _displayNameController.text = "${_userProfile.name}";
          _userCodeController.text = "${_userProfile.userCode}";
          _userTypeController.text = _selectList
                  .firstWhere((element) =>
                      element.entries.first.key == "${_userProfile.userType}")
                  .entries
                  .first
                  .value ??
              "${_userProfile.userType}"; // _getUserTypeDescription();
          _emailController.text = "${_userProfile.email}";
          _phoneNumberController.text = "${_userProfile.phoneNumber}";
          _membersController.text =
              _userProfile.membersArr.last.count.toString();
          _billGenDateController.text = DateFormat('MMM dd, yyyy')
              .format(_userProfile.billingDate!)
              .toString();

          _isUpdate = true;
        });
        _isLoading.updateProgressStatus(msg: "");
      });
    } on FirebaseException catch (e) {
      _isLoading.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoading.updateProgressStatus(errMsg: "$e.");
    }
  }

  // String _generateUserCode() {
  //   var rng = Random();
  //   var code1 = rng.nextInt(9000) + 1000;
  //   var code2 = rng.nextInt(9000) + 1000;
  //   var code3 = rng.nextInt(9000) + 1000;
  //   return "$code1 $code2 $code3";
  // }

  _updatePayer() {
    _isLoading.updateProgressStatus(msg: "Saving...");

    try {
      if (_loggedInId != null) {
        DocumentReference _document =
            _ffInstance.collection("users").doc(_loggedInId);
        _userProfile.modifiedBy = _userProfile.id;
        _userProfile.modifiedOn = DateTime.now();
        _userProfile.billingDate = _userProfile.billingDate;
        _userProfile.members.clear();
        _userProfile.members =
            List<Map<String, dynamic>>.from(_userProfile.membersArr.map((e) {
          return e.toJson();
        }));

        _document.set(_userProfile.toJson()).then((value) {
          setState(() {
            _isUpdate = false;
          });
          _isLoading.updateProgressStatus(msg: "Update success.");
          _getCurrentUser();
        }).catchError((error) {
          _isLoading.updateProgressStatus(errMsg: error);
        });
      } else {
        _isLoading.updateProgressStatus(errMsg: "Invalid user.");
      }
    } on FirebaseException catch (e) {
      _isLoading.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoading.updateProgressStatus(errMsg: "$e.");
    }
  }

  

  Future<void> _getUserTypes() async {
    try {
      List<Map<String, dynamic>> users = [];
      CollectionReference _collection = _ffInstance.collection("user_types");
      _collection.get().then((snapshots) {
        for (var document in snapshots.docs) {
          users.add(
              {"id": document.id, "description": document.get('description')});
        }
      }).whenComplete(() {
        setState(() {
          _selectList.clear();
          _selectList.addAll(users);
        });
      });
    } on FirebaseException catch (e) {
      _isLoading.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoading.updateProgressStatus(errMsg: "$e.");
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
              _userTypeController.text = _selectList
                      .firstWhere((element) => element.entries.first.key == id)
                      .entries
                      .first
                      .value ??
                  id;
            } else {
              _selectedList.remove(id);
              _userProfile.userType = "";
              _userTypeController.text = "";
            }
          });
          if (kDebugMode) {
            print(_selectedList);
          }
          Navigator.pop(context);
        },
        value: _selectedList.contains(id),
        title: Text(description),
        subtitle: Text(id),
        controlAffinity: ListTileControlAffinity.leading,
      ));
      mList.add(const Divider());
    }
    return SizedBox(
        height: 150.0, // Change as per your requirement
        width: 300.0, // Change as per your requirement
        child: ListView(shrinkWrap: true, children: mList));
  }

  Future<void> infoDialog(String title, String msg) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(msg, style: _hint),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  // String _getUserTypeDescription() {
  //   String id = "${_userProfile.userType}";
  //   for (var p in _selectList) {
  //     if (p[0] == id) {
  //       return p[1] ?? id;
  //     }
  //   }
  //   return id;
  // }

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
