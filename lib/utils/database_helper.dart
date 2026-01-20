import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:expense_tracker/models/record.dart'; // 绝对正确

class DatabaseHelper {
  static const _databaseName = "expense_tracker.db";
  static const _databaseVersion = 1;
  static const table = 'records';
  static const columnId = 'id';
  static const columnAmount = 'amount';
  static const columnType = 'type';
  static const columnCategory = 'category';
  static const columnDescription = 'description';
  static const columnDate = 'date';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnAmount REAL NOT NULL,
            $columnType INTEGER NOT NULL,
            $columnCategory INTEGER NOT NULL,
            $columnDescription TEXT,
            $columnDate INTEGER NOT NULL
          )
          ''');
  }

  Future<int> insert(Record record) async {
    Database db = await instance.database;
    return await db.insert(table, record.toMap());
  }

  Future<List<Record>> queryAllRecords() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(table, orderBy: '$columnDate DESC');
    return List.generate(maps.length, (i) => Record.fromMap(maps[i]));
  }

  Future<List<Record>> queryRecordsByDateRange(DateTime startDate, DateTime endDate) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
      table,
      where: '$columnDate >= ? AND $columnDate <= ?',
      whereArgs: [
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: '$columnDate DESC',
    );
    return List.generate(maps.length, (i) => Record.fromMap(maps[i]));
  }

  Future<int> update(Record record) async {
    Database db = await instance.database;
    return await db.update(
      table,
      record.toMap(),
      where: '$columnId = ?',
      whereArgs: [record.id],
    );
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalAmountByType(RecordType type, DateTime? startDate, DateTime? endDate) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps;
    
    if (startDate != null && endDate != null) {
      maps = await db.query(
        table,
        columns: ['SUM($columnAmount) as total'],
        where: '$columnType = ? AND $columnDate >= ? AND $columnDate <= ?',
        whereArgs: [
          type.index,
          startDate.millisecondsSinceEpoch,
          endDate.millisecondsSinceEpoch,
        ],
      );
    } else {
      maps = await db.query(
        table,
        columns: ['SUM($columnAmount) as total'],
        where: '$columnType = ?',
        whereArgs: [type.index],
      );
    }
    
    return maps.isNotEmpty && maps[0]['total'] != null ? maps[0]['total'] : 0;
  }

  Future<Map<Category, double>> getAmountByCategory(RecordType type, DateTime? startDate, DateTime? endDate) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> maps;
    
    if (startDate != null && endDate != null) {
      maps = await db.rawQuery('''
        SELECT $columnCategory, SUM($columnAmount) as total
        FROM $table
        WHERE $columnType = ? AND $columnDate >= ? AND $columnDate <= ?
        GROUP BY $columnCategory
      ''', [
        type.index,
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ]);
    } else {
      maps = await db.rawQuery('''
        SELECT $columnCategory, SUM($columnAmount) as total
        FROM $table
        WHERE $columnType = ?
        GROUP BY $columnCategory
      ''', [type.index]);
    }
    
    Map<Category, double> result = {};
    for (var map in maps) {
      result[Category.values[map[columnCategory]]] = map['total'];
    }
    return result;
  }
}