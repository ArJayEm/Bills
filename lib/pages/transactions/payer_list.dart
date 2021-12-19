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

  final String _title = "Monthly Bills";

  bool _isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
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
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.grey.shade300),
          //titleTextStyle: TextTheme(headline6: TextStyle(color: Colors.white, fontSize: 25)),
          title: Text(_title),
          titleSpacing: 0,
          centerTitle: true,
          backgroundColor: Colors.grey.shade800,
          elevation: 1,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Bills"),
              Tab(text: "Generate"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            //_buildPayers(),
            _buildPayerList(),
            const Icon(Icons.directions_bike),
          ],
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        physics: const BouncingScrollPhysics(),
        child: Card(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            children: _userProfiles
                .map(
                  (user) => ListTile(
                    //dense: true,
                    title: Text("${user?.name}"),
                    subtitle: Text("${user?.members} member(s)"),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _getUserIds() async {
    _showProgressUi(true, "");

    try {
      var collection =
          _ffInstance.collection("users").where("deleted", isEqualTo: false);
      List<UserProfile?> userids = [];
      UserProfile up = UserProfile();

      collection.get().then((snapshot) {
        for (var document in snapshot.docs) {
          up = UserProfile.fromJson(document.data());
          up.id = document.id;
          userids.add(up);
        }
      }).whenComplete(() {
        setState(() {
          _userProfiles.clear();
          _userProfiles.addAll(userids);
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
