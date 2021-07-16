import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:bills/helpers/extensions/format_extension.dart';

import 'components/modal_base.dart';

Future<bool?> showAddRecord(context, data, title, color) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Management(data, title, color);
    },
  );
}

class Management extends StatefulWidget {
  final String title;
  final dynamic data;
  final Color color;

  const Management(this.data, this.title, this.color);

  @override
  State<StatefulWidget> createState() {
    return _ManagementState();
  }
}

class _ManagementState extends State<Management> {
  late FToast fToast = FToast();

  final DateTime _firstdate = DateTime(DateTime.now().year - 2);
  final DateTime _lastdate = DateTime.now();
  DateTime? _billdate = DateTime.now();
  num _amount = 0;
  int _kwh = 0;

  final _formKey = GlobalKey<FormState>();
  final _ctrlBillDate = TextEditingController();
  final _ctrlAmount = TextEditingController();
  final _ctrlKwh = TextEditingController();

  String _quantification = '';

  @override
  void initState() {
    super.initState();
    fToast.init(context);
    _quantification =
        widget.title.toLowerCase() == 'electricity' ? 'kwh' : 'cu.m';

    setState(() {
      _ctrlBillDate.text = _billdate!.format(dateOnly: true);
      _ctrlAmount.text = _amount.toString();
      _ctrlKwh.text = _kwh.toString();
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

    return generateModalBody(
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
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Amount', hintText: 'Amount'),
                controller: _ctrlAmount,
                onChanged: (value) {
                  setState(() {
                    _amount = num.parse(value);
                  });
                },
                onTap: () {
                  if (_amount.toString() == "0") {
                    _ctrlAmount.selection = TextSelection(
                        baseOffset: 0, extentOffset: _ctrlAmount.text.length);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Must be geater than 0.';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: _quantification, hintText: _quantification),
                controller: _ctrlKwh,
                onChanged: (value) {
                  setState(() {
                    _kwh = int.parse(value);
                  });
                },
                onTap: () {
                  if (_amount.toString() == "0") {
                    _ctrlKwh.selection = TextSelection(
                        baseOffset: 0, extentOffset: _ctrlKwh.text.length);
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Must be geater than 0.';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        [
          Expanded(
              child: TextButton(
                  onPressed: _cancel,
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: widget.color),
                  ))),
          Expanded(
            child: TextButton(
              child: Text('Save'),
              style: TextButton.styleFrom(
                  primary: Colors.white, backgroundColor: widget.color),
              // ButtonStyle(
              //   backgroundColor: MaterialStateProperty.all(widget.color),
              //   ),
              // color: widget.color,
              // textColor: Colors.white,
              onPressed: _saveRecord,
            ),
          )
        ],
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
          _quantification: _kwh,
          'created_on': DateTime.now().millisecondsSinceEpoch
        })
        .then((value) => print("Bill added."))
        .catchError((error) => print("Failed to add bill: $error"));
  }

  _cancel() {
    setState(() {
      // _electricBill = ElectricBill();
      // _ctrlDate.clear();
      _ctrlAmount.clear();
    });
    Navigator.of(context).pop(false);
  }

  _showToast(String msg) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.grey,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          //Icon(Icons.check),
          // SizedBox(
          //   width: 12.0,
          // ),
          Text(msg),
        ],
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: Duration(seconds: 3),
    );

    // Custom Toast Position
    fToast.showToast(
        child: toast,
        toastDuration: Duration(seconds: 3),
        positionedToastBuilder: (context, child) {
          return Positioned(
            child: child,
            top: 16.0,
            left: 16.0,
          );
        });
  }
}
