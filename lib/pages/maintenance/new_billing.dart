// ignore_for_file: prefer_final_fields

import 'dart:io';
import 'package:bills/helpers/functions/functions_global.dart';
import 'package:bills/helpers/values/strings.dart';
import 'package:bills/models/bill_type.dart';
import 'package:bills/models/billing.dart';
import 'package:bills/models/bill.dart';
import 'package:bills/models/coins.dart';
import 'package:bills/models/meter_readings.dart';
import 'package:bills/models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:print_color/print_color.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

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
  String? _hasBillingExistingText = "";
  String? _hasBillingExistingTextOld = "";
  bool _isEdit = false;
  bool _isLoading = false;
  bool _isLoadingBills = false;
  bool _isLoadingCoins = false;
  bool _hasBillingExists = false;
  bool _hasCoins = false;
  bool _useCoins = false;

  UserProfile _loggedInUserprofile = UserProfile();
  UserProfile _selectedUserProfile = UserProfile();
  final List<UserProfile?> _userProfiles = [];
  Billing _billingCurrent = Billing();
  Billing _billingPayment = Billing();
  Billing _billingPrevious = Billing();
  Billing _billingExisting = Billing();
  Coins _coins = Coins();

  final List<Bill?> _billsCurrrent = [];
  final List<BillType?> _billTypes = [];
  final List<int> _billTypeIds = [];
  final List<int> _currrentBillTypeIds = [];
  final List<int> _paymentBillTypeIds = [];
  final List<Reading?> _readings = [];

  final _ctrlBillDate = TextEditingController();
  //final _ctrlCreditAmount = TextEditingController();

  //final FocusNode _creditsFocusNode = FocusNode();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _ffInstance = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _fsInstance =
      firebase_storage.FirebaseStorage.instance;
  @override
  void initState() {
    super.initState();
    setState(() {
      //_auth = widget.auth;
      _loggedInId = widget.auth.currentUser!.uid;
      _selectedUserId = "";
      _billingCurrent.date = DateTime.now();
      _ctrlBillDate.text = _billingCurrent.date!.format(dateOnly: true);
      _billsFrom = DateTime(DateTime.now().year, DateTime.now().month, 1);
      _billsTo = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
    });
    _loadForm();
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
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildUsersDropdown(),
                        const SizedBox(height: 10),
                        _dateTimePicker(),
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
                            setState(
                              () {
                                _isEdit = false;
                              },
                            );
                          },
                        ),
                        //const SizedBox(height: 5),
                        //_getCurrentBillsWidget(isdebit: true),
                        const SizedBox(height: 5),
                        _getCurrentBillsWidget(),
                        _getSubtotal(),
                        if (_hasCoins) _getCoinsWidget(),
                        TextButton(
                          child: const Text('Generate PDF'),
                          style: TextButton.styleFrom(
                              minimumSize: const Size(double.infinity, 40),
                              primary: Colors.grey.shade800,
                              backgroundColor: Colors.white),
                          onPressed: () {
                            if (_billingCurrent.totalPayment != 0.0) {
                              _generatePdf(_billsCurrrent);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
            clipBehavior: Clip.hardEdge,
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
            : _getTotals(),
      ),
    );
  }

  Future<void> _loadForm() async {
    setState(() {
      _isLoading = true;
    });
    await _getBills();
  }

  Future<void> _getBills() async {
    if (kDebugMode) {
      print(_loggedInId);
    }
    setState(() {
      _coins.amount = 0.0;
      _isLoadingBills = true;
      _billsCurrrent.clear();
      _billingCurrent.id = null;
      //_billingCurrent = Billing();
      _billingCurrent.totalPayment = 0.00;
    });
    await _getUsers();
    await _getBillTypes();
    await _getReadings();
    await _getPaymentBills();
    await _getCoins();
    await _getPreviousBilling();
    await _getExistingBilling();
    //await _getCurrentBills();
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
              dateFormat: holoDateFormat,
              locale: DateTimePickerLocale.en_us,
              looping: true,
            ) ??
            _billingCurrent.date ??
            DateTime.now();

        setState(() {
          _billingCurrent.date = newDate;
          _billingCurrent.date = newDate;
          int dueMonth = newDate.month + 1;
          int dueYear = (newDate.month == 13 ? 1 : 0) + newDate.year;
          dueMonth = dueMonth == 13 ? 1 : dueMonth;
          _billsFrom = DateTime(newDate.year, newDate.month - 1, 16);
          _billsTo = DateTime(newDate.year, newDate.month, 16);
          _prevBillsFrom = DateTime(newDate.year, newDate.month - 1, 15);
          _prevBillsTo = DateTime(newDate.year, newDate.month, 15);
          _billingCurrent.dueDate = DateTime(dueYear, dueMonth, 15);
          _billingCurrent.billingFrom = _billsFrom;
          _billingCurrent.billingTo = _prevBillsTo;
          _billingCurrent.billingPeriod =
              "${_billsFrom.formatToMonthDay()} to ${_prevBillsTo.formatToMonthDay()}";
          _ctrlBillDate.text = newDate.format(dateOnly: true);
        });
      },
    );
  }

  Future<void> _getBillTypes() async {
    List<BillType?> billTypes = [];
    List<int> billTypeIds = [];
    List<int> currrentBillTypeIds = [];
    List<int> paymentBillTypeIds = [];
    try {
      _ffInstance
          .collection("bill_types")
          //.where("is_debit", isEqualTo: true)
          .orderBy("is_debit", descending: false)
          .get()
          .then((snapshots) {
        for (var document in snapshots.docs) {
          BillType? b = BillType.fromJson(document.data());
          b.id = document.id;
          int bId = int.parse(b.id!);
          if (b.includeInBilling ?? false) {
            currrentBillTypeIds.add(bId);
          } else {
            if (b.isCredit ?? false) {
              paymentBillTypeIds.add(bId);
            }
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
          _billTypes.addAll(billTypes);
          _billTypeIds.addAll(billTypeIds);
          _currrentBillTypeIds.addAll(currrentBillTypeIds);
          _paymentBillTypeIds.addAll(paymentBillTypeIds);
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
    String id = "";
    try {
      _ffInstance
          .collection("users")
          .where("deleted", isEqualTo: false)
          .orderBy("name")
          .get()
          .then((snapshots) {
        for (var document in snapshots.docs) {
          UserProfile up = UserProfile.fromJson(document.data());
          up.id = document.id;
          id = document.id;
          ups.add(up);
        }
      }).catchError((onError) {
        _isLoading.updateProgressStatus(errMsg: "${onError.toString()}: $id.");
      }).whenComplete(() {
        setState(() {
          _userProfiles.clear();
          _userProfiles.addAll(ups);
          if (_selectedUserId.isEmpty) {
            _selectedUserId = "${_userProfiles.first?.id}";
          } else {
            _selectedUserId = _selectedUserId;
          }
          //_selectedUserId = _userProfiles.first?.id ?? _selectedUserId;
          _selectedUserProfile = _userProfiles
                  .firstWhere((element) => element?.id == _selectedUserId) ??
              UserProfile();
          _loggedInUserprofile = _userProfiles
                  .firstWhere((element) => element?.id == _loggedInId) ??
              UserProfile();
        });
        printIfDebug(_userProfiles.toList(), desc: "_userProfiles: ");
      });
    } on FirebaseAuthException catch (e) {
      _isLoading.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoading.updateProgressStatus(errMsg: "$e.");
    }
  }

  Future<void> _getReadings() async {
    List<Reading> readings = [];
    List<String?> readingIds = [];

    setState(() {
      _isLoadingBills = true;
    });

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
          r.billType =
              _billTypes.firstWhere((e) => int.parse(e?.id ?? "0") == r.type);
          r.id = doc.id;
          readingIds.add(doc.id);
          readings.add(r);
        }
      }).whenComplete(() {
        setState(() {
          _readings.clear();
          _readings.addAll(readings);
          _billingCurrent.readingIds.clear();
          _billingCurrent.readingIds.addAll(readingIds);
          _isLoadingBills = false;
        });

        if (_readings.isEmpty) {
          String msg = "No Readings found.";
          _isLoadingBills.updateProgressStatus(msg: "$msg.");
        }
      });
    } on FirebaseAuthException catch (e) {
      _isLoadingBills.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoadingBills.updateProgressStatus(errMsg: "$e.");
    }
  }

  Widget _buildUsersDropdown() {
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
  }

  Future<void> _getPaymentBills() async {
    num subtotal = 0.00;
    List<Bill?> bills = [];
    List<String?> billIds = [];
    setState(() {
      _isLoadingBills = true;
    });

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
          subtotal += bill.amount;
          // } else {
          //   subtotal -= bill.amount ?? 0;
          // }
        }
      }).whenComplete(() {
        setState(() {
          //_billsCurrrent.clear();
          if (kDebugMode) {
            _billsCurrrent.addAll(bills);
          }
          //_billsPayments.clear();
          //_billsPayments.addAll(bills);
          _billingCurrent.paymentIds.clear();
          _billingCurrent.paymentIds.addAll(billIds);
          _billingPayment.subtotal = subtotal;
          _billingPayment.totalPayment = subtotal;
          _isLoadingBills = false;
        });
      });
    } on FirebaseAuthException catch (e) {
      _isLoadingBills.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoadingBills.updateProgressStatus(errMsg: "$e.");
    }
  }

  Future<void> _getPreviousBilling() async {
    Billing prevBilling = Billing();
    setState(() {
      _isLoadingBills = true;
    });

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
        num prevBillingTotal = 0.00;
        num coins = 0.00;
        if (prevBilling.totalPayment.roundTenths() >
            _billingPayment.totalPayment.roundTenths()) {
          prevBillingTotal =
              prevBilling.totalPayment - _billingPayment.totalPayment;
        } else {
          coins = _billingPayment.totalPayment - prevBilling.totalPayment;
        }
        setState(() {
          _billingPrevious = prevBilling;
          // _billingPrevious.id = prevBilling.id;
          // _billingPrevious.subtotal = prevBilling.subtotal;
          _billingPrevious.totalPayment = prevBillingTotal;
          _isLoadingBills = false;
        });

        Print.green(
            "_billsFrom: $_billsFrom, _billsTo: $_billsTo, _prevBillsFrom: $_prevBillsFrom, _prevBillsTo: $_prevBillsTo.");
        Print.green(
            "last payment: ${_billingPayment.totalPayment.formatForDisplay()}");

        setState(() {
          _hasCoins = coins.roundTenths() > 0.00;
          _useCoins = false; // coins > 0.00;
          _coins.amount = (coins.isNegative ? -1 : 1) * coins;
          _coins.totalAmount = _coins.amount;
        });
        if (kDebugMode) {
          Print.green(
              "_hasCoins: $_hasCoins ${_coins.amount.roundTenths().formatForDisplay()}");
        }
        _getCurrentBills();
      });
    } on FirebaseAuthException catch (e) {
      _isLoadingBills.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      setState(() {
        _isLoadingBills.updateProgressStatus(errMsg: "$e.");
      });
    }
  }

  void _computeCoins() {
    if (_useCoins) {
      if (_coins.amount > _billingCurrent.totalPayment) {
        setState(() {
          _coins.totalAmount = _coins.amount - _billingCurrent.totalPayment;
          _coins.amount = _coins.amount - _coins.totalAmount;
          _billingCurrent.totalPayment = 0.00;
        });
      } else {
        setState(() {
          _billingCurrent.totalPayment =
              _billingCurrent.totalPayment - _coins.amount;
          _billingCurrent.coins = _coins.amount;
          //_coins.totalAmount = 0.00;
        });
      }
      //_creditsFocusNode.unfocus();
    } else {
      if (_coins.amount > _billingCurrent.totalPayment) {
        setState(() {
          _coins.amount = _coins.amount + _coins.totalAmount;
          _coins.totalAmount = _coins.amount;
          _billingCurrent.totalPayment =
              _billingPrevious.totalPayment + _billingCurrent.subtotal;
          _billingCurrent.coins = 0.00;
          //_ctrlCreditAmount.clear();
        });
        //_creditsFocusNode.requestFocus();
      } else {
        _billingCurrent.totalPayment = _billingCurrent.subtotal;
      }
    }

    hasBillingExistingState();
  }

  Future<void> _getExistingBilling() async {
    Billing existingBilling = Billing();
    bool hasBillingExists = false;
    setState(() {
      _isLoadingBills = true;
    });

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
          existingBilling = Billing.fromJson(document.data());
          existingBilling.id = document.id;
          existingBilling.subtotal = existingBilling.subtotal;
          existingBilling.totalPayment = existingBilling.totalPayment;
          hasBillingExists = true;
        }
      }).whenComplete(() {
        setState(() {
          _billingExisting = existingBilling;
          _hasBillingExists = hasBillingExists;
          //_billingExisting = existingBilling;
          //_billingExisting.subtotal = existingBilling.subtotal;
          //_billingExisting.totalPayment = existingBilling.totalPayment;
        });

        if (kDebugMode) {
          if (_hasBillingExists) {
            _billingCurrent.id = _billingExisting.id;
            _isLoadingBills.updateProgressStatus(
                msg: "Billing with same Month and Year already exists!");
            _hasBillingExistingText =
                " ${_billingExisting.date?.format(dateOnly: true)} Billing (${_billingExisting.totalPayment.formatForDisplay()})";
            _hasBillingExistingTextOld = _hasBillingExistingText;
          }
        }
        //_setCoinsState();
      });
    } on FirebaseAuthException catch (e) {
      _isLoadingBills.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      setState(() {
        _isLoadingBills.updateProgressStatus(errMsg: "$e.");
      });
    }
  }

  Future<void> _getCurrentBills() async {
    num creditSubtotal = 0.00;
    //num debitSubtotal = 0.00;
    List<Bill?> bills = [];
    List<String?> creditBillIds = [];
    //List<String?> debitBillIds = [];
    Map<String, dynamic> c;
    List<Map<String, dynamic>> computations = [];
    setState(() {
      _isLoadingBills = true;
    });

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

          if (bill.billType?.isdebit ?? false) {
            //"electricity"
            if (bill.billTypeId == 6) {
              bill.rate =
                  num.parse((bill.amount / bill.quantification).toString());
              if (_readings.isNotEmpty) {
                bill.currentReading = _readings
                        .firstWhere((element) => element?.type == 6)
                        ?.reading ??
                    0;
              }
              bill.amountToPay = bill.rate * bill.currentReading;
              bill.computation =
                  "(${bill.amount} / ${bill.quantification} kwH) * ${bill.currentReading}";
            }
            //"water"
            else if (bill.billTypeId == 5) {
              int allMembers = _loggedInUserprofile.membersArr
                  .firstWhere((element) => _billsTo
                      .isBefore(element.effectivityEnd ?? DateTime.now()))
                  .count;
              int members = _selectedUserProfile.membersArr
                  .firstWhere((element) => _billsTo
                      .isBefore(element.effectivityEnd ?? DateTime.now()))
                  .count;
              bill.rate = num.parse((bill.amount / allMembers).toString());
              bill.amountToPay = bill.rate * members;
              bill.computation =
                  "(${bill.amount} / $allMembers members) * $members";
            }

            creditSubtotal += bill.amountToPay;
            c = {"id": bill.id, "computation": bill.computation};
            computations.add(c);
          } else {
            creditSubtotal -= bill.amount;
          }

          creditBillIds.add(bill.id);
          bills.add(bill);
        }
      }).whenComplete(() {
        // for (var bill in bills) { else {
        //     creditSubtotal -= (bill?.amountToPay ?? 0);
        //     //debitBillIds.add(bill?.id);
        //     //debitSubtotal -= bill?.amount ?? 0;
        //   }
        // }

        setState(() {
          _billsCurrrent.clear();
          _billsCurrrent.addAll(bills);
          _billingCurrent.billIds.clear();
          _billingCurrent.billIds.addAll(creditBillIds);
          //_billingCurrent.paymentIds.clear();
          //_billingCurrent.paymentIds.addAll(debitBillIds);
          _billingCurrent.computations.clear();
          _billingCurrent.computations.addAll(computations);

          // _billingPayment.subtotal = debitSubtotal;
          // _billingPayment.totalPayment = debitSubtotal;

          // _billingPrevious.totalPayment =
          //     (_billingPrevious.totalPayment - (_billingPayment.totalPayment ?? 0);

          _billingCurrent.subtotal = creditSubtotal;
          _billingCurrent.totalPayment =
              _billingPrevious.totalPayment + creditSubtotal;

          _isLoadingBills = false;
        });

        hasBillingExistingState();

        if (kDebugMode) {
          //print("bills: ${bills.toList()}");
        }
      });
    } on FirebaseAuthException catch (e) {
      _isLoadingBills.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoadingBills.updateProgressStatus(errMsg: "$e.");
    }

    setState(() {
      _isLoading = false;
    });
  }

  void hasBillingExistingState() {
    if (_billingCurrent.totalPayment.roundTenths() ==
        _billingExisting.totalPayment.roundTenths()) {
      setState(() {
        _hasBillingExists = false;
        _isEdit = true;
        _hasBillingExistingText = "";
      });
    } else {
      setState(() {
        _hasBillingExists = true;
        _isEdit = false;
        _hasBillingExistingText = _hasBillingExistingTextOld;
      });
    }
    // _hasBillingExists =
    //     !(_billingCurrent.totalPayment == _billingExisting.totalPayment);
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
                    ..._billsCurrrent
                        //.where((element) => element?.billType?.isdebit == isdebit)
                        .map((bill) {
                      isdebit = bill?.billType?.isdebit ?? false;
                      return ListTile(
                        // dense: true,
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
                                size: 25),
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
                                  fontSize: 12, fontWeight: FontWeight.w300),
                            ),
                            Text(
                                "${(bill?.billType?.isdebit ?? false ? bill?.amountToPay : bill?.amount)?.formatForDisplay()}",
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
                                    fontSize: 11, fontWeight: FontWeight.w300),
                              ),
                            if (!isdebit &&
                                (bill?.billType?.includeInBilling ?? false) ==
                                    false)
                              const Text(
                                "(for previous month billing.)",
                                style: TextStyle(
                                    fontSize: 11, fontWeight: FontWeight.w300),
                              ),
                          ],
                        ),
                        onTap: null,
                      );
                    }).toList(),
                  ],
                ),
              );
  }

  Widget _getSubtotal() {
    return Card(
      child: _isLoadingBills
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Text("Subtotal:"),
                      const Spacer(),
                      Text(
                        _billingCurrent.subtotal.formatForDisplay(),
                        style:
                            TextStyle(fontSize: 18, color: Colors.red.shade400),
                      ),
                    ],
                  ),
                  //SizedBox(height: 3),
                  if (_billingPrevious.totalPayment.roundTenths() > 0.00)
                    Row(
                      children: [
                        const Text("Previous Unpaid:"),
                        const Spacer(),
                        Text(
                            _billingPrevious.totalPayment
                                .roundTenths()
                                .formatForDisplay(),
                            style: TextStyle(
                                fontSize: 18, color: Colors.red.shade400))
                      ],
                    ),
                  //SizedBox(height: 3),
                ],
              ),
            ),
    );
  }

  Widget _getTotals() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
                _billingCurrent.totalPayment.formatForDisplay(),
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
            ],
          ),
          if (_billingCurrent.totalPayment != 0.00 ||
              (_useCoins && _billingCurrent.totalPayment == 0.00))
            const SizedBox(height: 10),
          if (_billingCurrent.totalPayment != 0.00 ||
              (_useCoins && _billingCurrent.totalPayment == 0.00))
            TextButton(
              child: Text(
                  _hasBillingExistingText!.isNotEmpty && _hasBillingExists
                      ? "Overwrite$_hasBillingExistingText"
                      : (_isEdit ? "Update" : "Generate"),
                  style: const TextStyle(fontSize: 18)),
              style: TextButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  primary: Colors.grey.shade700,
                  backgroundColor: Colors.white),
              onPressed: _generateBilling,
            ),
        ],
      ),
    );
  }

  Widget _getCoinsWidget() {
    return Card(
      child: CheckboxListTile(
        //visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
        //contentPadding: const EdgeInsets.all(0),
        dense: true,
        value: _useCoins,
        onChanged: (val) {
          // if (_coins.amount > 0) {
          //   setState(() {
          //     _useCoins = val!;
          //   });
          // } else {
          //   return;
          // }
          setState(() {
            _useCoins = val!; //_coins.amount > 0.00 ? val! : _useCoins;
          });
          _computeCoins();
          if (kDebugMode) {
            Print.green("_billingCurrent.coins: ${_billingCurrent.coins}");
          }
        },
        title: Row(
          children: [
            Text("Redeem coins ${_coins.totalAmount.formatForDisplay()}"),
            const Spacer(),
            Text("[-${_coins.amount.formatForDisplay()}]",
                style: TextStyle(
                    fontSize: 15,
                    color: _useCoins
                        ? Colors.green.shade400
                        : Colors.grey.shade500)),
          ],
        ),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: Colors.grey,
      ),
    );
  }

  Future<void> _getCoins() async {
    Coins coins = Coins();
    setState(() {
      _coins.amount = 0.00;
      _hasCoins = false;
      _useCoins = false;
      _isLoadingCoins = true;
      _billingCurrent.coins = 0;
    });

    try {
      _ffInstance
          .collection("coins")
          //.where("payerid_deleted", isEqualTo: "${_selectedUserId}_0")
          .where("user_ids", arrayContains: _selectedUserId)
          .where("deleted", isEqualTo: false)
          .limit(1)
          .get()
          .then((snapshots) {
        for (var doc in snapshots.docs) {
          coins = Coins.fromJson(doc.data());
          coins.id = doc.id;
          //coins += c.amount;
        }
      }).whenComplete(() {
        setState(() {
          //_coins.amount += coins;
          _coins = coins;
          _hasCoins = _coins.amount.roundTenths() > 0.00;
          _useCoins = false;
          _isLoadingCoins = false;
        });
      });
    } on FirebaseAuthException catch (e) {
      _isLoadingCoins.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoadingCoins.updateProgressStatus(errMsg: "$e.");
    }
  }

  Future<void> _generatePdf(List<Bill?> billsCurrrent) async {
    const PdfColor baseColor = PdfColors.grey; // PdfColors.teal;
    //const PdfColor accentColor = PdfColors.white; // blueGrey900;

    const _darkColor = PdfColors.grey; // blueGrey800;
    const _lightColor = PdfColors.teal; //white;

    //PdfColor _baseTextColor = baseColor.isLight ? _lightColor : _darkColor;

    PdfColor _accentTextColor = baseColor.isLight ? _lightColor : _darkColor;

    final String title =
        "Bills-${DateFormat("MMMM-yyyy").format(_billingCurrent.date!)}";
    final document = pw.Document();
    //final output = await getTemporaryDirectory();
    final appDocDir = await getApplicationDocumentsDirectory();
    final file = File('${appDocDir.path}/$title');

    //final image = await imageFromAssetBundle('assets/icons/playstore.png');

    const tableHeaders = [
      'Description',
      'Billing Date',
      'Amount',
      'Rate',
      'Computation',
      'Total'
    ];

    const tableHeadersReading = [
      'Description',
      'Billing Date',
      'Previous',
      'Current',
      'Consumption'
    ];

    //#region Readings
    List<List<dynamic>> readings = [];
    for (var reading in _readings) {
      readings.add([
        reading?.billType?.description,
        reading?.date?.formatDate(dateOnly: true),
        reading?.readingprevious,
        reading?.readingCurrent,
        reading?.reading
      ]);
    }
    ////#endregion

    //#region Current Billing
    List<List<dynamic>> currentBillings = [];
    for (var bill in billsCurrrent) {
      bool isDebit = bill?.billType?.isdebit ?? false;
      num total = (isDebit ? bill?.amountToPay : bill?.amount) ?? 0.00;
      num rate = (bill?.amount ?? 0) / (bill?.quantification ?? 0);
      String rateComputation = "";

      if (bill?.billType?.isdebit ?? false) {
        if (bill?.billTypeId == 6) {
          rateComputation =
              "Amount / ${(bill?.quantification as num)} kwH = ${rate.formatForDisplay(currency: "P")}";
          bill?.computation = "Rate x ${bill.currentReading}";
          //rateComputation = "$rate = $rateComputation";
        } else if (bill?.billTypeId == 5) {
          rateComputation =
              "Amount / ${_loggedInUserprofile.membersArr.firstWhere((element) => _billsTo.isBefore(element.effectivityEnd ?? DateTime.now())).count} members = ${rate.formatForDisplay(currency: "P")}";
          bill?.computation =
              "Rate x ${_selectedUserProfile.membersArr.firstWhere((element) => _billsTo.isBefore(element.effectivityEnd ?? DateTime.now())).count} members";
          //rateComputation = "$rate = $rateComputation";
        }
      }

      if (bill?.billType?.includeInBilling ?? false) {
        currentBillings.add([
          bill?.billType?.description,
          bill?.billDate?.formatDate(dateOnly: true),
          bill?.amount.formatForDisplay(currency: "P"),
          rateComputation,
          bill?.computation,
          "${isDebit ? "+" : "-"}${total.formatForDisplay(currency: "P")}"
        ]);
      }
    }
    currentBillings.add([
      "Subtotal:",
      "",
      "",
      "",
      "",
      _billingCurrent.subtotal.formatForDisplay(currency: "P")
    ]);
    if (_billingPrevious.totalPayment.roundTenths() > 0.00) {
      currentBillings.add([
        "Previous Unpaid:",
        _billingPrevious.date?.formatDate(dateOnly: true),
        _billingPrevious.subtotal.formatForDisplay(currency: "P"),
        "",
        "Amount - ${_billingPrevious.coins.formatForDisplay(currency: "P")} coins",
        _billingPrevious.totalPayment
            .roundTenths()
            .formatForDisplay(currency: "P")
      ]);
    }
    if (_useCoins) {
      currentBillings.add([
        "Coins:",
        "",
        "",
        "",
        "",
        "-${_coins.amount.formatForDisplay(currency: "P")}"
      ]);
    }
    currentBillings.add([
      "Amount to Pay:",
      "",
      "",
      "",
      "",
      _billingCurrent.totalPayment.formatForDisplay(currency: "P")
    ]);
    //#endregion

    document.addPage(
      pw.MultiPage(
          pageFormat: PdfPageFormat.letter,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) => [
                if (_readings.isNotEmpty)
                  pw.Table.fromTextArray(
                    cellAlignment: pw.Alignment.center,
                    headers: tableHeadersReading,
                    headerStyle: pw.TextStyle(
                      color: _accentTextColor,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    headerHeight: 25,
                    //cellHeight: 40,
                    cellAlignments: {
                      0: pw.Alignment.centerLeft,
                      1: pw.Alignment.center,
                      2: pw.Alignment.center,
                      3: pw.Alignment.center,
                      4: pw.Alignment.centerRight,
                    },
                    cellStyle: const pw.TextStyle(
                      fontSize: 8,
                    ),
                    data: readings,
                  ),
                if (_readings.isNotEmpty) pw.SizedBox(height: 10),
                pw.Table.fromTextArray(
                  cellAlignment: pw.Alignment.center,
                  headers: tableHeaders,
                  headerStyle: pw.TextStyle(
                    color: _accentTextColor,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  headerHeight: 25,
                  //cellHeight: 40,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.center,
                    2: pw.Alignment.centerRight,
                    3: pw.Alignment.center,
                    4: pw.Alignment.centerRight,
                  },
                  cellStyle: const pw.TextStyle(
                    fontSize: 8,
                  ),
                  data: currentBillings,
                ),
              ]),
    );

    try {
      await file.writeAsBytes(await document.save());
      Print.green("file location: ${file.toString()}");
      Fluttertoast.showToast(msg: "Billing created.");

      await _fsInstance
          .ref()
          .child("billing history")
          .child(_selectedUserId)
          .child(title)
          .putFile(file);
      Fluttertoast.showToast(msg: "Opening billing...");
    } on firebase_storage.FirebaseException catch (e) {
      String msg = getFirebaseStorageErrorMessage(e);
      Fluttertoast.showToast(msg: msg);
    }

    await Printing.layoutPdf(onLayout: (format) => document.save());

    // await for (var page
    //     in Printing.raster(await document.save(), pages: [0], dpi: 100)) {
    //   var pdfToImage = page.toPng(); // ...or page.toPng()
    //   await file.writeAsString(pdfToImage.toString());
    // }

    // Fluttertoast.showToast(msg: "opening file...");
    // PdfPreview(build: (format) => doc.save());
    // // await Printing.layoutPdf(
    //     onLayout: (PdfPageFormat format) async => doc.save());

    // //To print an HTML document:
    // await Printing.layoutPdf(
    // onLayout: (PdfPageFormat format) async => await Printing.convertHtml(
    //       format: format,
    //       html: '<html><body><p>Hello!</p></body></html>',
    //     ));

    // //To load an image from a Flutter asset:
    // final image = await imageFromAssetBundle('assets/image.png');
    // doc.addPage(pw.Page(
    //     build: (pw.Context context) {
    //       return pw.Center(
    //         child: pw.Image(image),
    //       );
    //     },),);

    // //To use a TrueType font from a flutter bundle:
    // final ttf = await fontFromAssetBundle('assets/open-sans.ttf');

    // doc.addPage(pw.Page(
    //     build: (pw.Context context) {
    //       return pw.Center(
    //         child: pw.Text('Dart is awesome', style: pw.TextStyle(font: ttf, fontSize: 40)),
    //       ); // Center
    //     })); // Page
  }

  Future<void> _generateBilling() async {
    _isLoading.updateProgressStatus(msg: "Saving...");

    if (_formKey.currentState!.validate()) {
      try {
        CollectionReference coinsCol = _ffInstance.collection("coins");
        if (_coins.id.isNullOrEmpty()) {
          if (_useCoins && _coins.amount > 0.00) {
            setState(() {
              _coins.payerId = _selectedUserId;
              _coins.payerIdDeleted = "${_selectedUserId}_0";
              _coins.userIds.clear();
              _coins.userIds.add(_selectedUserId);
              _coins.amount = _coins.totalAmount;
            });
            coinsCol.add(_coins.toJson()).then((document) {
              setState(() {
                _coins.id = document.id;
              });
            }).catchError((e) {
              _isLoading.updateProgressStatus(
                  msg: "Coins not saved!", errMsg: e.toString());
            });
          }
        } else {
          _coins.modifiedBy = _loggedInId;
          _coins.modifiedOn = DateTime.now();
          _coins.deleted = true;
          coinsCol.doc(_coins.id).update(_coins.toJson()).then((value) {
            if (kDebugMode) {
              Print.green("Coins: coins deleted");
            }
          });
        }

        CollectionReference collection = _ffInstance.collection("billings");
        if (_billingCurrent.id.isNullOrEmpty()) {
          _billingCurrent.createdBy = _loggedInId;
          _billingCurrent.totalPayment.roundTenths();
          var data = _billingCurrent.toJson();
          collection.add(data).then((document) {
            _isLoading.updateProgressStatus(msg: "Billing saved!");
            setState(() {
              _billingCurrent.id = document.id;
            });
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
              .then((value) {
            _isLoading.updateProgressStatus(msg: "Billing updated!");
          }).catchError((error) {
            _isLoading.updateProgressStatus(
                msg: "Failed to update billing.", errMsg: error);
          });
        }
        setState(() {
          _isEdit = true;
          //_billingExisting = _billingCurrent;
          _hasBillingExists = false;
          _useCoins = false;
        });
        //Generate PDF report
        //save in Firebase Storage, viewable and downloadable file
        _generatePdf(_billsCurrrent);
      } on FirebaseAuthException catch (e) {
        _isLoading.updateProgressStatus(errMsg: "${e.message}.");
      } catch (e) {
        _isLoading.updateProgressStatus(errMsg: "$e.");
      }
    }
  }
}
