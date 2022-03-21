//import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'package:bills/helpers/functions/functions_global.dart';
import 'package:bills/models/bill.dart';
import 'package:bills/models/billing.dart';
import 'package:bills/pages/components/custom_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:printing/printing.dart';

class ViewBilling extends StatefulWidget {
  const ViewBilling(
      {Key? key,
      required this.auth,
      required this.billing,
      required this.selectedUserId})
      : super(key: key);

  final FirebaseAuth auth;
  final Billing billing;
  final String selectedUserId;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<ViewBilling> {
  late FirebaseAuth _auth;
  final FirebaseFirestore _ffInstance = FirebaseFirestore.instance;
  final firebase_storage.FirebaseStorage _fsInstance =
      firebase_storage.FirebaseStorage.instance;
  String? _loggedInId;
  String? _selectedUserId;
  Billing _billing = Billing();
  final Billing _payment = Billing();
  final List<Bill?> _billPayments = [];

  final bool _isLoading = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    setState(() {
      _auth = widget.auth;
      _loggedInId = _auth.currentUser!.uid;
      _selectedUserId = widget.selectedUserId;
      _billing = widget.billing;
    });
    _onLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('View Billing')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(5),
          physics: const BouncingScrollPhysics(),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            children: [
              _getBillingWidget(),
              _getPaymentWidget(),
              const SizedBox(height: 10),
              TextButton(
                child: const Text("View Bill", style: TextStyle(fontSize: 18)),
                style: TextButton.styleFrom(
                    shape: const StadiumBorder(),
                    minimumSize: const Size(double.infinity, 50),
                    primary: Colors.grey.shade800,
                    backgroundColor: Colors.white),
                onPressed: () async {
                  Directory appDocDir =
                      await getApplicationDocumentsDirectory();
                  final String title =
                      "Bills-${DateFormat("MMMM-yyyy").format(_billing.date!)}";
                  File downloadFromCloud = File('${appDocDir.path}/$title');

                  try {
                    await _fsInstance
                        .ref()
                        .child("billing history")
                        .child("$_selectedUserId")
                        .child(title)
                        .writeToFile(downloadFromCloud);

                    String newFileName =
                        '$title-${DateTime.now().formatNoSpace()}';

                    await Printing.layoutPdf(
                        name: newFileName,
                        onLayout: (format) =>
                            downloadFromCloud.readAsBytesSync());
                  } on firebase_storage.FirebaseException catch (e) {
                    String msg = getFirebaseStorageErrorMessage(e);
                    Fluttertoast.showToast(msg: msg);

                    if (e.code == "object-not-found") {}
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onLoad() async {
    await _getBillPayments();
  }

  Widget _getBillingWidget() {
    return Card(
      child: ExpansionTile(
        title: const Text("Bill Details"),
        collapsedTextColor: Colors.white,
        controlAffinity: ListTileControlAffinity.trailing,
        //childrenPadding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
        initiallyExpanded: true,
        children: <Widget>[
          const CustomDivider(),
          ListTile(
              dense: true,
              title: const Text("Bill Period"),
              trailing: Text(
                  "${_billing.billingFrom?.formatToMonthDay()} - ${_billing.billingTo?.formatToMonthDay()}")),
          ListTile(
              dense: true,
              title: const Text("Invoice Date"),
              trailing: Text("${_billing.date?.format(dateOnly: true)}")),
          ListTile(
              dense: true,
              title: const Text("Bill Due Date"),
              trailing:
                  Text("${_billing.dueDate?.formatDate(dateOnly: true)}")),
          const ListTile(
              dense: true, title: Text("Bill Status"), trailing: Text("N/A")),
          ListTile(
              dense: true,
              title: const Text("Billed Amount"),
              trailing: Text(_billing.subtotal.formatForDisplay())),
          const CustomDivider(),
          ListTile(
              dense: true,
              title: const Text("Current Amount Due"),
              trailing: Text(_billing.totalPayment.formatForDisplay())),
        ],
      ),
    );
  }

  Widget _getPaymentWidget() {
    return Card(
      child: ExpansionTile(
        title: const Text("Payment Details"),
        collapsedTextColor: Colors.white,
        controlAffinity: ListTileControlAffinity.trailing,
        //childrenPadding: EdgeInsets.fromLTRB(25, 0, 0, 0),
        initiallyExpanded: false,
        children: <Widget>[
          if (_billPayments.isNotEmpty) const CustomDivider(),
          if (_billPayments.isNotEmpty)
            ListView(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              children: [
                ..._billPayments.map((bill) {
                  return ListTile(
                    dense: true,
                    title:
                        Text("${bill?.billDate?.formatDate(dateOnly: true)}"),
                    trailing: Text("${bill?.amount.formatForDisplay()}"),
                  );
                }),
              ],
            ),
          if (_billPayments.isNotEmpty) const CustomDivider(),
          // ListTile(
          //     dense: true,
          //     title: const Text("Credits Used"),
          //     trailing: Text(_payment.coins.formatForDisplay())),
          if (_billPayments.isNotEmpty)
            ListTile(
                dense: true,
                title: const Text("Total Paid Amount"),
                trailing: Text(_payment.totalPayment.formatForDisplay())),
        ],
      ),
    );
  }

  Future<void> _getBillPayments() async {
    List<Bill?> billPayments = [];
    num total = 0.00;
    // int prevMonth = (_billing.date?.month ?? 0) - 1;
    // prevMonth = prevMonth == 0 ? 12 : prevMonth;
    // int prevYear = (_billing.date?.year ?? DateTime.now().year) - (prevMonth == 12 ? 0 : 1);
    // prevMonth = prevMonth == 13 ? 1 : prevMonth;
    // DateTime prevDate = DateTime(prevYear, prevMonth, 15);
    try {
      _ffInstance
          .collection("bills")
          // .where("bill_date",
          //     isGreaterThanOrEqualTo: _prevBillsFrom.toIso8601String())
          // .where("bill_date",
          //     isLessThanOrEqualTo: _prevBillsTo.toIso8601String())
          .where("id", whereIn: _billing.paymentIds)
          .where('payers_billtype', arrayContains: "${_selectedUserId}_1")
          .orderBy('bill_date', descending: true)
          .get()
          .then((snapshots) {
        for (var document in snapshots.docs) {
          Bill bill = Bill();
          bill = Bill.fromJson(document.data());
          bill.id = document.id;
          total += bill.amount;
          billPayments.add(bill);
        }
      }).whenComplete(() {
        setState(() {
          _billPayments.clear();
          _billPayments.addAll(billPayments);
          _payment.billPayments.clear();
          _payment.billPayments.addAll(billPayments);
          _payment.totalPayment = total;
        });
      });
    } on FirebaseAuthException catch (e) {
      _isLoading.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoading.updateProgressStatus(errMsg: "$e.");
    }
  }
}
