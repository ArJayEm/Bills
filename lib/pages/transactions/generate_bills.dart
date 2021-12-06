import 'package:bills/models/billing.dart';
import 'package:bills/models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:bills/helpers/extensions/format_extension.dart';

class GenerateBills extends StatefulWidget {
  const GenerateBills({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _GenerateBillsState createState() => _GenerateBillsState();
}

class _GenerateBillsState extends State<GenerateBills> {
  bool _isDebug = false;
  _GenerateBillsState() {
    // Access configuration at constructor
    GlobalConfiguration cfg = new GlobalConfiguration();
    _isDebug = cfg.get("isDebug");
  }

  late FirebaseAuth _auth;
  String? _id;
  num? _availableCredits = 10.00;
  String? _selectedUser;
  bool _useAllCredits = false;
  final DateTime _firstdate = DateTime(DateTime.now().year - 2);
  final DateTime _lastdate = DateTime.now();
  Billing _bill = new Billing();

  final _ctrlBillDate = TextEditingController();
  final _ctrlCreditAmount = TextEditingController();

  final FocusNode _creditsFocusNode = FocusNode();

  String _title = "Generate Bills";

  bool _isLoading = false;

  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      _auth = widget.auth;
      _id = _auth.currentUser!.uid;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        //backgroundColor: widget.color,
        title: Text(
          _title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          physics: BouncingScrollPhysics(),
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(10),
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FormField<String>(
                          builder: (FormFieldState<String> state) {
                            return InputDecorator(
                              decoration: InputDecoration(
                                  prefixIcon:
                                      Icon(Icons.person, color: Colors.white),
                                  contentPadding: EdgeInsets.all(5),
                                  errorStyle: TextStyle(
                                      color: Colors.redAccent, fontSize: 16.0),
                                  hintText: 'Please select expense',
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(5.0))),
                              isEmpty: _selectedUser == '',
                              child: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .orderBy("name")
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData)
                                    return Center(
                                        child: CircularProgressIndicator());
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting)
                                    return Center(
                                        child: CircularProgressIndicator());
                                  return DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedUser,
                                      isDense: true,
                                      hint: Text("Choose user..."),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          _selectedUser = newValue;
                                          state.didChange(newValue);
                                        });
                                        if (_isDebug) {
                                          print("_selectedUser:$_selectedUser");
                                        }
                                      },
                                      items: snapshot.data?.docs
                                          .map((DocumentSnapshot document) {
                                        UserProfile up = UserProfile.fromJson(
                                            document.data()
                                                as Map<String, dynamic>);
                                        return DropdownMenuItem<String>(
                                          value: document.id,
                                          child: Text(up.name!),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.calendar_today,
                                  color: Colors.white),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              contentPadding: EdgeInsets.all(5),
                              labelText: 'Bill Date',
                              hintText: 'Bill Date'),
                          controller: _ctrlBillDate,
                          readOnly: true,
                          onTap: () {
                            _getDate();
                          },
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value == "0") {
                              return 'Invalid date.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        CheckboxListTile(
                          value: _useAllCredits,
                          onChanged: (val) {
                            setState(() {
                              _useAllCredits = val!;
                            });

                            if (!_useAllCredits) {
                              setState(() {
                                _bill.creditamount = 0.00;
                                _ctrlCreditAmount.clear();
                              });
                              _creditsFocusNode.requestFocus();
                            } else {
                              setState(() {
                                _bill.creditamount = _availableCredits;
                                _ctrlCreditAmount.text =
                                    (_availableCredits ?? 0.00)
                                        .formatForDisplay();
                              });
                              _creditsFocusNode.unfocus();
                            }
                          },
                          // subtitle: _useAllCredits!
                          //     ? Text(
                          //         'Required.',
                          //         style: TextStyle(color: Colors.red),
                          //       )
                          //     : null,
                          title: new Text(
                            'Available Credits: ${(_availableCredits ?? 0.00).formatForDisplay()}',
                            style: TextStyle(fontSize: 14.0),
                          ),
                          controlAffinity: ListTileControlAffinity.trailing,
                          activeColor: Colors.grey,
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(5),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              prefixIcon:
                                  Icon(Icons.credit_score, color: Colors.white),
                              labelText: 'Credit Amount',
                              hintText: 'Credit Amount'),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          enabled: !_useAllCredits,
                          focusNode: _creditsFocusNode,
                          controller: _ctrlCreditAmount,
                          onChanged: (value) {
                            if (value.isNotEmpty &&
                                num.parse(value) > _availableCredits!) {
                              print(
                                  'Cannot be greater than available credits.');
                            } else {
                              setState(() {
                                _bill.creditamount = num.parse(value);
                              });
                            }
                          },
                          validator: (String? value) {
                            if (value!.isNotEmpty &&
                                num.parse(value) > _availableCredits!) {
                              return "'Credit Amount' annot be greater than available credits.";
                            }
                            return null;
                          },
                          onTap: () {
                            if (_bill.creditamount.toString() == "0" ||
                                _bill.creditamount.toString() == "") {
                              _ctrlCreditAmount.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset: _ctrlCreditAmount.text.length);
                            }
                          },
                        ),
                        SizedBox(height: 30),
                        TextButton(
                          child:
                              Text("Generate", style: TextStyle(fontSize: 18)),
                          style: TextButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              primary: Colors.grey.shade700,
                              backgroundColor: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
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
        _ctrlBillDate.text =
            _bill.billdate!.formatDate(dateOnly: true, fullMonth: true);
      });
    }
  }
}
