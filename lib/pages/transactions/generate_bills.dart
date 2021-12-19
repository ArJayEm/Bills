//import 'package:bills/helpers/functions/functions_global.dart';
import 'package:bills/helpers/functions/functions_global.dart';
import 'package:bills/models/bill_type.dart';
import 'package:bills/models/billing.dart';
import 'package:bills/models/bill.dart';
//import 'package:bills/models/coins.dart';
//import 'package:bills/models/icon_data.dart';
import 'package:bills/models/meter_readings.dart';
import 'package:bills/models/user_profile.dart';
//import 'package:bills/pages/components/custom_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
//import 'package:intl/intl.dart';

class GenerateBills extends StatefulWidget {
  const GenerateBills({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _GenerateBillsState createState() => _GenerateBillsState();
}

class _GenerateBillsState extends State<GenerateBills> {
  final String _title = "Generate Bills";

  //late final FirebaseAuth _auth;
  late final String _loggedInId;
  late String _selectedUserId;
  DateTime _billsFrom = DateTime.now();
  DateTime _billsTo = DateTime.now();
  DateTime _prevBillsFrom = DateTime.now();
  DateTime _prevBillsTo = DateTime.now();
  //bool _useCoins = false;
  final bool _isLoading = false;
  bool _isLoadingBills = false;
  //final bool _isToOverwriteExists = false;

  UserProfile _loggedInUserprofile = UserProfile();
  UserProfile _selectedUserProfile = UserProfile();
  final List<UserProfile?> _userProfiles = [];
  final Billing _billingCurrent = Billing();
  final Billing _billingPayment = Billing();
  final Billing _billingPrevious = Billing();
  //final Billing _previousUnpaidBilling = Billing();
  //Billing _previousBilling = Billing();
  final Billing _billingExisting = Billing();

  final List<Bill?> _billsCurrrent = [];
  final List<Bill?> _billsPayments = [];
  //final List<Bill?> _billsPrevious = [];
  final List<BillType?> _billTypes = [];
  final List<int> _billTypeIds = [];
  final List<int> _currrentBillTypeIds = [];
  final List<int> _paymentBillTypeIds = [];
  final List<Reading?> _readings = [];
  // final List<int> _debitBillTypeIds = [0];
  // final List<int> _creditBillTypeIds = [0];
  // List<Reading?> _currentReading = [];
  // List<Reading?> _previousReading = [];

  final _ctrlBillDate = TextEditingController();
  //final _ctrlCreditAmount = TextEditingController();

  //final FocusNode _creditsFocusNode = FocusNode();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _ffInstance = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadForm();
    if (kDebugMode) {
      print(_loggedInId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text(_title)),
      body: RefreshIndicator(
        onRefresh: _loadForm,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _getUsersDropdown(),
                        const SizedBox(height: 10),
                        _dateTimePicker(),
                        //const SizedBox(height: 10),
                        //_holoDatePicker(),
                        const SizedBox(height: 10),
                        TextButton(
                          child: const Text("Search",
                              style: TextStyle(fontSize: 18)),
                          style: TextButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              primary: Colors.grey.shade700,
                              backgroundColor: Colors.white),
                          onPressed: () async {
                            await _getBills();
                          },
                        ),
                        const SizedBox(height: 5),
                        _getCurrentBillsWidget(isdebit: true),
                        const SizedBox(height: 5),
                        _getCurrentBillsWidget(),
                        //_getTotals(),
                        const SizedBox(height: 10),
                        //_getCoinsWidget(),
                      ],
                    ),
                  ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        clipBehavior: Clip.hardEdge,
        elevation: 9.0,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: _isLoadingBills
            ? const Padding(
                padding: EdgeInsets.all(5),
                child: Center(
                    child: CircularProgressIndicator(), heightFactor: 1.5))
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        const Text("Subtotal:"),
                        const Spacer(),
                        Text(
                          "${_billingCurrent.subtotal?.formatForDisplay()}",
                          style: TextStyle(color: Colors.red.shade400),
                        ),
                      ],
                    ),
                    //SizedBox(height: 3),
                    Row(
                      children: [
                        const Text("Previous Unpaid:"),
                        const Spacer(),
                        Text(
                            "${_billingPrevious.totalPayment?.formatForDisplay()}",
                            style: TextStyle(color: Colors.red.shade400))
                      ],
                    ),
                    //SizedBox(height: 3),
                    Row(
                      children: [
                        const Text(
                          "Total:",
                          style: TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${_billingCurrent.totalPayment?.formatForDisplay()}",
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        )
                      ],
                    ),
                    if (_billingCurrent.totalPayment != 0)
                      const SizedBox(height: 10),
                    if (_billingCurrent.totalPayment != 0)
                      TextButton(
                        child: Text(
                            (_billingCurrent.id ?? "").isNotEmpty
                                ? "Update"
                                : "Generate",
                            style: const TextStyle(fontSize: 18)),
                        style: TextButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            primary: Colors.grey.shade700,
                            backgroundColor: Colors.white),
                        onPressed: _generateBilling,
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _loadForm() async {
    setState(() {
      //_auth = widget.auth;
      _loggedInId = widget.auth.currentUser!.uid;
      _selectedUserId = "";
      _billingCurrent.date = DateTime.now();
      _ctrlBillDate.text = _billingCurrent.date!
          .formatDate(dateOnly: true, fullMonth: true, hideDay: true);
      _billsFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
      _billsTo = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
    });
    await _getUsers();
    await _getBillTypes();
    await _getBills();
  }

  Future<void> _getBills() async {
    await _getReadings();
    await _getPaymentBills();
    await _getPreviousBilling();
    await _getExistingBilling();
    await _getCurrentBills();
  }

  Widget _dateTimePicker() {
    final DateTime firstdate = DateTime(DateTime.now().year - 2);
    final DateTime lastdate = DateTime.now();

    return TextFormField(
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.calendar_today, color: Colors.white),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
          contentPadding: const EdgeInsets.all(5),
          labelText: 'Bill Date',
          hintText: 'Bill Date'),
      controller: _ctrlBillDate,
      readOnly: true,
      onTap: () async {
        DateTime newDate = await DatePicker.showSimpleDatePicker(
              context,
              initialDate: _billingCurrent.date!,
              firstDate: firstdate,
              lastDate: lastdate,
              dateFormat: "MMMM-yyyy",
              locale: DateTimePickerLocale.en_us,
              looping: true,
            ) ??
            _billingCurrent.date ??
            DateTime.now();

        setState(() {
          _billingCurrent.date = newDate;
          _billingCurrent.date = newDate;
          _billsFrom = DateTime(newDate.year, newDate.month - 1, 16);
          _billsTo = DateTime(newDate.year, newDate.month, 15);
          _prevBillsFrom = DateTime(newDate.year, newDate.month - 1, 15);
          _prevBillsTo = DateTime(newDate.year, newDate.month, 14);
          // _billsFrom = DateTime(newDate.year, newDate.month, 1);
          // _billsTo = DateTime(newDate.year, newDate.month + 1, 0);
          // _prevBillsFrom = DateTime(newDate.year, newDate.month - 1, 1);
          // _prevBillsTo = DateTime(newDate.year, newDate.month, 0);
          _ctrlBillDate.text = newDate.formatDate(
              dateOnly: true, fullMonth: true, hideDay: true);
        });

        // var date = await showDatePicker(
        //   context: context,
        //   initialDate: _billToPay.billingDate!,
        //   firstDate: _firstdate,
        //   lastDate: _lastdate,
        //   //initialDatePickerMode: DatePickerMode.year
        // );
        // if (date != null) {
        //   setState(() {
        //     _billToPay.billingDate = DateTime(date.year, date.month, date.day);
        //     _billsFrom = DateTime(date.year, date.month, 1);
        //     _billsTo = DateTime(date.year, date.month + 1, 0);
        //     _ctrlBillDate.text =
        //         date.formatDate(dateOnly: true, fullMonth: true, hideDay: true);
        //   });
        // }
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
    //List<int> debitBillTypeIds = [];
    //List<int> creditBillTypeIds = [];
    List<int> currrentBillTypeIds = [];
    List<int> paymentBillTypeIds = [];

    setState(() {
      _isLoadingBills = true;
    });
    try {
      _ffInstance
          .collection("bill_types")
          //.where("is_debit", isEqualTo: true)
          //.orderBy("is_debit", descending: true)
          .get()
          .then((snapshots) {
        for (var document in snapshots.docs) {
          BillType? b = BillType.fromJson(document.data());
          b.id = document.id;

          int bId = int.parse(document.id);
          // if (b.isdebit ?? false) {
          //   debitBillTypeIds.add(int.parse(document.id));
          // } else {
          //   creditBillTypeIds.add(int.parse(document.id));
          // }
          if (b.includeInBilling ?? false) {
            currrentBillTypeIds.add(bId);
          } else {
            paymentBillTypeIds.add(bId);
          }

          billTypeIds.add(bId);
          billTypes.add(b);
        }
      }).whenComplete(() {
        setState(() {
          _billTypes.clear();
          _billTypeIds.clear();
          _currrentBillTypeIds.clear();
          _paymentBillTypeIds.clear();
          //_debitBillTypeIds.clear();
          _billTypes.addAll(billTypes);
          _billTypeIds.addAll(billTypeIds);
          _currrentBillTypeIds.addAll(currrentBillTypeIds);
          _paymentBillTypeIds.addAll(paymentBillTypeIds);
          //_debitBillTypeIds.addAll(debitBillTypeIds);
          //_creditBillTypeIds.addAll(creditBillTypeIds);
        });

        if (kDebugMode) {
          print("_billTypes: $_billTypes");
        }
      });
    } on FirebaseAuthException catch (e) {
      _isLoading.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoading.updateProgressStatus(errMsg: "$e.");
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
        for (var document in snapshots.docs) {
          UserProfile up = UserProfile.fromJson(document.data());
          up.id = document.id;
          ups.add(up);
        }

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
        if (kDebugMode) {
          print("_userProfiles: ${_userProfiles.toList()}");
        }
      }).whenComplete(() {});
    } on FirebaseAuthException catch (e) {
      _isLoading.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoading.updateProgressStatus(errMsg: "$e.");
    }
  }

  Future<void> _getReadings() async {
    List<Reading> readings = [];
    List<String?> readingIds = [];

    try {
      _ffInstance
          .collection("meter_readings")
          .where("userid_deleted", arrayContains: "${_selectedUserId}_0")
          .where("reading_type", whereIn: _currrentBillTypeIds)
          //.where("deleted", isEqualTo: false)
          //.where("user_ids", arrayContains: _selectedUserId)
          .where("reading_date",
              isGreaterThanOrEqualTo:
                  _billsFrom.toIso8601String()) //_prevBillsFrom
          .where("reading_date",
              isLessThanOrEqualTo: _billsTo.toIso8601String())
          .orderBy("reading_date", descending: true)
          // .limit(2)
          .get()
          .then((snapshots) {
        for (var doc in snapshots.docs) {
          Reading r = Reading.fromJson(doc.data());
          r.id = doc.id;
          readingIds.add(doc.id);
          readings.add(r);
        }
      }).whenComplete(() {
        setState(() {
          _readings.clear();
          _billingCurrent.readingIds.clear();
          _readings.addAll(readings);
          _billingCurrent.readingIds.addAll(readingIds);
        });

        if (_readings.isEmpty) {
          String msg = "No Readings found.";
          if (kDebugMode) {
            print("Meter Readings error: $msg");
          }
          Fluttertoast.showToast(msg: msg);
        } else {
          if (kDebugMode) {
            print("${_readings.toList()}");
          }
        }
      });
    } on FirebaseAuthException catch (e) {
      _isLoading.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoading.updateProgressStatus(errMsg: "$e.");
    }
  }

  // Widget _getCoinsWidget() {
  //   return StreamBuilder<QuerySnapshot>(
  //     stream: _ffInstance
  //         .collection("coins")
  //         .where("payerid_deleted", isEqualTo: "${_selectedUserId}_0")
  //         .orderBy('created_on', descending: true)
  //         .snapshots(),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasError) {
  //         String msg = snapshot.error.toString();
  //         if (kDebugMode) {
  //           print("coins error: $msg");
  //         }
  //         Fluttertoast.showToast(msg: "Unable to get coins.");
  //       }
  //       num clientCoins = 0.00;
  //       //if (_selectedUserId.isNotEmpty) {
  //       for (var doc in snapshot.data!.docs) {
  //         Coins c = Coins.fromJson(doc.data() as Map<String, dynamic>);
  //         clientCoins += c.amount ?? 0;
  //       }
  //       //}
  //       return CheckboxListTile(
  //         contentPadding: EdgeInsets.zero,
  //         dense: true,
  //         value: _useCoins,
  //         onChanged: (val) {
  //           if (clientCoins > 0) {
  //             setState(() {
  //               _useCoins = val!;
  //             });
  //             if (_useCoins) {
  //               setState(() {
  //                 _billingToPay.coins = clientCoins;
  //                 _ctrlCreditAmount.text = (clientCoins).formatForDisplay();
  //               });
  //               _creditsFocusNode.unfocus();
  //             } else {
  //               setState(() {
  //                 _billingToPay.coins = 0.00;
  //                 _ctrlCreditAmount.clear();
  //               });
  //               _creditsFocusNode.requestFocus();
  //             }
  //             if (kDebugMode) {
  //               print("_billToPay.coins: ${_billingToPay.coins}");
  //             }
  //           } else {
  //             return;
  //           }
  //         },
  //         title: Row(
  //           children: [
  //             const Spacer(),
  //             const Text("Coins: "),
  //             Text(
  //               (snapshot.connectionState == ConnectionState.waiting
  //                       ? 0.00
  //                       : clientCoins)
  //                   .formatForDisplay(withCurrency: false),
  //               //style: TextStyle(fontSize: 14.0),
  //               textAlign: TextAlign.right,
  //             )
  //           ],
  //         ),
  //         controlAffinity: ListTileControlAffinity.trailing,
  //         activeColor: Colors.grey,
  //       );
  //     },
  //   );
  // }

  Widget _getUsersDropdown() {
    return FormField<String>(builder: (FormFieldState<String> state) {
      return InputDecorator(
        decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person, color: Colors.white),
            contentPadding: const EdgeInsets.all(5),
            errorStyle:
                const TextStyle(color: Colors.redAccent, fontSize: 16.0),
            hintText: 'User',
            labelText: 'User',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(5.0))),
        isEmpty: false, //_selectedUserId == '',
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedUserId.isNotEmpty
                ? _selectedUserId
                : _userProfiles.first?.id,
            isDense: true,
            hint: const Text("Choose user..."),
            onChanged: (String? newValue) async {
              setState(() {
                _selectedUserId = newValue!;
                _billingCurrent.userId = [_selectedUserId];
                _selectedUserProfile = _userProfiles.firstWhere(
                        (element) => element?.id == _selectedUserId) ??
                    UserProfile();
                state.didChange(newValue);
              });
              //await getBills();
              if (kDebugMode) {
                print("_selectedUser: $_selectedUserId");
              }
            },
            items: _userProfiles
                .map(
                  (up) => DropdownMenuItem<String>(
                    value: up?.id,
                    child: Text("${up?.name!}"),
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

  Future<void> _getCurrentBills() async {
    num subtotal = 0.00;
    List<Bill?> bills = [];
    List<String?>? billIds = [];

    try {
      _ffInstance
          .collection("bills")
          .where('payer_ids', arrayContains: _selectedUserId)
          .where("bill_type", whereIn: _currrentBillTypeIds)
          //.where("bill_type", whereNotIn: [1])
          .where("bill_date",
              isGreaterThanOrEqualTo: _billsFrom.toIso8601String())
          .where("bill_date", isLessThanOrEqualTo: _billsTo.toIso8601String())
          .get()
          .then((snapshots) {
        for (var document in snapshots.docs) {
          Bill bill = Bill.fromJson(document.data());
          bill.id = document.id;
          bill.billType =
              _billTypes.firstWhere((b) => b?.id == bill.billTypeId.toString());
          bill.billTypeId = int.parse(bill.billType?.id ?? "");

          bills.add(bill);
          billIds.add(document.id);
        }

        for (var bill in bills) {
          if (bill?.billType?.isdebit ?? false) {
            //"electricity"
            if (bill?.billTypeId == 6) {
              bill?.rate = num.parse(
                  ((bill.amount ?? 0) / (bill.quantification as num))
                      .toString());
              if (_readings.isNotEmpty) {
                bill?.currentReading = _readings
                        .firstWhere((element) => element?.type == 6)
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
        }
      }).whenComplete(() {
        setState(() {
          _billingCurrent.billIds.clear();
          _billingCurrent.billIds.addAll(billIds);
          _billingCurrent.subtotal = subtotal;
          _billingCurrent.totalPayment =
              (_billingPrevious.totalPayment ?? 0) + subtotal;
          _billsCurrrent.clear();
          _billsCurrrent.addAll(bills);
          _isLoadingBills = false;
        });

        if (kDebugMode) {
          //print("bills: ${bills.toList()}");
        }
      });
    } on FirebaseAuthException catch (e) {
      _isLoading.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoading.updateProgressStatus(errMsg: "$e.");
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

  Widget _getCurrentBillsWidget({bool isdebit = false}) {
    //List<Bill?> bills = isdebit ? _bills : _previousPayments;
    return _billsCurrrent.isEmpty
        ? const Card(
            child: ListTile(
              dense: true,
              title: Text("No bills found."),
            ),
          )
        : _isLoadingBills
            ? const Card(
                child: ListTile(
                  dense: true,
                  title: Center(child: CircularProgressIndicator()),
                ),
              )
            : Card(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  children: <Widget>[
                    //if (!isdebit)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      child: ListTile(
                        tileColor: isdebit
                            ? Colors.red.shade400
                            : Colors.green.shade400,
                        dense: true,
                        title: Text(isdebit ? "Debits" : "Credits",
                            style: const TextStyle(fontSize: 16)),
                        trailing: isdebit
                            ? null
                            : const Text(
                                "(Payments will reflect on next month's billing.)",
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w300),
                              ),
                      ),
                    ),
                    if (!isdebit) const Divider(height: 0),
                    ..._billsCurrrent
                        .where(
                            (element) => element?.billType?.isdebit == isdebit)
                        .map((bill) => ListTile(
                              //dense: true,
                              minLeadingWidth: 0,
                              iconColor:
                                  Color(bill?.billType?.iconData?.color ?? 0),
                              leading: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                      IconData(
                                          bill?.billType?.iconData?.codepoint ??
                                              0,
                                          fontFamily: bill
                                              ?.billType?.iconData?.fontfamily),
                                      color: Color(
                                          bill?.billType?.iconData?.color ?? 0),
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
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w300),
                                  ),
                                  Text(
                                      "${((isdebit) ? bill?.amountToPay : bill?.amount)?.formatForDisplay()}",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: (isdebit)
                                              ? Colors.red.shade400
                                              : Colors.green.shade400)),
                                  if (isdebit)
                                    Text(
                                      '${bill?.computation}',
                                      textAlign: TextAlign.right,
                                      style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w300),
                                    ),
                                ],
                              ),
                              onTap: null,
                            ))
                        .toList(),
                  ],
                ),
              );
  }

  Future<void> _getPaymentBills() async {
    num subtotal = 0.00;
    List<Bill?> bills = [];
    List<String?>? billIds = [];

    //Get bills and payments from last month to get unpaid amount

    try {
      _ffInstance
          .collection("bills")
          .where('payer_ids', arrayContains: _selectedUserId)
          .where("bill_type", whereIn: _paymentBillTypeIds)
          .where("bill_date",
              isGreaterThanOrEqualTo: _prevBillsFrom.toIso8601String())
          .where("bill_date",
              isLessThanOrEqualTo: _prevBillsTo.toIso8601String())
          .get()
          .then((snapshots) {
        for (var document in snapshots.docs) {
          Bill bill = Bill.fromJson(document.data());
          bill.id = document.id;
          bill.billType =
              _billTypes.firstWhere((b) => b?.id == bill.billTypeId.toString());
          bill.billTypeId = int.parse(bill.billType?.id ?? "0");

          bills.add(bill);
          billIds.add(document.id);

          // if (bill.billType?.isdebit ?? false) {
          subtotal += bill.amount ?? 0;
          // } else {
          //   subtotal -= bill.amount ?? 0;
          // }
        }
      }).whenComplete(() {
        setState(() {
          _billsPayments.clear();
          _billingCurrent.paymentIds.clear();
          _billsPayments.addAll(bills);
          _billingCurrent.paymentIds.addAll(billIds);
          _billingPayment.subtotal = subtotal;
          _billingPayment.totalPayment = subtotal;
          _isLoadingBills = false;
        });
      });
    } on FirebaseAuthException catch (e) {
      _isLoading.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoading.updateProgressStatus(errMsg: "$e.");
    }
  }

  Future<void> _getPreviousBilling() async {
    Billing prevBilling = Billing();

    try {
      _ffInstance
          .collection("billings")
          .where('user_id', arrayContains: _selectedUserId)
          .where("billing_date",
              isGreaterThanOrEqualTo: _prevBillsFrom.toIso8601String())
          .where("billing_date",
              isLessThanOrEqualTo: _prevBillsTo.toIso8601String())
          .limit(1)
          .get()
          .then((snapshots) {
        for (var document in snapshots.docs) {
          prevBilling = Billing.fromJson(document.data());
          prevBilling.id = document.id;
        }
      }).whenComplete(() {
        setState(() {
          _billingPrevious.id = prevBilling.id;
          _billingPrevious.subtotal = prevBilling.subtotal;
          _billingPrevious.totalPayment = prevBilling.totalPayment;
        });
      });
    } on FirebaseAuthException catch (e) {
      _isLoading.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      setState(() {
        _isLoading.updateProgressStatus(errMsg: "$e.");
      });
    }
  }

  Future<void> _getExistingBilling() async {
    Billing existingBilling = Billing();

    try {
      _ffInstance
          .collection("billings")
          .where('user_id', arrayContains: _selectedUserId)
          .where("billing_date",
              isGreaterThanOrEqualTo: _billsFrom.toIso8601String())
          .where("billing_date",
              isLessThanOrEqualTo: _billsTo.toIso8601String())
          .limit(1)
          .get()
          .then((snapshots) {
        for (var document in snapshots.docs) {
          //existingBilling = Billing.fromJson(document.data());
          existingBilling.id = document.id;
        }
      }).whenComplete(() {
        setState(() {
          _billingExisting.id = existingBilling.id;
          //_billingExisting = existingBilling;
          //_billingExisting.subtotal = existingBilling.subtotal;
          //_billingExisting.totalPayment = existingBilling.totalPayment;
        });

        if (kDebugMode) {
          if (existingBilling.id?.isNotEmpty ?? false) {
            _isLoadingBills.updateProgressStatus(
                msg: "Billing with same Month and Year already exists!");
            print("existingBilling id: ${existingBilling.id}");
          }
        }
      });
    } on FirebaseAuthException catch (e) {
      _isLoading.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      setState(() {
        _isLoading.updateProgressStatus(errMsg: "$e.");
      });
    }
  }

  Future<void> _generateBilling() async {
    _isLoading.updateProgressStatus(msg: "Saving...");

    if (_formKey.currentState!.validate()) {
      try {
        CollectionReference collection = _ffInstance.collection("billings");
        if (_billingCurrent.id.isNullOrEmpty()) {
          _billingCurrent.createdBy = _loggedInId;
          var data = _billingCurrent.toJson();
          collection.add(data).then((document) {
            _isLoading.updateProgressStatus(msg: "Billing saved!");
          }).catchError((error) {
            _isLoading.updateProgressStatus(
                msg: "Failed to add billing.", errMsg: error);
          });
        } else {
          _billingCurrent.modifiedBy = _loggedInId;
          _billingCurrent.modifiedOn = DateTime.now();
          collection
              .doc(_billingCurrent.id)
              .update(_billingCurrent.toJson())
              .then((document) {
            _isLoading.updateProgressStatus(msg: "Billing updated!");
          }).catchError((error) {
            _isLoading.updateProgressStatus(
                msg: "Failed to update billing.", errMsg: error);
          });
        }
        //Generate PDF report
        //save in Firebase Storage, viewable and downloadable file
      } on FirebaseAuthException catch (e) {
        _isLoading.updateProgressStatus(errMsg: "${e.message}.");
      } catch (e) {
        _isLoading.updateProgressStatus(errMsg: "$e.");
      }
    }
  }
}
