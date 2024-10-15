import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart';

import '../../helper/database_helper.dart';
import '../../helper/utils.dart';

class SyncForm extends StatefulWidget {
  const SyncForm({Key? key}) : super(key: key);

  @override
  State<SyncForm> createState() => _SyncFormState();
}

class _SyncFormState extends State<SyncForm> {
  String title = "";
  String subtitle = "";
  String message = "";
  int jumlahDataTersinkron = 0;
  int jumlahDataBelumTersinkron = 0;
  String lastUpdated = "";
  bool statusAutoSync = false;
  bool syncProcess = false;

  _getInfoSync() async {
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    var db = DatabaseHelper();
    List<dynamic> getInfo =
        await db.readDatabase("SELECT * FROM sync_info ORDER BY last_updated DESC LIMIT 1");
    List<dynamic> getInfoBarang =
        await db.readDatabase("SELECT COUNT(idbarang) as total FROM barang_temp");

    lastUpdated = getInfo[0]["last_updated"];
    statusAutoSync = (getInfo[0]["status_auto_sync"] == 1) ? true : false;
    jumlahDataTersinkron = getInfoBarang[0]["total"];

    String urlString =
        "${Utils.mainUrl}barang/getitemsync?tglupdate=$lastUpdated&idgudang=${Utils.idGudang}";
    log(urlString);
    Uri url = Uri.parse(urlString);
    Response response = await get(url, headers: Utils.setHeader());
    String body = response.body;
    log(body);
    var jsonData = jsonDecode(body)["data"];
    Navigator.pop(context);
    jumlahDataBelumTersinkron = jsonData["jumlah_item_sync"];
    setState(() {
      title = "Jumlah item tersinkronisasi = ${Utils.formatNumber(jumlahDataTersinkron)}";
      subtitle =
          "Jumlah item belum disinkronisasi = ${Utils.formatNumber(jumlahDataBelumTersinkron)}";
    });
  }

  @override
  void initState() {
    _getInfoSync();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Sinkronisasi"),
        ),
        body: Center(
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title),
                SizedBox(height: 10),
                Text(subtitle),
                SizedBox(height: 10),
                Text(message),
                SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 4),
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _doSync,
                    icon: Icon(Icons.sync_outlined),
                    iconSize: 80,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text("Klik untuk Sinkronisasi"),
              ],
            ),
          ),
        ));
  }

  _doSync() async {
    if (syncProcess == true) {
      Utils.showMessage("Harap menunggu, sedang dalam proses sinkronisasi", context);
      return;
    }

    bool doSync = await Utils.showConfirmMessage(
        context, "Mohon untuk tidak menutup form saat proses sinkronisasi, lanjutkan ?");

    if (doSync == false) {
      return;
    }

    var db = DatabaseHelper();
    double loopCountRaw = jumlahDataBelumTersinkron / 100;
    int loopCount = loopCountRaw.ceil();
    syncProcess = true;

    await db.writeDatabase("UPDATE sync_info SET status_done='0'");
    for (int i = 0; i < loopCount; i++) {
      int currentCount = 100 * (i + 1);
      setState(() {
        message =
            "Proses Sinkronisasi ${Utils.formatNumber(currentCount)} / ${Utils.formatNumber(jumlahDataBelumTersinkron)}";
      });
      await Utils.syncLocalData(lastUpdated, halaman: i, withCheckExists: false);
      log("sync count : ${i + 1}");
    }

    syncProcess = false;

    log("Updating sync info");
    await db.writeDatabase("UPDATE sync_info SET last_updated = ?, status_done='1'",
        params: [Utils.currentDateTimeString()]);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sinkronisasi Berhasil")));
  }
}
