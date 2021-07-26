import 'dart:convert' show json;

import 'package:bills/pages/mpin/mpin.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:http/http.dart" as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/sign_in_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  // Optional clientId
  // clientId: '479882132969-9i9aqik3jfjd7qhci1nqf0bm2g71rm1u.apps.googleusercontent.com',
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

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
          color: Color.fromARGB(255, 255, 158, 0),
        ),
        brightness: Brightness.dark,
        primaryColor: Color.fromARGB(255, 242, 163, 38),
        // ignore: deprecated_member_use
        accentColor: Color.fromARGB(255, 255, 158, 0),
        textTheme: TextTheme(
          headline1: TextStyle(color: Color.fromARGB(255, 112, 88, 52)),
          headline6: TextStyle(fontWeight: FontWeight.bold),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //home: LandingPage(title: 'Bills')
      //home: SignInPage(),
      home: InitializerWidget(),
    );
  }
}

class InitializerWidget extends StatefulWidget {
  @override
  _InitializerWidgetState createState() => _InitializerWidgetState();
}

class _InitializerWidgetState extends State<InitializerWidget> {
  UserProfile _userProfile = UserProfile();

  late DocumentReference _document;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser(); //.whenComplete(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:
          _isLoading ? Center(child: CircularProgressIndicator()) : _getPage(),
    );
  }

  Widget _getPage() {
    if (_userProfile.loggedIn == true) {
      return MpinSignInPage(userProfile: _userProfile);
    } else {
      return SignInPage();
    }
  }

  Future<void> _getCurrentUser() async {
    setState(() {
      _isLoading = true;
    });

    FirebaseAuth _auth = FirebaseAuth.instance;
    UserProfile userProfile = UserProfile();
    GoogleSignInAccount? currentUser;

    if (_auth.currentUser == null) {
      _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
        currentUser = account;
      }).onDone(() {
        if (currentUser != null) {
          userProfile = UserProfile(
              id: currentUser!.id,
              displayName: _handleGetContact(currentUser!).toString());

          _document = FirebaseFirestore.instance
              .collection('users')
              .doc(userProfile.id);

          // if (_auth.currentUser == null) {
          //   _document.update({'logged_in': false});
          // } else {
          //   _document.update({'logged_in': true});
          // }

          _document.get().then((snapshot) {
            if (snapshot.exists) {
              userProfile = UserProfile(
                  id: snapshot.id,
                  displayName: snapshot.get('display_name'),
                  loggedIn: snapshot.get('logged_in'));
            }
          }).whenComplete(() {
            setState(() {
              _userProfile = userProfile;
            });
          });
        }
      });
      _googleSignIn.signInSilently();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<String> _handleGetContact(GoogleSignInAccount user) async {
    String? _contactText;
    _contactText = "Loading contact info...";
    final http.Response response = await http.get(
      Uri.parse('https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names'),
      headers: await user.authHeaders,
    );
    if (response.statusCode != 200) {
      _contactText = "People API gave a ${response.statusCode} "
          "response. Check logs for details.";
      print('People API ${response.statusCode} response: ${response.body}');
    }
    final Map<String, dynamic> data = json.decode(response.body);
    final String? namedContact = _pickFirstNamedContact(data);
    if (namedContact != null) {
      _contactText = "I see you know $namedContact!";
    } else {
      _contactText = "No contacts to display.";
    }

    return _contactText;
  }

  String? _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic>? connections = data['connections'];
    final Map<String, dynamic>? contact = connections?.firstWhere(
      (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    );
    if (contact != null) {
      final Map<String, dynamic>? name = contact['names'].firstWhere(
        (dynamic name) => name['displayName'] != null,
        orElse: () => null,
      );
      if (name != null) {
        return name['displayName'];
      }
    }
    return null;
  }

  // Future<void> _handleSignIn() async {
  //   try {
  //     GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
  //     setState(() {
  //       _userProfile = UserProfile(
  //           id: googleSignInAccount!.id,
  //           displayName:
  //               googleSignInAccount.displayName ?? googleSignInAccount.email,
  //           email: googleSignInAccount.email,
  //           photoUrl: googleSignInAccount.photoUrl);
  //     });
  //     Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) =>
  //                 LandingPage(title: 'Bills', user: _userProfile)));
  //   } catch (error) {
  //     print(error);
  //   }
  // }

  //Future<void> _handleSignOut() => _googleSignIn.disconnect();
}
