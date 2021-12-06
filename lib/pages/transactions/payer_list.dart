import 'package:bills/models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PayerList extends StatefulWidget {
  const PayerList({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _PayerListState createState() => _PayerListState();
}

class _PayerListState extends State<PayerList> {
  late FirebaseAuth _auth;
  String? _id;
  List<dynamic> _userIds = [];
  List<dynamic> _payers = [];

  String _title = "Monthly Bills";

  bool _isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    setState(() {
      _auth = widget.auth;
      _id = _auth.currentUser!.uid;
    });
    _getUserIds();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.grey.shade300),
          //titleTextStyle: TextTheme(headline6: TextStyle(color: Colors.white, fontSize: 25)),
          title: Text(_title),
          titleSpacing: 0,
          centerTitle: false,
          backgroundColor: Colors.grey.shade800,
          elevation: 0,
          bottom: TabBar(
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
            Icon(Icons.directions_bike),
          ],
        ),
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
  //               return Center(child: Text('No $_title Yet.'));
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildPayerList() {
    List<Widget> mList = <Widget>[];
    for (int b = 0; b < _payers.length; b++) {
      mList.add(ListTile(
        title: Text(_payers[b][1]),
        subtitle: Text(
            "${int.parse(_payers[b][2].toString()) > 1 ? "${_payers[b][2]} members" : "Solo"}"),
        trailing: Icon(Icons.chevron_right),
      ));
    }
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        physics: BouncingScrollPhysics(),
        child: Card(
          child: ListView(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              children: mList),
        ),
      ),
    );
  }

  Future<void> _getlist() async {
    _showProgressUi(true, "");

    try {
      List<dynamic> payers = [];
      CollectionReference collection =
          FirebaseFirestore.instance.collection("users");
      List<UserProfile>? userProfile;
      collection.get().then((snapshots) {
        snapshots.docs.forEach((document) {
          if (_userIds.contains(document.id)) {
            UserProfile userProfile =
                UserProfile.fromJson(document.data() as Map<String, dynamic>);
            userProfile.id = document.id;
          }
        });
      }).whenComplete(() {
        setState(() {
          _payers.addAll(payers);
          //_listStream = stream;
        });
        _showProgressUi(false, userProfile.toString());
      });

      // collection.get().then((querySnapshot) {
      //   querySnapshot.docs.forEach((document) {
      //     stream
      //     users.add([document.id, document.get('name')]);
      //   });
      // }).whenComplete(() {
      //   setState(() {
      //     _listStream = stream;
      //   });
      //   _showProgressUi(false, "");
      // });
      // dynamic userIds = [];
      // Stream<QuerySnapshot<Object?>>? stream;

      // document.get().then((snapshot) {
      //   if (snapshot.exists) {
      //     userIds = snapshot.get('user_ids');
      //     //stream = document.snapshots();
      //   }
      // }).whenComplete(() {l
      // });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  Future<void> _getUserIds() async {
    _showProgressUi(true, "");

    try {
      var collection = FirebaseFirestore.instance.collection("users");
      var document = collection.doc(_id);
      List<dynamic> userids = [];
      // Fluttertoast.showToast(
      //     msg: FirebaseFirestore.instance.collection("users").path);
      // FirebaseFirestore.instance
      //     .collection("users").doc()
      //     .where("user_type", isNotEqualTo: _collectorId)
      //     .snapshots()
      //     .forEach((element) {
      //   element.docs.forEach((document) {
      //     users.add([document.id, document.get('name')]);
      //   });
      // }).whenComplete(() {
      //   setState(() {
      //     _selectList.addAll(users);
      //   });
      //   _showProgressUi(false, "");
      //   _getlist();
      // });

      document.get().then((snapshot) {
        if (snapshot.exists) {
          userids = snapshot.get('user_ids');
        }
      }).whenComplete(() {
        setState(() {
          _userIds = userids;
        });
        _showProgressUi(false, "");
        _getlist();
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
    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
    setState(() => _isLoading = isLoading);
    print(_isLoading);
  }
}
