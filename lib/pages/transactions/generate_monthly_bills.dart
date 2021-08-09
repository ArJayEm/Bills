import 'package:flutter/material.dart';

class GenerateMonthlyBills extends StatefulWidget {
  const GenerateMonthlyBills({Key? key}) : super(key: key);

  @override
  _GenerateMonthlyBillsState createState() => _GenerateMonthlyBillsState();
}

class _GenerateMonthlyBillsState extends State<GenerateMonthlyBills> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
