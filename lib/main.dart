import 'package:bills/pages/landing_page.dart';
import 'package:bills/providers/google_provider.dart';
import 'package:bills/providers/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => User()),
        ChangeNotifierProvider(create: (_) => GoogleProvider()),
      ],
      child: MyApp(),
    ),
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
          accentColor: Color.fromARGB(255, 255, 158, 0),
          textTheme: TextTheme(
            headline1: TextStyle(color: Color.fromARGB(255, 112, 88, 52)),
            headline6: TextStyle(fontWeight: FontWeight.bold),
          ),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LandingPage(title: 'Dashboard')
        // initialRoute: LandingPage.route,
        // onGenerateRoute: (setting) {
        //   switch (setting.name) {
        //     case LandingPage.route:
        //       return _buildRoute(setting, LandingPage(title: 'Dashboard'));
        //     // case Expenses.route:
        //     //   return _buildRoute(setting, Expenses());
        //     // case Bills.route:
        //     //   return _buildRoute(setting, Bills());
        //     // case Incomes.route:
        //     //   return _buildRoute(setting, Incomes());
        //     // case FolderBrowser.route:
        //     //   return _buildRoute(setting,
        //     //       FolderBrowser(args: setting.arguments as FolderArguments));
        //     default:
        //       return _buildRoute(setting, LandingPage(title: 'Dashboard'));
        //   }
        // },
        //home: LandingPage(title: 'Flutter Demo Home Page')
        // FutureBuilder(
        //   future: _db,
        //   builder: (context, snapshot) {
        //     if (snapshot.hasError) {
        //       print('You have an error! ${snapshot.error.toString()}');
        //       return Text('Something went wrong!');
        //     } else if (snapshot.hasData) {
        //       return MyHomePage(title: 'Flutter Demo Home Page');
        //     } else {
        //       return Center(
        //         child: CircularProgressIndicator(),
        //       );
        //     }
        //   },
        // )
        );
  }

  // MaterialPageRoute _buildRoute(RouteSettings settings, Widget page) {
  //   return MaterialPageRoute(
  //     settings: settings,
  //     builder: (ctx) => SafeArea(child: page),
  //   );
  // }
}
