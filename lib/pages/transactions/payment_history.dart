import 'package:bills/models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _PaymentHistoryState createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  late FirebaseAuth _auth;
  String? _id;
  //Stream<QuerySnapshot>? _listStream;
  List<dynamic> _userIds = [];
  List<dynamic> _payers = [];

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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey.shade300),
        textTheme:
            TextTheme(headline6: TextStyle(color: Colors.white, fontSize: 25)),
        title: Text('Payment History'),
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: Center(
          // child: DropdownSearch<UserProfile>(
          //   label: "Name",
          //   onFind: (String filter) async {
          //     var response = await Dio().get(
          //       "http://5d85ccfb1e61af001471bf60.mockapi.io/user",
          //       queryParameters: {"filter": filter},
          //     );
          //     var models = UserProfile.fromJson(response.data);
          //     return models;
          //   },
          //   onChanged: (UserProfile data) {
          //     print(data);
          //   },
          // ),
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
      //     users.add([document.id, document.get('display_name')]);
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

  String _getPayerName(String? id) {
    String payer = '';
    for (var p in _userIds) {
      if (p[0] == id) {
        payer = p[1] ?? '';
        break;
      }
    }
    return payer;
  }

  _showProgressUi(bool isLoading, String msg) {
    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
    setState(() => _isLoading = isLoading);
  }
}
