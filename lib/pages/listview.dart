import 'package:bills/models/bills.dart';
import 'package:bills/pages/new_record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:bills/helpers/extensions/format_extension.dart';

import 'components/bottom_navigation.dart';

class ListViewPage extends StatefulWidget {
  ListViewPage(
      {required this.title, required this.quantification, required this.color});

  final String title;
  final String quantification;
  final Color color;

  @override
  _ListViewPage createState() => _ListViewPage();
}

class _ListViewPage extends State<ListViewPage> {
  late FToast fToast = FToast();
  Bills? _bill;
  late Stream<QuerySnapshot> _listStream;
  String _quantification = '';
  String _collectionName = '';
  String _errorMsg = '';
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    fToast.init(context);

    setState(() {
      _collectionName = widget.title.toLowerCase();
      _quantification = widget
          .quantification; //_collectionName == 'electricity' ? 'kwh' : 'cu.m';
    });

    _getlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: widget.color,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _getlist,
        child: _buildBody(),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
      floatingActionButton: CustomFloatingActionButton(
          title: 'Add ${widget.title}',
          icon: Icons.add,
          color: widget.color,
          onTap: () {
            _showDataManager(_bill, widget.title);
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot>(
      stream: _listStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return !snapshot.hasData
            ? Center(child: Text('No Data'))
            : ListView(
                children: snapshot.data!.docs.map(
                  (DocumentSnapshot document) {
                    Bills _bill =
                        Bills.fromJson(document.data() as Map<String, dynamic>);
                    _bill.id = document.id;
                    // Map<String, dynamic> data =
                    //     document.data() as Map<String, dynamic>;
                    return ConstrainedBox(
                      constraints: new BoxConstraints(
                        minHeight: _isExpanded ? 100 : 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: Text(DateTime.fromMillisecondsSinceEpoch(
                                    _bill.billdate!)
                                .format(dateOnly: true)),
                            //subtitle: Text('Created On: ${DateTime.fromMillisecondsSinceEpoch(data['created_on']).format()}'),
                            subtitle: Text(
                                'id: ${document.id} | ${_bill.payerIds!.length}'),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'P ${_bill.amount}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontSize: 20, color: widget.color),
                                ),
                                Text(
                                  '${_bill.quantification} $_quantification',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontWeight: FontWeight.w200),
                                ),
                              ],
                            ),
                            onTap: () {
                              // setState(() {
                              //   _isExpanded = !_isExpanded;
                              // });
                              _showDataManager(_bill, widget.title);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ).toList(),
              );
      },
    );
  }

  _showDataManager(data, title) async {
    if ((await showAddRecord(
            context, data, _quantification, title, widget.color)) ??
        false) _getlist();
  }

  Future<void> _getlist() async {
    setState(() {
      _errorMsg = "";
    });

    try {
      var list = FirebaseFirestore.instance
          .collection(_collectionName)
          .orderBy('bill_date', descending: true)
          .snapshots();

      setState(() {
        _listStream = list;
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
}
