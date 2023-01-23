import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SqlHelperClass {
  //method to create table in memory
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE items(
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            title TEXT,
            description TEXT,
            createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP)""");
  }

  //method to create a db
  static Future<sql.Database> openDb() async {
    return sql.openDatabase(
      'mydbSqlHelperClass',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new item (journal)
  static Future<int> createItem(String title, String? descrption) async {
    final db = await SqlHelperClass.openDb();

    final data = {'title': title, 'description': descrption};
    final id = await db.insert('items', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all items (journals)
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SqlHelperClass.openDb();
    return db.query('items', orderBy: "id");
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SqlHelperClass.openDb();
    return db.query('items', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an item by id
  static Future<int> updateItem(int id, String title, String? descrption) async {
    final db = await SqlHelperClass.openDb();

    final data = {'title': title, 'description': descrption, 'createdAt': DateTime.now().toString()};

    final result = await db.update('items', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteItem(int id) async {
    final db = await SqlHelperClass.openDb();
    try {
      await db.delete("items", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      debugPrint("Something went wrong when deleting an item: $err");
    }
  }
}
