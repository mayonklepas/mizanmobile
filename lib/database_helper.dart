import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  Future<Database> databaseConnection() async {
    Database _database = await openDatabase(
      join(await getDatabasesPath(), "mizan_temp.db"),
      version: 1,
      onCreate: (db, version) async {
        await db.execute("CREATE TABLE barang_temp(id INTEGER PRIMARY KEY,)");
      },
    );
    return _database;
  }

  Future<List<Map<String, Object?>>> readDatabases(String query) async {
    Database database = await databaseConnection();
    return database.rawQuery(query);
  }
}
