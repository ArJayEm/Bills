import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class BillingHistory extends StatefulWidget {
  const BillingHistory({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _BillingHistoryState createState() => _BillingHistoryState();
}

class _BillingHistoryState extends State<BillingHistory> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey.shade300),
        //titleTextStyle: TextTheme(headline6: TextStyle(color: Colors.white, fontSize: 25)),
        title: const Text('Billing History'),
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Billing History'),
      ),
    );
  }
  
  Widget _buildBillingsListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: _ffInstance
          .collection("meter_readings")
          .where('userid_deleted', arrayContains: "${_selectedUserId}_0")
          .where("reading_type",
              isEqualTo: int.parse(_bill.billType?.id ?? "0"))
          .orderBy("reading_date", descending: true)
          //.limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          String msg = snapshot.error.toString();
          if (kDebugMode) {
            print("list error: $msg");
          }
          Fluttertoast.showToast(msg: msg);
          return const Center(child: Text('Something went wrong'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        return snapshot.data!.docs.isEmpty
            ? const Center(child: Text('No readings found.'))
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Card(
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            children: snapshot.data!.docs.map(
                              (DocumentSnapshot document) {
                                Reading reading = Reading.fromJson(
                                    document.data() as Map<String, dynamic>);
                                reading.id = document.id;
                                reading.billType = _billTypes.firstWhere(
                                    (element) =>
                                        element?.id == reading.type.toString());
                                String _lastModified =
                                    DateFormat('MMM dd, yyyy hh:mm aaa').format(
                                        reading.modifiedOn ??
                                            reading.createdOn);
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      //isThreeLine: true,
                                      //title: Text("${_setSelectedPayersDisplay(reading.payerIds)}${!(reading.description?.isEmpty ?? true) ? " | ${reading.description}" : ""}"),
                                      title: Text(
                                        '${reading.date?.formatDate(dateOnly: true)}',
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      subtitle: Text(_lastModified),
                                      trailing: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${reading.reading} ${reading.billType?.quantification}',
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontSize: 25,
                                              color: Color(_bill.billType
                                                      ?.iconData?.color ??
                                                  0),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        // setState(() {
                                        //   _isExpanded = !_isExpanded;
                                        // });
                                        _showDataManager(reading);
                                      },
                                    ),
                                    const Divider()
                                  ],
                                );
                              },
                            ).toList(),
                          ),
                        ),
                ),
              );
      },
    );
  }

}
