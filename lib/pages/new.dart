import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SelectPayers extends StatefulWidget {
  const SelectPayers({Key? key}) : super(key: key);

  @override
  _SelectPayersState createState() => _SelectPayersState();
}

class _SelectPayersState extends State<SelectPayers> {
  Map<String, bool> _selectedPayers = Map<String, bool>();
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _users;
  static Map<String, bool> mappedItem = Map<String, bool>();

  bool _sampleCheckState = false;
  String _errorMsg = '';

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _getPayers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Select Payers'),
        iconTheme: IconThemeData(color: Colors.grey.shade300),
        textTheme:
            TextTheme(headline6: TextStyle(color: Colors.white, fontSize: 25)),
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: Colors.grey.shade800,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Fluttertoast.showToast(msg: 'Done');
              },
              child: Icon(
                Icons.done,
                size: 26.0,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("users").snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Something went wrong'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return !snapshot.hasData
                ? Center(child: Text('No Data'))
                : ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      var data = snapshot.data!.docs;
                      return CheckboxListTile(
                        //dense: true,
                        contentPadding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                        value: _sampleCheckState,
                        onChanged: (bool? val) {
                          setState(() => _sampleCheckState = val ?? false);
                        },
                        title: Text(data[index].get('display_name').toString()),
                        subtitle: Text('id: ${data[index].id.toString()}'),
                        controlAffinity: ListTileControlAffinity.leading,
                        activeColor: Colors.green,
                      );
                    },
                  );
          },
        ),
      ),
    );
  }

  Future<void> _getPayers() async {
    setState(() {
      _errorMsg = "";
    });

    List<dynamic> users = [];
    try {
      var users = FirebaseFirestore.instance.collection("users").snapshots();
      setState(() {
        _users = users;
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
