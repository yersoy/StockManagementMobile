import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final _dbName = "ritmaCounter.db";
  static final _dbVersion = 1;
  static final _tableName = 'counts';

  DbHelper._privateConstructor();
  static final DbHelper instance = DbHelper._privateConstructor();
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _initiateDatabase();
    return _database;
  }

  _initiateDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) {
    db.execute('''
      CREATE TABLE $_tableName  (id INTEGER primary key autoincrement, barcode  String , name String, count INTEGER,date String)
    ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(_tableName, row);
  }

  Future<List<Map<String, dynamic>>> queryAll() async {
    Database db = await instance.database;
    return await db.query(_tableName);
  }
 Future<List<Map<String, dynamic>>> getFiltered(code) async {
    Database db = await instance.database;
    return await db.query(_tableName, where: 'barcode = ?', whereArgs: [code],orderBy: "id desc",limit: 1,);
  }
  Future<List<Map<String, dynamic>>> getFilteredId(id) async {
    Database db = await instance.database;
    return await db.query(_tableName, where: 'barcode = ?', whereArgs: [id],orderBy: "id desc",limit: 1,);
  }
  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row["id"];
    return await db.update(_tableName, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }
}
