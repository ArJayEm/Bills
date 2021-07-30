// import 'dart:js';

import 'package:bills/models/menu.dart';
import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/mpin/mpin.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'about.dart';
import 'listview.dart';

class LandingPage extends StatefulWidget {
  static const String route = '/';
  LandingPage({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late FirebaseAuth _auth;
  late User _user;
  late String _displayName;

  CollectionReference _collection =
      FirebaseFirestore.instance.collection('users');

  num _curentAmount = 0;

  bool _getUserLoading = false;
  bool _getAmountToPayLoading = false;

  List<Menu> menu = [
    Menu(
        location: 'Billing',
        view: ListViewPage(
            title: 'Billing', quantification: '', color: Colors.green.shade800),
        icon: Icon(Icons.receipt, color: Colors.green.shade800)),
    Menu(
        location: 'Payments',
        view: ListViewPage(
            title: 'Payments',
            quantification: '',
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
            title: 'Loans', quantification: '', color: Colors.yellow.shade200),
        icon: Icon(Icons.money_outlined, color: Colors.yellow.shade200)),
    Menu(
        location: 'Salary',
        view: ListViewPage(
            title: 'Salarys', quantification: '', color: Colors.lightGreen),
        icon: Icon(Icons.attach_money_outlined, color: Colors.lightGreen)),
    Menu(
        location: 'Subscriptions',
        view: ListViewPage(
            title: 'Subscriptions',
            quantification: '',
            color: Colors.red.shade600),
        icon: Icon(Icons.subscriptions_rounded, color: Colors.red.shade600)),
  ];

  @override
  void initState() {
    super.initState();
    //_getSdkVersion();
    setState(() {
      _auth = widget.auth;
      //_user = _auth.currentUser!;
    });
    _getCurrentUser();
    _loadLandingPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SafeArea(
        child: Drawer(
          child: Container(
            //decoration: BoxDecoration(color: Color(0xFF0098c2)),
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      _user.photoURL.toString().length > 0 ?
                      Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(
                              _user.photoURL.toString(),
                            ),
                          ),
                        ),
                      ) : SizedBox(),
                      SizedBox(height: 28.0),
                      Text(
                        "Logged in as: ${_user.displayName}",
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.restore),
                  title: Text('Backup & Restore'),
                  onTap: () {
                    Navigator.pop(context);
                    _openBills(context, About());
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('About'),
                  onTap: () {
                    Navigator.pop(context);
                    _openBills(context, About());
                  },
                ),
                Divider(),
                Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Column(
                    children: <Widget>[
                      //Divider(),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Log Out'),
                        onTap: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title:
                                const Text('Are you sure you want to logout?'),
                            content: const Text(
                                'Your account will be removed from the device.'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.pop(context, 'Cancel'),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  _collection
                                      .doc(_user.uid)
                                      .update({'logged_in': false});
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MpinSignInPage(
                                              auth: _auth,
                                              displayName: _displayName)));
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
    setState(() => _getUserLoading = true);
    String msg = '';
    try {
      if (_auth.currentUser != null) {
        setState(() {
          _user = _auth.currentUser!;
        });
        DocumentReference _document = _collection.doc(_user.uid);
        UserProfile userProfile = UserProfile();

        _document.get().then((snapshot) {
          if (snapshot.exists) {
            userProfile.displayName = snapshot.get('display_name');
          }
        }).whenComplete(() {
          setState(() {
            _displayName = userProfile.displayName!;
          });
          if (userProfile.displayName != _user.displayName &&
              _user.displayName != null) {
            _document.update({'display_name': _user.displayName});
          }
        });
      }
    } catch (error) {
      msg = error.toString();
    }

    setState(() => _getUserLoading = false);
    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
  }

  Future _loadLandingPage() async {
    setState(() {
      _curentAmount = 0;
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
}
