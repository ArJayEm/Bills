import 'package:bills/models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'components/modal_base.dart';
import 'components/multi_select_dialog.dart';

Future<bool?> showAddRecord(context, data, quantification, title, color) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Management(data, quantification, title, color);
    },
  );
}

class Management extends StatefulWidget {
  final String title;
  final dynamic data;
  final String quantification;
  final Color color;

  const Management(this.data, this.quantification, this.title, this.color);

  @override
  State<StatefulWidget> createState() {
    return _ManagementState();
  }
}

class _ManagementState extends State<Management> {
  final DateTime _firstdate = DateTime(DateTime.now().year - 2);
  final DateTime _lastdate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  final _ctrlBillDate = TextEditingController();
  final _ctrlAmount = TextEditingController();
  final _ctrlQuantif = TextEditingController();
  TextEditingController _ctrlSelectedPayers = TextEditingController();
  String _selectedPayersLabelText = 'Selected Payers (0)';

  DateTime? _billdate = DateTime.now();
  num _amount = 0;
  int _quantif = 0;

  List<UserProfile> _payerList = [];
  List<String> _selectedPayerList = [];

  String _quantification = '';

  bool _fetchingPayers = false;
  String _errorMsg = '';

  @override
  void initState() {
    super.initState();
    _getPayers();
    _quantification = widget
        .quantification; //widget.title.toLowerCase() == 'electricity' ? 'kwh' : 'cu.m';
    setState(() {
      _ctrlBillDate.text = _billdate!.format(dateOnly: true);
      _ctrlAmount.text = _amount.toString();
      _ctrlQuantif.text = _quantif.toString();
      _ctrlSelectedPayers.text = 'No Payers Selected';
    });
  }

  @override
  Widget build(BuildContext context) {
    String titleLast =
        widget.title.substring(widget.title.length - 1, widget.title.length);
    bool isLastS = titleLast == 's';
    String _title = isLastS
        ? widget.title.substring(0, widget.title.length - 1)
        : widget.title;

    return _fetchingPayers
        ? Center(child: CircularProgressIndicator())
        : generateModalBody(
            Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: 'Bill Date', hintText: 'Bill Date'),
                    controller: _ctrlBillDate,
                    readOnly: true,
                    onTap: () {
                      _getDate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Invalid date.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                        labelText: 'Amount', hintText: 'Amount'),
                    controller: _ctrlAmount,
                    onChanged: (value) {
                      setState(() {
                        _amount = num.parse(value);
                      });
                    },
                    onTap: () {
                      if (_amount.toString() == "0") {
                        _ctrlAmount.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _ctrlAmount.text.length);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Must be geater than 0.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: _quantification, hintText: _quantification),
                    controller: _ctrlQuantif,
                    onChanged: (value) {
                      setState(() {
                        _quantif = int.parse(value);
                      });
                    },
                    onTap: () {
                      if (_quantif.toString() == "0") {
                        _ctrlQuantif.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _ctrlQuantif.text.length);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Must be geater than 0.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    showCursor: false,
                    readOnly: true,
                    controller: _ctrlSelectedPayers,
                    decoration: InputDecoration(
                      labelText: _selectedPayersLabelText,
                      hintText: 'Select Payers',
                    ),
                    onTap: () async {
                      var selected = await showDialog<List<String>>(
                          context: context,
                          builder: (_) => MultiSelectDialog(
                              question: Text('Select Payers'),
                              payers: _payerList));
                      print(selected);
                      if (selected!.isNotEmpty == true) {
                        setState(() {
                          _selectedPayerList = selected;
                          _selectedPayersLabelText =
                              'Selected Payers (${selected.length})';
                          _ctrlSelectedPayers.text = '$selected';
                        });
                      } else {
                        _selectedPayersLabelText = 'Select Payers';
                        _ctrlSelectedPayers.text = 'No Payers Selected';
                      }
                    },
                  ),
                  SizedBox(height: 60),
                  ElevatedButton(
                    child: Text('Save'),
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 40),
                        //primary: widget.color,
                        textStyle: TextStyle(color: Colors.white)),
                    onPressed: _saveRecord,
                  ),
                  SizedBox(height: 10),
                  TextButton(
                    onPressed: _cancel,
                    child: Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 40),
                        textStyle: TextStyle(color: widget.color)),
                  ),
                ],
              ),
            ),
            [],
            header: 'Add $_title');
  }

  _getDate() async {
    var date = await showDatePicker(
      context: context,
      initialDate: _billdate ?? _lastdate,
      firstDate: _firstdate,
      lastDate: _lastdate,
    );
    if (date != null) {
      setState(() {
        _billdate = DateTime(date.year, date.month, date.day);
        _ctrlBillDate.text = _billdate!.format(dateOnly: true);
      });
    }
  }

  Future<void> _saveRecord() {
    String collection = widget.title.toLowerCase();
    CollectionReference list =
        FirebaseFirestore.instance.collection(collection);

    return list
        .add({
          'bill_date': _billdate!.millisecondsSinceEpoch,
          'amount': _amount,
          _quantification: _quantif,
          'created_on': DateTime.now().millisecondsSinceEpoch,
          'payers': _selectedPayerList
        })
        .then((value) => print("Bill added."))
        .catchError((error) => print("Failed to add bill: $error"));
  }

  _cancel() {
    setState(() {
      _ctrlBillDate.clear();
      _ctrlAmount.clear();
      _payerList.clear();
    });
    Navigator.of(context).pop(false);
  }

  Future<void> _getPayers() async {
    setState(() {
      _errorMsg = "";
    });

    List<UserProfile> _ps = [];
    try {
      var collection = FirebaseFirestore.instance.collection('users');

      collection.get().then((snapshot) {
        UserProfile up = UserProfile();
        for (var i = 0; i < snapshot.docs.length; i++) {
          up.id = snapshot.docs[i].id.toString();
          up.displayName = snapshot.docs[i].get('display_name').toString();
          up.members = int.parse(snapshot.docs[i].get('members'));
          up.loggedIn = snapshot.docs[i].get('logged_in');
          _ps.add(up);
        }
      }).whenComplete(() {
        setState(() {
          _payerList = _ps;
        });
      });
      print('_payerList: ${_payerList.toString()}');
    } on FirebaseAuthException catch (e) {
      _errorMsg = '${e.message}';
    } catch (error) {
      _errorMsg = error.toString();
    }

    if (_errorMsg.length > 0) {
      Fluttertoast.showToast(msg: _errorMsg);
    }
  }
}
