import 'package:badges/badges.dart';
//import 'package:bills/helpers/firebase/firebase_helpers.dart';
import 'package:bills/helpers/functions/functions_global.dart';
import 'package:bills/models/bill_type.dart';
import 'package:bills/models/billing.dart';
//import 'package:bills/models/coins.dart';
import 'package:bills/models/menu.dart';
import 'package:bills/models/pallette_swatch.dart';
import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/about.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:bills/pages/components/custom_widgets.dart';
import 'package:bills/pages/maintenance/listview_bill_types.dart';
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
import 'package:palette_generator/palette_generator.dart';
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
  String? _imagePath;
  String? _loggedInId;
  UserProfile _userProfile = UserProfile();
  PaletteGenerator? _paletteGenerator;

  final FirebaseFirestore _ffInstance = FirebaseFirestore.instance;
  //late CollectionReference _collection;

  Billing? _billingCurrent = Billing();

  bool _isLoadingAmountToPay = false;
  // ignore: unused_field
  final bool _isLoading = false;
  final bool _isLoggingOut = false;

  final List<Menu> _billTypeMenuList = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final GlobalKey _drawerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    setState(() {
      _auth = widget.auth;
      _loggedInId = _auth.currentUser!.uid;
      _imagePath = _auth.currentUser!.photoURL;
      //_collection = _ffInstance.collection('users');
    });
    _onLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: true,
      onDrawerChanged: (isOpen) {
        if (!isOpen && _userProfile.isNewUser()) {
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
                  tileColor: _paletteGenerator?.vibrantColor?.color ??
                      Colors.white54, // Colors.yellow.shade800,
                  contentPadding: const EdgeInsets.fromLTRB(18, 20, 15, 15),
                  leading: _userProfile.isNewUser()
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
                    ListTile(
                      leading: const Icon(Icons.settings),
                      //minLeadingWidth: 0,
                      title: const Text('Settings'),
                      //trailing: const Icon(Icons.chevron_right, size: 20),
                      onTap: _settings,
                    ),
                    if (_userProfile.isAdmin ?? false) _getBillsWidgets(),
                    if (_userProfile.isAdmin ?? false) _getTestWidgets(),
                    if (_userProfile.isAdmin ?? false) _getMaintenanceWidget(),
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
        title: Text('Hi, ${_userProfile.name}'),
        leading: IconButton(
          icon: _userProfile.isNewUser()
              ? Badge(
                  badgeContent: const Text(''),
                  animationType: BadgeAnimationType.scale,
                  child: _getUserImage())
              : _getUserImage(),
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
            _openBills(context, ListViewBillTypes(auth: _auth));
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

  Future<void> _getPalletteColor() async {
    _paletteGenerator = await PaletteGenerator.fromImageProvider(
        _imagePath != null
            ? NetworkImage(_imagePath.toString())
            : _userProfile.userImage);
    setState(() {
      PalletteSwatch ps = PalletteSwatch();
      ps.dominantColor = _paletteGenerator?.dominantColor?.color.value ?? 0;
      ps.lightVibrantColor =
          _paletteGenerator?.lightVibrantColor?.color.value ?? 0;
      ps.vibrantColor = _paletteGenerator?.vibrantColor?.color.value ?? 0;
      ps.darkVibrantColor =
          _paletteGenerator?.darkVibrantColor?.color.value ?? 0;
      ps.lightMutedColor = _paletteGenerator?.lightMutedColor?.color.value ?? 0;
      ps.mutedColor = _paletteGenerator?.mutedColor?.color.value ?? 0;
      ps.darkMutedColor = _paletteGenerator?.darkMutedColor?.color.value ?? 0;
      _userProfile.palletteSwatch = ps;
    });
  }

  Widget _getUserImage() {
    return GetUserImage(
        height: 50,
        width: 50,
        borderColor: Colors.white,
        borderWidth: 1.5,
        //shape: BoxShape.circle,
        image: _imagePath != null
            ? NetworkImage(_imagePath.toString())
            : _userProfile.userImage);
  }

  Future<void> _getCurrentUser() async {
    _isLoading.updateProgressStatus(msg: "");

    try {
      DocumentReference document =
          _ffInstance.collection('users').doc(_loggedInId);
      UserProfile up = UserProfile();

      document.get().then((snapshot) {
        if (snapshot.exists) {
          up = UserProfile.fromJson(snapshot.data() as Map<String, dynamic>);
          up.id = snapshot.id;
          up.mapMembers();
        }
      }).whenComplete(() {
        if (_imagePath.isNullOrEmpty() && up.photoUrl != _imagePath) {
          document.update({"photo_url": _imagePath});
          up.photoUrl = _imagePath;
          up.userImage = _imagePath != null
              ? NetworkImage(_imagePath.toString())
              : up.userImage;
        }
        setState(() {
          _userProfile = up;
        });
        _isLoading.updateProgressStatus(msg: "");
      });
    } on FirebaseException catch (e) {
      _isLoading.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoading.updateProgressStatus(errMsg: "$e.");
    }
    _welcomeDialog(_userProfile.isNewUser());
  }

  Future _loadLandingPage() async {
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
        _isLoadingAmountToPay = true;
      });

      _ffInstance
          .collection("billings")
          .where("user_id", arrayContains: _loggedInId)
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
          _isLoadingAmountToPay = false;
        });
      });
    } on FirebaseAuthException catch (e) {
      _isLoadingAmountToPay.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoadingAmountToPay.updateProgressStatus(errMsg: "$e.");
    }
  }

  Widget _amountToPay() {
    return _isLoadingAmountToPay
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
          errorMsg = snapshot.error.toString();
          printMessage("list error: $errorMsg");
        }
        if (snapshot.data!.docs.isNotEmpty) {
          for (var doc in snapshot.data!.docs) {
            coins = doc.get("total_amount") ?? 0.00;
          }
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingWidget();
        }
        return  Card(
          child: ListTile(
            dense: true,
            title: const Text('Coins:', style: TextStyle(fontSize: 15)),
            subtitle: snapshot.hasError
                ? Text(errorMsg,
                    style: const TextStyle(color: Colors.redAccent))
                : null,
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
          Icon icon = b.iconData!.getIcon();
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

  _welcomeDialog(bool show) {
    return show
        ? showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => AlertDialog(
              title: const Text('Welcome to Bills'),
              content: const Text(
                  "Before using this app, let's set up a few things."),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context, 'Later'),
                  child: const Text('Later'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileHome(auth: _auth)),
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            ),
          )
        : null;
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
    await _getPalletteColor();
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
      //_getCurrentUser();
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
}
