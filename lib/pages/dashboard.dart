// import 'dart:js';

import 'package:badges/badges.dart';
import 'package:bills/models/menu.dart';
import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/about.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:bills/pages/components/custom_widgets.dart';
import 'package:bills/pages/pin/pin_home.dart';
import 'package:bills/pages/profile/profile_home.dart';
import 'package:bills/pages/settings/settings_home.dart';
import 'package:bills/pages/test/dropdown_test.dart';
import 'package:bills/pages/transactions/billing_history.dart';
import 'package:bills/pages/transactions/payer_list.dart';
import 'package:bills/pages/transactions/payment_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_configuration/global_configuration.dart';

import 'listview.dart';

class Dashboard extends StatefulWidget {
  static const String route = '/';
  Dashboard({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isDebug = false;
  String _collectorId = "";
  _DashboardState() {
    // Access configuration at constructor
    GlobalConfiguration cfg = new GlobalConfiguration();
    _isDebug = cfg.get("isDebug");
    _collectorId = cfg.get("collectorId");
    //Fluttertoast.showToast(msg: "isDebug: $isDebug");
  }

  late FirebaseAuth _auth;
  UserProfile _userProfile = UserProfile();

  CollectionReference _collection =
      FirebaseFirestore.instance.collection('users');

  String? _displayname;
  num _curentAmount = 0;

  bool _isPayer = false;
  bool _getAmountToPayLoading = false;
  // ignore: unused_field
  bool _isLoadingUser = false;

  int _selectedIndex = 0;
  bool _isNewUser = false;
  bool _hasRequiredFields = false;

  List<Menu> menu = [
    // Menu(
    //     location: 'Billing',
    //     view: ListViewPage(
    //         title: 'Billing',
    //         quantification: 'Quantity',
    //         color: Colors.green.shade800),
    //     icon: Icon(Icons.receipt, color: Colors.green.shade800)),
    Menu(
        location: 'Payments',
        view: ListViewPage(
            title: 'Payments',
            quantification: 'Quantity',
            color: Colors.green.shade800),
        icon: Icon(Icons.payment, color: Colors.green.shade800)),
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
        location: 'Salarys',
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
  final GlobalKey _drawerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    //_getSdkVersion();
    setState(() {
      _auth = widget.auth;
    });
    _getCurrentUser();
    _loadLandingPage();
    // _widgetOptions.add(_buildDashboard());
    // _widgetOptions.add(SettingsHome(auth: _auth));
    // _widgetOptions.add(ProfileHome(auth: _auth));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      onDrawerChanged: (isOpen) {
        if (!isOpen && _hasRequiredFields) {
          _getCurrentUser();
        }
      },
      drawer: SafeArea(
        child: Drawer(
          key: _drawerKey,
          child: Container(
            //decoration: BoxDecoration(color: Color(0xFF0098c2)),
            child: ListView(
              children: <Widget>[
                // _isLoadingUser
                //     ? Container(
                //         padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                //         child: Row(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               Center(child: CircularProgressIndicator())
                //             ]),
                //       )
                //     :
                ListTile(
                  contentPadding: EdgeInsets.fromLTRB(18, 20, 15, 15),
                  leading: _hasRequiredFields
                      ? Badge(
                          badgeContent: Text(''),
                          animationType: BadgeAnimationType.scale,
                          child: _getUserImage(),
                        )
                      : _getUserImage(),
                  title: Text(
                    "$_displayname",
                    style: TextStyle(fontSize: 20.0),
                  ),
                  trailing: Icon(Icons.chevron_right, size: 20),
                  onTap: _profile,
                ),
                Divider(indent: 15, endIndent: 15, thickness: 1),
                ListTile(
                  leading: Icon(Icons.settings),
                  minLeadingWidth: 0,
                  title: Text('Settings'),
                  trailing: Icon(Icons.chevron_right, size: 20),
                  onTap: _settings,
                ),
                //Divider(indent: 15, endIndent: 15, thickness: 1),
                // ListTile(
                //   leading: Icon(Icons.expand),
                //   minLeadingWidth: 0,
                //   title: Text('New Record'),
                //   onTap: () {
                //     Navigator.pop(context);
                //     _openBills(context, SelectPayers());
                //   },
                // ),
                //Divider(indent: 15, endIndent: 15, thickness: 1),
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
                //Divider(indent: 15, endIndent: 15, thickness: 1),
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
                Divider(indent: 15, endIndent: 15, thickness: 1),
                ListTile(
                  leading: Icon(Icons.expand),
                  minLeadingWidth: 0,
                  title: Text('Dropdown'),
                  onTap: () {
                    Navigator.pop(context);
                    _openBills(context, DropdDownTest());
                  },
                ),
                Divider(indent: 15, endIndent: 15, thickness: 1),
                ListTile(
                  leading: Icon(Icons.logout),
                  minLeadingWidth: 0,
                  title: Text('Log Out'),
                  onTap: _logoutDialog,
                ),
                Divider(indent: 15, endIndent: 15, thickness: 1),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  minLeadingWidth: 0,
                  title: Text('About'),
                  onTap: () {
                    Navigator.pop(context);
                    _openBills(context, About());
                  },
                ),
                Divider(indent: 15, endIndent: 15, thickness: 1),
              ],
            ),
          ),
        ),
      ),
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        //titleTextStyle: Theme.of(context).textTheme,
        title: Text('Bills'),
        leading: _hasRequiredFields
            ? IconButton(
                icon: Badge(
                    badgeContent: Text(''),
                    animationType: BadgeAnimationType.scale,
                    //child: Icon(Icons.menu)),
                    child: _getUserImage()),
                onPressed: () => _scaffoldKey.currentState!.openDrawer(),
              )
            : IconButton(
                //icon: Icon(Icons.menu),
                icon: _getUserImage(),
                onPressed: () => _scaffoldKey.currentState!.openDrawer(),
              ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadLandingPage,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(10),
            physics: BouncingScrollPhysics(),
            child: _buildDashboard(),
            //  _widgetOptions.elementAt(_selectedIndex),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("assets/icons/google.png"),
              color: Color(0xFF3A5A98),
            ),
            label: 'Me',
          ),
        ],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        backgroundColor: Colors.grey.shade800,
        selectedItemColor: Colors.white,
        selectedFontSize: 12,
        unselectedItemColor: Colors.grey.shade700,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // switch (index) {
          //   case 2:
          //     _profile();
          //     break;
          //   case 1:
          //     _settings();
          //     break;
          //   default:
          //     _home();
          //     break;
          // }
        },
      ),
      //),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: addUser,
      //   tooltip: 'Add ${widget.title}',
      //   child: Icon(Icons.add, color: Colors.white),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
    );
  }

  Widget _getUserImage() {
    return GetUserImage(
        height: 40,
        width: 40,
        borderColor: Colors.white,
        borderWidth: 1.5,
        //shape: BoxShape.circle,
        imagePath: _auth.currentUser!.photoURL);
  }

  Future<void> _getCurrentUser() async {
    _showProgressUi(true, "");

    try {
      if (_auth.currentUser != null) {
        DocumentReference _document = _collection.doc(_auth.currentUser!.uid);
        UserProfile userProfile = UserProfile();

        _collection.get().then((snapshots) {
          snapshots.docs.forEach((document) {
            if (document.id == _auth.currentUser!.uid) {
              userProfile =
                  UserProfile.fromJson(document.data() as Map<String, dynamic>);
              userProfile.id = document.id;
            }
          });
        }).whenComplete(() {
          setState(() {
            _userProfile = userProfile;
            _displayname = userProfile.displayName ?? "No Name";
            _isNewUser = (userProfile.userType.isNullOrEmpty()) &&
                userProfile.members == 0;
            _hasRequiredFields = (userProfile.userType.isNullOrEmpty()) ||
                (_userProfile.displayName.isNullOrEmpty()) ||
                userProfile.members == 0;
            _isPayer = !_userProfile.userType.isNullOrEmpty() &&
                _userProfile.userType != _collectorId;
          });
          if (_auth.currentUser?.email == userProfile.email) {
            _document.update({
              'display_name': _displayname ?? _auth.currentUser!.displayName
            });
          }
          _showProgressUi(false, "");
          Fluttertoast.showToast(msg: _isPayer.toString());
          if (_isNewUser) {
            _welcomeDialog();
          }
        });
      }
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  Future _loadLandingPage() async {
    setState(() {
      _curentAmount = _getAmountToPayLoading ? 100 : 0;
    });
  }

  Widget _buildDashboard() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      children: [
        _isDebug || _isPayer ? _amountToPay() : SizedBox(),
        _isDebug || _isPayer ? _billingPayment() : SizedBox(),
        _isDebug || !_isPayer ? _menuButtons() : SizedBox(),
        _isDebug || !_isPayer
            ? Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.people_alt_outlined),
                      minLeadingWidth: 0,
                      title: Text('Payers'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PayerList(auth: _auth)));
                      },
                    ),
                    CustomDivider(),
                    ListTile(
                      leading: Icon(Icons.receipt_long),
                      minLeadingWidth: 0,
                      title: Text('Generate Bills'),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PayerList(auth: _auth)));
                      },
                    ),
                  ],
                ),
              )
            : SizedBox(),
      ],
    );
  }

  Widget _billingPayment() {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.receipt),
            minLeadingWidth: 0,
            title: Text('Billing History'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BillingHistory(auth: _auth)));
            },
          ),
          CustomDivider(),
          ListTile(
            leading: Icon(Icons.payment),
            minLeadingWidth: 0,
            title: Text('Payment History'),
            trailing: Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PaymentHistory(auth: _auth)));
            },
          ),
        ],
      ),
    );
  }

  Widget _amountToPay() {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text('Amount to pay', style: TextStyle(fontSize: 20)),
            trailing:
                Text(_curentAmount.format(), style: TextStyle(fontSize: 20)),
          ),
          CustomDivider(),
          _curentAmount > 0
              ? SizedBox()
              : ListTile(
                  dense: true,
                  title: Text(
                    'Thank you for your payment!',
                    style: TextStyle(fontSize: 15),
                    textAlign: TextAlign.center,
                  ),
                )
          // const ListTile(
          //   leading: Icon(Icons.album),
          //   title: Text('The Enchanted Nightingale'),
          //   subtitle: Text('Music by Julie Gable. Lyrics by Sidney Stein.'),
          // ),
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.end,
          //   children: <Widget>[
          //     TextButton(
          //       child: const Text('BUY TICKETS'),
          //       onPressed: () {/* ... */},
          //     ),
          //     const SizedBox(width: 8),
          //     TextButton(
          //       child: const Text('LISTEN'),
          //       onPressed: () {/* ... */},
          //     ),
          //     const SizedBox(width: 8),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _menuButtons() {
    return _isDebug
        ? Column(
            children: [
              GridView.builder(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
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
              )
            ],
          )
        : SizedBox();
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
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Are you sure you want to logout?'),
        content: const Text('account will be removed from the device.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              _logout();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  _welcomeDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Welcome to Bills'),
        content:
            const Text("Before using this app, let's set up a few things."),
        actions: <Widget>[
          // TextButton(
          //   onPressed: () => Navigator.pop(context, 'Cancel'),
          //   child: const Text('No'),
          // ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProfileHome(auth: _auth)),
              );
            },
            child: const Text("Let's go"),
          ),
        ],
      ),
    );
  }

  _logout() {
    _showProgressUi(true, "Logging Out.");

    try {
      DocumentReference _document = _collection.doc(_auth.currentUser!.uid);
      UserProfile userProfile = UserProfile();

      _document.get().then((snapshot) {
        if (snapshot.exists) {
          userProfile =
              UserProfile.fromJson(snapshot.data() as Map<String, dynamic>);
          userProfile.id = snapshot.id;
          //userProfile.displayName = snapshot.get('display_name');
          _document.update({'logged_in': false});
        }
      }).whenComplete(() {
        setState(() {
          _displayname = userProfile.displayName;
        });
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    PinHome(auth: _auth, displayName: _displayname!)));
      });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  _showProgressUi(bool isLoading, String msg) {
    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
    setState(() => _isLoadingUser = isLoading);
  }

  void _profile() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileHome(auth: _auth)),
    ).whenComplete(() {
      _getCurrentUser();
      _scaffoldKey.currentState!.openDrawer();
    });
  }

  void _settings() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsHome(auth: _auth)),
    ).whenComplete(() => _scaffoldKey.currentState!.openDrawer());
  }

  // ignore: unused_element
  void _home() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Dashboard(auth: _auth)));
  }
}

class CustomDivider extends StatelessWidget {
  // final double height;
  // final double indent;
  // final double endIndent;
  // final Color color;

  // CustomDivider(
  //     {this.height = 2,
  //     this.indent = 10,
  //     this.endIndent = 10,
  //     this.color = Colors.grey});

  @override
  Widget build(BuildContext context) {
    return Divider(height: 2, indent: 10, endIndent: 10, color: Colors.grey);
  }
}
