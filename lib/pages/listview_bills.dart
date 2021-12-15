//import 'package:bills/models/bill_type.dart';
// ignore_for_file: unnecessary_string_interpolations, void_checks

import 'package:bills/models/bill_type.dart';
import 'package:bills/models/bill.dart';
import 'package:bills/models/user_model.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/maintenance/new_bill.dart';
import 'package:bills/pages/maintenance/new_reading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:intl/intl.dart';

import 'components/custom_widgets.dart';

class ListViewBills extends StatefulWidget {
  const ListViewBills({Key? key, required this.billType}) : super(key: key);

  final BillType billType;

  @override
  _ListViewPage createState() => _ListViewPage();
}

class _ListViewPage extends State<ListViewBills> {
  String _collectorId = "";

  _ListViewPage() {
    GlobalConfiguration cfg = GlobalConfiguration();
    _collectorId = cfg.get("collectorId");
  }

  late FToast fToast = FToast();
  final FirebaseFirestore _ffInstance = FirebaseFirestore.instance;

  String _title = "";

  final Bill _bill = Bill();
  late String _selectedUserId;
  final List<dynamic> _users = [];
  final List<BillType?> _billTypes = [];
  int _billTypeId = 0;
  String? _quantification = "";

  // ignore: unused_field
  final bool _isExpanded = false;
  bool _isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  var isDialOpen = ValueNotifier<bool>(false);
  var customDialRoot = false;
  var visible = true;

  @override
  void initState() {
    super.initState();
    fToast.init(context);
    setState(() {
      _bill.billType = widget.billType;
      _quantification = _bill.billType?.quantification;
      _billTypeId = int.parse(_bill.billType!.id!);
      _selectedUserId = "";
      _title = _bill.billType!.description!;
    });
    _getBillTypes();
    // await _migrate();
    // await _combineField();
    _getUsers();
    if (kDebugMode) {
      print(_collectorId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Color(_bill.billType?.iconData?.color ?? 0),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          physics: const BouncingScrollPhysics(),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    //_buildDropdownSearch(),
                    _buildUsersDropdown(),
                    const SizedBox(height: 10),
                    _buildBody()
                  ],
                ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
      // floatingActionButton: CustomFloatingActionButton(
      //   title: 'Add ${_bill.billType?.description}',
      //   icon: Icons.add,
      //   color: Color(_bill.billType?.iconData?.color ?? 0),
      //   onTap: () {
      //     _showDataManager(_bill);
      //   },
      // ),
      floatingActionButton: SpeedDial(
        // animatedIcon: AnimatedIcons.menu_close,
        // animatedIconTheme: IconThemeData(size: 22.0),
        // / This is ignored if animatedIcon is non null
        // child: Text("open"),
        // activeChild: Text("close"),
        icon: Icons.add,
        activeIcon: Icons.close,
        spacing: 3,
        openCloseDial: isDialOpen,
        childPadding: const EdgeInsets.all(5),
        spaceBetweenChildren: 4,
        dialRoot: customDialRoot
            ? (ctx, open, toggleChildren) {
                return ElevatedButton(
                  onPressed: toggleChildren,
                  style: ElevatedButton.styleFrom(
                    primary: Color(_bill.billType?.iconData?.color ?? 0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 18),
                  ),
                  child: const Text(
                    "Custom Dial Root",
                    style: TextStyle(fontSize: 17),
                  ),
                );
              }
            : null,
        //buttonSize: buttonSize, // it's the SpeedDial size which defaults to 56 itself
        // iconTheme: IconThemeData(size: 22),
        //label: extend ? const Text("Open") : null, // The label of the main button.
        /// The active label of the main button, Defaults to label if not specified.
        //activeLabel: extend ? const Text("Close") : null,

        /// Transition Builder between label and activeLabel, defaults to FadeTransition.
        // labelTransitionBuilder: (widget, animation) => ScaleTransition(scale: animation,child: widget),
        /// The below button size defaults to 56 itself, its the SpeedDial childrens size
        childrenButtonSize: const Size(56.0, 56.0),
        visible: visible,
        direction: SpeedDialDirection.up,
        switchLabelPosition: false,

        /// If true user is forced to close dial manually
        //closeManually: closeManually,

        /// If false, backgroundOverlay will not be rendered.
        renderOverlay: true,
        // overlayColor: Colors.black,
        // overlayOpacity: 0.5,
        onOpen: () => debugPrint('OPENING DIAL'),
        onClose: () => debugPrint('DIAL CLOSED'),
        useRotationAnimation: true,
        tooltip: 'Add',
        heroTag: 'speed-dial-hero-tag',
        foregroundColor: Colors.white,
        backgroundColor: Color(_bill.billType?.iconData?.color ?? 0),
        //activeForegroundColor: Colors.red,
        //activeBackgroundColor: Colors.blue,
        elevation: 8.0,
        isOpenOnStart: false,
        animationSpeed: 200,
        shape: customDialRoot
            ? const RoundedRectangleBorder()
            : const StadiumBorder(),
        // childMargin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.receipt),
            foregroundColor: Colors.white,
            backgroundColor: Color(_bill.billType?.iconData?.color ?? 0),
            label: 'Bill',
            onTap: () => _showDataManager(_bill, 1),
            //onLongPress: () => debugPrint('FIRST CHILD LONG PRESS'),
          ),
          SpeedDialChild(
              visible: _bill.billType?.hasReading ?? false,
              child: const Icon(Icons.show_chart),
              foregroundColor: Colors.white,
              backgroundColor: Color(_bill.billType?.iconData?.color ?? 0),
              label: 'Reading',
              onTap: () => _showDataManager(_bill, 2)),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: _ffInstance
          .collection("bills")
          .where('payers_billtype',
              arrayContains: "${_selectedUserId}_$_billTypeId")
          //.where("bill_type", isEqualTo: _billTypeId)
          .orderBy('bill_date', descending: true)
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
            ? Center(child: Text('No ${_bill.billType?.description} Yet.'))
            : Card(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: snapshot.data!.docs.map(
                    (DocumentSnapshot document) {
                      Bill bill = Bill.fromJson(
                          document.data() as Map<String, dynamic>);
                      bill.id = document.id;
                      bill.billType = _billTypes.firstWhere(
                          (bt) => bt?.id == bill.billTypeId.toString());
                      bill.description = bill.description; // ?? widget.title;
                      String _formattedBillDate =
                          DateFormat('MMM dd, yyyy').format(bill.billDate!);
                      String _lastModified =
                          DateFormat('MMM dd, yyyy hh:mm aaa')
                              .format(bill.modifiedOn ?? bill.createdOn);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            //isThreeLine: true,
                            title: Text(
                                "${_setSelectedPayersDisplay(bill.payerIds ?? {})}${!(bill.description?.isEmpty ?? true) ? " | ${bill.description}" : ""}"),
                            //subtitle: Text('Created On: ${DateTime.fromMillisecondsSinceEpoch(data['created_on']).format()}'),
                            subtitle: Text(_lastModified),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$_formattedBillDate',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300),
                                ),
                                Text(
                                  '${bill.amount?.formatForDisplay()}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 25,
                                    color: Color(
                                        _bill.billType?.iconData?.color ?? 0),
                                  ),
                                ),
                                Text(
                                  '${bill.quantification} $_quantification',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w200),
                                ),
                              ],
                            ),
                            onTap: () {
                              // setState(() {
                              //   _isExpanded = !_isExpanded;
                              // });
                              _showDataManager(bill, 1);
                            },
                          ),
                          const Divider()
                        ],
                      );
                    },
                  ).toList(),
                ),
              );
      },
    );
  }

  _showDataManager(data, type) async {
    switch (type) {
      case 1:
        if ((await showBillManagement(
                context,
                data,
                _quantification,
                _bill.billType?.description,
                Color(_bill.billType?.iconData?.color ?? 0),
                _selectedUserId)) ??
            false) {
          //return added record userid (only first one if multiple selected users), then update _selectedUserId
        }
        break;
      case 2:
        if ((await showReadingManagement(
                context,
                data,
                _bill.billType?.description,
                Color(_bill.billType?.iconData?.color ?? 0),
                _selectedUserId)) ??
            false) {
          //return added record userid (only first one if multiple selected users), then update _selectedUserId
        }
        break;
    }
  }

  String _setSelectedPayersDisplay(dynamic _selectedUserIds) {
    if (_selectedUserIds.length >= 1) {
      int left = _selectedUserIds.length - 1;
      String? payer = _getPayerName(_selectedUserId);
      String others = _selectedUserIds.length > 1
          ? ' and $left other${left > 1 ? 's' : ''}'
          : '';
      return '$payer$others';
    } else {
      return 'Select a Payer';
    }
  }

  _showProgressUi(bool isLoading, String msg) {
    if (msg.isNotEmpty) {
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
          .collection("bills")
          //.where('payer_ids', arrayContains: _userId)
          .where('name_separated',
              arrayContains: filter.toString().toLowerCase())
          .orderBy('name');

      col.get().then((snapshots) {
        for (var document in snapshots.docs) {
          UserProfile up = UserProfile.fromJson(document.data());
          UserModel um = UserModel(id: document.id, name: up.name!);
          userModels.add(um);
        }
      }).whenComplete(() {
        if (kDebugMode) {
          print("name: ${userModels[0].name}");
        }
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

  Widget _buildUsersDropdown() {
    return FormField<String>(
      builder: (FormFieldState<String> state) {
        return InputDecorator(
          decoration: InputDecoration(
              prefixIcon: const Icon(Icons.person, color: Colors.white),
              contentPadding: const EdgeInsets.all(5),
              errorStyle:
                  const TextStyle(color: Colors.redAccent, fontSize: 16.0),
              hintText: 'Client',
              labelText: 'Client',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
          isEmpty: false, //_selectedUserId == '',
          child: StreamBuilder<QuerySnapshot>(
            stream: _ffInstance
                .collection('users')
                .where("deleted", isEqualTo: false)
                .orderBy("name")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (_selectedUserId.isEmpty && snapshot.data!.docs.isNotEmpty) {
                _selectedUserId =
                    snapshot.data?.docs.first.id ?? _selectedUserId;
              }
              return DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedUserId,
                  isDense: true,
                  hint: const Text("Choose user..."),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedUserId = newValue!;
                      state.didChange(newValue);
                    });
                    if (kDebugMode) {
                      print("_selectedUserId:$_selectedUserId");
                    }
                  },
                  items: snapshot.data?.docs.map((document) {
                    return DropdownMenuItem<String>(
                      value: document.id,
                      child: Text(document.get("name")),
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
    //         value: _selectedUserId,
    //         isDense: true,
    //         onChanged: (valueSelectedByUser) {
    //           setState(() {
    //             _selectedUserId = valueSelectedByUser.toString();
    //           });
    //           print(_selectedUserId);
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
    if (_users.isNotEmpty) {
      return (_users.where((element) => element.first == id).last)
          .last
          .toString();
    } else {
      return "";
    }
  }

  Future<void> _getBillTypes() async {
    List<BillType?> billTypes = [];
    try {
      _ffInstance
          .collection("bill_types")
          .orderBy('description')
          .get()
          .then((snapshots) {
        for (var document in snapshots.docs) {
          BillType bt = BillType.fromJson(document.data());
          bt.id = document.id;
          billTypes.add(bt);
        }
      }).whenComplete(() {
        setState(() {
          _billTypes.clear();
          _billTypes.addAll(billTypes);
        });
        if (kDebugMode) {
          print("_billTypes: $_billTypes");
        }
      });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  // int _getBillType(String collectionName, {int id = 0, String desc = ""}) {
  //   switch (_collectionName) {
  //     case "payments":
  //       id = 1;
  //       break;
  //     case "salarys":
  //       id = 2;
  //       break;
  //     case "subscriptions":
  //       id = 3;
  //       break;
  //     case "loans":
  //       id = 4;
  //       break;
  //     case "water":
  //       id = 5;
  //       break;
  //     case "electricity":
  //       id = 6;
  //       break;
  //   }
  //   return id;
  //   // if (_billTypeIds.length > 0) {
  //   //   BillType? bt = _billTypeIds.where((bill) => bill?.desciption == desc).last;
  //   //   String? id = bt?.id;
  //   //   return int.parse(id ?? "0");
  //   // } else {
  //   //   return 0;
  //   // }
  // }

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
  //         _billTypeIds.clear();
  //         _billTypeIds.addAll(bts);
  //       });
  //       print("_billTypeIds: $_billTypeIds");
  //     });
  //     _showProgressUi(false, "");
  //   } on FirebaseAuthException catch (e) {
  //     _showProgressUi(false, "${e.message}.");
  //   } catch (e) {
  //     _showProgressUi(false, "$e.");
  //   }
  // }

  // Future<void> _combineField() async {
  //   bool done = false;
  //   try {
  //     CollectionReference bills = _ffInstance.collection("bills");
  //     bills.get().then((snapshots) {
  //       snapshots.docs.forEach((document) {
  //         Bills bill = Bills.fromJson(document.data() as Map<String, dynamic>);
  //         List<String?> newPayers = [];
  //         bill.payerIds?.forEach((element) {
  //           String? pbt = "${element}_${bill.billtype}";
  //           newPayers.add(pbt);
  //         });
  //         DocumentReference doc =
  //             _ffInstance.collection("bills").doc(document.id);
  //         doc.update({"payers_billtype": newPayers});
  //         // bills.doc(document.id).update(_bill.toJson()).then((value) {
  //         //   _showProgressUi(false, "Bill updated.");
  //         // }).catchError((error) {
  //         //   _showProgressUi(
  //         //       false, "Failed to update bill id: ${document.id}\n$error.");
  //         // });
  //       });
  //     });
  //   } on FirebaseAuthException catch (e) {
  //     _showProgressUi(false, "${e.message}.");
  //   } catch (e) {
  //     _showProgressUi(false, "$e.");
  //   }
  // }

  // Future<void> _migrate() async {
  //   bool done = false;

  //   try {
  //     //temp code for migration
  //     CollectionReference copyFrom = _ffInstance.collection(_collectionName);
  //     CollectionReference copyTo = _ffInstance.collection("bills");
  //     copyFrom.get().then((snapshots) {
  //       snapshots.docs.forEach((document) {
  //         Bills bill = Bills.fromJson(document.data() as Map<String, dynamic>);
  //         // List<String?> newPayers = [];
  //         // bill.payerIds?.forEach((element) {
  //         //   String? pbt = "${element}_${bill.billtype}";
  //         //   newPayers.add(pbt);
  //         // });
  //         // bill.payersbilltype = newPayers.cast<String>();
  //         // var dd = _billTypeIds
  //         //     .where((element) =>
  //         //         element?.desciption?.toLowerCase().trim() == _collectionName)
  //         //     .first as int?;
  //         // bill.billtype = dd;
  //         // switch (_collectionName) {
  //         //   case "electricity":
  //         //     bill.billtype = 6;
  //         //     break;
  //         //   case "loans":
  //         //     bill.billtype = 4;
  //         //     break;
  //         //   case "payments":
  //         //     bill.billtype = 1;
  //         //     break;
  //         //   case "salary":
  //         //     bill.billtype = 2;
  //         //     break;
  //         //   case "subscriptions":
  //         //     bill.billtype = 3;
  //         //     break;
  //         //   default:
  //         //     bill.billtype = 5;
  //         //     break;
  //         // }

  //         bill.billtype = _getBillType(_collectionName);

  //         var data = bill.toJson();
  //         if (bill.billtype! > 0) {
  //           copyTo.add(data).then((value) {
  //             if (value.id.isNotEmpty) {
  //               print("${document.id} transferred to ${value.id}. Success.");
  //               setState(() {
  //                 done = true;
  //               });
  //             } else {
  //               print("asdasd");
  //             }
  //           }).catchError((error) {
  //             _showProgressUi(false, "error migrating record: $error.");
  //           });
  //         } else {
  //           _showProgressUi(false, "Invalid bill type.");
  //         }
  //       });
  //     }).whenComplete(() {
  //       if (done) {
  //         _showProgressUi(
  //             false, "All $_collectionName transferred to 'bills' table.");
  //       }
  //     });
  //     //temp code for migration
  //   } on FirebaseAuthException catch (e) {
  //     _showProgressUi(false, "${e.message}.");
  //   } catch (e) {
  //     _showProgressUi(false, "$e.");
  //   }
  // }

  Future<void> _getUsers() async {
    _showProgressUi(true, "");
    List<dynamic> users = [];

    try {
      _ffInstance
          .collection("users")
          .where("deleted", isEqualTo: false)
          .get()
          .then((snapshot) {
        users =
            snapshot.docs.map((doc) => ([doc.id, doc.get('name')])).toList();
      }).whenComplete(() {
        setState(() {
          _users.clear();
          _users.addAll(users);
        });
        if (kDebugMode) {
          print("users: $users");
        }
      });

      _showProgressUi(false, "");
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }
}
