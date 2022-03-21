//import 'dart:io';

import 'package:bills/helpers/functions/functions_global.dart';
import 'package:bills/models/billing.dart';
//import 'package:bills/models/members.dart';
import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/maintenance/view_billing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
//import 'package:intl/intl.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:intl/intl.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:printing/printing.dart';
//import 'package:firebase_core/firebase_core.dart' as firebase_core;
//import 'package:print_color/print_color.dart';
//import 'package:printing/printing.dart';
//import 'package:path/path.dart' as path;

class BillingHistory extends StatefulWidget {
  const BillingHistory({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _BillingHistoryState createState() => _BillingHistoryState();
}

class _BillingHistoryState extends State<BillingHistory> {
  late FirebaseAuth _auth;
  late final String _loggedInId;
  late String _selectedUserId;

  UserProfile _loggedInUserprofile = UserProfile();
  //UserProfile _selectedUserProfile = UserProfile();
  final List<UserProfile?> _userProfiles = [];

  final bool _isLoading = false;
  bool _isAdmin = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final FirebaseFirestore _ffInstance = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    setState(() {
      _auth = widget.auth;
      _loggedInId = widget.auth.currentUser!.uid;
      _selectedUserId = "";
    });
    _getUsers();
    if (kDebugMode) {
      print(_loggedInId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        //leadingWidth: 0,
        centerTitle: true,
        toolbarHeight: _isAdmin ? 100 : null,
        title: Column(
          children: [
            const Text("Billing History"),
            if (_isAdmin) const SizedBox(height: 10),
            if (_isAdmin) _buildUsersDropdown(),
          ],
        ),
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: _loadForm,
        child: _buildBillingsListView(),
      ),
    );
  }

  Future<void> _getUsers() async {
    List<UserProfile?> ups = [];
    try {
      _ffInstance
          .collection("users")
          .where("deleted", isEqualTo: false)
          .orderBy("name")
          .get()
          .then((snapshots) {
        for (var document in snapshots.docs) {
          UserProfile up = UserProfile.fromJson(document.data());
          // up.membersArr =
          //     List<Members>.from(up.members.map((e) => Members.fromJson(e)));
          up.id = document.id;
          ups.add(up);
        }
      }).whenComplete(() {
        setState(() {
          _userProfiles.clear();
          _userProfiles.addAll(ups);

          _loggedInUserprofile = _userProfiles
                  .firstWhere((element) => element?.id == _loggedInId) ??
              UserProfile();
          _isAdmin = _loggedInUserprofile.isAdmin ?? false;
          _selectedUserId = (_isAdmin ? _userProfiles.first?.id : _loggedInId)!;
        });
        if (kDebugMode) {
          print("_userProfiles: ${_userProfiles.toList()}");
        }
      });
    } on FirebaseAuthException catch (e) {
      _isLoading.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoading.updateProgressStatus(errMsg: "$e.");
    }
  }

  Widget _buildUsersDropdown() {
    return FormField<String>(builder: (FormFieldState<String> state) {
      return InputDecorator(
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person, color: Colors.white),
            contentPadding: const EdgeInsets.all(5),
            errorStyle:
                const TextStyle(color: Colors.redAccent, fontSize: 16.0),
            hintText: 'User',
            labelText: 'User',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
        isEmpty: false, //_selectedUserId == '',
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedUserId.isNotEmpty
                ? _selectedUserId
                : _userProfiles.first?.id,
            isDense: true,
            hint: const Text("Choose user..."),
            onChanged: (String? newValue) async {
              setState(() {
                _selectedUserId = newValue!;
                // _selectedUserProfile = _userProfiles.firstWhere(
                //         (element) => element?.id == _selectedUserId) ??
                //     UserProfile();
                state.didChange(newValue);
              });
              //await getBills();
              if (kDebugMode) {
                print("_selectedUser: $_selectedUserId");
              }
            },
            items: _userProfiles
                .map(
                  (up) => DropdownMenuItem<String>(
                    value: up?.id,
                    child: Text("${up?.name!}"),
                  ),
                )
                .toList(),
          ),
        ),
      );
    });
  }

  Widget _buildBillingsListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _ffInstance
          .collection("billings")
          .where('user_id', arrayContains: _selectedUserId)
          .where("deleted", isEqualTo: false)
          .orderBy("billing_date", descending: true)
          //.limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          String msg = snapshot.error.toString();
          if (kDebugMode) {
            print("list error: $msg");
          }
          Fluttertoast.showToast(msg: msg);
          return const Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return snapshot.data!.docs.isEmpty
            ? const Center(child: Text('No billings found.'))
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                  physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Card(
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            children: snapshot.data!.docs.map(
                              (DocumentSnapshot document) {
                                Billing billing = Billing.fromJson(
                                    document.data() as Map<String, dynamic>);
                                billing.id = document.id;
                                //bool pdfExists = true;
                                // final String title =
                                //     "Bills-${DateFormat("MMMM-yyyy").format(billing.date!)}";
                                // String path = "";
                                // getApplicationDocumentsDirectory()
                                //     .then((value) => path = value.path);
                                // final file = File('$path/$title');
                                // try {
                                //   _fsInstance
                                //       .ref()
                                //       .child("billing history")
                                //       .child(_selectedUserId)
                                //       .child(title)
                                //       .putFile(file);
                                // } catch (error) {
                                //   pdfExists = false;
                                // }
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      //isThreeLine: true,
                                      //title: Text("${_setSelectedPayersDisplay(reading.payerIds)}${!(reading.description?.isEmpty ?? true) ? " | ${reading.description}" : ""}"),
                                      title: Text(
                                        '${billing.billingFrom?.formatToMonthDay()} - ${billing.billingTo?.formatToMonthDay()}',
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      subtitle: Text(
                                          "Due on: ${billing.dueDate?.formatDate(dateOnly: true)}"),
                                      // trailing: Row(
                                      //   mainAxisSize: MainAxisSize.min,
                                      //   children: [
                                      //     Text(
                                      //         billing.totalPayment.formatForDisplay(),
                                      //         textAlign: TextAlign.right,
                                      //         style: const TextStyle(
                                      //             fontSize: 25)),
                                      //     const Icon(Icons.chevron_right),
                                      //   ],
                                      // ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              const Spacer(),
                                              Text(
                                                billing.totalPayment
                                                    .formatForDisplay(),
                                                style: const TextStyle(
                                                    fontSize: 20),
                                              ),
                                              const Spacer(),
                                            ],
                                          ),
                                          const Icon(Icons.chevron_right)
                                          // IconButton(
                                          //     tooltip: "View Billing",
                                          //     icon: const Icon(
                                          //         Icons.chevron_right),
                                          //     onPressed: () async {
                                          //       Navigator.push(
                                          //         context,
                                          //         MaterialPageRoute(
                                          //           builder: (context) =>
                                          //               ViewBilling(auth: _auth, billing: billing),
                                          //         ),
                                          //       );
                                          //     }),
                                        ],
                                      ),
                                      // trailing: Row(
                                      //   mainAxisSize: MainAxisSize.min,
                                      //   children: [
                                      //     IconButton(
                                      //         tooltip: "View Billing",
                                      //         onPressed: () async {
                                      //           //if (pdfExists) {
                                      //           Directory appDocDir =
                                      //               await getApplicationDocumentsDirectory();
                                      //           final String title =
                                      //               "Bills-${DateFormat("MMMM-yyyy").format(billing.date!)}";
                                      //           File downloadFromCloud = File(
                                      //               '${appDocDir.path}/$title');

                                      //           try {
                                      //             await _fsInstance
                                      //                 .ref()
                                      //                 .child("billing history")
                                      //                 .child(_selectedUserId)
                                      //                 .child(title)
                                      //                 .writeToFile(
                                      //                     downloadFromCloud);

                                      //             String newFileName =
                                      //                 '$title-${DateTime.now().formatNoSpace()}';

                                      //             await Printing.layoutPdf(
                                      //                 name: newFileName,
                                      //                 onLayout: (format) =>
                                      //                     downloadFromCloud
                                      //                         .readAsBytesSync());
                                      //           } on firebase_storage
                                      //               .FirebaseException catch (e) {
                                      //             String msg =
                                      //                 getFirebaseStorageErrorMessage(
                                      //                     e);
                                      //             Fluttertoast.showToast(
                                      //                 msg: msg);

                                      //             if (e.code ==
                                      //                 "object-not-found") {}
                                      //           }
                                      //           //}
                                      //         },
                                      //         icon: const Icon(
                                      //             //pdfExists ?
                                      //             Icons.visibility
                                      //             //: Icons.visibility_off
                                      //             )),
                                      //     // IconButton(
                                      //     //   tooltip: "Donwload Billing",
                                      //     //   onPressed: () async {
                                      //     //     final String url =
                                      //     //         await _fsInstance.ref().getDownloadURL();
                                      //     //     final http.Response downloadData =
                                      //     //         await http.get(url);
                                      //     //   },
                                      //     //   icon: const Icon(Icons.download),
                                      //     // ),
                                      //   ],
                                      // ),
                                      onTap: () {
                                        // setState(() {
                                        //   _isExpanded = !_isExpanded;
                                        // });
                                        //_showDataManager(billing);
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ViewBilling(
                                                auth: _auth,
                                                billing: billing,
                                                selectedUserId:
                                                    _selectedUserId),
                                          ),
                                        );
                                      },
                                    ),
                                    //const Divider()
                                  ],
                                );
                              },
                            ).toList(),
                          ),
                        ),
                ),
              );
      },
    );
  }
}
