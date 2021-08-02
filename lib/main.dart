import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/dashboard.dart';
import 'package:bills/pages/mpin/mpin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:bills/pages/signin/home.dart';

enum LoginType { EMAIL, MOBILE_NUMBER, GOOGLE, MPIN }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    // MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider(create: (_) => User()),
    //     ChangeNotifierProvider(create: (_) => GoogleProvider()),
    //   ],
    //   child: MyApp(),
    // ),
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'),
        Locale('zh'),
        Locale('fr'),
        Locale('es'),
        Locale('de'),
        Locale('ru'),
        Locale('ja'),
        Locale('ar'),
        Locale('fa'),
        Locale("es"),
      ],
      title: 'Bills',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        iconTheme: IconThemeData(color: Colors.white),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          brightness: Brightness.dark,
          color: Colors.grey.shade800,
        ),
        brightness: Brightness.dark,
        primaryColor: Colors.grey.shade300,
        textTheme: TextTheme(
            // headline1: TextStyle(color: Color.fromARGB(255, 112, 88, 52)),
            // headline6: TextStyle(fontWeight: FontWeight.bold),
            ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: InitializerWidget(),
    );
  }
}

class InitializerWidget extends StatefulWidget {
  @override
  _InitializerWidgetState createState() => _InitializerWidgetState();
}

class _InitializerWidgetState extends State<InitializerWidget> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  late User _currentUser;
  UserProfile _userProfile = UserProfile();

  CollectionReference _collection =
      FirebaseFirestore.instance.collection('users');

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // setState(() {
    //   _currentUser = _auth.currentUser;
    // });
    _getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SignInPage(auth: _auth),
    );
  }

  _getCurrentUser() async {
    setState(() => _isLoading = true);
    String msg = '';

    if (_auth.currentUser != null) {
      setState(() {
        _currentUser = _auth.currentUser!;
      });
      try {
        DocumentReference _document = _collection.doc(_currentUser.uid);
        UserProfile userProfile = UserProfile();

        _document.get().then((snapshot) {
          if (snapshot.exists) {
            userProfile.id = snapshot.id;
            userProfile.displayName = snapshot.get('display_name');
            userProfile.loggedIn = snapshot.get('logged_in');
          }
        }).whenComplete(() {
          setState(() {
            _userProfile = userProfile;
          });
          if (_userProfile.loggedIn == true) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Dashboard(auth: _auth),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MpinSignInPage(
                    auth: _auth,
                    displayName: _userProfile.displayName ??
                        userProfile.displayName ??
                        'User'),
              ),
            );
          }
        });
      } on FirebaseAuthException catch (e) {
        setState(() => _isLoading = false);
        msg = '${e.message}';
      } catch (error) {
        setState(() => _isLoading = false);
        msg = error.toString();
      }
    } else {
      setState(() => _isLoading = false);
    }

    if (msg.length > 0) {
      print('error: $msg');
      Fluttertoast.showToast(msg: msg);
    }
  }

  // Future<void> _getCurrentUser() async {
  //   setState(() => _isLoading = true);

  //   if (_auth.currentUser == null) {
  //     _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
  //       setState(() => _currentUser = account);
  //       //   if (account != null) {
  //       //     userProfile.id = account.id;
  //       //     userProfile.displayName = _handleGetContact(account).toString();
  //       //     userProfile.email = account.email;
  //       //     userProfile.photoUrl = account.photoUrl;
  //       //   }
  //     });
  //     // _googleSignIn.signInSilently();
  //     // userProfile.id = _auth.currentUser!.uid;
  //     // userProfile.displayName = _auth.currentUser!.displayName;
  //     //     userProfile.email = _auth.currentUser!.email;
  //     //     userProfile.photoUrl = _auth.currentUser!.photoURL;
  //     //     userProfile.phoneNumber = _auth.currentUser!.phoneNumber;
  //   }

  //   // DocumentReference _document =
  //   //     _collection.doc(userProfile.id);
  //   // _document.get().then((snapshot) {
  //   //   if (snapshot.exists) {
  //   //     userProfile.id = snapshot.id;
  //   //     userProfile.displayName = snapshot.get('display_name');
  //   //     userProfile.loggedIn = snapshot.get('logged_in');
  //   //   }
  //   // }).whenComplete(() {
  //   //   setState(() => _userProfile = userProfile);
  //   // });
  //   setState(() => _isLoading = false);
  // }

  // Future<String> _handleGetContact(GoogleSignInAccount user) async {
  //   String? _contactText;
  //   _contactText = "Loading contact info...";
  //   final http.Response response = await http.get(
  //     Uri.parse('https://people.googleapis.com/v1/people/me/connections'
  //         '?requestMask.includeField=person.names'),
  //     headers: await user.authHeaders,
  //   );
  //   if (response.statusCode != 200) {
  //     _contactText = "People API gave a ${response.statusCode} "
  //         "response. Check logs for details.";
  //     print('People API ${response.statusCode} response: ${response.body}');
  //   }
  //   final Map<String, dynamic> data = json.decode(response.body);
  //   final String? namedContact = _pickFirstNamedContact(data);
  //   if (namedContact != null) {
  //     _contactText = "I see you know $namedContact!";
  //   } else {
  //     _contactText = "No contacts to display.";
  //   }

  //   return _contactText;
  // }

  // String? _pickFirstNamedContact(Map<String, dynamic> data) {
  //   final List<dynamic>? connections = data['connections'];
  //   final Map<String, dynamic>? contact = connections?.firstWhere(
  //     (dynamic contact) => contact['names'] != null,
  //     orElse: () => null,
  //   );
  //   if (contact != null) {
  //     final Map<String, dynamic>? name = contact['names'].firstWhere(
  //       (dynamic name) => name['displayName'] != null,
  //       orElse: () => null,
  //     );
  //     if (name != null) {
  //       return name['displayName'];
  //     }
  //   }
  //   return null;
  // }
}
