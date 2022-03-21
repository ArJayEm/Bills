import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:bills/helpers/functions/functions_global.dart';
import 'package:bills/models/members.dart';
//import 'package:bills/models/members.dart';
//import 'package:bills/models/members.dart';
import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/components/custom_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PayerList extends StatefulWidget {
  const PayerList({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _PayerListState createState() => _PayerListState();
}

class _PayerListState extends State<PayerList> {
  //late final FirebaseAuth _auth;
  final FirebaseFirestore _ffInstance = FirebaseFirestore.instance;
  //late final String? _id;
  final List<UserProfile?> _userProfiles = [];

  bool _isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadForm();
  }

  Future<void> _loadForm() async {
    setState(() {
      //_auth = widget.auth;
      //_id = _auth.currentUser!.uid;
    });
    _getUserIds();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      //initialIndex: 1,
      child: Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.grey.shade300),
          //titleTextStyle: TextTheme(headline6: TextStyle(color: Colors.white, fontSize: 25)),
          title: const Text("Payers"),
          titleSpacing: 0,
          centerTitle: true,
          backgroundColor: Colors.grey.shade800,
          elevation: 1,
        ),
        body: RefreshIndicator(
          onRefresh: _loadForm,
          child: _buildPayerList(),
        ),
        bottomNavigationBar: const CustomBottomNavigationBar(),
      ),
    );
  }

  // Widget _buildPayers() {
  //   return SafeArea(
  //     child: SingleChildScrollView(
  //       padding: EdgeInsets.all(10),
  //       physics: BouncingScrollPhysics(),
  //       child: Column(
  //         children: [
  //           ElevatedButton(
  //             onPressed: () => null,
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.center,
  //               children: [
  //                 Icon(Icons.person_add),
  //                 Text('  Add Payer', style: TextStyle(fontSize: 20))
  //               ],
  //             ),
  //             style: ElevatedButton.styleFrom(
  //               minimumSize: Size(double.infinity, 50),
  //               primary: Colors.grey.shade800,
  //             ),
  //           ),
  //           SizedBox(height: 10),
  //           StreamBuilder<QuerySnapshot>(
  //             stream: _listStream,
  //             builder: (BuildContext context,
  //                 AsyncSnapshot<QuerySnapshot> snapshot) {
  //               if (snapshot.hasError) {
  //                 return Center(child: Text('Something went wrong'));
  //               }
  //               // if (snapshot.connectionState == ConnectionState.waiting) {
  //               //   return Center(child: CircularProgressIndicator());
  //               // }
  //               if (snapshot.connectionState == ConnectionState.done &&
  //                   snapshot.hasData &&
  //                   snapshot.data != null) {
  //                 return Card(
  //                   child: ListView(
  //                     physics: const BouncingScrollPhysics(),
  //                     shrinkWrap: true,
  //                     children: snapshot.data!.docs.map(
  //                       (DocumentSnapshot document) {
  //                         return Column(
  //                           crossAxisAlignment: CrossAxisAlignment.stretch,
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           mainAxisSize: MainAxisSize.min,
  //                           children: [
  //                             ListTile(
  //                               title: Text(_getPayerName(document.id)),
  //                             ),
  //                           ],
  //                         );
  //                       },
  //                     ).toList(),
  //                   ),
  //                 );
  //               }
  //               return Center(child: Text('No $_titlefound.'));
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPayerList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _ffInstance
          .collection("users")
          .where("deleted", isEqualTo: false)
          .orderBy("name")
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
            ? const Center(child: Text('No users found.'))
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
                                UserProfile userProfile = UserProfile.fromJson(
                                    document.data() as Map<String, dynamic>);
                                userProfile.id = document.id;
                                userProfile.membersArr =
                                    userProfile.members.mapMembers();
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      //isThreeLine: true,
                                      //title: Text("${_setSelectedPayersDisplay(reading.payerIds)}${!(reading.description?.isEmpty ?? true) ? " | ${reading.description}" : ""}"),
                                      title: Text("${userProfile.name}"),
                                      subtitle: Text(userProfile.createdOn
                                          .lastModified(
                                              userProfile.modifiedOn)),
                                      // trailing: Text(
                                      //     "${(userProfile.membersArr.last.count)} members"),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                              "${(userProfile.membersArr.last.count)} member(s)",
                                              textAlign: TextAlign.right),
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

  Future<void> _getUserIds() async {
    _showProgressUi(true, "");
    String id = "";

    try {
      var collection = _ffInstance
          .collection("users")
          .where("deleted", isEqualTo: false)
          .orderBy("name");
      List<UserProfile?> userProfiles = [];
      UserProfile up = UserProfile();

      collection.get().then((snapshot) {
        for (var document in snapshot.docs) {
          up = UserProfile.fromJson(document.data());
          up.membersArr = List<Members>.from(up.members.map((e) {
            return Members.fromJson(e);
          }));
          up.id = document.id;
          userProfiles.add(up);
        }
      }).catchError((onError) {
        _isLoading.updateProgressStatus(errMsg: "${onError.toString()}: $id.");
      }).whenComplete(() {
        setState(() {
          _userProfiles.clear();
          _userProfiles.addAll(userProfiles);
        });
        _showProgressUi(false, "");
      });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  // String _getPayerName(String? id) {
  //   String payer = '';
  //   for (var p in _userIds) {
  //     if (p[0] == id) {
  //       payer = p[1] ?? '';
  //       break;
  //     }
  //   }
  //   return payer;
  // }

  _showProgressUi(bool isLoading, String msg) {
    if (msg.isNotEmpty) {
      Fluttertoast.showToast(msg: msg);
    }
    setState(() => _isLoading = isLoading);
    if (kDebugMode) {
      print(_isLoading);
    }
  }
}
