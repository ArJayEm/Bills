// import 'dart:js';

import 'package:bills/models/menu.dart';
import 'package:bills/models/payer.dart';
import 'package:bills/pages/about.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:bills/pages/pin/pin_home.dart';
import 'package:bills/pages/profile/profile_home.dart';
import 'package:bills/pages/settings/settings_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'listview.dart';

class Dashboard extends StatefulWidget {
  static const String route = '/';
  Dashboard({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late FirebaseAuth _auth;

  CollectionReference _collection =
      FirebaseFirestore.instance.collection('users');

  late String _displayName;
  num _curentAmount = 0;

  bool _getAmountToPayLoading = false;
  bool _isLoadingUser = false;
  String _errorMsg = '';

  List<Menu> menu = [
    Menu(
        location: 'Billing',
        view: ListViewPage(
            title: 'Billing',
            quantification: 'Quantity',
            color: Colors.green.shade800),
        icon: Icon(Icons.receipt, color: Colors.green.shade800)),
    Menu(
        location: 'Payments',
        view: ListViewPage(
            title: 'Payments',
            quantification: 'Quantity',
            color: Colors.green.shade800),
        icon: Icon(Icons.payments_outlined, color: Colors.green.shade800)),
    Menu(
        location: 'Electricity',
        view: ListViewPage(
            title: 'Electricity',
            quantification: 'kwh',
            color: Colors.deepOrange.shade400),
        icon: Icon(Icons.bolt, color: Colors.deepOrange.shade400)),
    Menu(
        location: 'Water',
        view: ListViewPage(
            title: 'Water', quantification: 'cu.m', color: Colors.lightBlue),
        icon: Icon(Icons.water_damage, color: Colors.lightBlue)),
    Menu(
        location: 'Loans',
        view: ListViewPage(
            title: 'Loans',
            quantification: 'Quantity',
            color: Colors.yellow.shade200),
        icon: Icon(Icons.money_outlined, color: Colors.yellow.shade200)),
    Menu(
        location: 'Salary',
        view: ListViewPage(
            title: 'Salarys',
            quantification: 'Quantity',
            color: Colors.lightGreen),
        icon: Icon(Icons.attach_money_outlined, color: Colors.lightGreen)),
    Menu(
        location: 'Subscriptions',
        view: ListViewPage(
            title: 'Subscriptions',
            quantification: 'Quantity',
            color: Colors.red.shade600),
        icon: Icon(Icons.subscriptions_rounded, color: Colors.red.shade600)),
  ];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    //_getSdkVersion();
    setState(() {
      _auth = widget.auth;
    });
    _getCurrentUser();
    _loadLandingPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      drawer: SafeArea(
        child: Drawer(
          child: Container(
            //decoration: BoxDecoration(color: Color(0xFF0098c2)),
            child: ListView(
              children: <Widget>[
                _isLoadingUser
                    ? Container(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(child: CircularProgressIndicator())
                            ]),
                      )
                    : ListTile(
                        contentPadding: EdgeInsets.fromLTRB(18, 20, 15, 15),
                        leading: _auth.currentUser!.photoURL != null
                            ? Container(
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white, width: 1.5),
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        fit: BoxFit.fill,
                                        image: NetworkImage(
                                          _auth.currentUser!.photoURL
                                              .toString(),
                                        ))))
                            : null,
                        title: Text(
                          "$_displayName",
                          style: TextStyle(fontSize: 20.0),
                        ),
                        trailing: Icon(Icons.chevron_right, size: 20),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProfileHome(auth: _auth)),
                          ).whenComplete(
                              () => _scaffoldKey.currentState!.openDrawer());
                        },
                      ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.settings),
                  minLeadingWidth: 0,
                  title: Text('Settings'),
                  trailing: Icon(Icons.chevron_right, size: 20),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SettingsHome(auth: _auth)),
                    ).whenComplete(
                        () => _scaffoldKey.currentState!.openDrawer());
                  },
                ),
                // Divider(),
                // ListTile(
                //   leading: Icon(Icons.expand),
                //   minLeadingWidth: 0,
                //   title: Text('New Record'),
                //   onTap: () {
                //     Navigator.pop(context);
                //     _openBills(context, SelectPayers());
                //   },
                // ),
                // Divider(),
                // ListTile(
                //   leading: Icon(Icons.info_outline),
                //   minLeadingWidth: 0,
                //   title: Text('Dynamic Form'),
                //   onTap: () {
                //     Navigator.pop(context);
                //     _openBills(context, DynamicForm());
                //   },
                // ),
                //Divider(),
                // Divider(),
                // ListTile(
                //   leading: Icon(Icons.expand),
                //   minLeadingWidth: 0,
                //   title: Text('Expandable'),
                //   onTap: () {
                //     Navigator.pop(context);
                //     _openBills(context, ExpandableSample());
                //   },
                // ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout),
                  minLeadingWidth: 0,
                  title: Text('Log Out'),
                  onTap: _logoutDialog,
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  minLeadingWidth: 0,
                  title: Text('About'),
                  onTap: () {
                    Navigator.pop(context);
                    _openBills(context, About());
                  },
                ),
                Divider(),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        textTheme: Theme.of(context).textTheme,
        title: Text('Bills'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadLandingPage,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            physics: BouncingScrollPhysics(),
            child: _buildDashboard(),
          ),
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Dashboard',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.receipt_long),
      //       label: 'Billing',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.person),
      //       label: 'Me',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor: Color.fromARGB(255, 255, 158, 0),
      //   onTap: () {
      // setState(() {
      //   _selectedIndex = index;
      // });
      // }),
      // ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: addUser,
      //   tooltip: 'Add ${widget.title}',
      //   child: Icon(Icons.add, color: Colors.white),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
    );
  }

  Future<void> _getCurrentUser() async {
    setState(() {
      _errorMsg = "";
      _isLoadingUser = true;
    });

    try {
      if (_auth.currentUser != null) {
        DocumentReference _document = _collection.doc(_auth.currentUser!.uid);
        Payer up = Payer();

        _document.get().then((snapshot) {
          if (snapshot.exists) {
            up.displayName = snapshot.get('display_name') ?? "";
            up.email = snapshot.get('email');
          }
        }).whenComplete(() {
          setState(() {
            _isLoadingUser = false;
            _displayName = up.displayName ?? "";
          });
          if (_auth.currentUser?.email != up.email) {
            _document.update({'display_name': _auth.currentUser!.displayName});
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      _errorMsg = '${e.message}';
    } catch (error) {
      _errorMsg = error.toString();
    }

    if (_errorMsg.length > 0) {
      setState(() => _isLoadingUser = false);
      Fluttertoast.showToast(msg: _errorMsg);
    }
  }

  Future _loadLandingPage() async {
    setState(() {
      _curentAmount = _getAmountToPayLoading ? 100 : 0;
    });
  }

  Widget _buildDashboard() {
    return Column(
      children: [..._amountToPay(), _menuButtons()],
    );
  }

  List<Widget> _amountToPay() {
    return [
      ListTile(
        title: Text('Amount to pay'),
        trailing: Text(_curentAmount.format(), style: TextStyle(fontSize: 20)),
      ),
      Divider(height: 2, indent: 10, endIndent: 10, color: Colors.grey),
      _curentAmount > 0
          ? SizedBox()
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thank you for your payment!',
                  style: TextStyle(fontSize: 20, height: 3),
                ),
                Text(
                  '',
                  style: TextStyle(height: 6),
                )
              ],
            ),
    ];
  }

  Widget _menuButtons() {
    return GridView.builder(
      shrinkWrap: true,
      physics: BouncingScrollPhysics(),
      itemCount: menu.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 1,
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0),
      itemBuilder: (BuildContext context, int index) {
        return Card(
          child: InkWell(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                menu[index].icon!,
                SizedBox(height: 20),
                Text(
                  menu[index].location!,
                  textAlign: TextAlign.center,
                )
              ],
            ),
            onTap: () {
              _setAllFalse();
              menu[index].isSelected = true;
              _openBills(context, menu[index].view!);
            },
          ),
        );
      },
    );
  }

  _openBills(context, view) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => view),
    );
  }

  _setAllFalse() {
    setState(() {
      for (int i = 0; i < menu.length; i++) {
        menu[i].isSelected = false;
      }
    });
  }

  Future<String?> _logoutDialog() {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Are you sure you want to logout?'),
        content: const Text('Your account will be removed from the device.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              DocumentReference _document =
                  _collection.doc(_auth.currentUser!.uid);
              late String displayName;

              _document.get().then((snapshot) {
                if (snapshot.exists) {
                  displayName = snapshot.get('display_name');
                  _document.update({'logged_in': false});
                }
              }).whenComplete(() {
                setState(() {
                  _displayName = displayName;
                });
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PinHome(auth: _auth, displayName: _displayName)));
              });
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
