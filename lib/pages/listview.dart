import 'package:bills/pages/new_record.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  dynamic _data;
  late final Stream<QuerySnapshot> _listStream;
  String _quantification = '';
  String _collectionName = '';

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
            _addRecord(_data, widget.title);
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
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return !snapshot.hasData
            ? Center(
                child: Text('No Data'),
              )
            : ListView(
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(
                        DateTime.fromMillisecondsSinceEpoch(data['bill_date'])
                            .format(dateOnly: true)),
                    subtitle: Text(
                        'Created On: ${DateTime.fromMillisecondsSinceEpoch(data['created_on']).format()}'),
                    trailing: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'P ${data['amount']}',
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: 20, color: widget.color),
                        ),
                        Text('${data[_quantification]} $_quantification',
                            textAlign: TextAlign.right,
                            style: TextStyle(fontWeight: FontWeight.w200)),
                      ],
                    ),
                  );
                }).toList(),
              );
      },
    );
  }

  _addRecord(data, title) async {
    if ((await showAddRecord(
            context, data, _quantification, title, widget.color)) ??
        false) _getlist();
  }

  Future _getlist() async {
    var list = FirebaseFirestore.instance
        .collection(_collectionName)
        .orderBy('bill_date', descending: true)
        .snapshots();

    setState(() {
      _listStream = list;
    });
  }
}
