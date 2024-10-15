import 'package:mizanmobile/helper/utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  Future<Database> databaseConnection() async {
    //databaseFactory.deleteDatabase(join(await getDatabasesPath(), "mizan_temp.db"));
    Database _database = await openDatabase(
        join(await getDatabasesPath(), "${Utils.companyCode}_mizan_temp.db"),
        version: 2, onCreate: (db, version) async {
      await db.execute("CREATE TABLE IF NOT EXISTS sync_info(id INTEGER PRIMARY KEY," +
          "status_auto_sync INTEGER,last_updated DATETIME, " +
          "status_done INTEGER, last_loop INTEGER, max_loop INTEGER)");

      await db.execute("INSERT INTO sync_info(id,status_auto_sync,last_updated,status_done, " +
          "last_loop, max_loop) VALUES(1,0,'1945-01-01 00:00:00','0','0','0')");

      await db.execute("CREATE TABLE IF NOT EXISTS barang_temp(" +
          "id INTEGER PRIMARY KEY,idbarang VARCHAR(100)," +
          "kode VARCHAR(100),nama TEXT, detail_barang TEXT,multi_satuan TEXT," +
          "multi_harga TEXT,harga_tanggal TEXT,date_created DATETIME)");
    }, onUpgrade: (db, oldVersion, newVersion) async {
      await db.execute("CREATE TABLE IF NOT EXISTS data_penjualan_temp(" +
          "id VARCHAR(100) PRIMARY KEY," +
          "tanggal DATE," +
          "nama_user_input VARCHAR(100)," +
          "nama_pelanggan VARCHAR(100)," +
          "data TEXT," +
          "date_created DATETIME)");

      await db.execute("CREATE TABLE IF NOT EXISTS master_data_temp(" +
          "id INTEGER PRIMARY KEY AUTOINCREMENT," +
          "category VARCHAR(100)," +
          "data TEXT)");
    });

    return _database;
  }

  Future<List<dynamic>> readDatabase(String query, {List<Object>? params}) async {
    Database database = await databaseConnection();
    if (params == null) {
      return database.rawQuery(query);
    }
    return database.rawQuery(query, params);
  }

  Future<int> writeDatabase(String query, {List<Object>? params}) async {
    Database database = await databaseConnection();
    String queryTipe = query.substring(0, 10).toLowerCase();
    if (queryTipe.contains("update")) {
      if (params == null) {
        return database.transaction((txn) async => await txn.rawUpdate(query));
      }
      return database.transaction((txn) async => await txn.rawUpdate(query, params));
    } else if (queryTipe.contains("insert")) {
      if (params == null) {
        return database.transaction((txn) async => await txn.rawInsert(query));
      }
      return database.transaction((txn) async => await txn.rawInsert(query, params));
    } else {
      if (params == null) {
        return database.transaction((txn) async => await txn.rawDelete(query));
      }
      return database.transaction((txn) async => await txn.rawDelete(query, params));
    }
  }

  Future writeBatchDatabase(List<String> lsQuery) async {
    Database database = await databaseConnection();
    Batch batch = database.batch();
    for (var d in lsQuery) {
      batch.rawQuery(d);
    }
    List<Object?> resultExec = await batch.commit();
    return resultExec;
  }

  Future<void> execQuery(String sql) async {
    Database database = await databaseConnection();
    database.rawQuery(sql);
  }
}
