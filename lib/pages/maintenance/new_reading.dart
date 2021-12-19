// ignore_for_file: use_key_in_widget_constructors, unused_import, prefer_final_fields

import 'package:bills/helpers/functions/functions_global.dart';
import 'package:bills/models/bill.dart';
import 'package:bills/models/bill_type.dart';
import 'package:bills/models/meter_readings.dart';
import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/components/custom_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:bills/pages/components/modal_base.dart';
import 'package:print_color/print_color.dart';

Future<bool?> showReadingManagement(context, reading, billType, userid) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Management(reading, billType, userid);
    },
  );
}

class Management extends StatefulWidget {
  final Reading reading;
  final BillType billType;
  final String? selectedUserId;

  const Management(this.reading, this.billType, this.selectedUserId);

  @override
  State<StatefulWidget> createState() {
    return _ManagementState();
  }
}

class _ManagementState extends State<Management> {
  final FirebaseFirestore _ffInstance = FirebaseFirestore.instance;
  final DateTime _firstdate = DateTime(DateTime.now().year - 2);
  final DateTime _lastdate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  final _ctrlBillDate = TextEditingController();
  final _ctrlReading = TextEditingController();
  final _ctrlSelectedPayers = TextEditingController();

  BillType _billType = BillType();
  Reading _reading = Reading();

  late String _selectedUserId;
  List<String?> _selectedList = [];
  List<dynamic> _selectList = [];
  bool _selectedAll = false;
  bool _isExpanded = false;

  int _billTypeId = 0;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _billType = widget.billType;
      _billTypeId = int.parse(_billType.id!);
      _selectedUserId = widget.selectedUserId ?? "";
      _selectedList.add(_selectedUserId); //_reading.userIds ?? ;
      _reading = widget.reading;
      _reading.type = _billTypeId;
      _reading.date = (_reading.date ?? DateTime.now()).formatDateOnly();
      _ctrlBillDate.text = _reading.date!.formatDate(dateOnly: true);
      _ctrlReading.text = _reading.reading.toString();
    });
    _getPayers();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //String titleLast = _billType.description.substring(_billType.description.length - 1, _billType.description.length);
    //bool isLastS = _billType.description.endsWith("s"); //titleLast == 's';
    String? _title = _billType.description!.endsWith("s")
        ? _billType.description?.substring(0, _billType.description!.length - 1)
        : _billType.description;

    return _isLoading
        ? const Center(child: CircularProgressIndicator(), heightFactor: 2)
        : generateModalBody(
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(5),
                          icon: Icon(Icons.calendar_today,
                              color: Color(_billType.iconData!.color ?? 0)),
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
                    const SizedBox(height: 10),
                    AnimatedContainer(
                      height: _isExpanded ? 600 : 50,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.fastOutSlowIn,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            showCursor: false,
                            readOnly: true,
                            enabled: false,
                            controller: _ctrlSelectedPayers,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(5),
                              icon: Icon(Icons.person,
                                  color: Color(_billType.iconData?.color ?? 0)),
                              suffixIcon: _isExpanded
                                  ? CustomAppBarButton(
                                      onTap: () => setState(() {
                                        _selectedList.clear();
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
                                  : const SizedBox(),
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
                                  const Divider(thickness: 1, height: 0),
                                  _payersSelectionWidget()
                                ]
                              : <Widget>[]
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(5),
                          icon: Icon(Icons.show_chart,
                              color: Color(_billType.iconData?.color ?? 0)),
                          labelText: 'Reading',
                          hintText: 'Reading'),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      controller: _ctrlReading,
                      onChanged: (value) {
                        setState(() {
                          _reading.reading = int.parse(value);
                        });
                      },
                      onTap: () {
                        if (_reading.reading.toString() == "0" ||
                            _reading.reading.toString() == "") {
                          _ctrlReading.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: _ctrlReading.text.length);
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty || value == "0") {
                          return 'Must be geater than 0.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            [],
            headWidget: Row(
              children: [
                TextButton(
                  child: const Icon(Icons.close, size: 30, color: Colors.grey),
                  onPressed: _cancel,
                ),
                const Spacer(),
                Text(
                    '${_reading.id != null ? 'Manage' : "Add"} $_title Reading',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20)),
                const Spacer(),
                _reading.id != null
                    ? TextButton(
                        child: const Icon(Icons.delete,
                            size: 30, color: Colors.grey),
                        onPressed: !_isLoading ? _deleteRecord : null,
                      )
                    : const SizedBox(),
                TextButton(
                  child: Icon(Icons.done,
                      size: 30, color: Color(_billType.iconData!.color ?? 0)),
                  onPressed: !_isLoading ? _saveRecord : null,
                ),
              ],
            ),
            header: 'Add $_title');
  }

  Future<void> _getPayers() async {
    _isLoading.updateProgressStatus();

    try {
      List<dynamic> users = [];
      DocumentReference _document =
          _ffInstance.collection("users").doc(_selectedUserId);
      _document.get().then((snapshot) {
        // for (var document in snapshots.docs) {
        //   //String pbt = "${document.id}_$_billType";
        //   users.add([document.id, document.get('name')]);
        // }
        users.add([snapshot.id, snapshot.get('name')]);
      }).whenComplete(() {
        setState(() {
          _selectList.clear();
          _selectList.addAll(users);
        });
        _isLoading.updateProgressStatus();
        _setSelectedPayersDisplay();
      });
    } on FirebaseAuthException catch (e) {
      _isLoading.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoading.updateProgressStatus(errMsg: "$e.");
    }
  }

  _getDate() async {
    var date = await showDatePicker(
      context: context,
      initialDate: _reading.date!,
      firstDate: _firstdate,
      lastDate: _lastdate,
    );
    if (date != null) {
      setState(() {
        _reading.date = DateTime(date.year, date.month, date.day);
        _ctrlBillDate.text = _reading.date!.formatDate(dateOnly: true);
      });
    }
  }

  _cancel() {
    setState(() {
      _ctrlBillDate.clear();
      _ctrlReading.clear();
      _selectedList.clear();
    });
    Navigator.of(context).pop(false);
  }

  _saveRecord() async {
    _isLoading.updateProgressStatus(msg: "Saving");
    // String? msg;
    // String? errMsg;

    setState(() {
      _reading.userid = _selectedList.first;
      _reading.userIdDeleted?.clear();
      _reading.userIdDeleted?.add("${_selectedList.first}_0");
    });

    if (_formKey.currentState!.validate()) {
      try {
        CollectionReference collection =
            _ffInstance.collection("meter_readings");
        if (_reading.id.isNullOrEmpty()) {
          var data = _reading.toJson();
          collection.add(data).then((document) {
            setState(() {
              _isExpanded = false;
              _reading.id = document.id;
            });
            //msg = "Reading saved!";
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                overlays: SystemUiOverlay.values);
            _isLoading.updateProgressStatus(msg: "Reading saved!");
          }).catchError((error) {
            _isLoading.updateProgressStatus(
                msg: "Failed to add reading.", errMsg: error);
          });
        } else {
          _reading.modifiedOn = DateTime.now();
          collection
              .doc(_reading.id)
              .update(_reading.toJson())
              .then((document) {
            setState(() {
              _isExpanded = false;
            });
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                overlays: SystemUiOverlay.values);
            _isLoading.updateProgressStatus(msg: "Reading updated!");
          }).catchError((error) {
            _isLoading.updateProgressStatus(
                msg: "Failed to update reading.", errMsg: error);
          });
        }
      } on FirebaseAuthException catch (e) {
        _isLoading.updateProgressStatus(errMsg: "${e.message}.");
      } catch (e) {
        _isLoading.updateProgressStatus(errMsg: "$e.");
      }
    }
  }

  _deleteRecord() async {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
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
              _isLoading.updateProgressStatus(msg: "Deleting record...");
              try {
                _ffInstance
                    .collection("meter_readings")
                    .doc(_reading.id)
                    .delete()
                    .then((value) {
                  _isLoading.updateProgressStatus(msg: "Reading deleted!");
                  Navigator.pop(context);
                  Navigator.pop(context);
                });
              } on FirebaseAuthException catch (e) {
                _isLoading.updateProgressStatus(errMsg: "${e.message}.");
              } catch (e) {
                _isLoading.updateProgressStatus(errMsg: "$e.");
              }
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  _setSelectedPayersDisplay() {
    setState(() {
      if (_selectedList.isNotEmpty) {
        int left = _selectedList.length - 1;
        String? payer = _selectList
            .where((element) => element.first == _selectedUserId)
            .last
            .last
            .toString();
        String? others =
            left > 0 ? " and $left other${left > 1 ? 's' : ''}" : "";
        _ctrlSelectedPayers.text = "$payer$others";
      } else {
        _ctrlSelectedPayers.text = 'Select Payer(s)';
      }
      _selectedAll = _selectList.length == _selectedList.length;
    });
  }

  Widget _payersSelectionWidget() {
    List<Widget> mList = <Widget>[];
    for (int b = 0; b < _selectList.length; b++) {
      String id = _selectList[b][0];
      String displayname = _selectList[b][1] ?? "No Name";
      mList.add(CheckboxListTile(
        selected: _selectedList.toString().contains(id),
        onChanged: (bool? value) {
          setState(() {
            if (value as bool) {
              _selectedList.add(id);
            } else {
              _selectedList.remove(id);
            }
          });
          if (kDebugMode) {
            print(_selectedList);
          }
          _setSelectedPayersDisplay();
        },
        value: _selectedList.toString().contains(id),
        title: Text(displayname),
        controlAffinity: ListTileControlAffinity.leading,
      ));
    }
    return ListView(shrinkWrap: true, children: mList);
  }
}
