import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/dashboard.dart';
import 'package:bills/pages/pin/pin_home.dart';
//import 'package:bills/pages/signin/email.dart';
import 'package:bills/pages/signin/signin_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:global_configuration/global_configuration.dart';

enum LoginType { EMAIL, MOBILE_NUMBER, GOOGLE, PIN }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  await Firebase.initializeApp();
  await GlobalConfiguration().loadFromAsset("app_settings");

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
  MyApp() {
    // Access configuration at constructor
    GlobalConfiguration cfg = new GlobalConfiguration();
    print("isDebug has value ${cfg.get("isDebug")}");
    print("isDebug has value ${GlobalConfiguration().get("isDebug")}");
    print("isDebug has value ${cfg.get("isDebug")}, this should be null!");
  }

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
    _getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SignInHome(auth: _auth),
      //: EmailSignInPage(auth: _auth, isSignin: true),
    );
  }

  _getCurrentUser() async {
    _showProgressUi(true, "");

    if (_auth.currentUser != null) {
      setState(() {
        _currentUser = _auth.currentUser!;
      });
      try {
        DocumentReference _document = _collection.doc(_currentUser.uid);
        UserProfile userProfile = UserProfile();

        _document.get().then((snapshot) {
          if (snapshot.exists) {
            userProfile =
                UserProfile.fromJson(snapshot.data() as Map<String, dynamic>);
            userProfile.id = snapshot.id;
            // userProfile.displayName = snapshot.get('name');
            // userProfile.loggedIn = snapshot.get('logged_in');
          }
        }).whenComplete(() {
          setState(() {
            _userProfile = userProfile;
          });
          if (_userProfile.loggedIn == true) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Dashboard(auth: _auth)));
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PinHome(
                    auth: _auth,
                    displayName: _userProfile.displayName ??
                        userProfile.displayName ??
                        'User'),
              ),
            );
          }
        });
      } on FirebaseAuthException catch (e) {
        _showProgressUi(false, "${e.message}.");
      } catch (e) {
        _showProgressUi(false, "$e.");
      }
    } else {
      _showProgressUi(false, "");
    }
  }

  _showProgressUi(bool isLoading, String msg) {
    if (msg.length > 0) {
      Fluttertoast.showToast(msg: msg);
    }
    setState(() => _isLoading = isLoading);
  }
}
