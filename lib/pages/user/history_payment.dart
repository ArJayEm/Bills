import 'package:bills/helpers/functions/functions_global.dart';
import 'package:bills/models/bill.dart';
//import 'package:bills/models/members.dart';
import 'package:bills/models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
//import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
//import 'package:intl/intl.dart';
//import 'package:firebase_core/firebase_core.dart' as firebase_core;

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _PaymentHistoryState createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  //late FirebaseAuth _auth;
  late final String _loggedInId;
  late String _selectedUserId;

  UserProfile _loggedInUserprofile = UserProfile();
  //UserProfile _selectedUserProfile = UserProfile();
  final List<UserProfile?> _userProfiles = [];

  final bool _isLoading = false;
  bool _isAdmin = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final FirebaseFirestore _ffInstance = FirebaseFirestore.instance;
  //final firebase_storage.FirebaseStorage _fsInstance = firebase_storage.FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    setState(() {
      //_auth = widget.auth;
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
            const Text("Payment History"),
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
          // up.membersArr = List<Members>.from(up.members.map((e) {
          //   return Members.fromJson(e);
          // }));
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
          //if (_selectedUserId.isNullOrEmpty()) {
          //  _selectedUserId = _selectedUserId;
          //} else {
          _selectedUserId = (_isAdmin ? _userProfiles.first?.id : _loggedInId)!;
          //}
          // _selectedUserProfile = _userProfiles
          //         .firstWhere((element) => element?.id == _selectedUserId) ??
          //     UserProfile();
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
    setState(() {});
    return StreamBuilder<QuerySnapshot>(
      stream: _ffInstance
          .collection("bills")
          //.where('user_id', arrayContains: _selectedUserId)
          .where('payers_billtype', arrayContains: "${_selectedUserId}_1")
          .where("deleted", isEqualTo: false)
          .orderBy("bill_date", descending: true)
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
                                Bill bill = Bill.fromJson(
                                    document.data() as Map<String, dynamic>);
                                bill.id = document.id;
                                // bill.billType = _billTypes.firstWhere((bt) =>
                                //     bt?.id == bill.billTypeId.toString());
                                // bill.billTypeId = int.parse(
                                //     bill.billType?.id.toString() ?? "0");
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
                                        "${bill.billDate?.format(dateOnly: true)}",
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      subtitle: Text(bill.createdOn
                                          .lastModified(
                                              bill.modifiedOn)),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "${bill.description.isNullOrEmpty() ? "Payment" : bill.description}",
                                                textAlign: TextAlign.right,
                                              ),
                                              Text(
                                                  bill.amount
                                                      .formatForDisplay(),
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                      fontSize: 25,
                                                      color: Colors.green)),
                                            ],
                                          ),
                                          const Icon(Icons.chevron_right),
                                        ],
                                      ),
                                      onTap: () {
                                        // setState(() {
                                        //   _isExpanded = !_isExpanded;
                                        // });
                                        //_showDataManager(billing);
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
