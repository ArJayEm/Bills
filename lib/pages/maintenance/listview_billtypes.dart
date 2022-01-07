import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:bills/helpers/functions/functions_global.dart';
import 'package:bills/models/bill_type.dart';
import 'package:bills/models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ListViewBillTypes extends StatefulWidget {
  const ListViewBillTypes(
      {Key? key, required this.auth, required this.billType})
      : super(key: key);

  final FirebaseAuth auth;
  final BillType billType;

  @override
  _ListViewBillTypesState createState() => _ListViewBillTypesState();
}

class _ListViewBillTypesState extends State<ListViewBillTypes> {
  late FirebaseAuth _auth;
  late FToast fToast = FToast();
  final FirebaseFirestore _ffInstance = FirebaseFirestore.instance;
  late CollectionReference _collection;
  late final String _loggedInId;
  late String _selectedUserId;

  final bool _isLoading = false;
  UserProfile _userProfile = UserProfile();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    //_getSdkVersion();
    setState(() {
      _auth = widget.auth;
      _collection = _ffInstance.collection('bill_types');
    });
    _onLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      body: RefreshIndicator(onRefresh: _refresh, child: _buildBillTypes()),
    );
  }

  Future<void> _onLoad() async {
    await _getCurrentUser();
  }

  Future<void> _refresh() async {}

  Widget _buildBillTypes() {
    return StreamBuilder<QuerySnapshot>(
      stream: _ffInstance
          .collection("bill_types")
          .orderBy('description')
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
            ? const Center(child: Text('No bill types found.'))
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
                                BillType billType = BillType.fromJson(
                                    document.data() as Map<String, dynamic>);
                                billType.id = document.id;
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      //isThreeLine: true,
                                      title: Text("${billType.description}"),
                                      subtitle: Text(billType.createdOn
                                          .lastModified(
                                              modified: billType.modifiedOn)),
                                      trailing: const Icon(Icons.chevron_right),
                                      onTap: () async {},
                                    ),
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

  Future<void> _getCurrentUser() async {
    _isLoading.updateProgressStatus(msg: "");

    try {
      if (_auth.currentUser != null) {
        DocumentReference doc = _collection.doc(_auth.currentUser!.uid);
        UserProfile up = UserProfile.fromJson(doc as Map<String, dynamic>);
        up.id = doc.id;

        setState(() {
          _userProfile = up;
        });
        _isLoading.updateProgressStatus(msg: "");
      }
    } on FirebaseAuthException catch (e) {
      _isLoading.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoading.updateProgressStatus(errMsg: "$e.");
    }
  }
}
