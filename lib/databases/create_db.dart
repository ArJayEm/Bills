// import 'dart:io';

// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';

// class MainDB {
//   static const _dbName = 'bills.db';
//   static const _version = 1;

//   MainDB._();
//   static final MainDB instance = MainDB._();

//   Database? _db;
//   Future<Database?> get db async {
//     if (_db != null) return _db;
//     _db = await _initDatabase();
//     return _db;
//   }

//   Future<String> getFilePath() async {
//     Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
//     String appDocumentsPath = appDocumentsDirectory.path;
//     String filePath = '$appDocumentsPath/bills.bak';

//     return filePath;
//   }

//   Future<Database> _initDatabase() async {
//     Directory directory = await getApplicationDocumentsDirectory();
//     print(directory.path);
//     String dbPath = join(directory.path, _dbName);
//     return await openDatabase(dbPath,
//         version: _version, onCreate: _onCreate, onUpgrade: _onUpgrade);
//   }

//   _onUpgrade(db, int oldVersion, int newVersion) async {
//     if (oldVersion < newVersion) {
//       // await db.execute(
//       //     "ALTER TABLE ${ElectricBillHelper.tblName} ADD COLUMN ${ElectricBillHelper.colCurrentReading} INTEGER DEFAULT 0");
//     }
//   }

//   _onCreate(Database db, int version) async {}
// }
