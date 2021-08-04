import 'package:bills/models/bills.dart';
import 'package:bills/pages/components/custom_icon_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'components/modal_base.dart';

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
  final Bills data;
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

  late Bills _bill;

  List<dynamic> _selectedList = [];
  List<dynamic> _selectList = [];
  bool _selectedAll = false;
  bool _isExpanded = false;

  String _quantification = '';

  bool _fetchingPayers = false;
  String _errorMsg = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _getPayers();
    setState(() {
      _bill = widget.data;
      _selectedList = _bill.payerIds!;
      _quantification = widget
          .quantification; //widget.title.toLowerCase() == 'electricity' ? 'kwh' : 'cu.m';
      _ctrlBillDate.text = _bill.billdate!.formatToDateTimeString();
      _ctrlAmount.text = _bill.amount.toString();
      _ctrlQuantif.text = _bill.quantification.toString();
      //_ctrlSelectedPayers.text = 'No Payers Selected';
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
                        contentPadding: EdgeInsets.all(5),
                        icon: Icon(Icons.calendar_today),
                        labelText: 'Bill Date',
                        hintText: 'Bill Date'),
                    controller: _ctrlBillDate,
                    readOnly: true,
                    onTap: () {
                      _getDate();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty || value == "0") {
                        return 'Invalid date.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(5),
                        icon: Icon(Icons.attach_money_outlined),
                        labelText: 'Amount',
                        hintText: 'Amount'),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    controller: _ctrlAmount,
                    onChanged: (value) {
                      setState(() {
                        _bill.amount = num.parse(value);
                      });
                    },
                    onTap: () {
                      if (_bill.amount.toString() == "0") {
                        _ctrlAmount.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _ctrlAmount.text.length);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty || value == "0") {
                        return 'Must be geater than 0.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(5),
                        icon: Icon(Icons.pin),
                        labelText: _quantification,
                        hintText: _quantification),
                    keyboardType: TextInputType.number,
                    controller: _ctrlQuantif,
                    onChanged: (value) {
                      setState(() {
                        _bill.quantification = int.parse(value);
                      });
                    },
                    onTap: () {
                      if (_bill.quantification.toString() == "0") {
                        _ctrlQuantif.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _ctrlQuantif.text.length);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty || value == "0") {
                        return 'Must be geater than 0.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: new BoxConstraints(
                      minHeight: _isExpanded ? 100 : 0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          showCursor: false,
                          readOnly: true,
                          controller: _ctrlSelectedPayers,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(5),
                            icon: Icon(Icons.person),
                            suffixIcon: _isExpanded
                                ? CustomAppBarButton(
                                    onTap: () => setState(() {
                                      _selectedList.clear();
                                      if (!_selectedAll) {
                                        for (int b = 0;
                                            b < _selectList.length;
                                            b++) {
                                          _selectedList.add(_selectList[b][0]);
                                        }
                                      }
                                      setState(() {
                                        _selectedAll = !_selectedAll;
                                      });
                                    }),
                                    icon: Icons.select_all,
                                    checkedColor: Colors.teal,
                                    uncheckedColor: Colors.white,
                                    isChecked: _selectedAll,
                                  )
                                : SizedBox(),
                            labelText: 'Payers',
                            hintText:
                                'Selected Payers (${_selectedList.length})',
                          ),
                          onTap: () async {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          onChanged: (value) {},
                          validator: (value) {
                            if (_selectedList.length == 0) {
                              return 'Must select at least 1';
                            }
                            return null;
                          },
                        ),
                        ..._isExpanded
                            ? <Widget>[
                                Divider(thickness: 1, height: 0),
                                createMenuWidget()
                              ]
                            : <Widget>[]
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                  ElevatedButton(
                    child: _isSaving
                        ? Center(child: CircularProgressIndicator())
                        : Text('Save'),
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        primary: widget.color,
                        textStyle: TextStyle(color: Colors.white)),
                    onPressed: !_isSaving ? _saveRecord : null,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _cancel,
                    child: Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        primary: Colors.grey.shade800,
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
      initialDate: DateTime.fromMillisecondsSinceEpoch(_bill.billdate!),
      firstDate: _firstdate,
      lastDate: _lastdate,
    );
    if (date != null) {
      setState(() {
        _bill.billdate =
            DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
        _ctrlBillDate.text = _bill.billdate!.formatToDateTimeString();
      });
    }
  }

  void _saveRecord() {
    setState(() {
      _errorMsg = "";
      _isSaving = true;
    });

    if (_formKey.currentState!.validate()) {
      Fluttertoast.showToast(msg: 'Processing Data');

      try {
        String collection = widget.title.toLowerCase();
        CollectionReference list =
            FirebaseFirestore.instance.collection(collection);
        if (_bill.id == null) {
          list
              .add({
                'bill_date': _bill.billdate,
                'amount': _bill.amount,
                _quantification: _bill.quantification,
                'created_on': DateTime.now().millisecondsSinceEpoch,
                'payer_ids': _selectedList
              })
              .then((value) => print("Bill added."))
              .catchError((error) => print("Failed to add bill: $error"));
        } else {
          list
              .doc(_bill.id)
              .update({
                'bill_date': _bill.billdate,
                'amount': _bill.amount,
                _quantification: _bill.quantification,
                'created_on': DateTime.now().millisecondsSinceEpoch,
                'payer_ids': _selectedList
              })
              .then((value) => print("Bill added."))
              .catchError((error) => print("Failed to add bill: $error"));
        }
      } on FirebaseAuthException catch (e) {
        _errorMsg = '${e.message}';
      } catch (error) {
        _errorMsg = error.toString();
      }
    }

    setState(() => _isSaving = false);
    if (_errorMsg.length > 0) {
      Fluttertoast.showToast(msg: _errorMsg);
    }
  }

  _cancel() {
    setState(() {
      _ctrlBillDate.clear();
      _ctrlAmount.clear();
      _selectedList.clear();
    });
    Navigator.of(context).pop(false);
  }

  Future<void> _getPayers() async {
    setState(() {
      _errorMsg = "";
    });

    try {
      List<dynamic> users = [];
      CollectionReference _collection =
          FirebaseFirestore.instance.collection("users");
      _collection.get().then((querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          users.add([doc.id, doc.get('display_name')]);
        });
      }).whenComplete(() {
        setState(() {
          _selectList.addAll(users);
        });
      });
    } on FirebaseAuthException catch (e) {
      _errorMsg = '${e.message}';
    } catch (error) {
      _errorMsg = error.toString();
    }

    if (_errorMsg.length > 0) {
      Fluttertoast.showToast(msg: _errorMsg);
    }
  }

  Widget createMenuWidget() {
    List<Widget> mList = <Widget>[];
    for (int b = 0; b < _selectList.length; b++) {
      String id = _selectList[b][0];
      String displayname = _selectList[b][1];
      mList.add(CheckboxListTile(
        selected: _selectedList.contains(id),
        onChanged: (bool? value) {
          setState(() {
            if (value == true) {
              _selectedList.add(id);
            } else {
              _selectedList.remove(id);
            }
            _selectedAll = _selectList.length == _selectedList.length;
          });
          print(_selectedList);
        },
        value: _selectedList.contains(id),
        title: new Text(displayname),
        subtitle: new Text(id),
        controlAffinity: ListTileControlAffinity.leading,
      ));
    }
    return ListView(shrinkWrap: true, children: mList);
  }
}
