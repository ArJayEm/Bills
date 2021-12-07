//import 'package:bills/models/bill_type.dart';
import 'package:bills/models/bills.dart';
import 'package:bills/models/user_model.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/new_record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:dropdown_search/dropdown_search.dart';
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
  bool _isDebug = false;
  String _collectorId = "";
  _ListViewPage() {
    GlobalConfiguration cfg = new GlobalConfiguration();
    _collectorId = cfg.get("collectorId");
    _isDebug = cfg.get("isDebug");
  }

  late FToast fToast = FToast();
  final FirebaseFirestore _ffInstance = FirebaseFirestore.instance;

  Bills _bill = Bills();

  String? _selectedUser;
  List<dynamic> _users = [];
  //List<BillType?> _billTypes = [];
  String _quantification = '';
  String _collectionName = '';
  int _billType = 0;

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
    _billType = _getBillType(_collectionName);
    //_getbillTypes();
    // _migrate();
    // _combineField();
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
                    //_buildDropdownSearch(),
                    _buildDropDown(),
                    SizedBox(height: 10),
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
      stream: _ffInstance
          .collection("bills")
          .where('payers_billtype',
              arrayContains: "${_selectedUser}_$_billType")
          //.where("bill_type", isEqualTo: _billType)
          .orderBy('bill_date', descending: true)
          //.limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          String msg = snapshot.error.toString();
          print("list error: $msg");
          Fluttertoast.showToast(msg: msg);
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
    if ((await showAddRecord(context, data, _quantification, widget.title,
            widget.color, _selectedUser)) ??
        false) {
      //return added record userid (only first one if multiple selected users), then update _selectedUser
    }
  }

  String _setSelectedPayersDisplay(dynamic _selectedUsers) {
    if (_selectedUsers.length >= 1) {
      int left = _selectedUsers.length - 1;
      String? payer = _getPayerName(_selectedUser);
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

  // Widget _buildDropdownSearch() {
  //   return DropdownSearch<UserModel>(
  //     items: [
  //       UserModel(name: "Choose a User", id: ""),
  //     ],
  //     maxHeight: 300,
  //     onFind: (String? filter) {
  //       return getData("ell");
  //     },
  //     onChanged: print,
  //     showSearchBox: true,
  //   );
  // }

  Future<List<UserModel>> getData(filter) async {
    List<UserModel> userModels = [];
    try {
      var col = _ffInstance
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
    return FormField<String>(
      builder: (FormFieldState<String> state) {
        return InputDecorator(
          decoration: InputDecoration(
              prefixIcon: Icon(Icons.person, color: Colors.white),
              contentPadding: EdgeInsets.all(5),
              errorStyle: TextStyle(color: Colors.redAccent, fontSize: 16.0),
              hintText: 'Please select expense',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
          isEmpty: _selectedUser == '',
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .orderBy("name")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());
              return DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedUser,
                  isDense: true,
                  hint: Text("Choose user..."),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedUser = newValue;
                      state.didChange(newValue);
                    });
                    if (_isDebug) {
                      print("_selectedUser:$_selectedUser");
                    }
                  },
                  items: snapshot.data?.docs.map((DocumentSnapshot document) {
                    UserProfile up = UserProfile.fromJson(
                        document.data() as Map<String, dynamic>);
                    return DropdownMenuItem<String>(
                      value: document.id,
                      child: Text(up.name!),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        );
      },
    );
    // StreamBuilder<QuerySnapshot>(
    //   stream: _ffInstance.collection('users').snapshots(),
    //   builder: (context, snapshot) {
    //     if (!snapshot.hasData)
    //       return Center(child: CircularProgressIndicator());
    //     if (snapshot.connectionState == ConnectionState.waiting)
    //       return Center(child: CircularProgressIndicator());
    //     return Container(
    //       padding: EdgeInsets.all(10),
    //       child: DropdownButton(
    //         value: _selectedUser,
    //         isDense: true,
    //         onChanged: (valueSelectedByUser) {
    //           setState(() {
    //             _selectedUser = valueSelectedByUser.toString();
    //           });
    //           print(_selectedUser);
    //         },
    //         hint: Text('Client Name...'),
    //         items: snapshot.data?.docs.map(
    //           (DocumentSnapshot document) {
    //             UserProfile up = UserProfile.fromJson(
    //                 document.data() as Map<String, dynamic>);
    //             up.id = document.id;
    //             return DropdownMenuItem<String>(
    //               value: up.id,
    //               child: Text(up.name!),
    //             );
    //           },
    //         ).toList(),
    //       ),
    //     );
    //   },
    // );
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

  int _getBillType(String desc) {
    int id = 0;

    switch (_collectionName) {
      case "payments":
        id = 1;
        break;
      case "salarys":
        id = 2;
        break;
      case "subscriptions":
        id = 3;
        break;
      case "loans":
        id = 4;
        break;
      case "water":
        id = 5;
        break;
      case "electricity":
        id = 6;
        break;
    }

    return id;
  }

  // Future<void> _getbillTypes() async {
  //   List<BillType?> bts = [];
  //   try {
  //     var col = _ffInstance.collection("bill_types");

  //     col.get().then((snapshots) {
  //       snapshots.docs.forEach((document) {
  //         BillType? bt = BillType.fromJson(document.data());
  //         bt.desciption = document.get('description').toLowerCase().trim();
  //         bts.add(bt);
  //       });
  //     }).whenComplete(() {
  //       setState(() {
  //         _billTypes.addAll(bts);
  //       });
  //       print("_billTypes: $_billTypes");
  //     });
  //     _showProgressUi(false, "");
  //   } on FirebaseAuthException catch (e) {
  //     _showProgressUi(false, "${e.message}.");
  //   } catch (e) {
  //     _showProgressUi(false, "$e.");
  //   }
  // }

  Future<void> _combineField() async {
    bool done = false;
    try {
      CollectionReference bills = _ffInstance.collection("bills");
      bills.get().then((snapshots) {
        snapshots.docs.forEach((document) {
          Bills bill = Bills.fromJson(document.data() as Map<String, dynamic>);
          List<String?> newPayers = [];
          bill.payerIds?.forEach((element) {
            String? pbt = "${element}_${bill.billtype}";
            newPayers.add(pbt);
          });
          DocumentReference doc =
              _ffInstance.collection("bills").doc(document.id);
          doc.update({"payers_billtype": newPayers});
          // bills.doc(document.id).update(_bill.toJson()).then((value) {
          //   _showProgressUi(false, "Bill updated.");
          // }).catchError((error) {
          //   _showProgressUi(
          //       false, "Failed to update bill id: ${document.id}\n$error.");
          // });
        });
      });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  Future<void> _migrate() async {
    bool done = false;

    try {
      //temp code for migration
      CollectionReference copyFrom = _ffInstance.collection(_collectionName);
      CollectionReference copyTo = _ffInstance.collection("bills");
      copyFrom.get().then((snapshots) {
        snapshots.docs.forEach((document) {
          Bills bill = Bills.fromJson(document.data() as Map<String, dynamic>);
          // List<String?> newPayers = [];
          // bill.payerIds?.forEach((element) {
          //   String? pbt = "${element}_${bill.billtype}";
          //   newPayers.add(pbt);
          // });
          // bill.payersbilltype = newPayers.cast<String>();
          // var dd = _billTypes
          //     .where((element) =>
          //         element?.desciption?.toLowerCase().trim() == _collectionName)
          //     .first as int?;
          // bill.billtype = dd;
          // switch (_collectionName) {
          //   case "electricity":
          //     bill.billtype = 6;
          //     break;
          //   case "loans":
          //     bill.billtype = 4;
          //     break;
          //   case "payments":
          //     bill.billtype = 1;
          //     break;
          //   case "salary":
          //     bill.billtype = 2;
          //     break;
          //   case "subscriptions":
          //     bill.billtype = 3;
          //     break;
          //   default:
          //     bill.billtype = 5;
          //     break;
          // }

          bill.billtype = _getBillType(_collectionName);

          var data = bill.toJson();
          if (bill.billtype! > 0) {
            copyTo.add(data).then((value) {
              if (value.id.isNotEmpty) {
                print("${document.id} transferred to ${value.id}. Success.");
                setState(() {
                  done = true;
                });
              } else {
                print("asdasd");
              }
            }).catchError((error) {
              _showProgressUi(false, "error migrating record: $error.");
            });
          } else {
            _showProgressUi(false, "Invalid bill type.");
          }
        });
      }).whenComplete(() {
        if (done) {
          _showProgressUi(
              false, "All $_collectionName transferred to 'bills' table.");
        }
      });
      //temp code for migration
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  Future<void> _getUsers() async {
    _showProgressUi(true, "");
    List<dynamic> users = [];

    try {
      _ffInstance.collection("users").get().then((snapshot) {
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
