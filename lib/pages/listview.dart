import 'package:bills/models/bills.dart';
import 'package:bills/models/user_model.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/new_record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';

import 'components/custom_widgets.dart';

class ListViewPage extends StatefulWidget {
  ListViewPage(
      {required this.title, required this.quantification, required this.color});

  final String title;
  final String quantification;
  final Color color;

  @override
  _ListViewPage createState() => _ListViewPage();
}

class _ListViewPage extends State<ListViewPage> {
  String _collectorId = "";
  _ListViewPage() {
    GlobalConfiguration cfg = new GlobalConfiguration();
    _collectorId = cfg.get("collectorId");
  }

  late FToast fToast = FToast();

  Bills _bill = Bills();

  String? _selectedUser;
  List<dynamic> _users = [];
  String _quantification = '';
  String _collectionName = '';

  // ignore: unused_field
  bool _isExpanded = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    fToast.init(context);
    setState(() {
      _collectionName = widget.title.toLowerCase();
      _quantification = widget.quantification;
    });
    _getUsers();
    _migrate();
    print(_collectorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: widget.color,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          physics: BouncingScrollPhysics(),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildDropdownSearch(),
                    _buildDropDown(),
                    _buildBody()
                  ],
                ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
      floatingActionButton: CustomFloatingActionButton(
          title: 'Add ${widget.title}',
          icon: Icons.add,
          color: widget.color,
          onTap: () {
            _showDataManager(_bill);
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(_collectionName)
          .where('payer_ids', arrayContains: _selectedUser)
          .orderBy('bill_date', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("list error: ${snapshot.error}");
          return Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return snapshot.data!.docs.length == 0
            ? Center(child: Text('No ${widget.title} Yet.'))
            : Card(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: snapshot.data!.docs.map(
                    (DocumentSnapshot document) {
                      Bills _bill = Bills.fromJson(
                          document.data() as Map<String, dynamic>);
                      _bill.id = document.id;
                      _bill.desciption = _bill.desciption; // ?? widget.title;
                      String _formattedBillDate =
                          DateFormat('MMM dd, yyyy').format(_bill.billdate!);
                      String _lastModified =
                          DateFormat('MMM dd, yyyy hh:mm aaa')
                              .format(_bill.modifiedOn ?? _bill.createdOn);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            //isThreeLine: true,
                            title: Text(
                                "${_setSelectedPayersDisplay(_bill.payerIds ?? {})}${!(_bill.desciption?.isEmpty ?? true) ? " | ${_bill.desciption}" : ""}"),
                            //subtitle: Text('Created On: ${DateTime.fromMillisecondsSinceEpoch(data['created_on']).format()}'),
                            subtitle: Text("$_lastModified"),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$_formattedBillDate',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300),
                                ),
                                Text(
                                  '${_bill.amount?.formatForDisplay()}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 25, color: widget.color),
                                ),
                                Text(
                                  '${_bill.quantification} $_quantification',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w200),
                                ),
                              ],
                            ),
                            onTap: () {
                              // setState(() {
                              //   _isExpanded = !_isExpanded;
                              // });
                              _showDataManager(_bill);
                            },
                          ),
                          Divider()
                        ],
                      );
                    },
                  ).toList(),
                ),
              );
      },
    );
  }

  _showDataManager(data) async {
    if ((await showAddRecord(
            context, data, _quantification, widget.title, widget.color)) ??
        false) {}
  }

  String _setSelectedPayersDisplay(dynamic _selectedUsers) {
    if (_selectedUsers.length >= 1) {
      int left = _selectedUsers.length - 1;
      String? payer = _getPayerName(_selectedUsers[
          0]); //_selectedUsers[0].values.last; // _selectedUsers[1];
      String others = _selectedUsers.length > 1
          ? ' and $left other${left > 1 ? 's' : ''}'
          : '';
      return '$payer$others';
    } else {
      return 'Select a Payer';
    }
  }

  _showProgressUi(bool isLoading, String msg) {
    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
    setState(() => _isLoading = isLoading);
  }

  Widget _buildDropdownSearch() {
    return DropdownSearch<UserModel>(
      items: [
        UserModel(name: "Choose a User", id: ""),
      ],
      maxHeight: 300,
      onFind: (String? filter) {
        return getData("ell");
      },
      onChanged: print,
      showSearchBox: true,
    );
  }

  void _migrate() {
    try {
      //temp code for migration
      CollectionReference collection =
          FirebaseFirestore.instance.collection("bills");
      collection.get().then((snapshots) {
        snapshots.docs.forEach((document) {
          Bills bill = Bills.fromJson(document.data() as Map<String, dynamic>);
          collection.add(bill).then((value) {
            print("${document.id} transferred to ${value.id}. Success.");
          });
        });
      }).whenComplete(() {
        _showProgressUi(
            false, "All $_collectionName transferred to 'bills' table.");
      });
      //temp code for migration
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  Future<List<UserModel>> getData(filter) async {
    List<UserModel> userModels = [];
    try {
      var col = FirebaseFirestore.instance
          .collection(_collectionName)
          //.where('payer_ids', arrayContains: _userId)
          .where('name_separated',
              arrayContains: filter.toString().toLowerCase())
          .orderBy('name');

      col.get().then((snapshots) {
        snapshots.docs.forEach((document) {
          UserProfile up = UserProfile.fromJson(document.data());
          UserModel um = UserModel(id: document.id, name: up.name!);
          userModels.add(um);
        });
      }).whenComplete(() {
        print("name: ${userModels[0].name}");
        return userModels;
      });
      _showProgressUi(false, "");
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
    return userModels;
  }

  Widget _buildDropDown() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        return Container(
          padding: EdgeInsets.all(10),
          child: DropdownButton(
            value: _selectedUser,
            isDense: true,
            onChanged: (valueSelectedByUser) {
              setState(() {
                _selectedUser = valueSelectedByUser.toString();
              });
              print(_selectedUser);
            },
            hint: Text('Client Name...'),
            items: snapshot.data?.docs.map(
              (DocumentSnapshot document) {
                UserProfile up = UserProfile.fromJson(
                    document.data() as Map<String, dynamic>);
                up.id = document.id;
                return DropdownMenuItem<String>(
                  value: up.id,
                  child: Text(up.name!),
                );
              },
            ).toList(),
          ),
        );
      },
    );
  }

  String? _getPayerName(String? id) {
    if (_users.length > 0) {
      return (_users.where((element) => element.first == id).last)
          .last
          .toString();
    } else {
      return "";
    }
  }

  Future<void> _getUsers() async {
    _showProgressUi(true, "");
    List<dynamic> users = [];

    try {
      FirebaseFirestore.instance.collection("users").get().then((snapshot) {
        users =
            snapshot.docs.map((doc) => ([doc.id, doc.get('name')])).toList();
      }).whenComplete(() {
        setState(() {
          _users = users;
        });
        print("users: $users");
      });

      _showProgressUi(false, "");
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }
}
