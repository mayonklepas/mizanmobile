import 'package:mizanmobile/utils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  Future<Database> databaseConnection() async {
    //databaseFactory.deleteDatabase(join(await getDatabasesPath(), "mizan_temp.db"));
    Database _database = await openDatabase(
      join(await getDatabasesPath(), "${Utils.companyCode}_mizan_temp.db"),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            "CREATE TABLE sync_info(id INTEGER PRIMARY KEY,status int,last_updated DATETIME)");
        await db.execute("CREATE TABLE barang_temp(" +
            "id INTEGER PRIMARY KEY,idbarang VARCHAR(100)," +
            "kode VARCHAR(100),nama TEXT, detail_barang TEXT,multi_satuan TEXT," +
            "multi_harga TEXT,harga_tanggal TEXT,date_created DATETIME)");
        await db.execute(
            "INSERT INTO sync_info(id,status,last_updated) VALUES(1,0,'1945-01-01 00:00:00')");
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

  Future<void> writeBatchDatabase(List<String> lsQuery) async {
    Database database = await databaseConnection();
    Batch batch = database.batch();
    for (var d in lsQuery) {
      batch.rawQuery(d);
    }
    await batch.commit(noResult: true);
  }

  Future<void> execQuery(String sql) async {
    Database database = await databaseConnection();
    database.rawQuery(sql);
  }
}
