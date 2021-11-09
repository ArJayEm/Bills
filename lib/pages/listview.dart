import 'package:bills/models/bills.dart';
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

  String _userId = "";
  List<dynamic> _users = [];
  //List<UserProfile> _userProfiles = [];
  //Stream<QuerySnapshot>? _listStream;
  //Future<List<Bills>>? _bills;
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
      //_userId = "hrB58ui8mAOwnLKeGYcj7sFXd282";
      // "IfFnR6UnbOMPHdiy5aCUUbCavhw1";
      _collectionName = widget.title.toLowerCase();
      _quantification = widget
          .quantification; //_collectionName == 'electricity' ? 'kwh' : 'cu.m';
      //_bills = _getStream();
    });
    _getUsers();
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
                  children: [_buildDropDown(), _buildBody()],
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

  // Widget _buildBills() {
  //   return Card(
  //     child: RefreshIndicator(
  //       onRefresh: () {
  //         setState(() {
  //           _bills = _getStream();
  //         });
  //       },
  //       child: ListView(shrinkWrap: true, children: _buildList()),
  //     ),
  //   );
  // }

  // List<Widget> _buildList() {
  //   List<Widget> mList = <Widget>[];
  //   for (int b = 0; b < _bills.length; b++) {
  //     String _lastModified = DateFormat('MMM dd, yyyy hh:mm aaa')
  //         .format(_bills[b].modifiedOn ?? _bills[b].createdOn);
  //     String _formattedBillDate =
  //         DateFormat('MMM dd, yyyy').format(_bills[b].billdate!);
  //     mList.add(
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.stretch,
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           ListTile(
  //             //isThreeLine: true,
  //             title: Text(_formattedBillDate),
  //             //subtitle: Text('Created On: ${DateTime.fromMillisecondsSinceEpoch(data['created_on']).format()}'),
  //             subtitle: Text(
  //                 "${_bill.payerNames}${!(_bills[b].desciption?.isEmpty ?? true) ? " | ${_bill.desciption}" : ""}"),
  //             //_setSelectedPayersDisplay(_bills[b].payerIds ?? {})
  //             trailing: Column(
  //               crossAxisAlignment: CrossAxisAlignment.end,
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Text(
  //                   'P ${_bills[b].amount}',
  //                   textAlign: TextAlign.right,
  //                   style: TextStyle(fontSize: 25, color: widget.color),
  //                 ),
  //                 Text(
  //                   '${_bills[b].quantification} $_quantification',
  //                   textAlign: TextAlign.right,
  //                   style: TextStyle(fontSize: 13, fontWeight: FontWeight.w200),
  //                 ),
  //                 Text(
  //                   '$_lastModified',
  //                   textAlign: TextAlign.right,
  //                   style: TextStyle(fontWeight: FontWeight.w200),
  //                 ),
  //               ],
  //             ),
  //             onTap: () {
  //               // setState(() {
  //               //   _isExpanded = !_isExpanded;
  //               // });
  //               _showDataManager(_bills[b]);
  //             },
  //           ),
  //           Divider()
  //         ],
  //       ),
  //     );
  //   }
  //   return mList;
  // }

  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        physics: BouncingScrollPhysics(),
        child: StreamBuilder<QuerySnapshot>(
          stream: //_getStream(_userId),
              FirebaseFirestore.instance
                  .collection(_collectionName)
                  //.where('payer_ids', arrayContains: {"id": "hrB58ui8mAOwnLKeGYcj7sFXd282"})
                  // .where('payer_ids', arrayContainsAny: [
                  //   {"id": "IfFnR6UnbOMPHdiy5aCUUbCavhw1"}
                  // ])
                  //.where('payer_ids',
                  //    arrayContainsAny: ["IfFnR6UnbOMPHdiy5aCUUbCavhw1"])
                  //.where('payer_ids',
                  //    arrayContainsAny: ["IfFnR6UnbOMPHdiy5aCUUbCavhw1"])
                  //.where('payer_ids.id', whereIn: ["IfFnR6UnbOMPHdiy5aCUUbCavhw1"])
                  //.where('payer_ids', arrayContains: "hrB58ui8mAOwnLKeGYcj7sFXd282")
                  //.where('payer_ids.id', isEqualTo: _userId)
                  .orderBy('bill_date', descending: true)
                  .limit(10)
                  .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                    // child: RefreshIndicator(
                    //   onRefresh: _getStream(_userId),
                    //   child: ,
                    // ),
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      children: snapshot.data!.docs.map(
                        (DocumentSnapshot document) {
                          var data = document.data();
                          Bills _bill =
                              Bills.fromJson(data as Map<String, dynamic>);
                          //if (_bill.payerIds.toString().contains("$_userId")) {
                          _bill.id = document.id;
                          _bill.desciption =
                              _bill.desciption; // ?? widget.title;
                          String _formattedBillDate = DateFormat('MMM dd, yyyy')
                              .format(_bill.billdate!);
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
                                title: Text(_formattedBillDate),
                                //subtitle: Text('Created On: ${DateTime.fromMillisecondsSinceEpoch(data['created_on']).format()}'),
                                subtitle: Text(
                                    "${_setSelectedPayersDisplay(_bill.payerIds ?? {})}${!(_bill.desciption?.isEmpty ?? true) ? " | ${_bill.desciption}" : ""}"),

                                trailing: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'P ${_bill.amount}',
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
                                    Text(
                                      '$_lastModified',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
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
                          //} else {
                          //  return SizedBox();
                          //}
                        },
                      ).toList(),
                    ),
                  );
          },
        ),
      ),
    );
  }

  _showDataManager(data) async {
    if ((await showAddRecord(
            context, data, _quantification, widget.title, widget.color)) ??
        false) {
      _getStream();
    }
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

  Future<void> _getUsers() async {
    _showProgressUi(true, "");
    List<dynamic> users = [];

    try {
      FirebaseFirestore.instance.collection("users").get().then((snapshot) {
        users = snapshot.docs
            .map((doc) => ([doc.id, doc.get('display_name')]))
            .toList();
      }).whenComplete(() {
        setState(() {
          _users = users;
        });
        print("users: $users");
        _getStream();
      });

      _showProgressUi(false, "");
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  Future<void> _getStream() async {
    //_showProgressUi(true, "");
    //Stream<QuerySnapshot<Map<String, dynamic>>> stream;
    //List<Bills> bills = [];

    try {
      FirebaseFirestore.instance
          .collection(_collectionName)
          .orderBy('bill_date', descending: true)
          .get()
          .then((snapshots) {
        snapshots.docs.forEach((document) {
          if (document.data().toString().contains(_userId)) {
            Bills bill =
                Bills.fromJson(document.data());
            bill.id = document.id;
            //bills.add(bill);
            //var d = document.data() as QueryDocumentSnapshot<Map<String, dynamic>>;
            //stream.doc
          }
        });
      }).whenComplete(() {
        //stream = bills as Stream<QuerySnapshot>;
        //return stream;
        // setState(() {
        //   //_bills = bills;
        //   _listStream = stream;
        // });
        // setState(() {
        //   _listStream = collection;
        // });
        //return bills;
      });
      _showProgressUi(false, "");
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
    //return bills;
  }

  _showProgressUi(bool isLoading, String msg) {
    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
    setState(() => _isLoading = isLoading);
  }

  Widget _buildDropDown() {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 15, 15, 0),
      child: DropdownSearch<UserProfile>(
        showSelectedItem: true,
        showSearchBox: true,
        compareFn: (i, s) => i.isEqual(s),
        label: "Your Payers",
        onFind: (filter) => getData(filter),
        onChanged: (data) {
          print("data: $data");
          // setState(() {
          //   _userId = data?.id;
          // });
          //_getlist();
        },
        dropdownBuilder: _customDropDownExample,
        popupItemBuilder: _customPopupItemBuilderExample2,
        showFavoriteItems: false,
        favoriteItemsAlignment: MainAxisAlignment.start,
        favoriteItems: (items) {
          return items.where((e) => e.displayName!.contains("Raff")).toList();
        },
        favoriteItemBuilder: (context, item) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[100]),
            child: Text(
              "${item.displayName}",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.indigo),
            ),
          );
        },
      ),
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

  Future<List<UserProfile>> getData(filter) async {
    List<UserProfile> userProfiles = [];
    try {
      var col = FirebaseFirestore.instance
          .collection(_collectionName)
          //.where('payer_ids', arrayContains: _userId)
          .where('display_name', arrayContains: filter)
          .orderBy('bill_date', descending: true);

      col.get().then((snapshots) {
        snapshots.docs.forEach((document) {
          UserProfile up =
              UserProfile.fromJson(document.data());
          up.id = document.id;
          userProfiles.add(up);
        });
        //print("snapshot.docs: ${snapshot.docs.first.data()}");
        // userProfiles = snapshot.docs
        //     .map((e) =>
        //         UserProfile.fromJson(e.data(). as Map<String, dynamic>))
        //     .toList();

        // userProfiles = snapshot.docs
        //     .map((doc) => UserProfile.fromJson(doc.data()))
        //     .toList();

        //return list.map((item) => UserModel.fromJson(item)).toList();
      }).whenComplete(() {
        print("displayName: ${userProfiles[0].displayName}");
        return userProfiles;
      });
      _showProgressUi(false, "");
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
    return userProfiles;
  }

  Widget _customDropDownExample(context, item, itemDesignation) {
    return item == null
        ? Container()
        : Container(
            child: (item.photoUrl == null)
                ? ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: CircleAvatar(),
                    title: Text("No item selected"),
                  )
                : ListTile(
                    contentPadding: EdgeInsets.all(0),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(item.photoUrl ?? ''),
                    ),
                    title: Text("${item.displayName}"),
                    //subtitle: Text(item.billingDate!.formatDate(dateOnly: true)),
                  ),
          );
  }

  Widget _customPopupItemBuilderExample2(context, item, isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: Text("${item.displayName}"),
        //subtitle: Text(item.createdOn.format(dateOnly: true)),
        leading: CircleAvatar(
            // this does not work - throws 404 error
            // backgroundImage: NetworkImage(item.avatar ?? ''),
            ),
      ),
    );
  }
}
