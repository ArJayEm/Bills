// ignore_for_file: use_key_in_widget_constructors, unused_import, prefer_final_fields

import 'package:bills/models/bill.dart';
import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/components/custom_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:flutter/services.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_configuration/global_configuration.dart';

import 'package:bills/pages/components/modal_base.dart';
import 'package:print_color/print_color.dart';

Future<bool?> showBillManagement(
    context, data, color, userid, loggedInId) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Management(data, color, userid, loggedInId);
    },
  );
}

class Management extends StatefulWidget {
  final Bill bill;
  final Color color;
  final String? selectedUserId;
  final String? loggedInId;

  const Management(this.bill, this.color, this.selectedUserId, this.loggedInId);

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
  final _ctrlDesciption = TextEditingController();
  final _ctrlAmount = TextEditingController();
  final _ctrlQuantif = TextEditingController();
  final _ctrlSelectedPayers = TextEditingController();

  Bill _bill = Bill();

  late String _selectedUserId;
  List<String?> _selectedUserList = [];
  List<String?> _selectedUserBillTypeList = [];
  List<dynamic> _userList = [];
  bool _selectedAll = false;
  bool _isExpanded = false;

  String _quantification = '';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _bill = widget.bill;
      _quantification = _bill.billType?.quantification ?? "";

      _bill.billTypeId = int.parse(_bill.billType!.id!);
      _selectedUserId = widget.selectedUserId ?? "";
      _selectedUserList = [_selectedUserId];
      _selectedUserBillTypeList = ["${_selectedUserId}_${_bill.billTypeId}"];
      _bill.payerIds?.addAll(_selectedUserList);
      _bill.payersBillType?.addAll(_selectedUserBillTypeList);
      //_selectedUserList.add(_selectedUserId);
      //_selectedUserBillTypeList.add("${_selectedUserId}_${_bill.billTypeId}");
      _bill.billDate = _bill.billDate ?? DateTime.now();

      _ctrlBillDate.text = _bill.billDate!.format(dateOnly: true);
      _ctrlDesciption.text = _bill.description ?? "";
      _ctrlAmount.text = _bill.amount.format();
      _ctrlQuantif.text = _bill.quantification.toString();
    });
    _onLoad();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? _title = (_bill.billType?.description ?? "").endsWith("s")
        ? _bill.billType?.description
            ?.substring(0, (_bill.billType?.description ?? "").length - 1)
        : _bill.billType?.description;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : generateModalBody(
            Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(5),
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
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(5),
                          icon: Icon(Icons.label, color: widget.color),
                          labelText: 'Description',
                          hintText: 'Description'),
                      keyboardType: TextInputType.name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      controller: _ctrlDesciption,
                      onChanged: (value) {
                        setState(() {
                          _bill.description = value;
                        });
                      },
                      onTap: () {
                        if ((_bill.description.isNullOrEmpty()) ||
                            _bill.description!.isEmpty ||
                            _bill.description == _bill.billType?.description) {
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
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(5),
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
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(5),
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
                            controller: _ctrlSelectedPayers,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.all(5),
                              icon: Icon(Icons.person, color: widget.color),
                              suffixIcon: _isExpanded
                                  ? CustomAppBarButton(
                                      onTap: () {
                                        setState(() {
                                          _selectedUserList.clear();
                                          _selectedUserBillTypeList.clear();
                                          if (!_selectedAll) {
                                            for (var user in _userList) {
                                              _selectedUserList.add(user.id);
                                              _selectedUserBillTypeList.add(
                                                  "${user.id}_${_bill.billType?.id}");
                                            }
                                          }
                                          _selectedAll = !_selectedAll;
                                        });
                                        _setSelectedPayersDisplay();
                                      },
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
                              if (_selectedUserList.isEmpty) {
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
                    const SizedBox(height: 20),
                    ElevatedButton(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : const Text('Save'),
                      style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          primary: widget.color,
                          textStyle: const TextStyle(color: Colors.white)),
                      onPressed: !_isLoading ? _saveRecord : null,
                    ),
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
                  child: const Icon(Icons.close, size: 30, color: Colors.grey),
                  onPressed: _cancel,
                ),
                const Spacer(),
                Text('${_bill.id != null ? 'Manage' : "Add"} $_title',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20)),
                const Spacer(),
                _bill.id != null
                    ? TextButton(
                        child: const Icon(Icons.delete,
                            size: 30, color: Colors.grey),
                        onPressed: !_isLoading ? _deleteRecord : null,
                      )
                    : const SizedBox(width: 53),
                // TextButton(
                //   child: Icon(Icons.done, size: 30, color: widget.color),
                //   onPressed: !_isLoading ? _saveRecord : null,
                // ),
              ],
            ),
            header: 'Add $_title');
  }

  Future<void> _onLoad() async {
    await _getPayers();
    await _setSelectedPayersDisplay();
  }

  _getDate() async {
    // DateTime newDate = await showDatePicker(
    //       context: context,
    //       initialDate: _bill.billDate!,
    //       firstDate: _firstdate,
    //       lastDate: _lastdate,
    //     ) ??
    //     _bill.billDate ??
    //     DateTime.now();
    DateTime newDate = await DatePicker.showSimpleDatePicker(
          context,
          initialDate: _bill.billDate!,
          firstDate: _firstdate,
          lastDate: _lastdate,
          dateFormat: "yyyy-MMMM-dd",
          locale: DateTimePickerLocale.en_us,
          looping: true,
        ) ??
        _bill.billDate ??
        DateTime.now();

    setState(() {
      _bill.billDate = DateTime(newDate.year, newDate.month, newDate.day);
      _ctrlBillDate.text = _bill.billDate!.formatDate(dateOnly: true);
    });
  }

  _saveRecord() async {
    _showProgressUi(msg: "Saving");
    setState(() {
      _isExpanded = false;
      _bill.payerIds?.clear();
      _bill.payersBillType?.clear();
      _bill.payerIds?.addAll(_selectedUserList);
      _bill.payersBillType?.addAll(_selectedUserBillTypeList);
    });

    if (_formKey.currentState!.validate()) {
      try {
        CollectionReference list = _ffInstance.collection("bills");
        if (_bill.id.isNullOrEmpty()) {
          _bill.createdBy = widget.loggedInId;
          var data = _bill.toJson();
          list.add(data).then((document) {
            setState(() {
              _bill.id = document.id;
            });
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                overlays: SystemUiOverlay.values);
            _updateBillingDates();
            _showProgressUi(msg: "Bill saved!");
            //Navigator.pop(context);
          }).catchError((error) {
            _showProgressUi(errMsg: error, msg: "Failed to add bill.");
          });
        } else {
          _bill.modifiedBy = widget.loggedInId;
          _bill.modifiedOn = DateTime.now();
          list.doc(_bill.id).update(_bill.toJson()).then((value) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
                overlays: SystemUiOverlay.values);
            Navigator.pop(context);
            _updateBillingDates();
            _showProgressUi(msg: "Bill updated!");
          }).catchError((error) {
            _showProgressUi(errMsg: error, msg: "Failed to update bill.");
          });
        }
      } on FirebaseAuthException catch (e) {
        _showProgressUi(errMsg: "${e.message}.");
      } catch (e) {
        _showProgressUi(errMsg: "$e.");
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
              _showProgressUi(msg: "Deleting record...");
              try {
                _ffInstance
                    .collection("bills")
                    .doc(_bill.id)
                    .delete()
                    .then((value) {
                  _showProgressUi(msg: "Bill deleted!");
                  Navigator.pop(context);
                  Navigator.pop(context);
                });
              } on FirebaseAuthException catch (e) {
                _showProgressUi(errMsg: "${e.message}.");
              } catch (e) {
                _showProgressUi(errMsg: "$e.");
              }
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  _updateBillingDates() {
    if (_bill.billType?.description?.toLowerCase() != 'payment') {
      try {
        CollectionReference collection = _ffInstance.collection("users");
        UserProfile userProfile = UserProfile();
        collection
          .orderBy("name").get().then((snapshots) {
          for (var document in snapshots.docs) {
            if (_bill.payerIds?.contains(document.id) ?? false) {
              userProfile =
                  UserProfile.fromJson(document.data() as Map<String, dynamic>);
              userProfile.id = document.id;
              if (userProfile.billingDate == null) {
                collection.doc(userProfile.id).update({
                  'billing_date': _bill.billDate?.toIso8601String()
                }).whenComplete(() {});
              }
            }
          }
        }).whenComplete(() {
          _showProgressUi();
        });
      } on FirebaseAuthException catch (e) {
        _showProgressUi(errMsg: "${e.message}.");
      } catch (e) {
        _showProgressUi(errMsg: "$e.");
      }
    }
  }

  _cancel() {
    setState(() {
      _ctrlBillDate.clear();
      _ctrlAmount.clear();
      _selectedUserList.clear();
    });
    Navigator.of(context).pop(false);
  }

  Future<void> _getPayers() async {
    //_showProgressUi(true);

    try {
      List<dynamic> users = [];
      CollectionReference _collection = _ffInstance.collection("users");
      _collection
          .orderBy("name").get().then((snapshots) {
        for (var document in snapshots.docs) {
          //String pbt = "${document.id}_$_billType";
          users.add([document.id, document.get('name')]);
        }
      }).whenComplete(() {
        setState(() {
          _userList.clear();
          _userList.addAll(users);
        });
        //_showProgressUi(false);
        _setSelectedPayersDisplay();
      });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(errMsg: "${e.message}.");
    } catch (e) {
      _showProgressUi(errMsg: "$e.");
    }
  }

  Widget _payersSelectionWidget() {
    List<Widget> mList = <Widget>[];
    for (int b = 0; b < _userList.length; b++) {
      String id = _userList[b][0];
      String displayname = _userList[b][1] ?? "No Name";
      mList.add(CheckboxListTile(
        selected: _selectedUserList.toString().contains(id),
        //selected: _selectedList.contains(id),
        //selected: _selectedList.contains((value) => value[0] == id),
        //selected: _selectedList.contains((value) => value.contains(id)),
        onChanged: (bool? value) {
          setState(() {
            if (value as bool) {
              _selectedUserList.add(id);
              _bill.payerIds?.add(id);
              _bill.payersBillType?.add("${id}_1");
            } else {
              _selectedUserList.remove(id);
              _bill.payerIds?.remove(id);
              _bill.payersBillType?.remove("${id}_1");
            }
          });
          if (kDebugMode) {
            print(_selectedUserList);
          }
          _setSelectedPayersDisplay();
        },
        value: _selectedUserList.toString().contains(id),
        title: Text(displayname),
        controlAffinity: ListTileControlAffinity.leading,
      ));
    }
    return ListView(shrinkWrap: true, children: mList);
  }

  _setSelectedPayersDisplay() {
    String selectedPayers = "";
    if (_selectedUserList.isNotEmpty && _userList.isNotEmpty) {
      int left = _selectedUserList.length - 1;
      String? payer = _userList
          .where((element) => element.first == _selectedUserId)
          .last
          .last
          .toString();
      String? others = left > 0 ? " and $left other${left > 1 ? 's' : ''}" : "";
      selectedPayers = "$payer$others";
    } else {
      selectedPayers = 'Select Payer(s)';
    }

    setState(() {
      _ctrlSelectedPayers.text = selectedPayers;
      _selectedAll = _userList.length == _selectedUserList.length;
    });
  }

  _showProgressUi({String? errMsg, String? msg}) {
    if (!msg.isNullOrEmpty()) {
      Fluttertoast.showToast(msg: msg!);
      setState(() => _isLoading = !_isLoading);
    }
    if (!errMsg.isNullOrEmpty()) {
      Fluttertoast.showToast(msg: "Something went wrong.");

      if (kDebugMode) {
        Print.red("msg: $errMsg");
      }
      setState(() => _isLoading = !_isLoading);
    }
  }
}
