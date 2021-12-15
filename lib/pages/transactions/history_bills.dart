import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
}
