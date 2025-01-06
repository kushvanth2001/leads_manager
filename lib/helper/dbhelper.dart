// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class DataBaseHelper {
//   static final _dbName = "snappe.db";
//   static final _dbVersion = 1;

//   static final tableUserDetails = "userDetails";

//   static final cID = "id";
//   static final cUserID = "userid";
//   static final cUserName = "username";
//   static final cClientGroupName = "ClientGroupName";
//   static final cClientName = "ClientName";
//   static final cPhoneNo = "PhoneNo";
//   static final cRole = "Role";

//   DataBaseHelper._privateConstructor();
//   static final DataBaseHelper instance = DataBaseHelper._privateConstructor();

//   static Database? _database;
//   Future<Database> get databse async => _database ?? await _initDatabase();

//   Future<Database> _initDatabase() async {
//     print("=========_initDatabase========");
//     Directory directory = await getApplicationDocumentsDirectory();
//     String path = join(directory.path + _dbName);
//     print("Db path  - " + path);
//     return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
//   }

//   Future _onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE $tableUserDetails(
//         $cID INTERGER PRIMARY KEY AUTOINCREMENT,
//         $cUserID INTERGER NOT NULL,
//         $cUserName TEXT NOT NULL,        
//         $cClientGroupName INTERGER NOT NULL,
//         $cPhoneNo INTERGER NOT NULL,
//         $cRole INTERGER NOT NULL,
//       )
//       ''');
//   }

//   //Function to insert , query , update and delete

//   Future<int> insert(Map<String, dynamic> row) async {
//     Database db = await instance.databse;
//     return await db.insert(tableUserDetails, row);
//   }
// }
