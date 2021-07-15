import 'package:bills/models/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';

import 'about_page.dart';
import 'components/bottom_navigation.dart';
//import 'electricity.dart';
// import 'components/electricity_manager.dart';
import 'listview_page.dart';
//import 'water.dart';

class LandingPage extends StatefulWidget {
  static const String route = '/';
  LandingPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final plugin = FacebookLogin(debug: true);
  String? _sdkVersion;
  FacebookAccessToken? _token;
  FacebookUserProfile? _profile;
  String? _email;
  String? _imageUrl;

  num _curentAmount = 0;

  List<Menu> menu = [
    //Menu(
    //    location: 'Bills',
    //    view: Bill(),
    //    icon: Icon(Icons.receipt_long_outlined, color: Colors.white),
    //    isSelected: true),
    // Menu(
    //     location: 'Payers',
    //     view: Payer(),
    //     icon: Icon(Icons.people_alt_outlined, color: Colors.yellowAccent)),
    Menu(
        location: 'Payments',
        view: ListViewPage(title: 'Payments', color: Colors.green.shade800),
        icon: Icon(Icons.payments_outlined, color: Colors.green.shade800)),
    Menu(
        location: 'Electricity',
        view: ListViewPage(
            title: 'Electricity', color: Colors.deepOrange.shade400),
        icon: Icon(Icons.bolt, color: Colors.deepOrange.shade400)),
    Menu(
        location: 'Water',
        view: ListViewPage(title: 'Water', color: Colors.lightBlue),
        icon: Icon(Icons.water_damage, color: Colors.lightBlue)),
    Menu(
        location: 'Loans',
        view: ListViewPage(title: 'Loans', color: Colors.yellow.shade200),
        icon: Icon(Icons.money_outlined, color: Colors.yellow.shade200)),
    Menu(
        location: 'Wages',
        view: ListViewPage(title: 'Wages', color: Colors.lightGreen),
        icon: Icon(Icons.attach_money_outlined, color: Colors.lightGreen)),
    Menu(
        location: 'Subscriptions',
        view: ListViewPage(title: 'Subscriptions', color: Colors.red.shade600),
        icon: Icon(Icons.subscriptions_rounded, color: Colors.red.shade600)),
  ];

  @override
  void initState() {
    super.initState();
    _getSdkVersion();
    _loadLandingPage();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isLogin = _token != null && _profile != null;
    // final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
    //     .collection('users')
    //     .orderBy('full_name')
    //     .snapshots();

    return Scaffold(
      drawer: SafeArea(
          child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Center(
                child: Column(
                  children: <Widget>[
                    if (_sdkVersion != null) Text('SDK v$_sdkVersion'),
                    if (isLogin)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child:
                            _buildUserInfo(context, _profile!, _token!, _email),
                      ),
                    isLogin
                        ? InkWell(
                            child: Text('Log Out'),
                            onTap: _onLogout,
                          )
                        : InkWell(
                            child: Text('Log In'),
                            onTap: _onLogin,
                          ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.restore),
              title: Text('Backup & Restore'),
              onTap: () {
                Navigator.pop(context);
                _openBills(About());
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('About'),
              onTap: () {
                Navigator.pop(context);
                _openBills(About());
              },
            ),
          ],
        ),
      )),
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        textTheme: Theme.of(context).textTheme,
        title: Text(widget.title),
      ),
      body: RefreshIndicator(
        onRefresh: _loadLandingPage,
        child: _buildBody(),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: addUser,
        tooltip: 'Add ${widget.title}',
        child: Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndDocked,
    );
  }

  Future _loadLandingPage() async {
    setState(() {
      _curentAmount = 0;
    });
  }

  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            _amountToPay(),
            _curentAmount > 0 ? SizedBox() : _thankYou(),
            _menuButtons(),
          ],
        ),
      ),
    );
  }

  Widget _amountToPay() {
    return Card(
      child: Text('Amount to pay ${_curentAmount.format()}'),
    );
  }

  Widget _thankYou() {
    return Card(
      child: Text('Thank you for your payment!'),
    );
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
              _openBills(menu[index].view!);
            },
          ),
        );
      },
    );
  }

  Future<void> _onLogin() async {
    await plugin.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);
    //await _updateLoginInfo();
  }

  Future<void> _onLogout() async {
    await plugin.logOut();
    //await _updateLoginInfo();
  }

  Future<void> _getSdkVersion() async {
    final sdkVesion = await plugin.sdkVersion;
    setState(() {
      _sdkVersion = sdkVesion;
    });
  }

  _openBills(Widget view) async {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) {
        return view;
      },
    )); //.whenComplete(() => _getList());
  }

  _setAllFalse() {
    setState(() {
      for (int i = 0; i < menu.length; i++) {
        menu[i].isSelected = false;
      }
    });
  }

  Widget _buildUserInfo(BuildContext context, FacebookUserProfile profile,
      FacebookAccessToken accessToken, String? email) {
    final avatarUrl = _imageUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (avatarUrl != null)
          Center(
            child: Image.network(avatarUrl),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text('User: '),
            Text(
              '${profile.firstName} ${profile.lastName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Text('AccessToken: '),
        Text(
          accessToken.token,
          softWrap: true,
        ),
        if (email != null) Text('Email: $email'),
      ],
    );
  }

  Future<void> addUser() {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    String fullName = 'John Wick';
    String company = 'Hired Killer';
    int age = 42;

    return users
        .add({
          'full_name': fullName, // John Doe
          'company': company, // Stokes and Sons
          'age': age // 42
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  //Future<void> getUsers() {}
}
