import 'package:bills/pages/biometrics/biometrics.dart';
import 'package:bills/pages/dashboard.dart';
import 'package:bills/pages/pin/current.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SettingsHome extends StatefulWidget {
  const SettingsHome({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _SettingsHomeState createState() => _SettingsHomeState();
}

class _SettingsHomeState extends State<SettingsHome> {
  late FirebaseAuth _auth;

  @override
  void initState() {
    super.initState();
    setState(() {
      _auth = widget.auth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: GestureDetector(
        //   onTap: () => Navigator.pop(context),
        //   child: Icon(Icons.arrow_back),
        // ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Dashboard(auth: _auth)),
            );
          },
          child: const Icon(Icons.arrow_back),
        ),
        iconTheme: IconThemeData(color: Colors.grey.shade300),
        //titleTextStyle: TextTheme(headline6: TextStyle(color: Colors.white, fontSize: 25)),
        title: const Text('Settings'),
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: Colors.grey.shade800,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const Divider(),
            ListTile(
              leading: const Icon(Icons.pin),
              minLeadingWidth: 0,
              title: const Text('Change PIN'),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EnterCurrent(auth: _auth)));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.fingerprint),
              minLeadingWidth: 0,
              title: const Text('Biometrics'),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Biometrics(auth: _auth)));
              },
            ),
            const Divider(),
            // ListTile(
            //   leading: Icon(Icons.restore),
            //   title: Text('Backup & Restore'),
            //   trailing: Icon(Icons.chevron_right, size: 20),
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => About()),
            //     );
            //   },
            // ),
            //Divider(),
          ],
        ),
      ),
    );
  }
}
