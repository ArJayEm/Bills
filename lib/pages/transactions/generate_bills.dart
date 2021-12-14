import 'package:bills/models/bill_type.dart';
import 'package:bills/models/billing.dart';
import 'package:bills/models/bill.dart';
import 'package:bills/models/coins.dart';
import 'package:bills/models/icon_data.dart';
import 'package:bills/models/meter_readings.dart';
import 'package:bills/models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:intl/intl.dart';

class GenerateBills extends StatefulWidget {
  const GenerateBills({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _GenerateBillsState createState() => _GenerateBillsState();
}

class _GenerateBillsState extends State<GenerateBills> {
  bool _isDebug = false;
  _GenerateBillsState() {
    // Access configuration at constructor
    GlobalConfiguration cfg = new GlobalConfiguration();
    _isDebug = cfg.get("isDebug");
  }

  String _title = "Generate Bills";

  //late final FirebaseAuth _auth;
  late final String _loggedInId;
  late String _selectedUserId;
  final DateTime _firstdate = DateTime(DateTime.now().year - 2);
  final DateTime _lastdate = DateTime.now();
  DateTime _billsFrom = DateTime.now();
  DateTime _billsTo = DateTime.now();
  DateTime _previousMonthStart = DateTime.now();
  DateTime _previousMonthEnd = DateTime.now();
  bool _useCoins = false;
  bool _isLoading = false;
  bool _isToOverwriteExists = false;

  UserProfile _loggedInUserprofile = UserProfile();
  UserProfile _selectedUserProfile = UserProfile();
  List<UserProfile?> _userProfiles = [];
  Billing _billToPay = new Billing();
  Billing _previousUnpaidBilling = new Billing();
  Billing _previousBilling = new Billing();
  Billing _billToOverwrite = new Billing();

  List<Bill?> _bills = [];
  List<BillType?> _billTypes = [];
  List<int> _billTypeIds = [0];
  List<MeterReadings?> _readings = [];
  // List<int> _debitBillTypeIds = [0];
  // List<int> _creditBillTypeIds = [0];
  // List<MeterReadings?> _currentReadings = [];
  // List<MeterReadings?> _previousReadings = [];

  final _ctrlBillDate = TextEditingController();
  final _ctrlCreditAmount = TextEditingController();

  final FocusNode _creditsFocusNode = FocusNode();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _ffInstance = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    setState(() {
      //_auth = widget.auth;
      _loggedInId = widget.auth.currentUser!.uid;
      _selectedUserId = "";
      _billToPay.billingDate = DateTime.now();
      _ctrlBillDate.text = _billToPay.billingDate!
          .formatDate(dateOnly: true, fullMonth: true, hideDay: true);
      _billsFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
      _billsTo = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
    });
    _loadForm();
    print(_loggedInId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(_title),
      ),
      body: RefreshIndicator(
        onRefresh: _loadForm,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            physics: BouncingScrollPhysics(),
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _getUsersDropdown(),
                        SizedBox(height: 10),
                        _dateTimePicker(),
                        SizedBox(height: 10),
                        TextButton(
                          child: Text("Search", style: TextStyle(fontSize: 18)),
                          style: TextButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              primary: Colors.grey.shade700,
                              backgroundColor: Colors.white),
                          onPressed: () {
                            _getUsers();
                            _getBillTypes();
                            _getClientMeterReadings();
                            _getPreviousUnpaidAmount();
                            _getBills();
                          },
                        ),
                        SizedBox(height: 5),
                        _getBillsList(),
                        _getTotals(),
                        SizedBox(height: 10),
                        //_getCoinsWidget(),
                        //SizedBox(height: 10),
                        TextButton(
                          child:
                              Text("Generate", style: TextStyle(fontSize: 18)),
                          style: TextButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              primary: Colors.grey.shade700,
                              backgroundColor: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadForm() async {
    await _getUsers();
    await _getBillTypes();
    await _getClientMeterReadings();
    await _getPreviousUnpaidAmount();
    await _getBills();
  }

  Widget _dateTimePicker() {
    return TextFormField(
      decoration: InputDecoration(
          prefixIcon: Icon(Icons.calendar_today, color: Colors.white),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          contentPadding: EdgeInsets.all(5),
          labelText: 'Bill Date',
          hintText: 'Bill Date'),
      controller: _ctrlBillDate,
      readOnly: true,
      onTap: () async {
        var date = await showDatePicker(
          context: context,
          initialDate: _billToPay.billingDate!,
          firstDate: _firstdate,
          lastDate: _lastdate,
          //initialDatePickerMode: DatePickerMode.year
        );
        if (date != null) {
          setState(() {
            _billToPay.billingDate = DateTime(date.year, date.month, date.day);
            _billsFrom = DateTime(date.year, date.month, 1);
            _billsTo = DateTime(date.year, date.month + 1, 0);
            _previousMonthEnd = DateTime(_billsFrom.year, _billsFrom.month, 0);
            _previousMonthStart =
                DateTime(_billsFrom.year, _billsFrom.month - 1, 1);
            _ctrlBillDate.text =
                date.formatDate(dateOnly: true, fullMonth: true, hideDay: true);
          });
          await _getClientMeterReadings();
          await _getPreviousUnpaidAmount();
          await _getBills();
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty || value == "0") {
          return 'Invalid Bill Date.';
        }
        return null;
      },
    );
  }

  Future<void> _getBillTypes() async {
    List<BillType?> billTypes = [];
    List<int> billTypeIds = [];
    try {
      _ffInstance
          .collection("bill_types")
          .orderBy("is_debit", descending: true)
          .get()
          .then((snapshots) {
        snapshots.docs.forEach((document) {
          BillType? b = BillType.fromJson(document.data());
          b.id = document.id;

          billTypeIds.add(int.parse(document.id));
          billTypes.add(b);
        });
      }).whenComplete(() {
        setState(() {
          _billTypes.clear();
          _billTypeIds.clear();
          _billTypes.addAll(billTypes);
          _billTypeIds.addAll(billTypeIds);
        });
        printIfDebugging("_billTypes: $_billTypes");
      });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  Future<void> _getUsers() async {
    List<UserProfile?> ups = [];
    try {
      _ffInstance
          .collection("users")
          .where("deleted", isEqualTo: false)
          .get()
          .then((snapshots) {
        snapshots.docs.forEach((document) {
          UserProfile up = UserProfile.fromJson(document.data());
          up.id = document.id;
          ups.add(up);
        });
      }).whenComplete(() {
        setState(() {
          _userProfiles.clear();
          _userProfiles.addAll(ups);
          if (_selectedUserId.isNotEmpty) {
            _selectedUserId = _selectedUserId;
          } else {
            _selectedUserId = _userProfiles.first?.id ?? _selectedUserId;
          }
          _selectedUserProfile = _userProfiles
                  .firstWhere((element) => element?.id == _selectedUserId) ??
              UserProfile();
          _loggedInUserprofile = _userProfiles
                  .firstWhere((element) => element?.id == _loggedInId) ??
              UserProfile();
        });
        printIfDebugging("_userProfiles: ${_userProfiles.toList()}");
      });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  Future<void> _getClientMeterReadings() async {
    List<MeterReadings> readings = [];
    try {
      _ffInstance
          .collection("meter_readings")
          .where("userid_deleted", isEqualTo: "${_selectedUserId}_0")
          .where("reading_date",
              isGreaterThanOrEqualTo:
                  _billsFrom.toIso8601String()) //_previousMonthStart
          .where("reading_date",
              isLessThanOrEqualTo: _billsTo.toIso8601String())
          .limit(2)
          .get()
          .then((snapshots) {
        snapshots.docs.forEach((doc) {
          readings.add(MeterReadings.fromJson(doc.data()));
        });
      }).whenComplete(() {
        setState(() {
          _readings.clear();
          _readings.addAll(readings);
          if (_readings.length == 0) {
            String msg = "No Readings found.";
            print("Meter Readings error: $msg");
            Fluttertoast.showToast(msg: msg);
          } else {
            print("${_readings.toList()}");
          }
        });
      });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  // Widget _getPreviousUnpaid() {
  //   Billing billing = Billing();
  //   Widget ret = Container(
  //     padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
  //     child: Row(
  //       children: [
  //         Text("Previous Unpaid:"),
  //         Spacer(),
  //         StreamBuilder<QuerySnapshot>(
  //           stream: _ffInstance
  //               .collection("billings")
  //               .where('user_id', arrayContains: _selectedUserId)
  //               .where("billing_date",
  //                   isGreaterThanOrEqualTo:
  //                       _previousMonthStart.toIso8601String())
  //               .where("billing_date",
  //                   isLessThanOrEqualTo: _previousMonthEnd.toIso8601String())
  //               .limit(1)
  //               .snapshots(),
  //           builder: (context, snapshot) {
  //             if (snapshot.hasError) {
  //               String msg = snapshot.error.toString();
  //               print("Previous Unpaid error: $msg");
  //               Fluttertoast.showToast(msg: "Unable to get Previous Unpaid.");
  //               return Text("0.00");
  //             }
  //             if (snapshot.connectionState == ConnectionState.waiting) {
  //               return Text("0.00");
  //             }
  //             return Text("${billing.totalPayment?.formatForDisplay()}");
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  //   // setState(() {
  //   //   _previousUnpaidBilling = billing;
  //   // });
  //   return ret;

  // Billing prevBilling = Billing();
  // num totalPayment = 0;

  // try {
  //   _ffInstance
  //       .collection("billings")
  //       .where('user_id', arrayContains: _selectedUserId)
  //       .where("billing_date",
  //           isGreaterThanOrEqualTo: _previousMonthStart.toIso8601String())
  //       .where("billing_date",
  //           isLessThanOrEqualTo: _previousMonthEnd.toIso8601String())
  //       .limit(1)
  //       .get()
  //       .then((snapshots) {
  //     snapshots.docs.forEach((doc) {
  //       prevBilling = Billing.fromJson(doc.data());
  //     });
  //   }).whenComplete(() {
  //     // setState(() {
  //     //   _previousBilling = prevBilling;
  //     // });
  //     if (_previousBilling.id!.isNotEmpty) {
  //       print("Previous Billing: $_previousBilling");
  //       totalPayment = prevBilling.totalPayment;
  //     } else {
  //       String msg = "No Previous Billing found.";
  //       print(msg);
  //       Fluttertoast.showToast(msg: msg);
  //     }
  //   });
  // } on FirebaseAuthException catch (e) {
  //   _showProgressUi(false, "${e.message}.");
  // } catch (e) {
  //   _showProgressUi(false, "$e.");
  // }

  // return totalPayment.formatForDisplay();
  //}

  Widget _getCoinsWidget() {
    return StreamBuilder<QuerySnapshot>(
      stream: _ffInstance
          .collection("coins")
          .where("payerid_deleted", isEqualTo: "${_selectedUserId}_0")
          .orderBy('created_on', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          String msg = snapshot.error.toString();
          print("coins error: $msg");
          Fluttertoast.showToast(msg: "Unable to get coins.");
        }
        num clientCoins = 0.00;
        //if (_selectedUserId.isNotEmpty) {
        snapshot.data!.docs.forEach((doc) {
          Coins c = Coins.fromJson(doc.data() as Map<String, dynamic>);
          clientCoins += c.amount ?? 0;
        });
        //}
        return CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          value: _useCoins,
          onChanged: (val) {
            if (clientCoins > 0) {
              setState(() {
                _useCoins = val!;
              });
              if (_useCoins) {
                setState(() {
                  _billToPay.coins = clientCoins;
                  _ctrlCreditAmount.text = (clientCoins).formatForDisplay();
                });
                _creditsFocusNode.unfocus();
              } else {
                setState(() {
                  _billToPay.coins = 0.00;
                  _ctrlCreditAmount.clear();
                });
                _creditsFocusNode.requestFocus();
              }
              print("_billToPay.coins: ${_billToPay.coins}");
            } else {
              return;
            }
          },
          title: Row(
            children: [
              Spacer(),
              new Text("Coins: "),
              new Text(
                '${(snapshot.connectionState == ConnectionState.waiting ? 0.00 : clientCoins).formatForDisplay(withCurrency: false)}',
                //style: TextStyle(fontSize: 14.0),
                textAlign: TextAlign.right,
              )
            ],
          ),
          controlAffinity: ListTileControlAffinity.trailing,
          activeColor: Colors.grey,
        );
      },
    );
  }

  Widget _getUsersDropdown() {
    return FormField<String>(builder: (FormFieldState<String> state) {
      return InputDecorator(
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.person, color: Colors.white),
            contentPadding: EdgeInsets.all(5),
            errorStyle: TextStyle(color: Colors.redAccent, fontSize: 16.0),
            hintText: 'Client',
            labelText: 'Client',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
        isEmpty: false, //_selectedUserId == '',
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedUserId.isNotEmpty
                ? _selectedUserId
                : _userProfiles.first?.id,
            isDense: true,
            hint: Text("Choose user..."),
            onChanged: (String? newValue) {
              setState(() {
                _selectedUserId = newValue!;
                _billToPay.userId = [_selectedUserId];
                _selectedUserProfile = _userProfiles.firstWhere(
                        (element) => element?.id == _selectedUserId) ??
                    UserProfile();
                state.didChange(newValue);
              });
              _getClientMeterReadings();
              _getBills();
              printIfDebugging("_selectedUser: $_selectedUserId");
            },
            items: _userProfiles
                .map(
                  (up) => DropdownMenuItem<String>(
                    value: up?.id,
                    child: new Text("${up?.name!}"),
                  ),
                )
                .toList(),
          ),
        ),
      );
    });

    // //StreamBuilder<QuerySnapshot>(
    //         stream: _ffInstance
    //             .collection('users')
    //             .where("deleted", isEqualTo: false)
    //             .orderBy("name")
    //             .snapshots(),
    //         builder: (context, snapshot) {
    //           if (!snapshot.hasData)
    //             return Center(child: CircularProgressIndicator());
    //           if (snapshot.connectionState == ConnectionState.waiting)
    //             return Center(child: CircularProgressIndicator());
    //           if (_selectedUserId.isEmpty && snapshot.data?.docs.length != 0) {
    //             _selectedUserId =
    //                 snapshot.data?.docs.first.id ?? _selectedUserId;
    //           }
    //           // if (snapshot.data?.docs.length != 0) {
    //           //   // if (_selectedUserId.isEmpty) {
    //           //   //   _selectedUserId =
    //           //   //       snapshot.data?.docs.first.id ??
    //           //   //           _selectedUserId;
    //           //   // }

    //           //   _userProfiles.clear();
    //           //   _userProfiles.addAll(snapshot.data?.docs
    //           //           .map((e) => UserProfile.fromJson(
    //           //               e.data()
    //           //                   as Map<String, dynamic>))
    //           //           .toList() ??
    //           //       []);
    //           //   // _selectedUserProfile = UserProfile.fromJson(
    //           //   //     snapshot.data?.docs
    //           //   //         .firstWhere((element) =>
    //           //   //             element.id == _selectedUserId)
    //           //   //         .data() as Map<String, dynamic>);
    //           // }
    //           return ;
    //         },
    //       )
  }

  Future<void> _getBills() async {
    num amount = 0.00;
    num rate = 0.00;
    num subtotal = 0.00;
    int currentRead = 0;
    String computation = "";
    num total = 0.00;
    List<Bill?> bills = [];
    List<String?>? billIds = [];

    try {
      _ffInstance
          .collection("bills")
          .where('payer_ids', arrayContains: _selectedUserId)
          .where("bill_type", whereIn: _billTypeIds)
          .where("bill_date",
              isGreaterThanOrEqualTo: _billsFrom.toIso8601String())
          .where("bill_date", isLessThanOrEqualTo: _billsTo.toIso8601String())
          .where("deleted", isEqualTo: true)
          //.orderBy("bill_type", descending: true)
          .get()
          .then((snapshots) {
        snapshots.docs.forEach((document) {
          Bill bill = Bill.fromJson(document.data());
          bill.id = document.id;
          bill.billType =
              _billTypes.firstWhere((b) => b?.id == bill.billTypeId.toString());
          bill.billTypeId = int.parse(bill.billType?.id ?? "");
          billIds.add(document.id);
          bills.add(bill);
        });
      }).whenComplete(() {
        bills.forEach((bill) {
          if (bill?.billType?.isdebit ?? false) {
            //"electricity"
            if (bill?.billTypeId == 6) {
              bill?.rate = num.parse(
                  ((bill.amount ?? 0) / (bill.quantification as num))
                      .toString());
              if (_readings.length != 0) {
                bill?.currentReading = _readings
                        .firstWhere((element) =>
                            element?.readingtype ==
                            6) // && element?.readingdate.month ==_billToPay.billdate.month
                        ?.reading ??
                    0;
              }
              bill?.amountToPay = bill.rate * bill.currentReading;
              bill?.computation =
                  "(${(bill.amount ?? 0)} / ${(bill.quantification as num)}kwH) * ${bill.currentReading}";
            }
            //"water"
            else if (bill?.billTypeId == 5) {
              bill?.rate = num.parse(
                  ((bill.amount ?? 0) / _loggedInUserprofile.members)
                      .toString());
              bill?.amountToPay = bill.rate * _selectedUserProfile.members;
              bill?.computation =
                  "(${(bill.amount ?? 0)} / ${_loggedInUserprofile.members} members) * ${_selectedUserProfile.members}";
            }
            subtotal += bill?.amountToPay ?? 0;
          } else {
            subtotal -= bill?.amount ?? 0;
          }
        });

        setState(() {
          _billToPay.billIds?.clear();
          _billToPay.billIds?.addAll(billIds);
          _billToPay.subtotal = subtotal;
          _bills.clear();
          _bills.addAll(bills);
        });

        printIfDebugging("bills: ${bills.toList()}");
      });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }

    // return Card(
    //   child:
    //     ListView(
    //         physics: const BouncingScrollPhysics(),
    //         shrinkWrap: true,
    //         children: bills.map((Bill bill) {
    //             CustomIconData cid = CustomIconData.fromJson(bill.billType?.iconData as Map<String, dynamic>);
    //             return ListTile(
    //                             dense: true,
    //                             minLeadingWidth: 0,
    //                             iconColor:  Color(billType?.iconData?.color ?? 0),
    //                             leading: Column(
    //                               mainAxisAlignment: MainAxisAlignment.center,
    //                               children: [
    //                                 Icon(
    //                                     IconData(
    //                                         billType?.iconData?.codepoint ?? 0,
    //                                         fontFamily: cid.fontfamily),
    //                                     color: Color(
    //                                         billType?.iconData?.color ?? 0),
    //                                     size: 28),
    //                               ],
    //                             ),
    //                             title: Text("${billType?.description}"),
    //                             //subtitle: Text('Created On: ${DateTime.fromMillisecondsSinceEpoch(data['created_on']).format()}'),
    //                             subtitle: Text("$_lastModified"),
    //                             trailing: Column(
    //                               crossAxisAlignment: CrossAxisAlignment.end,
    //                               mainAxisAlignment: MainAxisAlignment.center,
    //                               children: [
    //                                 Text(
    //                                   '${bill?.billDate!.formatDate(dateOnly: true)}',
    //                                   textAlign: TextAlign.right,
    //                                   style: TextStyle(
    //                                       fontSize: 13,
    //                                       fontWeight: FontWeight.w300),
    //                                 ),
    //                                 // Text(
    //                                 //     //${isDebit ? "-" : "+"}
    //                                 //     '${(isDebit ? amount : bill.amount!).formatForDisplay()}',
    //                                 //     textAlign: TextAlign.right,
    //                                 //     style: TextStyle(
    //                                 //         fontSize: 20,
    //                                 //         color: isDebit
    //                                 //             ? Colors.red.shade400
    //                                 //             : Colors.green.shade400)),
    //                                 Text(
    //                                   '$computation',
    //                                   textAlign: TextAlign.right,
    //                                   style: TextStyle(
    //                                       fontSize: 11,
    //                                       fontWeight: FontWeight.w300),
    //                                 ),
    //                               ],
    //                             ),
    //                             onTap: null,
    //                           ),
    //           }
    //         ),
    //       ],
    //     ),
    // );

    // return
    //                   children: snapshot.data!.docs.map(
    //                     (DocumentSnapshot document) {
    //                       Bill bill = Bill.fromJson(
    //                           document.data() as Map<String, dynamic>);
    //                       bill.id = document.id;
    //                       BillType? billType = _billTypes
    //                           .where((b) => b?.id == bill.billTypeId.toString())
    //                           .last;
    //                       CustomIconData cid = CustomIconData.fromJson(
    //                           billType?.iconData as Map<String, dynamic>);
    //                       String _lastModified = DateFormat('MMM dd, yyyy hh:mm aaa').format(bill.modifiedOn ?? bill.createdOn);
    //                       return Column(
    //                         crossAxisAlignment: CrossAxisAlignment.stretch,
    //                         mainAxisAlignment: MainAxisAlignment.start,
    //                         mainAxisSize: MainAxisSize.min,
    //                         children: [

    //                         ],
    //                       );
    //                     },
    //                   ).toList(),
    //                 ),
    //                 // ListTile(
    //                 //   dense: true,
    //                 //   title: Text("Previous Unpaid:"),
    //                 //   trailing: Text(
    //                 //       '${_previousBilling.totalPayment.formatForDisplay()}',
    //                 //       style: TextStyle(fontSize: 20)),
    //                 // ),
    //                 // ListTile(
    //                 //   dense: true,
    //                 //   title: Text("Subtotal:"),
    //                 //   trailing: Text('${subtotal.formatForDisplay()}',
    //                 //       style: TextStyle(fontSize: 20)),
    //                 // ),
    //               ],
    //             ),
    //           );
    //   },
    // );
  }

  Widget _getBillsList() {
    return _bills.length == 0
        ? Card(
            child: ListTile(
              dense: true,
              title: Text("No bills found."),
            ),
          )
        : Card(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              children: _bills
                  .map((bill) => ListTile(
                        dense: true,
                        minLeadingWidth: 0,
                        iconColor: Color(bill?.billType?.iconData?.color ?? 0),
                        leading: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                IconData(
                                    bill?.billType?.iconData?.codepoint ?? 0,
                                    fontFamily:
                                        bill?.billType?.iconData?.fontfamily),
                                color:
                                    Color(bill?.billType?.iconData?.color ?? 0),
                                size: 28),
                          ],
                        ),
                        title: Text("${bill?.billType?.description}"),
                        subtitle: Text(
                            "${(bill?.modifiedOn ?? bill?.createdOn)?.formatDate()}"),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${bill?.billDate!.formatDate(dateOnly: true)}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w300),
                            ),
                            Text(
                                "${((bill?.billType?.isdebit ?? false) ? bill?.amountToPay : bill?.amount)?.formatForDisplay()}",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: (bill?.billType?.isdebit ?? false)
                                        ? Colors.red.shade400
                                        : Colors.green.shade400)),
                            Text(
                              '${bill?.computation}',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w300),
                            ),
                          ],
                        ),
                        onTap: null,
                      ))
                  .toList(),
            ),
          );
  }

  Future<void> _getPreviousUnpaidAmount() async {
    Billing billing = Billing();
    try {
      _ffInstance
          .collection("billings")
          .where('user_id', arrayContains: _selectedUserId)
          .where("billing_date",
              isGreaterThanOrEqualTo: _previousMonthStart.toIso8601String())
          .where("billing_date",
              isLessThanOrEqualTo: _previousMonthEnd.toIso8601String())
          .limit(1)
          .get()
          .then((snapshots) {
        snapshots.docs.forEach((document) {
          billing = Billing.fromJson(document.data());
          billing.id = document.id;
        });
      }).whenComplete(() {
        setState(() {
          _previousBilling = billing;
          _billToPay.totalPayment =
              (_previousBilling.totalPayment ?? 0) + (_billToPay.subtotal ?? 0);
        });

        printIfDebugging("_previousBilling: $_previousBilling");
      });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  Widget _getTotals() {
    List<String>? billIds = [];
    Billing prevBilling = Billing();

    bool isDebit = false;
    num amount = 0.00;
    num rate = 0.00;
    num subtotal = 0.00;

    return Card(
      child: Container(
        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
        child: Column(
          children: [
            //Divider(height: 0),
            Row(
              children: [
                Text("Subtotal:"),
                Spacer(),
                Text("${_billToPay.subtotal?.formatForDisplay()}",
                    style: TextStyle(color: Colors.red.shade400))
              ],
            ),
            SizedBox(height: 3),
            Row(
              children: [
                Text("Previous Unpaid:"),
                Spacer(),
                Text("${_previousBilling.totalPayment?.formatForDisplay()}",
                    style: TextStyle(color: Colors.red.shade400))
              ],
            ),
            SizedBox(height: 3),
            Row(
              children: [
                Text(
                  "Total:",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                Spacer(),
                Text(
                  "${_billToPay.totalPayment?.formatForDisplay()}",
                  style: TextStyle(
                    fontSize: 20,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  _showProgressUi(bool isLoading, String msg) {
    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
    setState(() => _isLoading = isLoading);
  }

  printIfDebugging(String msg) {
    if (_isDebug) {
      print(msg);
    }
  }
}
