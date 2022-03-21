// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'dart:math';

import 'package:bills/helpers/extensions/format_extension.dart';
import 'package:bills/helpers/functions/functions_global.dart';
import 'package:bills/models/user_profile.dart';
import 'package:bills/pages/dashboard.dart';
import 'package:bills/pages/signin/pin/pin_home.dart';
//import 'package:bills/pages/signin/email.dart';
import 'package:bills/pages/signin/signin_home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/services.dart';
//import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:global_configuration/global_configuration.dart';
//import 'package:palette_generator/palette_generator.dart';

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
      theme: ThemeData(
        iconTheme: const IconThemeData(color: Colors.white),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          //brightness: Brightness.dark,
          color: Colors.white54, //_paletteGenerator?.dominantColor?.color ??
        ),
        brightness: Brightness.dark,
        primaryColor: Colors.grey.shade300,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
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
  String? _imagePath;
  late User _currentUser;
  UserProfile _userProfile = UserProfile();
  // PaletteGenerator? _paletteGenerator;

  final bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _currentUser = _auth.currentUser!;
    });
    _onLoad();
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

  Future<void> _onLoad() async {
    //await _getPalletteColor();
    await _getCurrentUser();
  }

  // Future<void> _getPalletteColor() async {
  //   _paletteGenerator = await PaletteGenerator.fromImageProvider(
  //       _imagePath != null
  //           ? NetworkImage(_imagePath.toString())
  //           : _userProfile.userImage);
  //   setState(() {});
  // }

  _getCurrentUser() async {
    _isLoading.updateProgressStatus(msg: "");

    try {
      DocumentReference _document =
          FirebaseFirestore.instance.collection("users").doc(_currentUser.uid);
      UserProfile up = UserProfile();

      _document.get().then((snapshot) {
        up.name = snapshot.get('name') as String?;
        up.userCode = snapshot.get('user_code') as String?;
        up.id = snapshot.id;
        if (up.userCode.isNullOrEmpty()) {
          _document.update({"user_code": _generateUserCode()});
        }
      }).whenComplete(() {
        setState(() {
          _userProfile = up;
        });
        var view = _userProfile.loggedIn ?? false
            ? Dashboard(auth: _auth)
            : PinHome(
                auth: _auth,
                displayName: _userProfile.name ?? _userProfile.name ?? 'User');
        _navigateTo(view);
      });
    } on FirebaseAuthException catch (e) {
      _isLoading.updateProgressStatus(errMsg: "${e.message}.");
    } catch (e) {
      _isLoading.updateProgressStatus(errMsg: "$e.");
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
}
