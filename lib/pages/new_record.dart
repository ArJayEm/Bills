import 'package:bills/models/bills.dart';
import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/components/custom_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:flutter/services.dart';
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
  final _ctrlDesciption = TextEditingController();
  final _ctrlAmount = TextEditingController();
  final _ctrlQuantif = TextEditingController();
  final _ctrlSelectedPayers = TextEditingController();

  Bills _bill = Bills();

  //List<Map<String, dynamic>> _selectedList = [];
  List<String> _selectedList = [];
  List<dynamic> _selectList = [];
  bool _selectedAll = false;
  bool _isExpanded = false;

  String _quantification = '';

  //bool _fetchingPayers = false;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getPayers();
    setState(() {
      _bill = widget.data;
      _selectedList = _bill.payerIds ?? [];
      //_selectedList2 =
      _quantification = widget
          .quantification; //widget.title.toLowerCase() == 'electricity' ? 'kwh' : 'cu.m';
      _bill.billdate = _bill.billdate ?? DateTime.now();
      _ctrlBillDate.text = _bill.billdate!.format();
      _ctrlDesciption.text = _bill.desciption ?? "";
      _ctrlAmount.text = _bill.amount.toString();
      _ctrlQuantif.text = _bill.quantification.toString();
      //_ctrlSelectedPayers.text = 'Selected Payers (${_selectedList.length})';
      //_ctrlSelectedPayers.text = _bill.payerNames ?? "Select Payer(s)";
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String titleLast =
        widget.title.substring(widget.title.length - 1, widget.title.length);
    bool isLastS = titleLast == 's';
    String _title = isLastS
        ? widget.title.substring(0, widget.title.length - 1)
        : widget.title;

    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : generateModalBody(
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(10),
                physics: BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(5),
                          icon: Icon(Icons.calendar_today, color: widget.color),
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
                          icon: Icon(Icons.label, color: widget.color),
                          labelText: 'Description',
                          hintText: 'Description'),
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      controller: _ctrlDesciption,
                      onChanged: (value) {
                        setState(() {
                          _bill.desciption = value;
                        });
                      },
                      onTap: () {
                        if ((_bill.desciption.isNullOrEmpty()) ||
                            _bill.desciption!.isEmpty ||
                            _bill.desciption == widget.title) {
                          _ctrlDesciption.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: _ctrlDesciption.text.length);
                        }
                      },
                      // validator: (value) {
                      //   if (value == null || value.isEmpty || value == "0") {
                      //     return 'Must be geater than 0.';
                      //   }
                      //   return null;
                      // },
                    ),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(5),
                          icon: Icon(Icons.attach_money_outlined,
                              color: widget.color),
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
                        if (_bill.amount.toString() == "0" ||
                            _bill.amount.toString() == "") {
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
                          icon: Icon(Icons.pin, color: widget.color),
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
                        if (_bill.quantification.toString() == "0" ||
                            _bill.quantification.toString() == "") {
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
                    AnimatedContainer(
                      height: _isExpanded ? 600 : 50,
                      duration: Duration(milliseconds: 600),
                      curve: Curves.fastOutSlowIn,
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
                              icon: Icon(Icons.person, color: widget.color),
                              suffixIcon: _isExpanded
                                  ? CustomAppBarButton(
                                      onTap: () => setState(() {
                                        _selectedList = [];
                                        //_selectedList2.clear();
                                        if (!_selectedAll) {
                                          for (int b = 0;
                                              b < _selectList.length;
                                              b++) {
                                            _selectedList
                                                .addAll(_selectList[b]);
                                            //_selectedList2.add(_selectList)
                                          }
                                        }
                                        setState(() {
                                          _selectedAll = !_selectedAll;
                                        });
                                        _setSelectedPayersDisplay();
                                      }),
                                      icon: Icons.select_all,
                                      checkedColor: Colors.teal,
                                      uncheckedColor: Colors.white,
                                      isChecked: _selectedAll,
                                    )
                                  : SizedBox(),
                              labelText: 'Select Payer(s)',
                              hintText: 'Select Payer(s)',
                            ),
                            onTap: () async {
                              setState(() {
                                if (_isExpanded) {
                                  _isExpanded = false;
                                  SystemChrome.setEnabledSystemUIMode(
                                      SystemUiMode.manual,
                                      overlays: SystemUiOverlay.values);
                                } else {
                                  _isExpanded = true;
                                  SystemChrome.setEnabledSystemUIMode(
                                      SystemUiMode.manual,
                                      overlays: [SystemUiOverlay.bottom]);
                                }
                              });
                            },
                            onChanged: (value) {},
                            validator: (value) {
                              if (_selectedList.isEmpty) {
                                return 'Must select at least 1';
                              }
                              return null;
                            },
                          ),
                          ..._isExpanded
                              ? <Widget>[
                                  Divider(thickness: 1, height: 0),
                                  _payersSelectionWidget()
                                ]
                              : <Widget>[]
                        ],
                      ),
                    ),
                    //SizedBox(height: 10),
                    // ElevatedButton(
                    //   child: _isLoading
                    //       ? Center(child: CircularProgressIndicator())
                    //       : Text('Save'),
                    //   style: ElevatedButton.styleFrom(
                    //       minimumSize: Size(double.infinity, 50),
                    //       primary: widget.color,
                    //       textStyle: TextStyle(color: Colors.white)),
                    //   onPressed: !_isLoading ? _saveRecord : null,
                    // ),
                    // SizedBox(height: 10),
                    // ElevatedButton(
                    //   onPressed: _cancel,
                    //   child: Text('Cancel'),
                    //   style: ElevatedButton.styleFrom(
                    //       minimumSize: Size(double.infinity, 50),
                    //       primary: Colors.grey.shade800,
                    //       textStyle: TextStyle(color: widget.color)),
                    // ),
                  ],
                ),
              ),
            ),
            [],
            headWidget: Row(
              children: [
                TextButton(
                  child: Icon(Icons.close, size: 30, color: Colors.grey),
                  onPressed: _cancel,
                ),
                Spacer(),
                Text('${_bill.id != null ? 'Manage' : "Add"} $_title',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Spacer(),
                _bill.id != null
                    ? TextButton(
                        child: Icon(Icons.delete, size: 30, color: Colors.grey),
                        onPressed: !_isLoading ? _deleteRecord : null,
                      )
                    : SizedBox(),
                TextButton(
                  child: Icon(Icons.done, size: 30, color: widget.color),
                  onPressed: !_isLoading ? _saveRecord : null,
                ),
              ],
            ),
            header: 'Add $_title');
  }

  _getDate() async {
    var date = await showDatePicker(
      context: context,
      initialDate: _bill.billdate!,
      firstDate: _firstdate,
      lastDate: _lastdate,
    );
    if (date != null) {
      setState(() {
        _bill.billdate = DateTime(date.year, date.month, date.day);
        _ctrlBillDate.text = _bill.billdate.toString();
      });
    }
  }

  _saveRecord() async {
    _showProgressUi(true, "Saving");

    if (_formKey.currentState!.validate()) {
      setState(() {
        _bill.payerIds = _selectedList;
        // if (!(_selectedList?.isEmpty ?? true))
        //   for (var i = 0; i < _selectedList!.length; i++) {
        //     _bill.payerIds?.addAll({
        //       'id': _selectList[i][0],
        //       'name': _selectList[i][1]
        //     });
        //   }
        //_bill.payerNames = _ctrlSelectedPayers.text;
      });

      try {
        String collection = widget.title.toLowerCase();
        CollectionReference list =
            FirebaseFirestore.instance.collection(collection);
        if (_bill.id.isNullOrEmpty()) {
          var data = _bill.toJson();
          list.add(data).then((value) {
            setState(() {
              _isExpanded = false;
            });
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                overlays: SystemUiOverlay.values);
            _updateBillingDates();
            _showProgressUi(false, "");
            Navigator.pop(context);
          }).catchError((error) {
            _showProgressUi(false, "Failed to add bill: $error.");
          });
        } else {
          _bill.modifiedOn = DateTime.now();
          list.doc(_bill.id).update(_bill.toJson()).then((value) {
            setState(() {
              _isExpanded = false;
            });
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                overlays: SystemUiOverlay.values);
            Navigator.pop(context);
            _updateBillingDates();
            _showProgressUi(false, "Bill updated.");
          }).catchError((error) {
            _showProgressUi(false, "Failed to update bill: $error.");
          });
        }
      } on FirebaseAuthException catch (e) {
        _showProgressUi(false, "${e.message}.");
      } catch (e) {
        _showProgressUi(false, "$e.");
      }
    }
  }

  _deleteRecord() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text(
            'You are about to delete a record. This action is irreversible'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              _showProgressUi(true, "Deleting record...");
              try {
                String collection = widget.title.toLowerCase();

                FirebaseFirestore.instance
                    .collection(collection)
                    .doc(_bill.id)
                    .delete()
                    .then((_) {
                  _showProgressUi(false, "Record deleted");
                  Navigator.pop(context);
                  Navigator.pop(context);
                });
              } on FirebaseAuthException catch (e) {
                _showProgressUi(false, "${e.message}.");
              } catch (e) {
                _showProgressUi(false, "$e.");
              }
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  _updateBillingDates() {
    if (widget.title.toLowerCase() != 'payment') {
      try {
        CollectionReference collection =
            FirebaseFirestore.instance.collection("users");
        UserProfile userProfile = UserProfile();
        collection.get().then((snapshots) {
          snapshots.docs.forEach((document) {
            if (_bill.payerIds!.contains((key) => key == document.id)) {
              userProfile =
                  UserProfile.fromJson(document.data() as Map<String, dynamic>);
              userProfile.id = document.id;
              if (userProfile.billingDate == null) {
                collection.doc(userProfile.id).update({
                  'billing_date': _bill.billdate?.toIso8601String()
                }).whenComplete(() {});
              }
            }
          });
        }).whenComplete(() {
          setState(() {
            //_payers.addAll(payers);
            //_listStream = stream;
          });
          _showProgressUi(false, "");
        });
      } on FirebaseAuthException catch (e) {
        _showProgressUi(false, "${e.message}.");
      } catch (e) {
        _showProgressUi(false, "$e.");
      }
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
    _showProgressUi(true, "");

    try {
      List<dynamic> users = [];
      CollectionReference _collection =
          FirebaseFirestore.instance.collection("users");
      _collection.get().then((querySnapshot) {
        querySnapshot.docs.forEach((document) {
          users.add([document.id, document.get('name')]);
        });
      }).whenComplete(() {
        setState(() {
          _selectList.addAll(users);
        });
        _showProgressUi(false, "");
        _setSelectedPayersDisplay();
      });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  Widget _payersSelectionWidget() {
    List<Widget> mList = <Widget>[];
    for (int b = 0; b < _selectList.length; b++) {
      String id = _selectList[b][0];
      String displayname = _selectList[b][1] ?? "No Name";
      mList.add(CheckboxListTile(
        selected: _selectedList.toString().contains(id),
        //selected: _selectedList.contains(id),
        //selected: _selectedList.contains((value) => value[0] == id),
        //selected: _selectedList.contains((value) => value.contains(id)),
        onChanged: (bool? value) {
          setState(() {
            if (value as bool) {
              _selectedList.add(id);
              //_selectedList.addAll({{"id": id, "name": displayname, "deleted": false}});
              //_selectedList.addAll({{"id": id, "deleted": false, "name": displayname}});
            } else {
              //_selectedList.removeWhere((value) => value.toString().contains(id));
              //_selectedList.remove((key, value) => key == id);
              _selectedList.remove(id);
              //_selectedList.remove((key, value) => key.containsKey(id));
              //_selectedList.removeWhere((key, value) => key == id);
            }
          });
          print(_selectedList);
          _setSelectedPayersDisplay();
        },
        value: _selectedList.toString().contains(id),
        //value: _selectedList.contains((value) => value[0] == id),
        //value: _selectedList.contains((value) => value.contains(id)),
        title: new Text(displayname),
        //subtitle: new Text(id),
        controlAffinity: ListTileControlAffinity.leading,
      ));
    }
    return ListView(shrinkWrap: true, children: mList);
  }

  _setSelectedPayersDisplay() {
    setState(() {
      if (_selectedList.isNotEmpty) {
        int left = _selectedList.length - 1;
        String? payer = _getPayerName(_selectedList[
            0]); //_selectedList[0].values.last; // _selectedList.first[0];
        String? others =
            left > 0 ? " and $left other${left > 1 ? 's' : ''}" : "";
        _ctrlSelectedPayers.text = "$payer$others";
      } else {
        _ctrlSelectedPayers.text = 'Select Payer(s)';
      }
      _selectedAll = _selectList.length == _selectedList.length;
    });
  }

  String? _getPayerName(String? id) {
    return (_selectList.where((element) => element.first == id).last)
        .last
        .toString();
  }

  _showProgressUi(bool isLoading, String msg) {
    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
    setState(() => _isLoading = isLoading);
  }
}
