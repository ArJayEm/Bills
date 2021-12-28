import 'package:bills/pages/settings/settings_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bills/helpers/functions/functions_global.dart';

class Logs extends StatefulWidget {
  const Logs({Key? key, required this.auth, required this.scaffoldKey})
      : super(key: key);

  final FirebaseAuth auth;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _LogsState createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  late FirebaseAuth _auth;
  late GlobalKey<ScaffoldState> _scaffoldKey;
  String _logs = "No logs yet.";

  @override
  void initState() {
    super.initState();
    setState(() {
      _auth = widget.auth;
      _scaffoldKey = widget.scaffoldKey;
    });
    _getLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text("Logs"),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      SettingsHome(auth: _auth, scaffoldKey: _scaffoldKey)),
            );
          },
          child: const Icon(Icons.arrow_back),
        ),
        iconTheme: IconThemeData(color: Colors.grey.shade300),
      ),
      body: RefreshIndicator(
        onRefresh: _getLogs,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            clipBehavior: Clip.hardEdge,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              children: ListTile.divideTiles(context: context, tiles: <Widget>[
                ..._logs.split('\n').map((line) {
                  return ListTile(
                    title: Text(line),
                  );
                }).toList(),
              ]).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getLogs() async {
    setState(() async {
      _logs = await ExceptionHandler.readLogs();
    });
  }
}
