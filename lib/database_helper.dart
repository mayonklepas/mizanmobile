import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  Future<Database> databaseConnection() async {
    Database _database = await openDatabase(
      join(await getDatabasesPath(), "mizan_temp.db"),
      version: 1,
      onCreate: (db, version) async {
        await db.execute("CREATE TABLE barang_temp(id INTEGER PRIMARY KEY,idbarang VARCHAR(100)," +
            "kode VARCHAR(100),nama VARCHAR(255), detail_barang TEXT,multi_satuan TEXT," +
            "multi_harga TEXT,harga_tanggal TEXT,date_update DATETIME DEFAULT CURRENT_TIMESTAMP)");
      },
    );
    return _database;
  }

  Future<List<dynamic>> readDatabase(String query, {List<Object>? params}) async {
    Database database = await databaseConnection();
    if (params == null) {
      return database.rawQuery(query);
    }
    return database.rawQuery(query, params);
  }

  Future<int> writeDatabase(String query, {List<Object>? params, bool isUpdate = false}) async {
    Database database = await databaseConnection();
    if (isUpdate) {
      if (params == null) {
        return database.rawUpdate(query);
      }
      return database.rawUpdate(query, params);
    } else {
      if (params == null) {
        return database.rawInsert(query);
      }
      return database.rawInsert(query, params);
    }
  }
}
