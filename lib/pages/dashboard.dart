import 'package:badges/badges.dart';
import 'package:bills/helpers/functions/functions_global.dart';
import 'package:bills/models/bill_type.dart';
import 'package:bills/models/billing.dart';
//import 'package:bills/models/coins.dart';
import 'package:bills/models/menu.dart';
import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/about.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:bills/pages/components/custom_widgets.dart';
import 'package:bills/pages/signin/pin/pin_home.dart';
import 'package:bills/pages/user/profile/profile_home.dart';
import 'package:bills/pages/settings/settings_home.dart';
import 'package:bills/pages/test/dropdown_test.dart';
import 'package:bills/pages/maintenance/new_billing.dart';
import 'package:bills/pages/user/history_bills.dart';
import 'package:bills/pages/maintenance/listview_users.dart';
import 'package:bills/pages/user/history_payment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
//import 'package:fluttertoast/fluttertoast.dart';
//import 'package:global_configuration/global_configuration.dart';
import 'package:print_color/print_color.dart';
import 'package:shimmer/shimmer.dart';

import 'maintenance/listview_bills.dart';

class Dashboard extends StatefulWidget {
  static const String route = '/';
  const Dashboard({Key? key, required this.auth}) : super(key: key);

  final FirebaseAuth auth;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  //bool _isDebug = false;
  //String _collectorId = "";
  _DashboardState() {
    //GlobalConfiguration cfg = GlobalConfiguration();
    //_isDebug = cfg.get("isDebug");
    //_collectorId = cfg.get("collectorId");
  }

  late FirebaseAuth _auth;
  UserProfile _userProfile = UserProfile();

  final FirebaseFirestore _ffInstance = FirebaseFirestore.instance;
  late CollectionReference _collection;

  Billing? _billingCurrent = Billing();

  bool _isLoadingGetAmountToPay = false;
  // ignore: unused_field
  final bool _isLoading = false;
  final bool _isLoadingUser = false;
  final bool _isLoggingOut = false;

  //int _selectedIndex = 0;
  bool _isNewUser = false;
  //bool _isPayer = false;
  //bool _hasRequiredFields = false;

  final List<Menu> _billTypeMenuList = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey _drawerKey = GlobalKey();

  //final Icon _iconData = const Icon(Icons.addchart, color: Colors.blueAccent);

  @override
  void initState() {
    super.initState();
    //_getSdkVersion();
    setState(() {
      _auth = widget.auth;
      _collection = _ffInstance.collection('users');
    });
    // if (kDebugMode) {
    //   print(
    //       "icondata: {color: ${_iconData.color?.value}, code_point: ${_iconData.icon?.codePoint}, font_family: ${_iconData.icon?.fontFamily}}");
    // }
    _onLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      onDrawerChanged: (isOpen) {
        if (!isOpen && _isNewUser) {
          _getCurrentUser();
        }
      },
      drawer: SafeArea(
        child: Drawer(
          key: _drawerKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DrawerHeader(
                padding: EdgeInsets.zero,
                child: ListTile(
                  tileColor: Colors.yellow.shade800,
                  contentPadding: const EdgeInsets.fromLTRB(18, 20, 15, 15),
                  leading: _isNewUser
                      ? Badge(
                          badgeContent: const Text(''),
                          animationType: BadgeAnimationType.scale,
                          child: _getUserImage(),
                        )
                      : _getUserImage(),
                  title: Text(
                    "${_userProfile.name}",
                    style: const TextStyle(fontSize: 20.0),
                  ),
                  subtitle:
                      Text("${(_userProfile.members.last["count"])} member(s)"),
                  trailing: const Icon(Icons.edit, size: 20),
                  onTap: _profile,
                ),
              ),
              Expanded(
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
                    // const Divider(indent: 15, endIndent: 15, thickness: 1),
                    // const Divider(),
                    // const Divider(indent: 15, endIndent: 15, thickness: 1),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      //minLeadingWidth: 0,
                      title: const Text('Settings'),
                      //trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: _settings,
                    ),
                    // const Divider(indent: 15, endIndent: 15, thickness: 1),
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
                    //const Divider(),
                    if (_userProfile.isAdmin ?? false) _getBillsWidgets(),
                    if (_userProfile.isAdmin ?? false) _getTestWidgets(),
                    if (_userProfile.isAdmin ?? false) _getMaintenanceWidget(),
                    // const Divider(indent: 15, endIndent: 15, thickness: 1),
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          //const Divider(indent: 15, endIndent: 15, thickness: 1),
                          ListTile(
                            leading: const Icon(Icons.logout),
                            //minLeadingWidth: 0,
                            title: const Text('Log Out'),
                            onTap: _logoutDialog,
                          ),
                          const Divider(
                              indent: 15, endIndent: 15, thickness: 1),
                          ListTile(
                            leading: const Icon(Icons.info_outline),
                            //minLeadingWidth: 0,
                            title: const Text('About'),
                            onTap: () {
                              Navigator.pop(context);
                              _openBills(context, const About());
                            },
                          ),
                        ],
                      ),
                    ),
                    // const Expanded(
                    //   child: Align(
                    //     alignment: FractionalOffset.bottomCenter,
                    //     child: ListTile(
                    //       leading:
                    //           Icon(Icons.account_box, color: Colors.white, size: 25),
                    //       //onTap: () {},
                    //       title: Text(
                    //         'Account',
                    //         style: TextStyle(color: Colors.white, fontSize: 20),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: Theme.of(context).iconTheme,
        //titleTextStyle: Theme.of(context).textTheme,
        title: Text('Hi, $_userProfile.name!'),
        leading: _isNewUser
            ? IconButton(
                icon: Badge(
                    badgeContent: const Text(''),
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
        onRefresh: _onLoad,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
            clipBehavior: Clip.hardEdge,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            child: _buildDashboard(),
            //  _widgetOptions.elementAt(_selectedIndex),
          ),
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: <BottomNavigationBarItem>[
      //     const BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'Dashboard',
      //     ),
      //     const BottomNavigationBarItem(
      //       icon: Icon(Icons.settings),
      //       label: 'Settings',
      //     ),
      //     BottomNavigationBarItem(
      //       // icon: ImageIcon(AssetImage("assets/icons/google.png"),
      //       //     color: Color(0xFF3A5A98)),
      //       icon: _hasRequiredFields
      //           ? Badge(
      //               badgeContent: const Text(''),
      //               animationType: BadgeAnimationType.scale,
      //               child: _getUserImage(),
      //             )
      //           : _getUserImage(),
      //       label: 'Me',
      //     ),
      //   ],
      //   showSelectedLabels: false,
      //   showUnselectedLabels: false,
      //   currentIndex: _selectedIndex,
      //   backgroundColor: Colors.grey.shade800,
      //   selectedItemColor: Colors.white,
      //   selectedFontSize: 12,
      //   unselectedItemColor: Colors.grey.shade700,
      //   onTap: (index) {
      //     setState(() {
      //       _selectedIndex = index;
      //     });
      //     switch (index) {
      //       case 2:
      //         //_profile();
      //         _scaffoldKey.currentState!.openDrawer();
      //         break;
      //       case 1:
      //         _settings();
      //         break;
      //       default:
      //         _home();
      //         break;
      //     }
      //   },
      // ),
      //),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: addUser,
      //   tooltip: 'Add ${widget.title}',
      //   child: Icon(Icons.add, color: Colors.white),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
    );
  }

  Widget _getTestWidgets() {
    return ExpansionTile(
      title: const Text("Test Widgets"),
      collapsedTextColor: Colors.white,
      leading: const Icon(Icons.science),
      childrenPadding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.arrow_drop_down),
          //minLeadingWidth: 0,
          title: const Text('Dropdown'),
          onTap: () {
            Navigator.pop(context);
            _openBills(context, const DropdDownTest());
          },
        ),
      ],
    );
  }

  Widget _getMaintenanceWidget() {
    return ExpansionTile(
      title: const Text("Maintenance"),
      collapsedTextColor: Colors.white,
      leading: const Icon(Icons.settings_applications),
      childrenPadding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.list_alt),
          //minLeadingWidth: 0,
          title: const Text('Bill Types'),
          onTap: () {
            Navigator.pop(context);
            _openBills(context, const DropdDownTest());
          },
        ),
      ],
    );
  }

  Widget _getBillsWidgets() {
    return ExpansionTile(
      title: const Text("Bills"),
      collapsedTextColor: Colors.white,
      leading: const Icon(Icons.list_alt),
      //tilePadding: const EdgeInsets.only(left: 0),
      //tilePadding: const EdgeInsets.only(left: 0),
      //controlAffinity: ListTileControlAffinity.trailing,
      childrenPadding: const EdgeInsets.fromLTRB(25, 0, 0, 0),
      children: <Widget>[
        ..._billTypeMenuList.map((menu) {
          return ListTile(
            //minLeadingWidth: 0,
            leading: Text(menu.iconData.name!,
                style: TextStyle(
                    fontSize: 25,
                    fontFamily: menu.iconData.fontfamily,
                    color: Color(menu.iconData.color ?? 0))),
            title: Text(menu.location),
            onTap: () {
              _setAllFalse();
              menu.isSelected = true;
              _openBills(context, menu.view);
            },
          );
        }).toList()
      ],
    );
  }

  Widget _getUserImage() {
    return GetUserImage(
        height: 50,
        width: 50,
        borderColor: Colors.white,
        borderWidth: 1.5,
        //shape: BoxShape.circle,
        imagePath: _auth.currentUser!.photoURL);
  }

  Future<void> _getCurrentUser() async {
    _isLoading.updateProgressStatus(msg: "");

    try {
      if (_auth.currentUser != null) {
        DocumentReference doc = _collection.doc(_auth.currentUser!.uid);
        UserProfile up = UserProfile.fromJson(doc as Map<String, dynamic>);
        up.id = doc.id;

        setState(() {
          _userProfile = up;
          _isNewUser = (up.userType.isNullOrEmpty()) ||
              (_userProfile.name.isNullOrEmpty()) ||
              up.membersArr.last.count == 0;
        });
    _isLoading.updateProgressStatus(msg: "");
        if (_isNewUser) {
          _welcomeDialog();
        }
      }
    } on FirebaseAuthException catch (e) {
      _isLoadingUser.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoadingUser.updateProgressStatus(errMsg: "$e.");
    }
  }

  Future _loadLandingPage() async {
    // setState(() {
    //   _currentAmount = _isLoadingGetAmountToPay ? 100 : 0;
    // });
    _getAmountToPay();
  }

  Widget _buildDashboard() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      children: [
        _amountToPay(),
        _buildCoinsWidget(),
        _billingPayment(),
        //if (_userProfile.isAdmin ?? false) _menuButtons(),
        if (_userProfile.isAdmin ?? false)
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.people_alt_outlined),
                  minLeadingWidth: 0,
                  title: const Text('Payers'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PayerList(auth: _auth)));
                  },
                ),
                const CustomDivider(),
                ListTile(
                  leading: const Icon(Icons.receipt_long),
                  minLeadingWidth: 0,
                  title: const Text('Generate Billing'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GenerateBills(auth: _auth)));
                  },
                ),
              ],
            ),
          )
      ],
    );
  }

  Widget _loadingWidget() {
    return Shimmer.fromColors(
      baseColor: Colors.grey,
      highlightColor: Colors.grey.shade100,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
          child: Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: double.infinity,
                  height: 18.0,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _billingPayment() {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.receipt),
            minLeadingWidth: 0,
            title: const Text('Billing History'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BillingHistory(auth: _auth)));
            },
          ),
          const CustomDivider(),
          ListTile(
            leading: const Icon(Icons.payment),
            minLeadingWidth: 0,
            title: const Text('Payment History'),
            trailing: const Icon(Icons.chevron_right),
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

  Future<void> _getAmountToPay() async {
    Billing billing = Billing();
    try {
      setState(() {
        _isLoadingGetAmountToPay = true;
      });

      _ffInstance
          .collection("billings")
          .where("user_id", arrayContains: _auth.currentUser!.uid)
          .where("deleted", isEqualTo: false)
          .orderBy("billing_date", descending: true)
          .limit(1)
          .get()
          .then((snapshots) {
        for (var document in snapshots.docs) {
          billing = Billing.fromJson(document.data());
        }
      }).whenComplete(() {
        setState(() {
          _billingCurrent = billing;
        });
        setState(() {
          _isLoadingGetAmountToPay = false;
        });
      });
    } on FirebaseAuthException catch (e) {
      _isLoadingGetAmountToPay.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoadingGetAmountToPay.updateProgressStatus(errMsg: "$e.");
    }
  }

  Widget _amountToPay() {
    return _isLoadingGetAmountToPay
        ? _loadingWidget()
        : Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                    title: const Text('Amount to pay',
                        style: TextStyle(fontSize: 20)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${_billingCurrent?.totalPayment.formatForDisplay()}",
                          style: const TextStyle(fontSize: 22),
                        ),
                        if ((_billingCurrent?.totalPayment ?? 0) > 0)
                          Text(
                            "Due on: ${_billingCurrent?.dueDate?.formatDate(dateOnly: true)}",
                            style: TextStyle(
                                color: _billingCurrent!.dueDate!
                                            .compareTo(DateTime.now()) >
                                        0
                                    ? Colors.redAccent
                                    : Colors.white),
                          ),
                      ],
                    )),
                if ((_billingCurrent?.totalPayment ?? 0) == 0)
                  const CustomDivider(),
                if ((_billingCurrent?.totalPayment ?? 0) == 0)
                  const ListTile(
                    dense: true,
                    title: Text(
                      'Thank you for your payment!',
                      style: TextStyle(fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ),
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

  // Widget _menuButtons() {
  //   return Column(
  //     children: [
  //       GridView.builder(
  //         padding: const EdgeInsets.fromLTRB(0, 5, 0, 10),
  //         shrinkWrap: true,
  //         physics: const BouncingScrollPhysics(),
  //         itemCount: _billTypeMenuList.length,
  //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //             childAspectRatio: 1,
  //             crossAxisCount: 4,
  //             crossAxisSpacing: 4.0,
  //             mainAxisSpacing: 4.0),
  //         itemBuilder: (BuildContext context, int index) {
  //           //_updateBillType(menu[index]);
  //           return Card(
  //             child: InkWell(
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: <Widget>[
  //                   //_billTypeMenuList[index].icon!,
  //                   Text("${_billTypeMenuList[index].iconData.name}",
  //                       style: TextStyle(
  //                           fontSize: 25,
  //                           fontFamily:
  //                               _billTypeMenuList[index].iconData.fontfamily,
  //                           color: Color(
  //                               _billTypeMenuList[index].iconData.color ?? 0))),
  //                   const SizedBox(height: 10),
  //                   Text(_billTypeMenuList[index].location,
  //                       textAlign: TextAlign.center,
  //                       overflow: TextOverflow.ellipsis)
  //                 ],
  //               ),
  //               onTap: () {
  //                 _setAllFalse();
  //                 setState(() {
  //                   _billTypeMenuList[index].isSelected = true;
  //                 });
  //                 _openBills(context, _billTypeMenuList[index].view);
  //               },
  //             ),
  //           );
  //         },
  //       )
  //     ],
  //   );
  // }

  Widget _buildCoinsWidget() {
    String errorMsg = "";
    bool hasError = false;
    num coins = 0.00;

    return StreamBuilder<QuerySnapshot>(
      stream: _ffInstance
          .collection("coins")
          //.where("payerid_deleted", isEqualTo: "${_selectedUserId}_0")
          .where("user_ids", arrayContains: _userProfile.id)
          .where("deleted", isEqualTo: false)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          hasError = true;
          errorMsg = snapshot.error.toString();
          ExceptionHandler.printMessage("list error: $errorMsg");
        }
        if (snapshot.data!.docs.isNotEmpty) {
          for (var doc in snapshot.data!.docs) {
            coins = doc.get("total_amount") ?? 0.00;
          }
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingWidget();
        }
        return Card(
          child: ListTile(
            dense: true,
            title: const Text('Coins:', style: TextStyle(fontSize: 15)),
            subtitle: hasError ? Text(errorMsg) : null,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  (snapshot.data!.docs.isEmpty ? 0.00 : coins)
                      .formatForDisplay(),
                ),
              ],
            ),
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
      for (var btml in _billTypeMenuList) {
        btml.isSelected = false;
      }
    });
  }

  Future<void> _getBillTypes() async {
    List<BillType?> billTypes = [];
    List<Menu> menu = [];
    try {
      _ffInstance
          .collection("bill_types")
          .orderBy('description')
          .get()
          .then((snapshots) {
        for (var document in snapshots.docs) {
          BillType? b = BillType.fromJson(document.data());
          b.id = document.id;
          billTypes.add(b);
          Icon icon = Icon(
              IconData(b.iconData?.codepoint ?? 0,
                  fontFamily: b.iconData?.fontfamily),
              color: Color(b.iconData?.color ?? 0));
          menu.add(Menu(
              location: "${b.description}",
              iconData: b.iconData!,
              view: ListViewBills(billType: b, auth: _auth),
              icon: icon));
          Print.green(
              "Icon : [codePoint: ${icon.icon?.codePoint}, key: ${icon.icon.toString()}, family: ${icon.icon?.fontFamily}, package: ${icon.icon?.fontPackage}]");
        }
      }).whenComplete(() {
        setState(() {
          _billTypeMenuList.clear();
          _billTypeMenuList.addAll(menu);
        });
      });
    } on FirebaseAuthException catch (e) {
      _isLoading.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoading.updateProgressStatus(errMsg: "$e.");
    }
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
    _isLoggingOut.updateProgressStatus(msg: "Logging Out.");

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PinHome(auth: _auth, displayName: "${_userProfile.name}")));
  }

  Future<void> _onLoad() async {
    setState(() {
      _billTypeMenuList.clear();
    });
    await _getCurrentUser();
    await _getBillTypes();
    await _loadLandingPage();
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
      MaterialPageRoute(
          builder: (context) =>
              SettingsHome(auth: _auth, scaffoldKey: _scaffoldKey)),
    ).whenComplete(() => _scaffoldKey.currentState!.openDrawer());
  }

  // ignore: unused_element
  void _home() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => Dashboard(auth: _auth)));
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({Key? key}) : super(key: key);

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
    return const Divider(
        height: 2, indent: 10, endIndent: 10, color: Colors.grey);
  }
}
