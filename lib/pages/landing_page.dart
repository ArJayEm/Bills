// import 'dart:js';

import 'package:bills/models/menu.dart';
import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/mpin/mpin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'about_page.dart';
import 'listview_page.dart';

class LandingPage extends StatefulWidget {
  static const String route = '/';
  LandingPage({Key? key, required this.userProfile}) : super(key: key);

  //final User user;
  final UserProfile userProfile;

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  UserProfile _userProfile = UserProfile();

  num _curentAmount = 0;
  //int _selectedIndex = 0;

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
    _loadLandingPage();

    setState(() {
      _userProfile = widget.userProfile;
    });
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
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        // if (_sdkVersion != null) Text('SDK v$_sdkVersion'),
                        // if (isLogin)
                        //   Padding(
                        //     padding: const EdgeInsets.only(bottom: 10),
                        //     child: _buildUserInfo(
                        //         context, _profile!, _token!, _email),
                        //   ),
                        // isLogin
                        //     ? InkWell(
                        //         child: Text('Log Out'),
                        //         onTap: _onLogout,
                        //       )
                        //     : InkWell(
                        //         child: Text('Log In'),
                        //         onTap: _onLogin,
                        //       ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Column(children: [
                            Text('id: ${_userProfile.id}'),
                            Text('Hello, ${_userProfile.displayName}!'),
                            //Text('Email: ${_userProfile.email}'),
                            //Text('Number: ${_userProfile.phoneNumber}'),
                            //Text('Photo Url: ${_userProfile.photoUrl}')
                          ]),
                        )
                      ],
                    ),
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
                                  FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(_userProfile.id)
                                      .update({'logged_in': false});
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MpinSignInPage(
                                              userProfile: _userProfile)));
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

  Future _loadLandingPage() async {
    setState(() {
      _curentAmount = 0;
    });

    // Fluttertoast.showToast(
    //   msg: 'Welcome ${widget.userProfile.displayName}!',
    //   toastLength: Toast.LENGTH_SHORT,
    //   gravity: ToastGravity.CENTER,
    //   timeInSecForIosWeb: 1,
    //   // backgroundColor: Colors.red,
    //   // textColor: Colors.white,
    //   // fontSize: 16.0,
    // );
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
          //elevation: 0.2,
          // shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(8.0)),
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
                  // style: TextStyle(
                  //     fontSize: 10, color: Colors.black87),
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

  // Widget _signOut(context) {
  //   return TextButton(
  //       child: Text('Log Out'),
  //       style: TextButton.styleFrom(
  //           shape: StadiumBorder(),
  //           primary: Colors.white,
  //           backgroundColor: Color.fromARGB(255, 242, 163, 38)),
  //       onPressed: () async {
  //         await _auth.signOut();
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(builder: (context) => SignInPage()),
  //         );
  //       });
  // }

  // Future<void> _onLogin() async {
  //   await plugin.logIn(permissions: [
  //     FacebookPermission.publicProfile,
  //     FacebookPermission.email,
  //   ]);
  //   //await _updateLoginInfo();
  // }

  // Future<void> _onLogout() async {
  //   await plugin.logOut();
  //   //await _updateLoginInfo();
  // }

  // Future<void> _getSdkVersion() async {
  //   final sdkVesion = await plugin.sdkVersion;
  //   setState(() {
  //     _sdkVersion = sdkVesion;
  //   });
  // }

  _openBills(context, view) async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => view),
    );
    // Navigator.pushReplacement(context, MaterialPageRoute(
    //   builder: (context) {
    //     return view;
    //   },
    // )); //.whenComplete(() => _getList());
  }

  _setAllFalse() {
    setState(() {
      for (int i = 0; i < menu.length; i++) {
        menu[i].isSelected = false;
      }
    });
  }

  // Widget _buildUserInfo(BuildContext context, FacebookUserProfile profile,
  //     FacebookAccessToken accessToken, String? email) {
  //   final avatarUrl = _imageUrl;
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       if (avatarUrl != null)
  //         Center(
  //           child: Image.network(avatarUrl),
  //         ),
  //       Row(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: <Widget>[
  //           const Text('User: '),
  //           Text(
  //             '${profile.firstName} ${profile.lastName}',
  //             style: const TextStyle(fontWeight: FontWeight.bold),
  //           ),
  //         ],
  //       ),
  //       const Text('AccessToken: '),
  //       Text(
  //         accessToken.token,
  //         softWrap: true,
  //       ),
  //       if (email != null) Text('Email: $email'),
  //     ],
  //   );
  // }

  Future<void> addUser() async {
    String msg = '';
//     DatabaseReference mDatabase =
//         FirebaseDatabase.instance.reference().child('users');

// // ignore: unnecessary_null_comparison
//     if (mDatabase == null) {
//       await mDatabase
//           .set(_userProfile.id, {
//             'age': 26,
//             'company': 'eLGU Navotas',
//             'email': "raffmartinez14@gmail.com",
//             'full_name': "Raff Julius O. Martinez",
//             'mobile number': "+639352525219",
//             'mpin': "120568",
//           })
//           .then((value) => {msg = "User Added"})
//           .catchError((error) => {msg = "Failed to add user: $error"});
//     } else {}

    var doc = FirebaseFirestore.instance
        .collection('users')
        .doc(_userProfile.id.toString());
    doc
        .update({
          'age': 26,
          'company': 'eLGU Navotas',
          'email': "raffmartinez14@gmail.com",
          'full_name': "Raff Julius O. Martinez",
          'mobile number': "+639352525219",
          'mpin': "120568",
          'display_name': "+639352525219",
        })
        .then((value) => {msg = "User Added"})
        .catchError((error) => {msg = "Failed to add user: $error"});

    Fluttertoast.showToast(msg: msg);
  }

  //Future<void> getUsers() {}
}
