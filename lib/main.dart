// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:math';

import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/dashboard.dart';
import 'package:bills/pages/pin/pin_home.dart';
//import 'package:bills/pages/signin/email.dart';
import 'package:bills/pages/signin/signin_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:global_configuration/global_configuration.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  //await EasyLocalization.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("app_settings");
  // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
  //   statusBarColor: Colors.transparent,
  // ));

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
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'),
        const Locale('zh'),
        const Locale('fr'),
        const Locale('es'),
        const Locale('de'),
        const Locale('ru'),
        const Locale('ja'),
        const Locale('ar'),
        const Locale('fa'),
        const Locale("es"),
      ],
      title: 'Bills',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        iconTheme: const IconThemeData(color: Colors.white),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          //brightness: Brightness.dark,
          color: Colors.grey.shade800,
        ),
        brightness: Brightness.dark,
        primaryColor: Colors.grey.shade300,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: InitializerWidget(),
    );
  }
}

class InitializerWidget extends StatefulWidget {
  const InitializerWidget({Key? key}) : super(key: key);

  @override
  _InitializerWidgetState createState() => _InitializerWidgetState();
}

class _InitializerWidgetState extends State<InitializerWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User _currentUser;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      if (_auth.currentUser != null) {
        _currentUser = _auth.currentUser!;
      }
    });
    _getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SignInHome(auth: _auth),
    );
  }

  _getCurrentUser() async {
    _showProgressUi(true, "");

    try {
      DocumentReference _document =
          FirebaseFirestore.instance.collection("users").doc(_currentUser.uid);
      UserProfile up = UserProfile();

      _document.get().then((snapshot) {
        //if (snapshot.exists) {
        up.name = snapshot.get('name') as String?;
        up.userCode = snapshot.get('user_code') as String?;
        //up = UserProfile.fromJson(snapshot.data() as Map<String, dynamic>);
        up.id = snapshot.id;
        if (up.userCode.isNullOrEmpty()) {
          _document.update({"user_code": _generateUserCode()});
        }
        //}
      }).whenComplete(() {
        var view = up.loggedIn == true
            ? Dashboard(auth: _auth)
            : PinHome(auth: _auth, displayName: up.name ?? up.name ?? 'User');
        _navigateTo(view);
      });
    } on FirebaseAuthException catch (e) {
      _showProgressUi(false, "${e.message}.");
    } catch (e) {
      _showProgressUi(false, "$e.");
    }
  }

  _navigateTo(Widget view) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => view,
      ),
    );
  }

  String _generateUserCode() {
    var rng = Random();
    var code1 = rng.nextInt(9000) + 1000;
    var code2 = rng.nextInt(9000) + 1000;
    var code3 = rng.nextInt(9000) + 1000;
    return "$code1 $code2 $code3";
  }

  _showProgressUi(bool isLoading, String msg) {
    if (msg.isNotEmpty) {
      Fluttertoast.showToast(msg: msg);
    }
    setState(() => _isLoading = isLoading);
  }
}
