// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class Grocery {
//   final int? id;
//   final String? name;
//   Grocery({this.id, this.name});
//   factory Grocery.fromMap(Map<String, dynamic> json) =>
//       new Grocery(id: json["id"], name: json['name']);
//   Map<String, dynamic> toMap() {
//     return {'id': id, 'name': name};
//   }
// }

// class DBHelper {
//   DBHelper._privateConstructor();
//   static final DBHelper instance = DBHelper._privateConstructor();

//   static Database? _database;
//   Future<Database> get databse async => _database ?? await _initDatabase();

//   Future<Database> _initDatabase() async {
//     Directory documentDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentDirectory.path, "groceries.db");
//     print("Db path  - " + path);
//     return await openDatabase(path, version: 1, onCreate: _onCreate);
//   }

//   Future _onCreate(Database db, int version) async {
//     await db.execute(''' 
//       CREATE TABLE groceries(
//         id INTERGER PRIMARY KEY,
//         name TEXT
//       )
//     ''');
//   }

//   Future<List<Grocery>> getGroceries() async {
//     Database db = await instance.databse;
//     var groceries = await db.query('groceries', orderBy: 'name');
//     List<Grocery> groceryList = groceries.isNotEmpty
//         ? groceries.map((e) => Grocery.fromMap(e)).toList()
//         : [];
//     print("get Groceries - $groceryList");
//     return groceryList;
//   }

//   Future<int> add(Grocery grocery) async {
//     Database db = await instance.databse;
//     return await db.insert("groceries", grocery.toMap());
//   }
// }
