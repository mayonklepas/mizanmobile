import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:mizanmobile/activity/barang/input_barang.dart';
import 'package:mizanmobile/helper/utils.dart';
import 'package:http/http.dart';

import '../../helper/database_helper.dart';
import '../sync/sync_form.dart';

class ListModalBarang extends StatefulWidget {
  final String keyword;
  final bool isLocal;
  const ListModalBarang({Key? key, this.keyword = "", this.isLocal = false}) : super(key: key);

  @override
  State<ListModalBarang> createState() => _ListModalBarangState();
}

class _ListModalBarangState extends State<ListModalBarang> {
  Future<List<dynamic>>? _dataBarang;
  String inKeyword = "";
  bool isShowLoading = false;
  String gambarUrlString = "${Utils.mainUrl}barang/download/";

  Future<List<dynamic>> _getDataBarang({String keyword = ""}) async {
    if (widget.isLocal) {
      isShowLoading = false;
      List<dynamic> listBarang = [];
      if (keyword.isEmpty) {
        listBarang = await DatabaseHelper()
            .readDatabase("SELECT idbarang,kode,nama,detail_barang FROM barang_temp LIMIT 100");
      } else {
        listBarang = await DatabaseHelper().readDatabase(
            "SELECT idbarang,kode,nama,detail_barang FROM barang_temp WHERE (nama LIKE ? OR kode LIKE ? OR multi_satuan LIKE ?) LIMIT 100",
            params: ["%$keyword%", "%$keyword%", "%$keyword%"]);
      }

      List<dynamic> listBarangFilter = listBarang.where((d) {
        dynamic detail = jsonDecode(d["detail_barang"]);
        int isActive = detail["ISACTIVE"];
        if (isActive == 1) {
          return true;
        }
        return false;
      }).toList();
      List<dynamic> listBarangSort = List.of(listBarangFilter);

      if (keyword.isNotEmpty) {
        listBarangSort.sort((a, b) {
          int indexA = a["nama"].toString().toLowerCase().indexOf(keyword.toLowerCase());
          int indexB = b["nama"].toString().toLowerCase().indexOf(keyword.toLowerCase());
          return indexA.compareTo(indexB);
        });
      }

      List<dynamic> listBarangContainer = [];
      listBarangSort.forEach((d) => listBarangContainer.add(jsonDecode(d["detail_barang"])));
      return listBarangContainer;
    }

    List<dynamic> listBarangContainer = await __getDataBarangOnline(keyword);
    return listBarangContainer;
  }

  Future<List<dynamic>> __getDataBarangOnline(String keyword) async {
    String mainUrlString =
        "${Utils.mainUrl}barang/caribarangjual?idgudang=${Utils.idGudang}&cari=" + keyword;
    Uri url = Uri.parse(mainUrlString);
    Response response = await get(url, headers: Utils.setHeader());
    log(mainUrlString);
    log(jsonDecode(response.body).toString());
    var jsonData = jsonDecode(response.body)["data"]["item"];
    return jsonData;
  }

  String mode = "onSubmit";

  @override
  void initState() {
    if (widget.isLocal) {
      mode = "onChange";
    }
    _dataBarang = _getDataBarang(keyword: widget.keyword);
    super.initState();
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataBarang,
      builder: ((context, snapshot) {
        List<dynamic> snap = snapshot.data ?? [];
        if (snapshot.connectionState == ConnectionState.waiting && widget.isLocal == false) {
          return Center(child: CircularProgressIndicator());
        } else {
          /*if (snap.isEmpty) {
            return Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Utils.labelSetter("Data tidak ditemukan di penyimpanan lokal", size: 17),
                    ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isShowLoading = true;
                            _dataBarang = __getDataBarangOnline(inKeyword);
                          });
                        },
                        child: Text("Cari online"))
                  ],
                ),
              ),
            );
          }*/
          return ListView.builder(
              itemCount: snap.length,
              itemBuilder: (BuildContext contex, int index) {
                dynamic dataList = snapshot.data![index];
                return Container(
                  child: Card(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context, dataList);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.network(
                              gambarUrlString + "thumbnail/" + dataList["NOINDEX"],
                              headers: {
                                'Authorization': 'Bearer ' + Utils.token,
                                'company-code': Utils.companyCode
                              },
                              height: 70,
                              width: 80,
                              fit: BoxFit.contain,
                            ),
                            //Utils.bagde(dataList["NAMA"].toString().substring(0, 1)),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Utils.labelSetter(dataList["NAMA"], bold: true),
                                    (Utils.labelSetter(dataList["KODE"])),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Utils.labelSetter(
                                            Utils.formatNumber(dataList["HARGA_JUAL"]),
                                            bold: true),
                                        Utils.widgetSetter(() {
                                          if (Utils.isShowStockProgram == "1") {
                                            return Utils.labelSetter(
                                                "Stok : " + Utils.formatNumber(dataList["STOK"]));
                                          }

                                          return Container();
                                        }),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              });
        }
      }),
    );
  }

  _initSync() async {
    try {
      var db = DatabaseHelper();
      List<dynamic> lsSyncInfo = await db.readDatabase("SELECT * FROM sync_info LIMIT 1");
      String lastUpdated = lsSyncInfo[0]["last_updated"];
      String urlString =
          "${Utils.mainUrl}barang/getitemsync?tglupdate=$lastUpdated&idgudang=${Utils.idGudang}";
      log(urlString);
      Uri url = Uri.parse(urlString);
      Response response = await get(url, headers: Utils.setHeader());
      String body = response.body;
      var jsonData = jsonDecode(body)["data"];

      int jumlahDataBelumTersinkron = jsonData["jumlah_item_sync"];
      if (jumlahDataBelumTersinkron == 0) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Data saat ini adalah yang terbaru")));
        return;
      }
      await db.writeDatabase("UPDATE sync_info SET status_done='0'");
      double loopCountRaw = jumlahDataBelumTersinkron / 100;
      int loopCount = loopCountRaw.ceil();
      for (int i = 0; i < loopCount; i++) {
        await Utils.syncLocalData(lastUpdated, halaman: i);
      }
      await db.writeDatabase("UPDATE sync_info SET last_updated = ?, status_done='1'",
          params: [Utils.currentDateTimeString()]);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Data telah diperbaharui dari sinkronisasi")));
    } catch (e) {
      log(e.toString());
    }
  }

  Icon customIcon = Icon(Icons.search);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Utils.widgetSetter(() {
        if (Utils.hakAkses["MOBILE_EDITDATAMASTER"] == 0) {
          return Container();
        }
        return FloatingActionButton(
          child: Icon(
            Icons.add,
            size: 30,
          ),
          onPressed: () async {
            dynamic res = await Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return InputBarang(
                  idBarang: "",
                );
              },
            ));

            await _initSync();
          },
        );
      }),
      appBar: AppBar(
        title: Utils.appBarSearchDynamic((keyword) {
          setState(() {
            inKeyword = keyword;
            _dataBarang = _getDataBarang(keyword: keyword);
          });
        }, hint: widget.keyword, mode: mode),
        actions: [
          IconButton(
              onPressed: () async {
                String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
                    "#ff6666", "Cancel", true, ScanMode.BARCODE);

                if (barcodeScanRes.isEmpty) {
                  Utils.showMessage("Data tidak ditemukan, coba ulangi", context);
                  return;
                }

                setState(() {
                  _dataBarang = _getDataBarang(keyword: barcodeScanRes);
                });
              },
              icon: Icon(Icons.qr_code_scanner)),
          IconButton(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return SyncForm();
                  },
                ));
                setState(() {
                  _dataBarang = _getDataBarang(keyword: inKeyword);
                });
              },
              icon: Icon(Icons.sync)),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.sync(() {
            setState(() {
              _dataBarang = _getDataBarang();
            });
          });
        },
        child: Container(
          child: setListFutureBuilder(),
        ),
      ),
    );
  }
}
