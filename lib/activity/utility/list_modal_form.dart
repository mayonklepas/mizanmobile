import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mizanmobile/activity/barang/input_barang.dart';
import 'package:mizanmobile/activity/pelanggan/pelanggan_view.dart';
import 'package:mizanmobile/helper/database_helper.dart';
import 'package:mizanmobile/helper/utils.dart';
import 'package:http/http.dart';

class ListModalForm extends StatefulWidget {
  final String type;
  final String idBarang;
  final String keyword;
  final bool isExtra;
  final bool withAll;
  final String idSuplier;
  const ListModalForm(
      {Key? key,
      required this.type,
      this.idBarang = "",
      this.keyword = "",
      this.isExtra = false,
      this.withAll = false,
      this.idSuplier = ""});

  @override
  State<ListModalForm> createState() => _ListModalFormState();
}

class _ListModalFormState extends State<ListModalForm> {
  Future<List<dynamic>>? _dataModal;
  List<dynamic>? _dataCache;
  bool isLocal = false;
  String headerBar = "";
  late Widget fab;

  Future<List<dynamic>> _getDataModal({String keyword = ""}) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    String mainUrlString = "";
    String type = widget.type;
    List<dynamic> jsonData = [];

    fab = Visibility(visible: false, child: FloatingActionButton(onPressed: () {}));

    if (Utils.isOffline) {
      headerBar = type;
      List<dynamic> masterDataList = await dbHelper
          .readDatabase("SELECT data FROM master_data_temp WHERE category = ?", params: [type]);
      if (masterDataList.isNotEmpty) {
        List<dynamic> masterData = jsonDecode(masterDataList[0]["data"]);
        jsonData = masterData;
      }
    } else {
      if (type == "satuan") {
        mainUrlString = "${Utils.mainUrl}datapopup/satuan?cari=";
        headerBar = "Satuan";
      } else if (type == "kelompokbarang") {
        mainUrlString = "${Utils.mainUrl}datapopup/kelompokbarang?cari=";
        headerBar = "Kelompok Barang";
      } else if (type == "suplier") {
        mainUrlString = "${Utils.mainUrl}datapopup/suplier?cari=";
        headerBar = "Suplier";
      } else if (type == "merk") {
        mainUrlString = "${Utils.mainUrl}datapopup/merek?cari=";
        headerBar = "Merk";
      } else if (type == "gudang") {
        mainUrlString = "${Utils.mainUrl}datapopup/gudang?cari=";
        headerBar = "Gudang";
      } else if (type == "lokasi") {
        mainUrlString = "${Utils.mainUrl}datapopup/lokasi?cari=";
        headerBar = "Lokasi";
      } else if (type == "dept") {
        mainUrlString = "${Utils.mainUrl}datapopup/dept?cari";
        headerBar = "Department";
      } else if (type == "golongan") {
        mainUrlString = "${Utils.mainUrl}datapopup/golongan?cari=";
        headerBar = "Golongan";
      } else if (type == "golongansuplier") {
        mainUrlString = "${Utils.mainUrl}datapopup/golongansuplier?cari=";
        headerBar = "Golongan Suplier";
      } else if (type == "golonganpelanggan") {
        mainUrlString = "${Utils.mainUrl}datapopup/golonganpelanggan?cari=";
        headerBar = "Golongan Pelanggan";
      } else if (type == "klasifikasi") {
        mainUrlString = "${Utils.mainUrl}datapopup/klasifikasi?cari=";
        headerBar = "Klasifikasi";
      } else if (type == "satuanbarang") {
        mainUrlString = "${Utils.mainUrl}datapopup/satuanbarang?idbarang=${widget.idBarang}";
        headerBar = "Satuan Barang";
      } else if (type == "akun") {
        mainUrlString = "${Utils.mainUrl}datapopup/akun?cari=";
        headerBar = "Akun";
      } else if (type == "pengguna") {
        mainUrlString = "${Utils.mainUrl}datapopup/pengguna?cari=";
        headerBar = "Pengguan";
      } else if (type == "pelanggan") {
        mainUrlString = "${Utils.mainUrl}datapopup/pelanggan?cari=";
        headerBar = "Pelanggan";
        fab = Visibility(
            visible: true,
            child: FloatingActionButton(
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return PelangganView();
                  },
                ));
                setState(() {
                  _dataModal = _getDataModal();
                  customSearchBar = Text("Data $headerBar");
                });
              },
              child: Icon(Icons.add),
            ));
      } else if (type == "top") {
        mainUrlString = "${Utils.mainUrl}datapopup/top?cari=";
        headerBar = "TOP";
      } else if (type == "penerimaanbarang") {
        mainUrlString =
            "${Utils.mainUrl}penerimaanbarang/daftarorder?idsuplier=${widget.idSuplier}";
        headerBar = "Order Penerimaan";
      } else if (type == "pembelianpenerimaan") {
        mainUrlString =
            "${Utils.mainUrl}pembelian/daftarpenerimaanbarang?idsuplier=${widget.idSuplier}";
        headerBar = "Penerimaan";
      } else if (type == "orderpenjualan") {
        mainUrlString = "${Utils.mainUrl}orderpenjualan/daftar";
        headerBar = "Order penjualan";
      } else if (type == "kelompoktransaksi") {
        mainUrlString = "${Utils.mainUrl}datapopup/kelompoktransaksi?cari=";
        headerBar = "Kelompok Transaksi";
      }

      Uri url = Uri.parse(mainUrlString + keyword);
      dynamic header = Utils.setHeader();
      Response response = await get(url, headers: header);
      jsonData = jsonDecode(response.body)["data"];
      if (type == "penerimaanbarang" || type == "pembelianpenerimaan") {
        for (int i = 0; i < jsonData.length; i++) {
          jsonData[i]["NAMA"] = jsonData[i]["NAMASUPLIER"];
          jsonData[i]["KODE"] = jsonData[i]["NOREF"];
        }
      } else if (type == "orderpenjualan") {}
      if (widget.withAll) {
        Map<String, dynamic> map = {"NAMA": "SEMUA", "KODE": "SEMUA", "NOINDEX": "-1"};
        jsonData.insert(0, map);
      }

      List<dynamic> checkData = await dbHelper
          .readDatabase("SELECT id FROM master_data_temp WHERE category = ?", params: [type]);

      if (checkData.isEmpty) {
        await dbHelper.writeDatabase("INSERT INTO master_data_temp(category,data) VALUES(?,?)",
            params: [type, jsonEncode(jsonData)]);
      } else {
        await dbHelper.writeDatabase("UPDATE master_data_temp SET data =? WHERE category=?",
            params: [jsonEncode(jsonData), type]);
      }
    }
    _dataCache = jsonData;

    return jsonData;
  }

  Future<List<dynamic>> _searchDataModal(String keyword) async {
    isLocal = true;
    List<dynamic> filterResult = [];
    for (var d in _dataCache!) {
      String nama = d["NAMA"].toString().toLowerCase();
      if (nama.contains(keyword.toLowerCase())) {
        filterResult.add(d);
      }
    }

    return filterResult;
  }

  Icon customIcon = Icon(Icons.search);
  Widget customSearchBar = Text("");

  @override
  void initState() {
    super.initState();
    _dataModal = _getDataModal();
    customSearchBar = Text("Data $headerBar");
  }

  FutureBuilder<List<dynamic>> setListFutureBuilder() {
    return FutureBuilder(
      future: _dataModal,
      builder: ((context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && isLocal == false) {
          return Center(child: CircularProgressIndicator());
        } else {
          return ListView.builder(
              itemCount: snapshot.data!.length,
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
                            Utils.bagde(Utils.koooosong(dataList["NAMA"]).substring(0, 1)),
                            Expanded(
                              flex: 3,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Utils.labelSetter(dataList["NAMA"].toString(), bold: true),
                                    Utils.labelSetter(dataList["KODE"].toString()),
                                    Utils.widgetSetter(() {
                                      if (widget.type == "pelanggan" || widget.type == "suplier") {
                                        return Utils.labelValueSetter(
                                            "GOL", dataList["NAMA_GOLONGAN"] ?? "");
                                      } else if (widget.type == "penerimaanbarang" ||
                                          widget.type == "pembelianpenerimaan") {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Utils.labelSetter(dataList["KETERANGAN"] ?? ""),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Utils.labelSetter(
                                                    Utils.formatNumber(dataList["TOTALORDER"]),
                                                    bold: true),
                                                Container(
                                                  alignment: Alignment.bottomRight,
                                                  child: Text(
                                                    Utils.formatDate(dataList["TANGGAL"]),
                                                    style: TextStyle(fontSize: 11),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        );
                                      }

                                      return Container();
                                    })
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: fab,
      appBar: AppBar(
        title: customSearchBar,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  if (customIcon.icon == Icons.search) {
                    customIcon = Icon(Icons.clear);
                    customSearchBar = Utils.appBarSearchDynamic((keyword) async {
                      setState(() {
                        _dataModal = _searchDataModal(keyword);
                      });
                    }, hint: "Cari $headerBar");
                  } else {
                    customIcon = Icon(Icons.search);
                    customSearchBar = Text("Data $headerBar");
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
              customSearchBar = Text("Data $headerBar");
              _dataModal = _dataModal;
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
