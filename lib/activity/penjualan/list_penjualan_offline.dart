import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:mizanmobile/activity/penjualan/input_penjualan.dart';
import 'package:mizanmobile/helper/utils.dart';
import 'package:http/http.dart';

import '../../helper/database_helper.dart';
import '../utility/bottom_modal_filter.dart';
import '../utility/printer_util.dart';

class ListPenjualanOffline extends StatefulWidget {
  const ListPenjualanOffline({Key? key}) : super(key: key);

  @override
  State<ListPenjualanOffline> createState() => _ListPenjualanOfflineState();
}

class _ListPenjualanOfflineState extends State<ListPenjualanOffline> {
  Future<List<dynamic>>? _dataPenjualan;

  Future<List<dynamic>> _getDataPenjualan({String keyword = ""}) async {
    DatabaseHelper db = DatabaseHelper();
    List<dynamic> dataLocal = [];
    try {
      dataLocal = await db.readDatabase("SELECT * FROM data_penjualan_temp");
    } catch (e) {
      log(e.toString());
    }

    List<dynamic> dataList = [];
    for (dynamic dataRow in dataLocal) {
      dynamic data = jsonDecode(dataRow["data"]);
      String noindex = dataRow["id"];
      dynamic header = data["header"];
      String namaPelanggan = dataRow["nama_pelanggan"];
      String bagianPenjualan = dataRow["nama_user_input"];
      String tanggalPenjualan = header["TANGGAL"];
      double totalPenjualan = header["JUMLAHBAYAR"];
      String keterangan = header["KETERANGAN"];

      dynamic dataMap = {
        "NOINDEX": noindex.toString(),
        "NAMA_PELANGGAN": namaPelanggan,
        "KETERANGAN": keterangan,
        "BAGIAN_PENJUALAN": bagianPenjualan,
        "TOTAL_PENJUALAN": totalPenjualan,
        "TANGGAL": tanggalPenjualan,
      };
      dataList.add(dataMap);
    }

    return dataList;
  }

  @override
  void initState() {
    Utils.initAppParam();
    _dataPenjualan = _getDataPenjualan();
    super.initState();
  }

  Future<dynamic> _deletePenjualan(id) async {
    DatabaseHelper db = DatabaseHelper();
    int result = await db.writeDatabase("DELETE FROM data_penjualan_temp WHERE id=?", params: [id]);
    return result;
  }

  Future<dynamic> showOption(noindex) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext content) {
          return Container(
            padding: EdgeInsets.only(top: 10, bottom: 10),
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                /*Column(
                  children: [
                    IconButton(
                        onPressed: () async {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.print,
                          color: Colors.black54,
                        )),
                    Text("Print Struk")
                  ],
                ),*/
                Column(
                  children: [
                    IconButton(
                        onPressed: () async {
                          if (Utils.hakAkses["MOBILE_EDITPENJUALAN"] == 0) {
                            return Utils.showMessage("Akses ditolak", context);
                          }

                          await Navigator.push(context, MaterialPageRoute(builder: (contenxt) {
                            return InputPenjualan(idTransaksi: noindex);
                          }));
                          setState(() {
                            _dataPenjualan = _getDataPenjualan();
                          });
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.black54,
                        )),
                    Text("Edit")
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: () async {
                          if (Utils.hakAkses["MOBILE_EDITPENJUALAN"] == 0) {
                            return Utils.showMessage("Akses ditolak", context);
                          }

                          bool isDelete = await Utils.showConfirmMessage(
                              context, "ingin menghapus penjualan ini ");
                          if (isDelete) {
                            dynamic result = await _deletePenjualan(noindex);

                            if (result == 0) {
                              Utils.showMessage("gagal menghapus data", context);
                              return;
                            }
                            setState(() {
                              _dataPenjualan = _getDataPenjualan();
                            });
                          }
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.black54,
                        )),
                    Text("Delete")
                  ],
                ),
              ],
            ),
          );
        });
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataPenjualan,
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext contex, int index) {
                      dynamic dataList = snapshot.data![index];
                      return Container(
                        child: Card(
                          child: InkWell(
                            onTap: () {
                              showOption(dataList["NOINDEX"]);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Utils.bagde((index + 1).toString()),
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Utils.labelSetter(
                                            dataList["NOINDEX"],
                                            bold: true,
                                          ),
                                          Utils.labelSetter(dataList["NAMA_PELANGGAN"]),
                                          Utils.labelSetter(dataList["KETERANGAN"]),
                                          Utils.labelSetter(
                                              dataList["BAGIAN_PENJUALAN"].toString()),
                                          Utils.labelSetter(
                                              Utils.formatNumber(dataList["TOTAL_PENJUALAN"]),
                                              bold: true),
                                          Container(
                                            alignment: Alignment.bottomRight,
                                            child: Utils.labelSetter(
                                                Utils.formatDate(dataList["TANGGAL"]),
                                                size: 12),
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
                    }),
              ),
            ],
          );
        }
      }),
    );
  }

  uploadPenjualanData() async {
    bool isProcess = await Utils.showConfirmMessage(
        context, "Ingin Mengupload transaksi penjualan ke server ? ");
    if (isProcess == false) {
      return;
    }
    Future.delayed(Duration.zero, () => Utils.showProgress(context));
    DatabaseHelper db = DatabaseHelper();
    List<dynamic> dataLocal = await db.readDatabase("SELECT * FROM data_penjualan_temp");
    for (var data in dataLocal) {
      String postBody = data["data"];
      String urlString = "${Utils.mainUrl}penjualan/insert";
      Uri url = Uri.parse(urlString);
      Response response = await post(url, body: postBody, headers: Utils.setHeader());
      var jsonData = jsonDecode(response.body);
      dynamic result = jsonData;

      if (result["status"] == 1) {
        Utils.showMessage(result["message"], context);
        break;
      }

      var dataResult = result["data"];

      List<dynamic> detailBarangPost = dataResult["detail_barang"];

      for (var d in detailBarangPost) {
        String idBarang = d["IDBARANG"];
        double stoktambahan = d["STOK"];

        List<dynamic> lsLocalUpdate = await db.readDatabase(
            "SELECT detail_barang FROM barang_temp WHERE idbarang =? ",
            params: [idBarang]);

        dynamic detailBarang = jsonDecode(lsLocalUpdate[0]["detail_barang"]);
        detailBarang["STOK"] = stoktambahan;
        String detailBarangStr = jsonEncode(detailBarang);

        await db.writeDatabase("UPDATE barang_temp SET detail_barang=? WHERE idbarang=?",
            params: [detailBarangStr, idBarang]);
      }

      await db.writeDatabase("DELETE FROM data_penjualan_temp WHERE id=?", params: [data["id"]]);
    }
    Navigator.pop(context);
    setState(() {
      _dataPenjualan = _getDataPenjualan();
    });
  }

  Icon customIcon = Icon(Icons.search);
  Widget customSearchBar = Text("Penjualan Offline");
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await uploadPenjualanData();
        },
        child: Icon(
          Icons.upload,
          size: 30,
        ),
      ),
      appBar: AppBar(
        title: customSearchBar,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  if (customIcon.icon == Icons.search) {
                    customIcon = Icon(Icons.clear);
                    customSearchBar = Utils.appBarSearch((keyword) {
                      setState(() {
                        _dataPenjualan = _getDataPenjualan(keyword: keyword);
                      });
                    }, hint: "Cari");
                  } else {
                    customIcon = Icon(Icons.search);
                    customSearchBar = Text("Penjualan Offline");
                  }
                });
              },
              icon: customIcon),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () {
          return Future.sync(() {
            setState(() {
              customIcon = Icon(Icons.search);
              customSearchBar = Text("Penjualan Offline");
              _dataPenjualan = _getDataPenjualan();
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
