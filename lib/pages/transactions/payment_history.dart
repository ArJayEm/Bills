import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PaymentHistory extends StatefulWidget {
  const PaymentHistory({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _PaymentHistoryState createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey.shade300),
        textTheme:
            TextTheme(headline6: TextStyle(color: Colors.white, fontSize: 25)),
        title: Text('Payment History'),
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: Center(
        child: Text('Payment History'),
      ),
    );
  }
}
