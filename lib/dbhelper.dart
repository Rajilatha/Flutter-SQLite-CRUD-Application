import 'package:sqflite/sqflite.dart' as sql;
import 'dart:async';

class DatabaseHelper{
 
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE contact(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        name TEXT,
        mobile TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }

   static Future<sql.Database> db() async {
    return sql.openDatabase(
      'ContactDB.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

 static Future<int> createItem(String name, String? mobile) async {
    final db = await DatabaseHelper.db();

    final data = {'name': name, 'mobile': mobile};
    final id = await db.insert('contact', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

// Read all items (journals)
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await DatabaseHelper.db();
    return db.query('contact', orderBy: "id");
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await DatabaseHelper.db();
    return db.query('contact', where: "id = ?", whereArgs: [id], limit: 1);
  }

// Update an item by id
  static Future<int> updateItem(
      int id, String name, String? mobile) async {
    final db = await DatabaseHelper.db();

    final data = {
      'name': name,
      'mobile': mobile,
      'createdAt': DateTime.now().toString()
    };

    final result =
        await db.update('contact', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

// Delete
  static Future<void> deleteItem(int id) async {
    final db = await DatabaseHelper.db();
    try {
      await db.delete("contact", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      // ignore: avoid_print
      print("Something went wrong when deleting an item: $err");
    }
  }
}

