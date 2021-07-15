import 'package:bills/pages/new_record_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:bills/helpers/extensions/format_extension.dart';

import 'components/bottom_navigation.dart';

class ListViewPage extends StatefulWidget {
  ListViewPage({required this.title, required this.color});

  final String title;
  final Color color;

  @override
  _ListViewPage createState() => _ListViewPage();
}

class _ListViewPage extends State<ListViewPage> {
  late FToast fToast;

  DateTime _billdate = DateTime.now();
  num _amount = 0;
  int _kwh = 0;

  dynamic _data = null;

  final _ctrlBillDate = TextEditingController();
  final _ctrlAmount = TextEditingController();
  final _ctrlKwh = TextEditingController();

  late final Stream<QuerySnapshot> _listStream;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);

    _getlist();

    setState(() {
      _ctrlBillDate.text = _billdate.format(dateOnly: true);
      _ctrlAmount.text = _amount.toString();
      _ctrlKwh.text = _kwh.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          return Text('Something went wrong');
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
                        Text('${data['kwh']} kwh',
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
    if ((await showAddRecord(context, data, title, widget.color)) ?? false)
      _getlist();
  }

  Future _getlist() async {
    String collection = widget.title.toLowerCase();

    var list = FirebaseFirestore.instance
        .collection(collection)
        .orderBy('bill_date', descending: true)
        .snapshots();

    setState(() {
      _listStream = list;
    });
  }
}
