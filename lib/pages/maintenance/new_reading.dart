// ignore_for_file: use_key_in_widget_constructors, unused_import, prefer_final_fields

import 'package:bills/models/bill.dart';
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

Future<bool?> showReadingManagement(
    context, reading, title, color, userid) async {
  return await showModalBottomSheet<bool?>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Management(reading, title, color, userid);
    },
  );
}

class Management extends StatefulWidget {
  final String title;
  final Reading reading;
  final Color color;
  final String? selectedUserId;

  const Management(this.reading, this.title, this.color, this.selectedUserId);

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

  Reading _reading = Reading();

  late String _selectedUser;
  List<String?> _selectedList = [];
  List<dynamic> _selectList = [];
  bool _selectedAll = false;

  int _billTypeId = 0;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    //_getPayers();
    setState(() {
      _reading = widget.reading;
      _selectedList = _reading.userIds ?? [];
      _billTypeId = _reading.readingtype!;
      _reading.readingtype = _billTypeId;
      _selectedUser = widget.selectedUserId ?? "";
      _reading.readingDate = _reading.readingDate ?? DateTime.now();
      _ctrlBillDate.text = _reading.readingDate!.format();
      _ctrlReading.text = _reading.reading.toString();
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
    //String titleLast = widget.title.substring(widget.title.length - 1, widget.title.length);
    //bool isLastS = widget.title.endsWith("s"); //titleLast == 's';
    String _title = widget.title.endsWith("s")
        ? widget.title.substring(0, widget.title.length - 1)
        : widget.title;

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
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
                Text('${_reading.id != null ? 'Manage' : "Add"} $_title',
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
      initialDate: _reading.readingDate!,
      firstDate: _firstdate,
      lastDate: _lastdate,
    );
    if (date != null) {
      setState(() {
        _reading.readingDate = DateTime(date.year, date.month, date.day);
        _ctrlBillDate.text = _reading.readingDate!.formatDate(dateOnly: true);
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

  _saveRecord() async {}

  _deleteRecord() async {}
}
