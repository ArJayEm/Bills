import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PayerList extends StatefulWidget {
  const PayerList({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _PayerListState createState() => _PayerListState();
}

class _PayerListState extends State<PayerList> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey.shade300),
        textTheme:
            TextTheme(headline6: TextStyle(color: Colors.white, fontSize: 25)),
        title: Text('Payer List'),
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: Center(
        child: Text('Payer List'),
      ),
    );
  }
}
